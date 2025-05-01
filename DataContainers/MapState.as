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
    UI::Texture@ thumbnail;

    MapState(SaveData@ saveData, MapInfo@ mapInfo, int seriesIndex, int mapIndex){
        @this.saveData = saveData;
        @this.mapInfo = mapInfo;
        this.targetTime = CalculateTargetTime();
        personalBestTime = 30000000;
        itemTypes = array<ItemTypes>(5);
        bool skipped = false;

        this.seriesIndex = seriesIndex;
        this.mapIndex = mapIndex;
        RequestThumbnail();
    }

    MapState(SaveData@ saveData, const Json::Value &in json, int seriesIndex, int mapIndex){
        try {
            @this.saveData = saveData;
            this.seriesIndex = seriesIndex;
            this.mapIndex = mapIndex;

            targetTime = json["targetTime"];
            personalBestTime = json["personalBestTime"];
            @mapInfo = MapInfo(json["mapInfo"]);
            skipped = json["skipped"] == "true" ? true : false;

            itemTypes = array<ItemTypes>(5);
            const Json::Value@ itemObjects = json["itemTypes"];
            for (uint i = 0; i < itemTypes.Length; i++) {
                int itemId = int(itemObjects[i]);
                if (itemId >= BASE_FILLER_ID && itemId != int(ItemTypes::Archipelago)){
                    itemTypes[i] = ItemTypes::Filler;
                }else{
                    itemTypes[i] = ItemTypes(int(itemObjects[i]));
                }
            }
            RequestThumbnail(true);
        } catch {
            Log::Error("Error parsing MapState for Series "+seriesIndex+" Map "+mapIndex+ "\nReason: " + getExceptionInfo());
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

    void RequestThumbnail(bool delay = false){
        API::NetworkCallback@ cb = API::NetworkCallback(ThumbnailRecieved);
        API::NetRequest@ request = API::NetRequest("https://trackmania.exchange/mapthumb/" + mapInfo.MapId, cb);
        if (delay) request.delayMS = 1000 * seriesIndex; //this is just a hacky way to not ddos tmx without adding a ton to this project i rly just wanna be doneaaaaaaaaa
        startnew(API::GetAsyncImg, request);
    }

    void ThumbnailRecieved(Net::HttpRequest@ request){
        if (request.ResponseCode() == 200){
            @thumbnail = UI::LoadTexture(request.Buffer());
        }
    }

    void UpdatePB(int raceTime){
        if (raceTime < personalBestTime && raceTime >= 0){
            personalBestTime = raceTime;
            UpdateCheckFlags();
        }
    }

    void Skip(){
        skipped = true;
        saveData.items.skipsUsed += 1;

        UpdateCheckFlags();
        saveFile.Save(saveData);
    }

    void UpdateCheckFlags(){
        if (personalBestTime <= mapInfo.BronzeTime || skipped){
            data.locations.FlagCheck(seriesIndex, mapIndex, CheckTypes::Bronze);
        }
        if ((personalBestTime <= mapInfo.SilverTime || skipped) && saveData.settings.targetTimeSetting >= 1.0){
            data.locations.FlagCheck(seriesIndex, mapIndex, CheckTypes::Silver);
        }
        if ((personalBestTime <= mapInfo.GoldTime || skipped) && saveData.settings.targetTimeSetting >= 2.0){
            data.locations.FlagCheck(seriesIndex, mapIndex, CheckTypes::Gold);
        }
        if ((personalBestTime <= mapInfo.AuthorTime || skipped) && saveData.settings.targetTimeSetting >= 3.0){
            data.locations.FlagCheck(seriesIndex, mapIndex, CheckTypes::Author);
        }
        if ((personalBestTime <= targetTime || skipped)){
            data.locations.FlagCheck(seriesIndex, mapIndex, CheckTypes::Target);
        }

        FireLocationChecks();
    }

    void FireLocationChecks(){
        //resending old checks doesn't cause any issues and makes this easier, so lets do it!

        array<int> checks = array<int>(5);
        int index = data.locations.AddLocationChecks(checks, seriesIndex, mapIndex);
        SendLocationChecks(checks, index);
    }

    Json::Value ToJson(){
        Json::Value json = Json::Object();
        try {
            json["targetTime"] = targetTime;
            json["personalBestTime"] = personalBestTime;
            json["mapInfo"] = mapInfo.ToJson();
            json["skipped"] = skipped? "true" : "false";
            Json::Value@ itemArray = Json::Array();
            for (uint i = 0; i < itemTypes.Length; i++) {
                itemArray.Add(int(itemTypes[i]));
            }
            json["itemTypes"] = itemArray;
        } catch {
            Log::Error("Error converting MapState to JSON for Series "+seriesIndex+" Map "+mapIndex);
        }
        return json;
    }
}