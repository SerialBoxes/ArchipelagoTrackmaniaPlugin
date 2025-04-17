bool isQueryingForMap = false;
bool isNextMapLoading = false;

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

        CTrackMania@ app = cast<CTrackMania>(GetApp());

        app.BackToMainMenu(); // If we're on a map, go back to the main menu else we'll get stuck on the current map
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
    params.Set("etag", ETAGS); //excluded tmx tags. These are Kacky, Royal, and Arena.
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
