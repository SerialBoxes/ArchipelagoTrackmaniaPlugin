class WebSocket{

    Net::Socket@ socket;
    string ip;
    int port;
    WebsocketConnectionState state;
    
    WebSocket(string ip, int port){
        this.ip = ip;
        this.port = port;
        socket = Net::Socket();
        state = WebsocketConnectionState::Disconnected;
    }


    void OpenSocket(){
        print("Opening Socket");
        startnew(CoroutineFunc(Connect));

    }

    void Connect(){
        bool result = socket.Connect(ip,port);
        if (result){
            while (!socket.IsReady()){
                yield();
            }
            print ("Sending Handshake");
            SocketHandshake();
            startnew(CoroutineFunc(ReadLoop));
        }else{
            print("Error Opening Socket, Closing");
            Close();
        }
    }

    void Close(){
        socket.Close();
        state = WebsocketConnectionState::Disconnected;
    }

    bool IsConnected(){
        return state != SocketConnectionState::Disconnected;
    }

    void ReadLoop() {
        while(IsConnected()){
            if (state == WebsocketConnectionState::Handshaking){
                ReadStringMessage();
            }else{
                ReadPacketMessage();
            }
            ReadNextMessage2();
        }
        //its so jover
    }

    void ReadPacketMessage(){
        while (socket.Available() < 1 && IsConnected()){
            yield();
        }
        if (!IsConnected()) return;
        uint8 opcode = socket.ReadUint8();
        bool validOpcode = CheckOpcode(opcode);

        if (!validOpcode){
            //this is a disconnect packet probably.
            //lets just panic and disconnect regardless
            //ok everyone ready? 3, 2, 1....
            //AAAAAAAAALKSJDFKL:EJS:IF
            Close();
            return;
        }

        while (socket.Available() < 1 && IsConnected()){
            yield();
        }
        if (!IsConnected()) return;
        uint8 lengthAndMask = socket.ReadUint8();
        uint64 length = lengthAndMask & 127;
        bool mask = (lengthAndMask >> 7) == 1;

        if (length == 126){
            while (socket.Available() < 2 && IsConnected()){
                yield();
            }
            if (!IsConnected()) return;
            length = socket.ReadUint16();
        }else if (length == 127){
            while (socket.Available() < 8 && IsConnected()){
                yield();
            }
            if (!IsConnected()) return;
            length = socket.ReadUint64();
        }

        if (mask){
            //we cry i dont wanna rn
            int masks = socket.ReadUint32();
            string msg = socket.ReadRaw(length);
            //tada problem gone
        }else{
            string msg = socket.ReadRaw(length);
            //pop this somehow idk
        }

    }

    string messsage;
    void ReadStringMessage(){
        string line;
        while (!socket.ReadLine(line) && IsConnected()){
            yield();
        }
        if (!IsConnected()) return;
        line = line.Trim();
        if (line.Length > 0){
            messsage += line + "\r\n";
        }else{
            ProcessHTTPMessage(messsage);
            messsage = "";
        }
    }

    void ProcessHTTPMessage(string msg){
        if (msg.Contains("Upgrade: websocket")){
            print("Hanshake Sucessful, Socket Fully Connected!");
            state = WebsocketConnectionState::Connected;
        }
    }

    bool CheckOpcode(uint8 opcode){
        uint8 nullbits = opcode & 112;
        if (nullbits != 0) return false;
        uint8 op = opcode & 15;
        if (op != 0 || op != 1 || op != 2 || op != 8 || op != 9 || op != 10 ) return false;
        return true;
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

    void SendWebsocketPacket(string message){
        //creates a packet that follows the websocket protocol
        //https://datatracker.ietf.org/doc/html/rfc6455#section-5.2
        array<uint8> masks = {Math::Rand(1,255),Math::Rand(1,255),Math::Rand(1,255),Math::Rand(1,255)};
        MemoryBuffer@ buffer = MemoryBuffer(message.Length+14);//maximum possible length
        int length = message.Length + 6;//minimum possible length
        buffer.Write(uint8(WebsocketMessageTypes::CODE_TEXT_FIN));//opcode
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
        print("Sent Packet! :)");
    }
}

/**
 * TCP opcodes.
 * These will be used in the TCPLink client to denote message types to the server
 *
 */
 enum WebsocketMessageTypes{
	CODE_TEXT_FIN = 129,           // (10000001) - Text frame with FIN bit set (use this for single-fragment text messages)
	CODE_CONTINUATION = 0,         // (00000000) - Continuation frame
	CODE_PING = 137,               // (10001001) - Ping
	CODE_PONG = 138,               // (10001010) - Pong
	CODE_TEXT = 1,                 // (00000001) - Text frame (use CODE_CONTINUATION to continue a text message)
    CODE_CONTINUATION_FIN = 128    // (10000000) - Continuation frame with FIN bit set (ends a multi-fragment message)
 }

 enum WebsocketConnectionState{
	Handshaking = 0,
	Connected = 1,
	Disconecting = 2,
	Disconnected = 3
 }