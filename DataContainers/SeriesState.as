class SeriesState{
    int medalTotal; //number of medals this series contributes to the final total 
    int mapCount; // maps in the series
    SearchCriteria@ searchBuilder; // handles making a MX search URL
    array<MapState@> maps;
    bool initialized;
    bool initializing;

    SaveData@ saveData;

    //derived data
    int seriesIndex;
    int medalRequirement; // progression medals required to unlock

    SeriesState(SaveData@ saveData, const Json::Value &in json, int seriesIndex, int requirement, bool isSlot = false){
        this.seriesIndex = seriesIndex;
        this.medalRequirement = requirement;
        @this.saveData = saveData;
        try {
            if (isSlot){
                ReadSlotData(json);
            } else{
                ReadJsonV1_2(json);
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
            MapInfo@ mapRoll = QueryForRandomMap(searchBuilder);
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
            if (saveData.settings.DoingBronze()){
                ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Bronze);
                index++;
            }
            if (saveData.settings.DoingSilver()){
                ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Silver);
                index++;
            }
            if (saveData.settings.DoingGold()){
                ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Gold);
                index++;
            }
            if (saveData.settings.DoingAuthor()){
                ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Author);
                index++;
            }
            ids[index] = MapIndicesToId(seriesIndex, i, CheckTypes::Target);
            index++;
        }
        SendLocationScouts(ids, index);
    }

    void ReadSlotData(const Json::Value@ &in json){
        this.medalTotal = json["MedalTotal"];
        this.mapCount = json["MapCount"];
        //print(json.HasKey("SearchCriteria"));
        @this.searchBuilder = SearchCriteria(seriesIndex, json["SearchCriteria"], true);
        maps = array<MapState@>(mapCount);

        initialized = false;
        initializing = false;
    }

    void ReadJsonV1_2(const Json::Value@ &in json){
        this.medalTotal = json["medalTotal"];
        this.mapCount = json["mapCount"];
        @this.searchBuilder = SearchCriteria(seriesIndex, json["searchBuilder"]);

        maps = array<MapState@>(mapCount);
        const Json::Value@ mapObjects = json["maps"];
        for (uint i = 0; i < mapObjects.Length; i++) {
            @maps[i] = MapState(saveData, mapObjects[i],seriesIndex,i);
        }

        SeriesStateThumbnailPacket@ packed = SeriesStateThumbnailPacket(this,json);
        startnew(function(ref@ packed) {
            SeriesStateThumbnailPacket@ packet =  cast<SeriesStateThumbnailPacket@>(packed);
            packet.seriesState.ReadThumbnails(packet.seriesJson);
        }, packed);

        initialized = int(mapObjects.Length) == mapCount;
        initializing = false;
    }

    void ReadThumbnails(const Json::Value@ &in json){
        for(int i = 0; i < seriesIndex+1; i++){
            yield();//cant load all thumbnails on the same frame or we die
        }
        const Json::Value@ mapObjects = json["maps"];
        for (uint i = 0; i < mapObjects.Length; i++) {
            maps[i].LoadThumbnail(mapObjects[i]);
        }
    }

    Json::Value ToJson(){
        Json::Value json = Json::Object();
        try {
            json["medalTotal"] = medalTotal;
            json["mapCount"] = mapCount;
            json["searchBuilder"] = searchBuilder.ToJson();

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

class SeriesStateThumbnailPacket{
    SeriesState@ seriesState;
    const Json::Value@ seriesJson;
    SeriesStateThumbnailPacket(SeriesState@ seriesState, const Json::Value@ seriesJson){
        @this.seriesState = seriesState;
        @this.seriesJson = seriesJson;
    }        
}