Net::Socket@ socket = Net::Socket();

void OpenSocket(){
    print("Connecting to Client");
    startnew(CoroutineFunc(Connect));

}

void Connect(){
    bool result = socket.Connect("localhost",22422);
    if (result){
        while (!socket.IsReady()){
            yield();
        }
        print ("sending handshake");
        SocketHandshake();
        startnew(CoroutineFunc(ReadLoop));
    }else{
        print("Error Opening Socket, Closing");
    }
}

bool IsConnected(){
    return true;//!socket.IsHungUp();
}

void ReadLoop() {
    RawMessage@ msg;
    print("readLoop");
    while(IsConnected()){
        ReadNextMessage2();
    }
    //its so jover
}

void ReadNextMessage(){
    while (socket.Available() < 4 && IsConnected()){
        //print (socket.Available());
        yield();
    }
    if (!IsConnected()) return;
    int msgLength = socket.ReadInt32();
    print (""+msgLength);

    while (socket.Available() < msgLength && IsConnected()) yield();//wait for message
    if (!IsConnected()) return;
    // MemoryBuffer@ buffer = socket.ReadBuffer(msgLength);
    // ProcessMessage(buffer);
}

string messsage;
void ReadNextMessage2(){
    string line;
    while (!socket.ReadLine(line)){
        yield();
        //print(""+socket.Available());
    }
    line = line.Trim();
    if (line.Length > 0){
        messsage += line + "\r\n";
    }else{
        ProcessMessage(messsage);
        messsage = "";
    }
}

void ProcessMessage(string msg){
    print ("Processing Message: " + msg);
    try {
        Json::Value@ json = Json::Parse(msg);
        print("Is a json message!");
        print(""+json.Length);
    } catch {
        //not a json message
        print("not a json message :(");
        if (msg.Contains("Upgrade: websocket")){
            //server handshake response, we just ignore it and send a packet :>
            print("Connecting...");
            SendConnectionPacket();
            yield(100);
            SendConnectionPacket();
        }
    }
}

void SocketHandshake(){
    //this works and it took me forever to get it working so we don't question it or touch it ever again okayge
    socket.WriteRaw("GET / HTTP/1.1\r\n");
	socket.WriteRaw("Host: localhost\r\n"); 
	socket.WriteRaw("Connection: keep-alive, Upgrade\r\n");
	socket.WriteRaw("Upgrade: websocket\r\n");
	socket.WriteRaw("Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n");
	socket.WriteRaw("Sec-WebSocket-Version: 13\r\n");
	socket.WriteRaw("Accept: /\r\n");
    socket.WriteRaw("\r\n");
}


void SendConnectionPacket(){
	
	// if (FullyConnected)
	// 	return;
	
	// ConnectingToAP = true;
	// CurrentMessage.Length = 0;
	
	// This Connect packet isn't actually sent to the server itself, but is used by the AP client
	Json::Value@ json = Json::Object();
    json["cmd"] = "Connect";
    json["game"] = "Trackmania";

    json["name"] = "";
    json["password"] = "";
    json["uuid"] = "";
    json["seed_name"] = "";

    json["items_handling"] = 7;
	json["slot_data"] = true;
	
    Json::Value@ jsonVersion = Json::Object();
    jsonVersion["major"] = "0";
    jsonVersion["minor"] = "4";
    jsonVersion["build"] = "1";
    jsonVersion["class"] = "Version";
    json["version"] = jsonVersion;
    Json::Value@ tags = Json::Array();
    tags.Add("AP");
    json["tags"] = tags;

    Json::Value@ parent = Json::Array();//commands expected as an array for some reason
    parent.Add(json);
	
    string message  = Json::Write(parent);
    print(message);

    SendWebsocketPacket(message);
}

void SendWebsocketPacket(string message){
    //creates a packet that follows the websocket protocol
    //https://datatracker.ietf.org/doc/html/rfc6455#section-5.2
    array<uint8> masks = {Math::Rand(1,255),Math::Rand(1,255),Math::Rand(1,255),Math::Rand(1,255)};
    MemoryBuffer@ buffer = MemoryBuffer(message.Length+14);//maximum possible length
    int length = message.Length + 6;//minimum possible length
    buffer.Write(uint8(TCPMessageTypes::CODE_TEXT_FIN));//opcode
    if (message.Length <= 125){
		buffer.Write(uint8(128+message.Length));
	}else if (message.Length <= 65535){
		buffer.Write(uint8(128+126));
        buffer.Write(uint16(message.Length));
        length += 2;
	}else{//larsing
        buffer.Write(uint8(128+127));
        buffer.Write(uint64(message.Length));
        length += 8;
    }
    buffer.Write(masks[0]);
    buffer.Write(masks[1]);
    buffer.Write(masks[2]);
    buffer.Write(masks[3]);
    for (int i = 0; i < message.Length; i++){
        uint8 masked = uint8(message.SubStr(i,1)[0]) ^ masks[i%4];
        buffer.Write(masked);
    }
    buffer.Seek(0);
    socket.Write(buffer, length);
    print("Sent Packet!");
}