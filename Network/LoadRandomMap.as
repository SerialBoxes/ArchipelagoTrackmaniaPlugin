bool isQueryingForMap = false;
bool isNextMapLoading = false;

void LoadMapByIndex(int seriesIndex, int mapIndex){
    @loadedMap = data.GetMap(seriesIndex, mapIndex);
    if (loadedMap !is null){
        MapInfo@ info = loadedMap.mapInfo;
        startnew(LoadMap,info);
    }
}

void RerollMap(int seriesI, int mapI){
    Log::Log("Rerolling Series " + (seriesI+1) + " Map " + (mapI+1) + ", one second please!", true);
    MapState@ mapState = data.world[seriesI].maps[mapI];

    SearchCriteria@ URLBuilder = data.world[seriesI].searchBuilder;
    MapInfo@ mapRoll = QueryForRandomMap(URLBuilder);
    if (mapRoll !is null){
        mapState.ReplaceMap(mapRoll);
        if (loadedMap.seriesIndex == seriesI && loadedMap.mapIndex == mapI){
            startnew(LoadMap,mapRoll);
        }
    }else{
        Log::Error("Unable to reroll map", true);
    }
}

void LoadMap(ref@ mapData){
    try {
        isNextMapLoading = true;

        MapInfo@ map = cast<MapInfo@>(mapData);

        if (map is null ){
            warn ("Error, tried to load null map");
            isNextMapLoading = false;
            return;
        }

        Log::LoadingMapNotification(map);

        ClosePauseMenu();
        BackToMainMenu(); // If we're on a map, go back to the main menu else we'll get stuck on the current map
        
        auto app = cast<CTrackMania>(GetApp());

        while(!app.ManiaTitleControlScriptAPI.IsReady) {
            yield(); // Wait until the ManiaTitleControlScriptAPI is ready for loading the next map
        }

        app.ManiaTitleControlScriptAPI.PlayMap("https://"+ MX_URL+"/mapgbx/"+map.MapId, "", "");

        isNextMapLoading = false;
    }
    catch
    {
        Log::Error("Could not load map. TMX API is not responding, it might be down...", true);
        isNextMapLoading = false;
    }
}

MapInfo@ QueryForRandomMap(SearchCriteria@ URLBuilder){
    if (!socket.NotDisconnected()) return null;
    isQueryingForMap = true;
    Json::Value@ res;
    Json::Value@ mapJson;
    bool reroll = false;

    while (true)
    {
        try {
            string URL = URLBuilder.BuildQueryURL();
            @res = API::GetAsync(URL)["Results"];
        }
        catch {
            Log::Error("Could not reach TMX, it might be down...", true);
            break;
        }

        if (res.GetType() != Json::Type::Array || res.Length == 0) {
            if (URLBuilder.forceSafeURL) {
                Log::Error("Unable to find any maps!", true);
                break;
            }

            Log::Error("Search either returned no results or errored, entering safe mode and retrying...", true);
            URLBuilder.forceSafeURL = true;
            sleep(1000);
            continue;
        }

        @mapJson = res[0];
        Log::Trace("Next Map: " + Json::Write(mapJson));
        if (!IsMapValid(mapJson)){
            Log::Warn("Map contains pre-patch physics, retrying...");
            sleep(1000);
            continue;
        }

        string mapUid = mapJson["MapUid"];
        if (!reroll && data.previouslySeenMaps.Exists(mapUid)) {
            Log::Warn("Map was previously rolled, retrying once...");
            reroll = true;
            sleep(1000);
            continue;
        }
        data.previouslySeenMaps.Set(mapUid, true);

        MapInfo@ map = MapInfo(mapJson);
        if (map is null){
            Log::Warn("Map is null, retrying...");
            sleep(1000);
            continue;
        }

        isQueryingForMap = false;
        return map;
    }
    isQueryingForMap = false;
    return null;
}

bool IsMapValid(Json::Value@ mapJson){
    //automatically throw out pre-patch ice and bob and water
    //sorry, I want this to be accessible to new players and I don't want to make them deal with pre-patch
    //nando plz add physics versioning
#if TMNEXT
    string exebuild = mapJson["Exebuild"];
    for(uint i = 0; i < PHYSICS_PATCHES.Length; i++){
        if (exebuild <= PHYSICS_PATCHES[i].exebuild){
            for (uint j = 0; j < PHYSICS_PATCHES[i].tags.Length; j++){
                for (uint k = 0; k < mapJson["Tags"].Length; k++){
                    int physicsTagId = int(GetTags()[PHYSICS_PATCHES[i].tags[j]]);
                    int mapTagId = int(mapJson["Tags"][k]["TagId"]);
                    if (physicsTagId == mapTagId){
                        //is pre-patch!!
                        return false;
                    }
                }
            }
        }
    }
#endif

    return true;
}
