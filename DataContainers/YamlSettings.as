class YamlSettings{
    float targetTimeSetting;
    int seriesCount;

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

    Json::Value ToJson() {
        Json::Value json = Json::Object();
        try {
            json["targetTimeSetting"] = targetTimeSetting;
            json["seriesCount"] = seriesCount;
        } catch {
            Log::Error("Error converting Yaml Settings to JSON");
        }
        return json;
    }

    void ReadSlotData(const Json::Value &in json){
        targetTimeSetting = json["TargetTimeSetting"];
        seriesCount = json["SeriesNumber"];
    }

    void ReadJsonV1_2(const Json::Value &in json){
        targetTimeSetting = json["targetTimeSetting"];
        seriesCount = json["seriesCount"];
    }
}