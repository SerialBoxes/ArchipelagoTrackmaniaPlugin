class MapState{
    int targetTime;
    int personalBestTime;
    MapInfo@ mapInfo;
    array<ItemTypes> itemTypes;//type of item in each of the 5 slots for a map. might not all be populated.
    bool skipped;//all our checks sent even if the pb isnt less than targetTime

    SaveData@ saveData;

    //derived data
    int seriesIndex;
    int mapIndex;

    MapState(SaveData@ saveData, MapInfo@ mapInfo, int seriesIndex, int mapIndex){
        @this.saveData = saveData;
        @this.mapInfo = mapInfo;
        this.targetTime = CalculateTargetTime();
        personalBestTime = 30000000;
        itemTypes = array<ItemTypes>(5);
        bool skipped = false;

        this.seriesIndex = seriesIndex;
        this.mapIndex = mapIndex;
    }

    MapState(SaveData@ saveData, const Json::Value &in json, int seriesIndex, int mapIndex){
        try {
            @this.saveData = saveData;
            this.seriesIndex = seriesIndex;
            this.mapIndex = mapIndex;

            targetTime = json["targetTime"];
            personalBestTime = json["personalBestTime"];
            mapInfo = MapInfo(json["mapInfo"]);
            skipped = json["skipped"] == "true" ? true : false;

            itemTypes = array<ItemTypes>(5);
            const Json::Value@ itemObjects = json["itemTypes"];
            for (uint i = 0; i < itemTypes.Length; i++) {
                itemTypes[i] = itemObjects[i];
            }
        } catch {
            Log::Warn("Error parsing MapState for Series "+seriesI+" Map "+mapI+ "\nReason: " + getExceptionInfo(), true);
        }
    }

    private int CalculateTargetTime(){
        float targetTimeSetting = saveData.settings.targetTimeSetting;
        int medalI = int(Math::Floor(targetTimeSetting));
        int nextMedalI = medalI + 1;
        float factor = targetTimeSetting - Math::Floor(targetTimeSetting);//no frac function imma cry ;-;
        array<int> medalTimes = {mapInfo.BronzeTime, mapInfo.SilverTime, mapInfo.GoldTime, mapInfo.AuthorTime, mapInfo.AuthorTime};
        float interpolatedTime = Math::Lerp(medalTimes[medalI],medalTimes[nextMedalI], factor);
        return int(Math::Round(interpolatedTime));
    }

    void SetItemType(ItemTypes itemType, CheckTypes checkLocation){
        itemTypes[int(checkLocation)] = itemType;
    }

    void ReplaceMap(MapInfo@ mapInfo){
        this.mapInfo = mapInfo;
        this.targetTime = CalculateTargetTime();
        personalBestTime = 30000000;
    }

    void UpdatePB(int raceTime){
        if (raceTime < personalBestTime && raceTime >= 0){
            personalBestTime = raceTime;
            FireLocationChecks();
        }
    }

    void Skip(){
        skipped = true;
        saveData.items.skipsUsed += 1;

        FireLocationChecks();
    }

    void FireLocationChecks(){
        //resending old checks doesn't cause any issues and makes this easier, so lets do it!

        array<int> checks = array<int>(5);
        int index = 0;
        if (personalBestTime < mapInfo.BronzeTime || skipped){
            checks[index] = MapIndicesToId(seriesIndex, mapIndex, CheckTypes::Bronze);
            index++;
        }
        if ((personalBestTime < mapInfo.SilverTime || skipped) && saveData.settings.targetTimeSetting >= 1.0){
            checks[index] = MapIndicesToId(seriesIndex, mapIndex, CheckTypes::Silver);
            index++;
        }
        if ((personalBestTime < mapInfo.GoldTime || skipped) && saveData.settings.targetTimeSetting >= 2.0){
            checks[index] = MapIndicesToId(seriesIndex, mapIndex, CheckTypes::Gold);
            index++;
        }
        if ((personalBestTime < mapInfo.AuthorTime || skipped) && saveData.settings.targetTimeSetting >= 3.0){
            checks[index] = MapIndicesToId(seriesIndex, mapIndex, CheckTypes::Author);
            index++;
        }
        if ((personalBestTime < targetTime || skipped)){
            checks[index] = MapIndicesToId(seriesIndex, mapIndex, CheckTypes::Target);
            index++;
        }
        SendLocationChecks(checks, index);
    }

    Json::Value ToJson(){
        Json::Value json = Json::Object();
        try {
            json["targetTime"] = targetTime;
            json["personalBestTime"] = personalBestTime;
            json["mapInfo"] = mapInfo.ToJson();
            json["skipped"] = skipped? "true" : "false";
            Json::Value itemArray = Json::Array();
            for (uint i = 0; i < itemTypes.Length; i++) {
                itemArray.Add(int(itemTypes[i]));
            }
            json["itemTypes"] = itemArray;
        } catch {
            Log::Error("Error converting MapState to JSON for Series "+seriesI+" Map "+mapI, true);
        }
        return json;
    }

    
}