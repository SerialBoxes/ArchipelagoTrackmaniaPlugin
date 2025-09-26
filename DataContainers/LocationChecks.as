class LocationChecks{

    array<array<uint>> checkFlags;

    SaveData@ saveData;

    LocationChecks(SaveData@ saveData, uint seriesCount){
        @this.saveData = saveData;
        checkFlags = array<array<uint>>(seriesCount, array<uint>(MAX_MAPS_IN_SERIES));
    }

    LocationChecks(SaveData@ saveData, const Json::Value &in json){
        @this.saveData = saveData;
        if (json !is null){
            checkFlags = array<array<uint>>(json.Length,array<uint>(MAX_MAPS_IN_SERIES));
            for (uint i = 0; i < json.Length; i++){
                for (uint j = 0; j < json[0].Length; j++){
                    checkFlags[i][j] = uint(json[i][j]);
                }
            }
        }
    }

    bool GotCheck(int seriesI, int mapI, CheckTypes check){
        return checkFlags[seriesI][mapI] & uint(TypeToFlag(check)) > 0;
    }

    void FlagCheck(int seriesI, int mapI, CheckTypes check){
        checkFlags[seriesI][mapI] |= uint(TypeToFlag(check));
    }

    void FlagAllChecksOfType(CheckTypes check){
        for (uint i = 0; i < checkFlags.Length; i++){
                for (uint j = 0; j < checkFlags[i].Length; j++){
                    checkFlags[i][j] |= uint(TypeToFlag(check));
                }
            }
    }

    bool GotAllChecks(int seriesI, int mapI){
        uint mask = 0;
        if (saveData.settings.DoingBronze()){
            mask |= uint(CheckFlags::Bronze);
        }
        if (saveData.settings.DoingSilver()){
            mask |= uint(CheckFlags::Silver);
        }
        if (saveData.settings.DoingGold()){
            mask |= uint(CheckFlags::Gold);
        }
        if (saveData.settings.DoingAuthor()){
            mask |= uint(CheckFlags::Author);
        }
        mask |= uint(CheckFlags::Target);
        uint masked = checkFlags[seriesI][mapI] & mask;
        return masked == mask;
    }

    CheckTypes GetNthCheck(int seriesI, int mapI, int n){
        int checkCount = 0;
        for (int i = 4; i >= 0; i--){
            if (GotCheck(seriesI, mapI, CheckTypes(i))){
                if (n == checkCount) return CheckTypes(i);
                checkCount++;
            }
        }
        return CheckTypes::Bronze;
    }

    int ChecksRemaining(int seriesI, int mapI){
        int remaining = 0;
        int checks = checkFlags[seriesI][mapI];
        if (saveData.settings.DoingBronze() && checks & CheckFlags::Bronze == 0){
            remaining += 1;
        }
        if (saveData.settings.DoingSilver() && checks & CheckFlags::Silver == 0){
            remaining += 1;
        }
        if (saveData.settings.DoingGold() && checks & CheckFlags::Gold == 0){
            remaining += 1;
        }
        if (saveData.settings.DoingAuthor() && checks & CheckFlags::Author == 0){
            remaining += 1;
        }
        if (checks & CheckFlags::Target == 0){
            remaining += 1;
        }
        return remaining;
    }

    int ChecksGotten(int seriesI, int mapI){
        int checkCount = 0;
        for (int i = 4; i >= 0; i--){
            if (GotCheck(seriesI, mapI, CheckTypes(i))){
                checkCount++;
            }
        }
        return checkCount;
    }

    int AddLocationChecks(array<int> &checks,int currentTotal, int seriesI, int mapI){
        int index = 0;
        for(int i = 0; i < 5; i++){
            if (GotCheck(seriesI, mapI, CheckTypes(i))){
                checks[currentTotal+index] = MapIndicesToId(seriesI, mapI, CheckTypes(i));
                index++;
            }
        }
        return index;
    }

    private CheckFlags TypeToFlag(CheckTypes type){
        switch (type){
            case CheckTypes::Bronze:
                return CheckFlags::Bronze;
            case CheckTypes::Silver:
                return CheckFlags::Silver;
            case CheckTypes::Gold:
                return CheckFlags::Gold;
            case CheckTypes::Author:
                return CheckFlags::Author;
            case CheckTypes::Target:
                return CheckFlags::Target;
            default:
                return CheckFlags::None;
        }
    }

    Json::Value ToJson(){
        Json::Value json = Json::Array();
        try {
            for (uint i = 0; i < checkFlags.Length; i++){
                Json::Value jsonRow = Json::Array();
                for (uint j = 0; j < checkFlags[i].Length; j++){
                    jsonRow.Add(checkFlags[i][j]);
                }
                json.Add(jsonRow);
            }
        } catch {
            Log::Error("Error converting Location Checks to JSON");
        }
        return json;
    }
}