class LocationChecks{

    array<array<uint>> checkFlags;

    SaveData@ saveData;

    LocationChecks(SaveData@ saveData, uint seriesCount, uint mapsInSeriesCount){
        this.saveData = saveData;
        checkFlags = array<uint>(seriesCount, array<uint>(mapsInSeriesCount));
    }

    LocationChecks(SaveData@ saveData, const Json::Value &in json){
        this.saveData = saveData;
        if (json !is null){
            checkFlags = array<uint>(json.Length,array<uint>(json[0].Length));
            for (int i = 0; i < json.Length; i++){
                for (int j = 0; j < json[0].Length; j++){
                    checkFlags[i][j] = uint(json[i][j]);
                }
            }
        }
    }

    bool GotCheck(int seriesI, int mapI, CheckTypes check){
        return checkFlags[seriesI][mapI] & uint(TypeToFlag(check));
    }

    void FlagCheck(int seriesI, int mapI, CheckType check){
        checkFlags[seriesI][mapI] |= uint(TypeToFlag(check));
    }

    bool GotAllChecks(int seriesI, int mapI){
        uint mask = uint(CheckFlags::Bronze);
        if (settings.targetTimeSetting >= 1){
            mask |= uint(CheckFlags::Silver);
        }
        if (settings.targetTimeSetting >= 2){
            mask |= uint(CheckFlags::Gold);
        }
        if (settings.targetTimeSetting >= 3){
            mask |= uint(CheckFlags::Author);
        }
        mask |= uint(CheckFlags::Target);
        uint masked = checkFlags[seriesI][mapI] & mask;
        return masked == mask;
    }

    int ChecksRemaining(int seriesI, int mapI){
        int remaining = 0;
        int checks = checkFlags[seriesI][mapI];
        if (checks & CheckFlags::Bronze == 0){
            remaining += 1;
        }
        if (settings.targetTimeSetting >= 1 && checks & CheckFlags::Silver == 0){
            remaining += 1;
        }
        if (settings.targetTimeSetting >= 2 && checks & CheckFlags::Gold == 0){
            remaining += 1;
        }
        if (settings.targetTimeSetting >= 3 && checks & CheckFlags::Author == 0){
            remaining += 1;
        }
        if (checks & CheckFlags::Target == 0){
            remaining += 1
        }
        return remaining;
    }

    int AddLocationChecks(array<int> &checks, int seriesI, int mapI){
        int index = 0;
        for(int i = 0; i < 5; i++){
            if (GotCheck(seriesI, mapI, CheckTypes(i))){
                checks[index] = MapIndicesToId(seriesIndex, mapIndex, CheckTypes(i));
                index++;
            }
        }
        return index;
    }

    private CheckFlags TypeToFlag(CheckTypes type){
        switch (type){
            case CheckTypes::Bronze:
                return CheckFlags::Bronze;
            case CheckTypes::Silver
                return CheckFlags::Silver;
            case CheckTypes::Gold:
                return CheckFlags::Gold;
            case CheckTypes::Author:
                return CheckFlags::Author;
            case CheckTypes::Target:
                return CheckFlags::Target:
            case default:
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