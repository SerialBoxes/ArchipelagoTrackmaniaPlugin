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
    string URL = BuildRandomMapQueryURL(seriesI);
    MapInfo@ mapRoll = QueryForRandomMap(URL, seriesI);
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

MapInfo@ QueryForRandomMap(const string &in URL, int seriesI){
    if (!socket.NotDisconnected()) return null;
    isQueryingForMap = true;
    Json::Value@ res;
    Json::Value@ mapJson;
    try {
        @res = API::GetAsync(URL)["Results"];
    } catch {
        Log::Error("Could not reach TMX, it might be down...", true);
        //sleep(3000);
        //return QueryForRandomMap(URL, seriesI);
        return null;
    }
    if (res.GetType() != Json::Type::Array || res.Length == 0){
        Log::Error("Tag Settings match no maps, disabling inclusive and using default etags", true);
        data.tagsOverride = true;
        sleep(1000);
        return QueryForRandomMap(BuildRandomMapQueryURL(seriesI),seriesI);
    }
    @mapJson = res[0];
    Log::Trace("Next Map: "+Json::Write(mapJson));
    if (!IsMapValid(mapJson)){
        Log::Warn("Map contains pre-patch physics, retrying...");
        sleep(1000);
        return QueryForRandomMap(URL, seriesI);
    }
    MapInfo@ map = MapInfo(mapJson);
    if (map is null){
        Log::Warn("Map is null, retrying...");
        sleep(1000);
        return QueryForRandomMap(URL, seriesI);
    }

    isQueryingForMap = false;
    return map;
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

string BuildRandomMapQueryURL(int seriesI){
    dictionary params;
    params.Set("fields", MAP_FIELDS); //fields that the API will return in the json object
    params.Set("random", "1");
    params.Set("count", "1");
    
    string tags = BuildTagIdString(data.world[seriesI].tags);
    if (tags.Length > 0){
        params.Set("tag", tags);
        params.Set("taginclusive", (data.settings.tagsInclusive && !data.tagsOverride)?"true":"false");
    }

    string etags = BuildTagIdString(data.settings.etags);
    if (etags.Length > 0){
        if (!data.tagsOverride){
            params.Set("etag", etags);
        }else{
            params.Set("etag", ETAGS);
        }
    }

    string difficulties = BuildDifficultyString(data.settings.difficulties);
    if (difficulties.Length > 0 && !data.tagsOverride){
        params.Set("difficulty", difficulties);
    }

    params.Set("authortimemax", tostring(MAX_AUTHOR_TIME)); //5 minute author time max
    //params.Set("vehicle", "1,2,3,4");//this locks out character pilot and black market maps
    params.Set("maptype", SUPPORTED_MAP_TYPE);

#if MP4
    params.Set("titlepack", CurrentTitlePack());
#endif

    string urlParams = DictToApiParams(params);
    return "https://" + MX_URL + "/api/maps" + urlParams;
}

string DictToApiParams(dictionary params) {
    string urlParams = "";
    if (!params.IsEmpty()) {
        auto keys = params.GetKeys();
        for (uint i = 0; i < keys.Length; i++) {
            string key = keys[i];
            string value;
            params.Get(key, value);

            urlParams += (i == 0 ? "?" : "&");
            urlParams += key + "=" + Net::UrlEncode(value.Trim());
        }
    }

    return urlParams;
}

string BuildTagIdString(array<string> tagList){
    string result = "";

    for (uint i = 0; i < tagList.Length; i++){
        if (GetTags().Exists(tagList[i])){
            result += "" + int(GetTags()[tagList[i]]) + ",";
        }
    }

    if (result.Length > 0){
        result = result.SubStr(0, result.Length - 1);
    }

    return result;
}

string BuildDifficultyString(array<string> difficultyList){
    string result = "";

    for (uint i = 0; i < difficultyList.Length; i++){
        if (TMX_DIFFICULTIES.Exists(difficultyList[i])){
            result += "" + int(TMX_DIFFICULTIES[difficultyList[i]]) + ",";
        }
    }

    if (result.Length > 0){
        result = result.SubStr(0, result.Length - 1);
    }

    return result;
}
