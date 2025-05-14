class YamlSettings{
    float targetTimeSetting;
    int seriesCount;
    bool bronzeDisabled;
    bool silverDisabled;
    bool goldDisabled;
    bool authorDisabled;

    YamlSettings() {
        targetTimeSetting = 0.0;
        seriesCount = 0;
    }

    YamlSettings(const Json::Value &in json, bool isSlot = false) {
        try {
            if (isSlot){
                ReadSlotData(json);            
            }else{
                ReadJsonV1_2(json);
            }
        } catch {
            Log::Warn("Error parsing YamlSettings"+ "\nReason: " + getExceptionInfo());
        }
    }

    bool DoingBronze(){
        return !bronzeDisabled;
    }

    bool DoingSilver(){
        return targetTimeSetting >= 1 && !silverDisabled;
    }

    bool DoingGold(){
        return targetTimeSetting >= 2 && !goldDisabled;
    }

    bool DoingAuthor(){
        return targetTimeSetting >= 3 && !authorDisabled;
    }

    Json::Value ToJson() {
        Json::Value json = Json::Object();
        try {
            json["targetTimeSetting"] = targetTimeSetting;
            json["seriesCount"] = seriesCount;
            json["bronzeDisabled"] = bronzeDisabled;
            json["silverDisabled"] = silverDisabled;
            json["goldDisabled"] = goldDisabled;
            json["authorDisabled"] = authorDisabled;
        } catch {
            Log::Error("Error converting Yaml Settings to JSON");
        }
        return json;
    }

    void ReadSlotData(const Json::Value &in json){
        targetTimeSetting = json["TargetTimeSetting"];
        seriesCount = json["SeriesNumber"];
        bronzeDisabled = JsonGetAsBool(json, "DisableBronze");
        silverDisabled = JsonGetAsBool(json, "DisableSilver");
        goldDisabled = JsonGetAsBool(json, "DisableGold");
        authorDisabled = JsonGetAsBool(json, "DisableAuthor");
    }

    void ReadJsonV1_2(const Json::Value &in json){
        targetTimeSetting = json["targetTimeSetting"];
        seriesCount = json["seriesCount"];
        bronzeDisabled = JsonGetAsBool(json, "bronzeDisabled");
        silverDisabled = JsonGetAsBool(json, "silverDisabled");
        goldDisabled = JsonGetAsBool(json, "goldDisabled");
        authorDisabled = JsonGetAsBool(json, "authorDisabled");
    }
}