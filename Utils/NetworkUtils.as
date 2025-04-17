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
                ProcessRoomInfo(cmdJson);
                SendConnectionPacket();
            }else if (cmd == "Connected"){
                ProcessConnected(cmdJson);
            }else if (cmd == "PrintJSON"){
                ProcessPrintJson(cmdJson);
            }else if (cmd == "ConnectionRefused"){
                ProcessConnectionRefused(cmdJson);
            }else if (cmd == "RecievedItems"){
                ProcessRecievedItems(cmdJson);
            }else if (cmd == "LocationInfo"){
                ProcessLocationInfo(cmdJson);
            }else if (cmd == "Bounced"){
                ProcessBounced(cmdJson);
            }else if (cmd == "Retrieved"){
                ProcessRetrieved(cmdJson);
            }else if (cmd == "RoomUpdate"){
                ProcessRoomUpdate(cmdJson);
            }
        }
    }catch{
        error("Message not valid JSON, dropping...");
    }
}

string seedNameCache = "";
void ProcessRoomInfo (Json::Value@ json){
    seedNameCache = json["seed_name"];
}

void ProcessConnected (Json::Value@ json){
    int teamI = json["team"];
    int playerI = json["slot"];

    bool existingSaveGame = false;// LookForExistingSave(seedNameCache, teamI, playerI);

    if (existingSaveGame){
        //load and use existing save
    } else{
        YamlSettings@ settings = YamlSettings();
        settings.targetTimeSetting = json["slot_data"]["TargetTimeSetting"];
        settings.seriesCount = json["slot_data"]["SeriesNumber"];
        settings.mapsInSeries = json["slot_data"]["SeriesMapNumber"];
        settings.medalRequirement = json["slot_data"]["MedalRequirement"];
        settings.tags = json["slot_data"]["MapTags"];
        settings.tagsInclusive = json["slot_data"]["MapTagsInclusive"];
        settings.etags = json["slot_data"]["MapETags"];

        @data = SaveData(seedNameCache, teamI, playerI, settings);

        seedNameCache = "";
    }
    
}

void ProcessPrintJson (Json::Value@ json){
    //¯\_(ツ)_/¯
}

void ProcessConnectionRefused (Json::Value@ json){
    seedNameCache = "";
    Log::Error("Server Refused Connection, closing...",true);
    socket.Close();
}

void ProcessRecievedItems (Json::Value@ json){
    
}

void ProcessLocationInfo (Json::Value@ json){
    
}

void ProcessBounced (Json::Value@ json){
    
}

void ProcessRetrieved (Json::Value@ json){
    
}

void ProcessRoomUpdate (Json::Value@ json){
    
}

void SendConnectionPacket(){

    // This Connect packet isn't actually sent to the server itself, but is used by the AP client
    // We only need the first two fields, but if we don't have the rest the packet gets rejected as invalid 
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