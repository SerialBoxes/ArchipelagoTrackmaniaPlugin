class SeriesState{
    int medalRequirement; // progression medals required to unlock
    int mapCount; // maps in the series
    array<MapState@> maps;
    bool initialized;
    bool initializing;

    SaveData@ saveData;

    //derived data
    int seriesIndex;

    SeriesState(SaveData@ saveData, int medalRequirement, int mapCount, int seriesIndex){
        this.medalRequirement = medalRequirement;
        this.mapCount = mapCount;
        this.seriesIndex = seriesIndex;
        @this.saveData = saveData;
        maps = array<MapState@>(mapCount);
        initialized = false;
        initializing = false;
    }

    SeriesState(SaveData@ saveData, const Json::Value &in json, int seriesIndex){

        maps = array<MapState@>(mapCount);
        initialized = false;
        initializing = false;
        try {
            this.seriesIndex = seriesIndex;
            @this.saveData = saveData;

            medalRequirement = json["medalRequirement"];
            mapCount = json["mapCount"];

            maps = array<MapState@>(mapCount);
            const Json::Value@ mapObjects = json["maps"];
            for (uint i = 0; i < mapObjects.Length; i++) {
                @maps[i] = MapState(saveData, mapObjects[i],seriesIndex,i);
            }
            initialized = int(mapObjects.Length) == mapCount;
            initializing = false;
        } catch {
            Log::Error("Error parsing SeriesState for Series "+seriesIndex+"\nReason: " + getExceptionInfo());
        }
    }

    void Initialize(){
        if (initialized || initializing) return;
        initializing = true;
        bool loadError = false;
        for(int i = 0; i < mapCount; i++){
            if (maps[i] !is null) continue;
            string URL = BuildRandomMapQueryURL();
            MapInfo@ mapRoll = QueryForRandomMap(URL);
            if (mapRoll is null){
                Log::Error("Unable to roll Series "+seriesIndex+" Map "+i);
                loadError = true;
                break;
            }
            @maps[i] = MapState(saveData, mapRoll, seriesIndex, i);
        }
        SendScouts();
        initialized = !loadError;
        initializing = false;
        saveFile.Save(saveData);
    }

    bool IsUnlocked(){
        return medalRequirement <= data.items.GetProgressionMedalCount();
    }

    void SendScouts(){
        array<int> ids = array<int>(MAX_MAP_LOCATIONS * mapCount);
        int index = 0;
        for(int i = 0; i < mapCount; i++){
            ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Bronze);
            index++;
            if (saveData.settings.targetTimeSetting >= 1){
                ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Silver);
                index++;
            }
            if (saveData.settings.targetTimeSetting >= 2){
                ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Gold);
                index++;
            }
            if (saveData.settings.targetTimeSetting >= 3){
                ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Author);
                index++;
            }
            ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Target);
            index++;
        }
        SendLocationScouts(ids, index);
    }

    Json::Value ToJson(){
        Json::Value json = Json::Object();
        try {
            json["medalRequirement"] = medalRequirement;
            json["mapCount"] = mapCount;
            Json::Value@ mapArray = Json::Array();
            for (uint i = 0; i < maps.Length; i++) {
                if (maps[i] !is null){
                    mapArray.Add(maps[i].ToJson());
                }
            }
            json["maps"] = mapArray;
        } catch {
            Log::Error("Error converting SeriesState to JSON for Series "+seriesIndex);
        }
        return json;
    }

}