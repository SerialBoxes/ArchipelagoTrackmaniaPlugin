class YamlSettings{
    float targetTimeSetting;
    int seriesCount;
    bool tagsInclusive;
    array<string> etags;
    array<string> difficulties;

    YamlSettings(){
        targetTimeSetting = 0.0;
        seriesCount = 0;
        tagsInclusive = false;
        etags = array<string>(0);
        difficulties = array<string>(0);
    }

    YamlSettings(const Json::Value &in json, bool isSlot = false){
        try {
            if (isSlot){
                ReadSlotData(json);            
            }else{
                ReadJsonV1_1(json);
            }
        } catch {
            Log::Warn("Error parsing YamlSettings"+ "\nReason: " + getExceptionInfo());
        }
    }

    Json::Value ToJson(){
        Json::Value json = Json::Object();
        try {
            json["targetTimeSetting"] = targetTimeSetting;
            json["seriesCount"] = seriesCount;
            json["tagsInclusive"] = tagsInclusive? "true" : "false";
            Json::Value@ etagsArray = Json::Array();
            for (uint i = 0; i < etags.Length; i++) {
                etagsArray.Add(etags[i]);
            }
            json["etags"] = etagsArray;
            Json::Value@ difficultiesArray = Json::Array();
            for (uint i = 0; i < difficulties.Length; i++) {
                difficultiesArray.Add(difficulties[i]);
            }
            json["difficulties"] = difficultiesArray;
        } catch {
            Log::Error("Error converting Yaml Settings to JSON");
        }
        return json;
    }

    void ReadSlotData(const Json::Value &in json){
        targetTimeSetting = json["TargetTimeSetting"];
        seriesCount = json["SeriesNumber"];
        tagsInclusive = json["MapTagsInclusive"] == 0 ? false : true;
        etags = FormatStringList(json["MapETags"]);
        difficulties = FormatStringList(json["Difficulties"]);
    }

    void ReadJsonV1_1(const Json::Value &in json){
        targetTimeSetting = json["targetTimeSetting"];
        seriesCount = json["seriesCount"];
        tagsInclusive = json["tagsInclusive"] == "true" ? true : false;

        const Json::Value@ etagObjects = json["etags"];
        etags = array<string>(etagObjects.Length);
        for (uint i = 0; i < etagObjects.Length; i++) {
            etags[i] = etagObjects[i];
        }

        const Json::Value@ difficultyObjects = json["difficulties"];
        difficulties = array<string>(difficultyObjects.Length);
        for (uint i = 0; i < difficultyObjects.Length; i++) {
            difficulties[i] = difficultyObjects[i];
        }
    }
}