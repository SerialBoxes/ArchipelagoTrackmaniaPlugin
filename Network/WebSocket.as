class WebSocket{

    Net::Socket@ socket;
    string ip;
    int port;
    WebsocketConnectionState state;
    array<string> messageQueue;
    
    WebSocket(const string &in ip, int port){
        this.ip = ip;
        this.port = port;
        @socket = Net::Socket();
        state = WebsocketConnectionState::Disconnected;
        messageQueue = array<string>(10);//surely we dont need more than this
    }


    void OpenSocket(){
        print("Opening Socket");
        state = WebsocketConnectionState::Handshaking;
        startnew(CoroutineFunc(Connect));
    }

    private void Connect(){
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

    bool NotDisconnected(){
        return state != WebsocketConnectionState::Disconnected;
    }

    bool IsConnected(){
        return state == WebsocketConnectionState::Connected;
    }

    private void ReadLoop() {
        while(NotDisconnected()){
            if (state == WebsocketConnectionState::Handshaking){
                ReadStringMessage();
            }else{
                ReadPacketMessage();
                // print (""+socket.Available());
                // yield();
            }
        }
        //its so jover
    }

    private void ReadPacketMessage(){
        while (socket.Available() < 1 && NotDisconnected()){
            yield();
        }
        if (!NotDisconnected()) return;
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

        while (socket.Available() < 1 && NotDisconnected()){
            yield();
        }
        if (!NotDisconnected()) return;
        uint8 lengthAndMask = socket.ReadUint8();
        uint64 length = lengthAndMask & 127;
        bool mask = (lengthAndMask >> 7) == 1;

        if (length == 126){
            while (socket.Available() < 2 && NotDisconnected()){
                yield();
            }
            if (!NotDisconnected()) return;
            int left = socket.ReadUint8();
            int right = socket.ReadUint8();
            length = left << 8 | right;
        }else if (length == 127){
            // while (socket.Available() < 8 && NotDisconnected()){
            //     yield();
            // }
            // if (!NotDisconnected()) return;
            // length = socket.ReadUint64();

            //more crying
        }

        if (mask){
            //we cry i dont wanna rn
            int masks = socket.ReadUint32();
            string msg = socket.ReadRaw(length);
            //tada problem gone
        }else{
            string msg = socket.ReadRaw(length);
            //PushMessage(msg);
            ProcessMessage(msg);
        }

    }

    string messsage;
    private void ReadStringMessage(){
        string line;
        while (!socket.ReadLine(line) && NotDisconnected()){
            yield();
        }
        if (!NotDisconnected()) return;
        line = line.Trim();
        if (line.Length > 0){
            messsage += line + "\r\n";
        }else{
            ProcessHTTPMessage(messsage);
            messsage = "";
        }
    }

    private void ProcessHTTPMessage(const string &in msg){
        if (msg.Contains("Upgrade: websocket")){
            print("Hanshake Sucessful, Socket Fully Connected!");
            state = WebsocketConnectionState::Connected;
        }
    }

    private bool CheckOpcode(uint8 opcode){
        int nullbits = opcode & 112;
        if (nullbits != 0) return false;
        uint8 op = opcode & 15;
        if (op != 0 && op != 1 && op != 2 && op != 8 && op != 9 && op != 10 ) return false;
        return true;
    }

    private void SocketHandshake(){
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

    //i know this is technically a queue and not a stack but I like push and pop as names ^-^
    private void PushMessage(const string &in message){
        for (uint i = 0; i < messageQueue.Length; i++){
            if (messageQueue[i].Length == 0){
                messageQueue[i] = message;
                return;
            }
        }
        warn("More than "+messageQueue.Length +" queued messages, dropping!");
    }

    string PopMessage(){
        for (uint i = 0; i < messageQueue.Length; i++){
            if (messageQueue[i].Length > 0){
                string result = messageQueue[i];
                messageQueue[i] = "";
                return result;
            }
        }
        return "";
    }

    void SendWebsocketPacket(const string &in message){
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
            buffer.Write(uint8((message.Length >> 8) & 255));
            buffer.Write(uint8(message.Length & 255));
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
        print("Sending Message: " + message);
        socket.Write(buffer, length);
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