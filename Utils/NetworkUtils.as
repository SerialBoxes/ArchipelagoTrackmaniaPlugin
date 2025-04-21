void ProcessMessage(const string &in message){
    print("Recieved Message: "+message);
    //try {
        Json::Value@ json = Json::Parse(message);
        for (uint i = 0; i < json.Length; i++){
            Json::Value@ cmdJson;
            if (json.GetType() == Json::Type::Array){
                @cmdJson = json[0];
            }else{
                @cmdJson = json;
            }
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
            }else if (cmd == "ReceivedItems"){
                ProcessReceivedItems(cmdJson);
            }else if (cmd == "LocationInfo"){
                ProcessLocationInfo(cmdJson);
            }else if (cmd == "Bounced"){
                ProcessBounced(cmdJson);
            }else if (cmd == "Retrieved"){
                ProcessRetrieved(cmdJson);
            }else if (cmd == "RoomUpdate"){
                ProcessRoomUpdate(cmdJson);
            }else if (cmd == "Reroll"){
                ProcessReroll(cmdJson);
            }
        }
    // }catch{
    //     error("Message not valid JSON, dropping...");
    // }
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
        settings.tags = GetMapTags(json["slot_data"]["MapTags"]);
        settings.tagsInclusive = json["slot_data"]["MapTagsInclusive"] == 0 ? false : true;
        settings.etags = GetMapTags(json["slot_data"]["MapETags"]);;

        @data = SaveData(seedNameCache, teamI, playerI, settings);

        seedNameCache = "";

        startnew(CoroutineFunc(data.world[0].Initialize));
    }
    SendStatusUpdate(ClientStatus::CLIENT_PLAYING);
    
}

void ProcessPrintJson (Json::Value@ json){
    //¯\_(ツ)_/¯
}

void ProcessConnectionRefused (Json::Value@ json){
    seedNameCache = "";
    Log::Error("Server Refused Connection, closing...",true);
    socket.Close();
}

void ProcessReceivedItems (Json::Value@ json){
    int serverIndex = json["index"];
    Json::Value@ items = json["items"];
    if (serverIndex == 0 && data.items.itemsRecieved > 0){
        //resync!!
        @data.items = Items();
    }
    for (uint i = 0; i < items.Length; i++){
        AddItem(items[i]["item"]);
    }
}

void ProcessLocationInfo (Json::Value@ json){
    for (uint i = 0; i < json["locations"].Length; i++){
        Json::Value@ netItem = json["locations"][i];
        vec3 location = GetMapIndicesFromId(netItem["location"]);
        ItemTypes itemType = ItemTypes::Archipelago;
        if (netItem["player"] == data.playerTeamIndex) {//not totally sure this works
            itemType = ItemTypes(int(netItem["item"]));
        }
        data.world[int(location.x)].maps[int(location.y)].SetItemType(itemType, CheckTypes(int(location.z)));
    }
}

void ProcessBounced (Json::Value@ json){
    //if we ever add deathlink it will be added here
}

void ProcessRetrieved (Json::Value@ json){
    //a response to a get command, which we arent using so this should never happen! ^-^
}

void ProcessRoomUpdate (Json::Value@ json){
    //update checked locations
    //we dont actually keep track of whats checked tho so :P
}

void ProcessReroll (Json::Value@ json){
    if (loadedMap !is null && loadedMap.mapInfo.MapUid == GetLoadedMapUid()){
        RerollMap(loadedMap.seriesIndex, loadedMap.mapIndex);   
    }
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
    print(message);
    socket.SendWebsocketPacket(message);
}

void SendLocationChecks(array<int> locationIds, int count){
    Json::Value@ json = Json::Object();
    json["cmd"] = "LocationChecks";
    Json::Value@ locationList = Json::Array();
    for (int i = 0; i < count; i++){
        locationList.Add(locationIds[i]);
    }
    json["locations"] = locationList;

    Json::Value@ parent = Json::Array();
    parent.Add(json);

    string message  = Json::Write(parent);
    socket.SendWebsocketPacket(message);
}

void SendLocationScouts(array<int> locationIds, int count){
    Json::Value@ json = Json::Object();
    json["cmd"] = "LocationScouts";
    Json::Value@ locationList = Json::Array();
    for (int i = 0; i < count; i++){
        locationList.Add(locationIds[i]);
    }
    json["locations"] = locationList;
    json["create_as_hint"] = 0;

    Json::Value@ parent = Json::Array();
    parent.Add(json);

    string message  = Json::Write(parent);
    socket.SendWebsocketPacket(message);
}

void SendStatusUpdate(ClientStatus status){
    Json::Value@ json = Json::Object();
    json["cmd"] = "StatusUpdate";
    json["status"] = int(status);
    Json::Value@ parent = Json::Array();
    parent.Add(json);
    string message  = Json::Write(parent);
    socket.SendWebsocketPacket(message);
}