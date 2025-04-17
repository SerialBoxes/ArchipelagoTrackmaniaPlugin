void ProcessMessage(const string &in message){
    print("Recieved Message: "+message);
    try {
        Json::Value@ json = Json::Parse(message);
        for (int i = 0; i < json.Length; i++){
            Json::Value@ cmdJson = json[0];
            string cmd = cmdJson["cmd"];
            print("CMD: " + cmd);

            //angelscript switch statements only work with numbers ;-;
            if (cmd == "RoomInfo"){
                SendConnectionPacket();
            }else if (cmd == "Connected"){

            }else if (cmd == "PrintJSON"){
                //idk if we do anything with this in game
            }else if (cmd == "ConnectionRefused"){
                //this shouldn't ever really happen
                Log::Error("Server Refused Connection, closing...",true);
                socket.Close();
            }else if (cmd == "RecievedItems"){

            }else if (cmd == "LocationInfo"){

            }else if (cmd == "Bounced"){
            
            }else if (cmd == "Retrieved"){
            
            }else if (cmd == "RoomUpdate"){
            
            }
        }
    }catch{
        error("Message not valid JSON, dropping...");
    }
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

    Json::Value@ parent = Json::Array();//commands expected as an array
    parent.Add(json);
    
    string message  = Json::Write(parent);

    socket.SendWebsocketPacket(message);
}