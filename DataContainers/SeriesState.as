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
            for (uint i = 0; i < mapObjects.Length; i++) {//check the length on this plz thx
                maps[i] = MapState(saveData, mapObjects[i],i);
            }
            initialized = mapObjects.Length == mapCount;//here too
            initializing = false;
        } catch {
            Log::Warn("Error parsing SeriesState for Series "+seriesI+"\nReason: " + getExceptionInfo(), true);
        }
    }

    void Initialize(){
        if (initialized || initializing) return;
        initializing = true;
        int checksPerMap = int(Math::Round(saveData.settings.targetTimeSetting - Math::Floor(saveData.settings.targetTimeSetting))) + 2;
        array<int> ids = array<int>(checksPerMap * mapCount);
        int index = 0;
        for(int i = 0; i < mapCount; i++){
            if (maps[i] !is null) continue;
            string URL = BuildRandomMapQueryURL();
            MapInfo@ mapRoll = QueryForRandomMap(URL);
            @maps[i] = MapState(saveData, mapRoll, seriesIndex, i);

            int bronzeId = MapIndicesToId(seriesIndex, i, CheckTypes::Bronze);
            ids[index] = bronzeId;
            index++;
            for (int j = 1; j < checksPerMap-1; j++){
                ids[index] = bronzeId + j;
                index++;
            }
            ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Target);
            index++;
        }
        SendLocationScouts(ids, index);
        initialized = true;
        initializing = false;
    }

    bool IsUnlocked(){
        return medalRequirement <= data.items.GetProgressionMedalCount();
    }

    Json::Value ToJson(){
        Json::Value json = Json::Object();
        try {
            json["medalRequirement"] = medalRequirement;
            json["mapCount"] = mapCount;
            Json::Value mapArray = Json::Array();
            for (uint i = 0; i < maps.Length; i++) {
                mapArray.Add(maps[i].ToJson());
            }
            json["maps"] = mapArray;
        } catch {
            Log::Error("Error converting SeriesState to JSON for Series "+seriesI, true);
        }
        return json;
    }

}