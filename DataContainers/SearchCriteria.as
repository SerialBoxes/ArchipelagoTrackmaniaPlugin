class SearchCriteria {
    bool forceSafeURL = false; // Ignores all but map_tags, sets default etags

    // Default options, always present in slot_data
    string map_tags;
    string map_etags;
    string difficulties;
    bool map_tags_inclusive;

    // Advanced search parameters
    string map_ids;
    string name;
    string uploaded_after; // ISO date format
    string uploaded_before; // ISO date format
    int author;
    int map_pack;
    int min_length;
    int max_length;
    bool has_award;
    bool has_replay;

    SearchCriteria(int seriesI, const Json::Value &in json, bool fromSlotData = false) {
        try {
            if (!fromSlotData) {
                this.map_tags = json["preconverted_map_tags"];
                this.map_etags = json["preconverted_map_etags"];
                this.difficulties = json["preconverted_difficulties"];
                this.forceSafeURL = JsonGetAsBool(json, "forceSafeURL");
            }
            else {
                array<string> tag_list = JsonToStringArray(json["map_tags"]);
                this.map_tags = BuildTagIdString(tag_list);
                array<string> etag_list = JsonToStringArray(json["map_etags"]);
                this.map_etags = BuildTagIdString(etag_list);
                array<string> diff_list = JsonToStringArray(json["difficulties"]);
                this.difficulties = BuildDifficultyString(diff_list);
            }
            this.map_tags_inclusive = JsonGetAsBool(json, "map_tags_inclusive");

            // Optional advanced search parameters
            if (!fromSlotData) {
                this.map_ids = json["preconverted_map_ids"];
            }
            else if (json.HasKey("map_ids")) {
                array<string> id_list = JsonToStringArray(json["map_ids"]);
                this.map_ids = string::Join(id_list, ",");
            }
            this.name = json.Get("name", "");
            this.uploaded_after = json.Get("uploaded_after", "");
            this.uploaded_before = json.Get("uploaded_before", "");
            this.author = json.Get("author", 0);
            this.map_pack = json.Get("map_pack", 0);
            this.min_length = json.Get("min_length", 0);
            this.max_length = json.Get("max_length", 0);
            this.has_award = JsonGetAsBool(json, "has_award");
            this.has_replay = JsonGetAsBool(json, "has_replay");
        }
        catch {
            Log::Error("Error parsing SearchCriteria for Series " + seriesI + "\nReason: " + getExceptionInfo());
            this.forceSafeURL = true;
        }
    }

    Json::Value ToJson() {
        Json::Value json = Json::Object();
        try {
            json["forceSafeURL"] = this.forceSafeURL;

            json["preconverted_map_tags"] = this.map_tags;
            json["preconverted_map_etags"] = this.map_etags;
            json["preconverted_difficulties"] = this.difficulties;
            json["map_tags_inclusive"] = this.map_tags_inclusive;

            json["preconverted_map_ids"] = this.map_ids;
            json["name"] = this.name;
            json["uploaded_after"] = this.uploaded_after;
            json["uploaded_before"] = this.uploaded_before;
            json["author"] = this.author;
            json["map_pack"] = this.map_pack;
            json["min_length"] = this.min_length;
            json["max_length"] = this.max_length;
            json["has_award"] = this.has_award;
            json["has_replay"] = this.has_replay;
        }
        catch {
            Log::Warn("Error converting SearchCriteria to json");
        }

        return json;
    }

    string BuildQueryURL() {
        dictionary params;

        // Always present parameters -- either required setup, or ensuring we get compatible maps
        params.Set("fields", MAP_FIELDS); //fields that the API will return in the json object
        params.Set("random", "1");
        params.Set("count", "1");
        params.Set("maptype", SUPPORTED_MAP_TYPE);
#if MP4
        params.Set("titlepack", CurrentTitlePack());
#endif

        // Base tag search -- always present, even in safe mode
        params.Set("tag", this.map_tags);

        if (!this.forceSafeURL) {
            params.Set("etag", this.map_etags);
            params.Set("difficulty", this.difficulties);
            if (this.map_tags_inclusive)
                params.Set("taginclusive", "true");

            // Custom advanced search parameters
            params.Set("id", this.map_ids);
            params.Set("name", this.name);
            params.Set("uploadedafter", this.uploaded_after);
            params.Set("uploadedbefore", this.uploaded_before);
            if (this.author > 0)
                params.Set("authoruserid", tostring(this.author));
            if (this.map_pack > 0)
                params.Set("mappackid", tostring(this.map_pack));
            if (this.min_length > 0)
                params.Set("authortimemin", tostring(this.min_length));
            if (this.max_length > 0)
                params.Set("authortimemax", tostring(this.max_length));
            if (this.has_award)
                params.Set("inlatestawardedauthor", "1");                
            if (this.has_replay)
                params.Set("inhasreplay", "1");
        }
        else {
            // Only use default etags and no other custom search parameters
            params.Set("etag", ETAGS);
        }

        string urlParams = DictToApiParams(params);
        return "https://" + MX_URL + "/api/maps" + urlParams;
    }
}


// Extra helper functions

string BuildTagIdString(array<string> tagList){
    string result = "";

    for (uint i = 0; i < tagList.Length; i++){
        if (GetTags().Exists(tagList[i])){
            result += "" + int(GetTags()[tagList[i]]) + ",";
        }
    }

    if (result.Length > 0){
        result = result.SubStr(0, result.Length - 1);
    }

    return result;
}

string BuildDifficultyString(array<string> difficultyList){
    string result = "";

    if (difficultyList.Length > 4) {
        // Presumably an API bug, MX won't accept 5+ difficulties
        return result;
    }

    for (uint i = 0; i < difficultyList.Length; i++){
        if (TMX_DIFFICULTIES.Exists(difficultyList[i])){
            result += "" + int(TMX_DIFFICULTIES[difficultyList[i]]) + ",";
        }
    }

    if (result.Length > 0){
        result = result.SubStr(0, result.Length - 1);
    }

    return result;
}

string DictToApiParams(dictionary params) {
    string urlParams = "";
    string nextParam = "?";

    if (!params.IsEmpty()) {
        auto keys = params.GetKeys();
        for (uint i = 0; i < keys.Length; i++) {
            string key = keys[i];
            string value;
            params.Get(key, value);

            // Automatically omit empty parameters
            if (value == "")
                continue;

            urlParams += nextParam + key + "=" + Net::UrlEncode(value.Trim());
            nextParam = "&";
        }
    }

    return urlParams;
}

array<string> JsonToStringArray(const Json::Value &in json) {
    array<string> new_array = array<string>(json.Length);
    for (uint i = 0; i < json.Length; i++) {
        try {
            new_array[i] = json[i];
        }
        catch {
            int temp = json[i];
            new_array[i] = tostring(temp);
        }
    }
    return new_array;
}

bool JsonGetAsBool(const Json::Value &in json, const string &in key) {
    try {
        bool result = json.Get(key, false);
        return result;
    }
    catch {
        int result = json.Get(key, 0);
        return result != 0;
    }
}