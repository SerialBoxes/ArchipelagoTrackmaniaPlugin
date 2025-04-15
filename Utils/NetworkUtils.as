
void ConfigureSocket(){
    string msg = "GET / HTTP/1.1\r\n"
	"Host: localhost\r\n" 
	"Connection: keep-alive, Upgrade\r\n"
	"Upgrade: websocket\r\n"
	"Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
	"Sec-WebSocket-Version: 13\r\n"
	"Accept: /\r\n";
    print (msg);
    MemoryBuffer@ buffer = MemoryBuffer(msg.Length+1);
    buffer.Write(msg);
    buffer.Seek(0);
    socket.Write(buffer, msg.Length);
    //socket.WriteRaw(msg);
}

void ConfigureSocket2(){
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


void SendClientHandshake(){
    Json::Value@ json;
	Json::Value jsonVersion;
	string message, slotName;
	
	// if (FullyConnected)
	// 	return;
	
	// ConnectingToAP = true;
	// CurrentMessage.Length = 0;
	
	// This Connect packet isn't actually sent to the server itself, but is used by the AP client
	@json = Json::Object();
    json["cmd"] = "Connect";
    json["game"] = "Trackmania";

    json["name"] = "";
    json["password"] = "";
    json["uuid"] = "";
    json["seed_name"] = "";

    json["items_handling"] = 7;
	json["slot_data"] = true;
	
    jsonVersion = Json::Object();
    jsonVersion["major"] = "0";
    jsonVersion["minor"] = "4";
    jsonVersion["build"] = "1";
    jsonVersion["class"] = "Version";
    json["version"] = jsonVersion;
    json["tags"] = "[\"AP\"]";
	
    message  = Json::Write(json);
    print (message);

    // socket.Write(TCPMessageTypes::CODE_TEXT_FIN);
    // socket.Write(message.Length);
    socket.Write(message);
	
	//socket.WriteMsg(TCPMessageTypes::CODE_TEXT_FIN,message);
}