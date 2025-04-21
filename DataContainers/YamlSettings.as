class YamlSettings{
    float targetTimeSetting;
    int seriesCount;
    int mapsInSeries;
    int medalRequirement;
    array<string> tags;
    bool tagsInclusive;
    array<string> etags;

    YamlSettings(){
        targetTimeSetting = 0.0;
        seriesCount = 0;
        mapsInSeries = 0;
        medalRequirement = 0;
        tags = array<string>(0);
        tagsInclusive = false;
        etags = array<string>(0);
    }

    YamlSettings(const Json::Value &in json){
        try {
            targetTimeSetting = json["targetTimeSetting"];
            seriesCount = json["seriesCount"];
            mapsInSeries = json["mapsInSeries"];
            medalRequirement = json["medalRequirement"];
            tagsInclusive = json["tagsInclusive"] == "true" ? true : false;

            const Json::Value@ tagObjects = json["tags"];
            tags = array<string>(tagObjects.Length); //check me toooooo
            for (uint i = 0; i < tagObjects.Length; i++) {
                tags[i] = tagObjects[i];
            }

            const Json::Value@ etagObjects = json["etags"];
            etags = array<string>(etagObjects.Length); //check me toooooo
            for (uint i = 0; i < etagObjects.Length; i++) {
                etags[i] = etagObjects[i];
            }
        } catch {
            Log::Warn("Error parsing YamlSettings"+ "\nReason: " + getExceptionInfo(), true);
        }
    }

    Json::Value ToJson(){
        Json::Value json = Json::Object();
        try {
            json["targetTimeSetting"] = targetTimeSetting;
            json["seriesCount"] = seriesCount;
            json["mapsInSeries"] = mapsInSeries;
            json["medalRequirement"] = medalRequirement;
            json["tagsInclusive"] = tagsInclusive? "true" : "false";
            Json::Value tagsArray = Json::Array();
            for (uint i = 0; i < tags.Length; i++) {
                tagsArray.Add(tags[i]);
            }
            json["tags"] = tagsArray;
            Json::Value etagsArray = Json::Array();
            for (uint i = 0; i < etags.Length; i++) {
                etagsArray.Add(etags[i]);
            }
            json["tags"] = etagsArray;
        } catch {
            Log::Error("Error converting Yaml Settings to JSON", true);
        }
        return json;
    }
}