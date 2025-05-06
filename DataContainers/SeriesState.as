class SeriesState{
    int medalRequirement; // progression medals required to unlock
    int mapCount; // maps in the series
    array<string> tags;
    array<MapState@> maps;
    bool initialized;
    bool initializing;

    SaveData@ saveData;

    //derived data
    int seriesIndex;

    SeriesState(SaveData@ saveData, const Json::Value &in json, int seriesIndex, bool isSlot = false){
        this.seriesIndex = seriesIndex;
        @this.saveData = saveData;
        try {
            if (isSlot){
                ReadSlotData(json);
            } else{
                ReadJsonV1_1(json);
            }
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
            string URL = BuildRandomMapQueryURL(seriesIndex);
            MapInfo@ mapRoll = QueryForRandomMap(URL, seriesIndex);
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

    void ReadSlotData(const Json::Value@ &in json){
        this.medalRequirement = json["MedalRequirement"];
        this.mapCount = json["MapCount"];
        maps = array<MapState@>(mapCount);
        tags = FormatStringList(json["MapTags"]);
        initialized = false;
        initializing = false;
    }

    void ReadJsonV1_1(const Json::Value@ &in json){
        initialized = false;
        initializing = false;

        medalRequirement = json["medalRequirement"];
        mapCount = json["mapCount"];

        maps = array<MapState@>(mapCount);
        const Json::Value@ mapObjects = json["maps"];
        for (uint i = 0; i < mapObjects.Length; i++) {
            @maps[i] = MapState(saveData, mapObjects[i],seriesIndex,i);
        }

        const Json::Value@ tagObjects = json["tags"];
        tags = array<string>(tagObjects.Length);
        for (uint i = 0; i < tagObjects.Length; i++) {
            tags[i] = tagObjects[i];
        }

        initialized = int(mapObjects.Length) == mapCount;
        initializing = false;
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
            Json::Value tagsArray = Json::Array();
            for (uint i = 0; i < tags.Length; i++) {
                tagsArray.Add(tags[i]);
            }
            json["tags"] = tagsArray;
        } catch {
            Log::Error("Error converting SeriesState to JSON for Series "+seriesIndex);
        }
        return json;
    }

}