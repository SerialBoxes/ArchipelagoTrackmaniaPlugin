
int MapIndicesToId(int seriesI, int mapI, CheckTypes checkType){
    int mapBase = BASE_ID + seriesI * (MAX_MAP_LOCATIONS * MAX_MAPS_IN_SERIES) + mapI * (MAX_MAP_LOCATIONS);
    return mapBase + int(checkType);
}

vec3 MapIdToIndices(int id){
    int num = id - BASE_ID;
    int series = num / (MAX_MAP_LOCATIONS * MAX_MAPS_IN_SERIES);
    int map = (num % (MAX_MAP_LOCATIONS * MAX_MAPS_IN_SERIES)) / MAX_MAP_LOCATIONS; 
    int check = num % MAX_MAP_LOCATIONS;
    return vec3(series, map, check);
}

string StripArchipelagoColorCodes(const string &in message){
    bool inCode = false;
    string result = "";
    for (int i = 0; i < message.Length; i++){
        string char = message.SubStr(i,1);
        if (char == ""){
            if (i+1 < message.Length && message.SubStr(i+1,1) =="["){
                inCode = true;
            }
        }
        if (!inCode){
            result += char;
        }else{
            if (char == "m"){
                inCode = false;
            }
        }
    }
    return result;
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