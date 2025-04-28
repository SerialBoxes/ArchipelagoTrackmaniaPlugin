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
        array<int> allChecks = array<int>(data.settings.seriesCount*data.settings.mapsInSeries*MAX_MAP_LOCATIONS);
        int total = 0;
        for (uint i = 0; i < data.world.Length; i++){
            for (uint j = 0; j < data.world[i].maps.Length; j++){
                if (data.world[i].maps[j] !is null){
                    total += data.world[i].maps[j].AddLocationChecks(allChecks);
                }
            }
        }
        SendLocationChecks(allChecks, total);
    } else{
        YamlSettings@ settings = YamlSettings();
        settings.targetTimeSetting = json["slot_data"]["TargetTimeSetting"];
        settings.seriesCount = json["slot_data"]["SeriesNumber"];
        settings.mapsInSeries = json["slot_data"]["SeriesMapNumber"];
        settings.medalRequirement = json["slot_data"]["MedalRequirement"];
        settings.tags = FormatStringList(json["slot_data"]["MapTags"]);
        settings.tagsInclusive = json["slot_data"]["MapTagsInclusive"] == 0 ? false : true;
        settings.etags = FormatStringList(json["slot_data"]["MapETags"]);;
        settings.difficulties = FormatStringList(json["slot_data"]["Difficulties"]);;

        @data = SaveData(seedNameCache, teamI, playerI, settings);

        startnew(CoroutineFunc(data.world[0].Initialize));
    }
    seedNameCache = "";
    SendStatusUpdate(ClientStatus::CLIENT_PLAYING);
    
}

void ProcessPrintJson (Json::Value@ json){
    //¯\_(ツ)_/¯
    Json::Value@ data = json["data"];
    if (data !is null && data.GetType() == Json::Type::Array){
        for (uint i = 0; i < data.Length; i++){
            string rawText = json["data"][i]["text"];
            string displayText = StripArchipelagoColorCodes(rawText);
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
    int serverIndex = json["index"];
    Json::Value@ items = json["items"];
    if (serverIndex == 0 && data.items.itemsRecieved > 0){
        //resync!!
        data.items.Reset();
    }
    for (uint i = 0; i < items.Length; i++){
        data.items.AddItem(items[i]["item"]);
    }
    //check if we won
    if (!data.hasGoal && data.items.GetProgressionMedalCount() >= data.settings.medalRequirement * data.settings.seriesCount){
        SendStatusUpdate(ClientStatus::CLIENT_GOAL);
        data.hasGoal = true;
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
            if (itemId >= BASE_FILLER_ID && itemId != int(ItemTypes::Archipelago)){
                itemType = ItemTypes::Filler;
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
    // Json::Value@ locations = json["checked_locations"];
    // if (locations !is null && locations.GetType() == Json::Type::Array){
    //     for (int i = 0; i < locations.Length; i++){
    //         int loc = locations[i];
    //         vec3 indices = MapIdToIndices(loc);
    //     }
    // }
    //update checked locations
    //im not sure what expected behaviour here should be
    //I think players will still want to be able to grind tracks and know their times even if the game ends
    //but also not doing anything here makes co-op very confusing.
    //idk ill get feedback first and go from there.
}

void ProcessReroll (Json::Value@ json){
    if (loadedMap !is null && loadedMap.mapInfo.MapUid == GetLoadedMapUid()){
        RerollMap(loadedMap.seriesIndex, loadedMap.mapIndex);   
    }
}

array<string> FormatStringList(const string &in bla){
    Json::Value@ json = Json::Parse(bla);
    array<string> arr = array<string>(json.Length);
    for (uint i = 0; i < json.Length; i++){
        arr[i] = json[i];
    }
    return arr;
}