bool isQueryingForMap = false;
bool isNextMapLoading = false;

void LoadMap(int seriesIndex, int mapIndex){
    @loadedMap = data.GetMap(seriesIndex, mapIndex);
    if (loadedMap !is null){
        LoadMap(loadedMap.mapInfo);
    }
}

void RerollMap(int seriesI, int mapI){
    Log::Log("Rerolling Series " + seriesI + " Map " + mapI + ", one second please!", true);
    MapState@ mapState = data.world[seriesI].maps[mapI];
    string URL = BuildRandomMapQueryURL();
    MapInfo@ mapRoll = QueryForRandomMap(URL);
    mapState.ReplaceMap(mapRoll);
    if (loadedMap.seriesIndex == seriesI && loadedMap.mapIndex == mapI){
        LoadMap(mapRoll);
    }
}

void LoadMap(MapInfo@ map){
    // try {
        isNextMapLoading = true;
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
    // }
    // catch
    // {
    //     Log::Warn("Error while loading map ");
    //     Log::Error("TMX API is not responding, it might be down.", true);
    //     //APIDown = true;
    //     isNextMapLoading = false;
    // }
}

MapInfo@ QueryForRandomMap(const string &in URL){
    isQueryingForMap = true;
    //string URL = BuildRandomMapQueryURL();
    print(URL);
    Json::Value res;
    try {
        res = API::GetAsync(URL)["Results"][0];
    } catch {
        Log::Error("ManiaExchange API returned an error, retrying...");
        sleep(3000);
        return QueryForRandomMap(URL);
    }
    Log::Trace("Next Map: "+Json::Write(res));
    MapInfo@ map = MapInfo(res);
    if (map is null){
        Log::Warn("Map is null, retrying...");
        sleep(1000);
        return QueryForRandomMap(URL);
    }

    isQueryingForMap = false;
    return map;
}

string BuildRandomMapQueryURL(){
    dictionary params;
    params.Set("fields", MAP_FIELDS); //fields that the API will return in the json object
    params.Set("random", "1");
    params.Set("count", "1");
    
    string tags = BuildTagIdString(data.settings.tags);
    if (tags.Length > 0){
        params.Set("tag", tags);
        params.Set("taginclusive", data.settings.tagsInclusive?"true":"false");
    }

    string etags = BuildTagIdString(data.settings.etags);
    if (etags.Length > 0){
        params.Set("etag", etags);
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
#if TMNEXT
    dict tags = TMX_TAGS;
#elif MP4
    dict tags = TM2_TAGS;
#endif

    for (int i = 0; i < tags.Length; i++){
        if (tags.exists(tagList[i])){
            result += "" + tagList[i] + ",";
        }
    }

    if (result.get_Length() > 0){
        result = result.SubStr(0, result.get_Length() - 1);
    }

    return result;
}
