void ProcessMessage(const string &in message){
    if (IS_DEV_MODE) print("Recieved Message: "+message);
    Json::Value@ cmdJson;
    string cmd = "";
    try {
        Json::Value@ json = Json::Parse(message);
        if (json.GetType() == Json::Type::Array){
            @cmdJson = json[0];
        }else{
            @cmdJson = json;
        }

        cmd = cmdJson["cmd"];
    }catch{
        //if we get a mesage with invalid json, its probably a disconnect request from the server
        print("Message not valid JSON. Disconnecting...");
        socket.Close();
        return;
    }

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

string seedNameCache = "";
void ProcessRoomInfo (Json::Value@ json){
    seedNameCache = json["seed_name"];
}

void ProcessConnected (Json::Value@ json){
    int teamI = json["team"];
    int playerI = json["slot"];

    @saveFile = SaveFile(seedNameCache, teamI, playerI);

    if (saveFile.Exists()){
        Json::Value@ saveJson = saveFile.Load();
        @data = SaveData(seedNameCache, teamI, playerI, saveJson);
        //resend all map checks we have, just in case some got missed!
        array<int> allChecks = array<int>(MAX_SERIES_COUNT*MAX_MAPS_IN_SERIES*MAX_MAP_LOCATIONS);
        int total = 0;
        for (uint i = 0; i < data.world.Length; i++){
            for (uint j = 0; j < data.world[i].maps.Length; j++){
                total += data.locations.AddLocationChecks(allChecks, i, j);
            }
        }
        SendLocationChecks(allChecks, total);
    } else{

        @data = SaveData(seedNameCache, teamI, playerI, json["slot_data"], true);

        startnew(CoroutineFunc(data.world[0].Initialize));
    }
    seedNameCache = "";
    if (!socket.NotDisconnected()) return;
    CheckLocations(json);
    SendStatusUpdate(ClientStatus::CLIENT_PLAYING);
    
}

void ProcessPrintJson (Json::Value@ json){
    //¯\_(ツ)_/¯
    Json::Value@ data = json["data"];
    if (data !is null && data.GetType() == Json::Type::Array){
        for (uint i = 0; i < data.Length; i++){
            string rawText = json["data"][i]["text"];
            string displayText = StripArchipelagoColorCodes(rawText);
            if (!displayText.Contains("found") || !Setting_ShowToasts) return;
            Log::ArchipelagoNotification(displayText);
        }
    }
}

void ProcessConnectionRefused (Json::Value@ json){
    seedNameCache = "";
    Log::Error("Server Refused Connection, closing...",true);
    socket.Close();
}

void ProcessReceivedItems (Json::Value@ json){
    if (data is null) return;
    int serverIndex = json["index"];
    Json::Value@ items = json["items"];
    if (serverIndex == 0 && data.items.itemsRecieved > 0){
        //resync!!
        data.items.Reset();
    }
    if (serverIndex > data.items.itemsRecieved){
        SendSync();
    }
    for (uint i = 0; i < items.Length; i++){
        data.items.AddItem(items[i]["item"]);
    }
    //check if we won
    if (!data.hasGoal && data.items.GetProgressionMedalCount() >= data.victoryRequirement){
        SendStatusUpdate(ClientStatus::CLIENT_GOAL);
        data.hasGoal = true;
        startnew(Celebrate);
    }

    //check if we need to preload a new series
    data.InitializeUpcomingSeries();
}

void ProcessLocationInfo (Json::Value@ json){
    if (json["locations"] is null) return;
    for (uint i = 0; i < json["locations"].Length; i++){
        Json::Value@ netItem = json["locations"][i];
        vec3 location = MapIdToIndices(netItem["location"]);
        ItemTypes itemType = ItemTypes::Archipelago;
        if (netItem["player"] == data.playerTeamIndex) {//not totally sure this works
            int itemId = int(netItem["item"]);
            if (itemId >= BASE_TRAP_ID && itemId != int(ItemTypes::Archipelago)){
                if (itemId < int(ItemTypes::Filler)){
                    itemType = ItemTypes::Trap;
                }else{
                    itemType = ItemTypes::Filler;
                }
            }else{
                itemType = ItemTypes(int(netItem["item"]));
            }
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
    CheckLocations(json);
}

void ProcessReroll (Json::Value@ json){
    if (json["series_index"] !is null 
        && json["map_index"] !is null
        && int(json["series_index"]) >= 1
        && int(json["map_index"]) >= 1){
        RerollMap(int(json["series_index"])-1, int(json["map_index"])-1); 
    }else if (loadedMap !is null && loadedMap.mapInfo.MapUid == GetLoadedMapUid()){
        RerollMap(loadedMap.seriesIndex, loadedMap.mapIndex);   
    }
}

// array<string> FormatStringList(const string &in bla){
//     Json::Value@ json = Json::Parse(bla);
//     array<string> arr = array<string>(json.Length);
//     for (uint i = 0; i < json.Length; i++){
//         arr[i] = json[i];
//     }
//     return arr;
// }

void CheckLocations(Json::Value@ json){
    Json::Value@ locations = json["checked_locations"];
    if (locations !is null && locations.GetType() == Json::Type::Array){
        for (uint i = 0; i < locations.Length; i++){
            int loc = locations[i];
            vec3 indices = MapIdToIndices(loc);
            data.locations.FlagCheck(int(indices.x),int(indices.y), CheckTypes(int(indices.z)));
        }
    }
}