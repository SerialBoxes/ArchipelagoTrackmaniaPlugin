class MapState{
    int targetTime;
    int personalBestTime;
    int personalBestDiscountTime;
    MapInfo@ mapInfo;
    array<ItemTypes> itemTypes;//type of item in each of the 5 slots for a map. might not all be populated.
    MemoryBuffer@ textureBuffer;
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
        personalBestDiscountTime = 0;
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
            personalBestDiscountTime = json["personalBestDiscountTime"] !is null ? json["personalBestDiscountTime"] : 0;
            @mapInfo = MapInfo(json["mapInfo"]);
            skipped = json["skipped"] == "true" ? true : false;

            itemTypes = array<ItemTypes>(5);
            const Json::Value@ itemObjects = json["itemTypes"];
            for (uint i = 0; i < itemTypes.Length; i++) {
                int itemId = int(itemObjects[i]);
                if (itemId >= BASE_TRAP_ID && itemId != int(ItemTypes::Archipelago)){
                    if (itemId < int(ItemTypes::Filler)){
                        itemTypes[i] = ItemTypes::Trap;
                    }else{
                        itemTypes[i] = ItemTypes::Filler;
                    }
                }else{
                    itemTypes[i] = ItemTypes(int(itemObjects[i]));
                }
            }
        } catch {
            Log::Error("Error parsing MapState for Series "+seriesIndex+" Map "+mapIndex+ "\nReason: " + getExceptionInfo());
        }
    }

    void LoadThumbnail(const Json::Value &in json){
        if (json["thumbnail"] !is null){
            @textureBuffer = MemoryBuffer();
            textureBuffer.WriteFromBase64(json["thumbnail"]);
            @thumbnail = UI::LoadTexture(textureBuffer);
        }else{
            RequestThumbnail(true);
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
        RequestThumbnail();
    }

    void RequestThumbnail(bool delay = false){
        API::NetworkCallback@ cb = API::NetworkCallback(ThumbnailRecieved);
        API::NetRequest@ request = API::NetRequest("https://"+MX_URL+"/mapthumb/" + mapInfo.MapId, cb);
        if (delay) request.delayMS = 4000 * seriesIndex; //this is just a hacky way to not ddos tmx without adding a ton to this project i rly just wanna be doneaaaaaaaaa
        if (socket.NotDisconnected())startnew(API::GetAsyncImg, request);
    }

    void ThumbnailRecieved(Net::HttpRequest@ request){
        if (request.ResponseCode() == 200){
            MemoryBuffer@ ogBuffer = request.Buffer();
            print(ogBuffer.GetSize());
            @textureBuffer = ogBuffer;
            @thumbnail = UI::LoadTexture(textureBuffer);
            print(thumbnail.GetSize());
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

    void Discount(){
        personalBestDiscountTime += GetDiscountAmount();
        saveData.items.discountsUsed += 1;

        UpdateCheckFlags();
        saveFile.Save(saveData);
    }

    int GetPBTime(){
        if (personalBestTime < 30000000){
            return personalBestTime - personalBestDiscountTime;
        }else{
            return 30000000;
        }
    }

    int GetDiscountAmount(){
        return int(Math::Round(float(targetTime)*DISCOUNT_PERCENT));
    }

    void UpdateCheckFlags(){
        if ((GetPBTime() <= mapInfo.BronzeTime || skipped) && saveData.settings.DoingBronze()){
            data.locations.FlagCheck(seriesIndex, mapIndex, CheckTypes::Bronze);
        }
        if ((GetPBTime() <= mapInfo.SilverTime || skipped) && saveData.settings.DoingSilver()){
            data.locations.FlagCheck(seriesIndex, mapIndex, CheckTypes::Silver);
        }
        if ((GetPBTime() <= mapInfo.GoldTime || skipped) && saveData.settings.DoingGold()){
            data.locations.FlagCheck(seriesIndex, mapIndex, CheckTypes::Gold);
        }
        if ((GetPBTime() <= mapInfo.AuthorTime || skipped) && saveData.settings.DoingAuthor()){
            data.locations.FlagCheck(seriesIndex, mapIndex, CheckTypes::Author);
        }
        if ((GetPBTime() <= targetTime || skipped)){
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
            json["personalBestDiscountTime"] = personalBestDiscountTime;
            json["mapInfo"] = mapInfo.ToJson();
            json["skipped"] = skipped? "true" : "false";
            Json::Value@ itemArray = Json::Array();
            for (uint i = 0; i < itemTypes.Length; i++) {
                itemArray.Add(int(itemTypes[i]));
            }
            json["itemTypes"] = itemArray;
            if (false && textureBuffer !is null && textureBuffer.GetSize() > 0 && !saveData.hasGoal){
                textureBuffer.Seek(0);
                json["thumbnail"] = textureBuffer.ReadToBase64(textureBuffer.GetSize());
            }
        } catch {
            Log::Error("Error converting MapState to JSON for Series "+seriesIndex+" Map "+mapIndex  + "\n" +getExceptionInfo());
        }
        return json;
    }
}