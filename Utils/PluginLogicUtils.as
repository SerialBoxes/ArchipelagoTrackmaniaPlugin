void LoadMap(int seriesIndex, int mapIndex){
    @loadedMap = data.GetMap(seriesIndex, mapIndex);
    if (loadedMap !is null){
        LoadMap(loadedMap.mapInfo);
    }
}

bool IsSeriesUnlocked(int seriesIndex){
    //I might have gone a bit crazy with the data structures
    return data.world[seriesIndex].medalRequirement <= data.items.GetProgressionMedalCount(data.settings.targetTimeSetting);
}

int GetLatestUnlockedSeries(){
    int index = 0;
    int medalCount = data.items.GetProgressionMedalCount(data.settings.targetTimeSetting);
    for (uint i = 0; i < data.world.Length; i++){
        if (data.world[i].medalRequirement <= medalCount){
            index = i;
        }else{
            break;
        }
    }
    return index;
}

void UpdatePBOnLoadedMap(int raceTime){
    loadedMap.personalBestTime = raceTime;
    DetermineLocationChecks(loadedMap);
}

void DetermineLocationChecks(MapState@ map){
    //resending old checks doesn't cause any issues and makes this easier, so lets do it!

    array<int> checks = array<int>(5);
    int index = 0;
    if (map.personalBestTime < map.mapInfo.BronzeTime){
        checks[index] = GetLocationID(map.seriesIndex, map.mapIndex, CheckTypes::Bronze);
        index++;
    }
    if (map.personalBestTime < map.mapInfo.SilverTime && data.settings.targetTimeSetting >= 1.0){
        checks[index] = GetLocationID(map.seriesIndex, map.mapIndex, CheckTypes::Silver);
        index++;
    }
    if (map.personalBestTime < map.mapInfo.GoldTime && data.settings.targetTimeSetting >= 2.0){
        checks[index] = GetLocationID(map.seriesIndex, map.mapIndex, CheckTypes::Gold);
        index++;
    }
    if (map.personalBestTime < map.mapInfo.AuthorTime && data.settings.targetTimeSetting >= 3.0){
        checks[index] = GetLocationID(map.seriesIndex, map.mapIndex, CheckTypes::Author);
        index++;
    }
    if (map.personalBestTime < map.targetTime){
        checks[index] = GetLocationID(map.seriesIndex, map.mapIndex, CheckTypes::Target);
        index++;
    }
    SendLocationChecks(checks, index);
}

int GetLocationID(int seriesI, int mapI, CheckTypes checkType){
    int base = 24000;
    int mapBase = base + seriesI * (5*20) + mapI * (5);
    return mapBase + int(checkType);
}

vec3 GetMapIndicesFromId(int id){
    id = id - 24000;
    int series = id / (20*5);
    int map = (id % 20*5) / 5; 
    int check = id % 5;
    return vec3(series, map, check);
}

void AddItem (int itemID, int itemCount = 1) {
    switch (itemID){
        case ItemTypes::BronzeMedal:
            data.items.bronzeMedals += itemCount;
            break;
        case ItemTypes::SilverMedal:
            data.items.silverMedals += itemCount;
            break;
        case ItemTypes::GoldMedal:
            data.items.goldMedals += itemCount;
            break;
        case ItemTypes::AuthorMedal:
            data.items.authorMedals += itemCount;
            break;
        case ItemTypes::Skip:
            data.items.skips += itemCount;
            break;
        case ItemTypes::Filler:
            data.items.filler += itemCount;
            break;
        default:
            return;
    }
    data.items.itemsRecieved += itemCount;

    if (!data.hasGoal && data.items.GetProgressionMedalCount(data.settings.targetTimeSetting) >= data.settings.medalRequirement * data.settings.seriesCount){
        SendStatusUpdate(ClientStatus::CLIENT_GOAL);
        data.hasGoal = true;
    }
    
    if (data.world[0].initialized)
        InitializeUpcomingSeries();
}

void InitializeUpcomingSeries(){
    uint currentSeries = GetLatestUnlockedSeries();
    print ("Last Unlocked Series: " + currentSeries);
    if (!data.world[currentSeries].initialized && !data.world[currentSeries].initializing){
        //this should never happen monkaS!!!!
        startnew(CoroutineFunc(data.world[currentSeries].Initialize));
    }
    if (currentSeries+1 < data.world.Length && !data.world[currentSeries+1].initialized && !data.world[currentSeries+1].initializing){
        startnew(CoroutineFunc(data.world[currentSeries+1].Initialize));
    }
}

void RerollMap(int seriesI, int mapI){
    MapState@ mapState = data.world[seriesI].maps[mapI];
    string URL = BuildRandomMapQueryURL();
    MapInfo@ mapRoll = QueryForRandomMap(URL);
    mapState.ReplaceMap(mapRoll, data.settings.targetTimeSetting);
    if (loadedMap.seriesIndex == seriesI && loadedMap.mapIndex == mapI){
        LoadMap(mapRoll);
    }
}

void SkipMap(MapState@ map){
    map.skipped = true;
    data.items.skipsUsed += 1;

    array<int> checks = array<int>(5);
    int index = 0;
    checks[index] = GetLocationID(map.seriesIndex, map.mapIndex, CheckTypes::Bronze);
    index++;
    if (data.settings.targetTimeSetting >= 1.0){
        checks[index] = GetLocationID(map.seriesIndex, map.mapIndex, CheckTypes::Silver);
        index++;
    }
    if (data.settings.targetTimeSetting >= 2.0){
        checks[index] = GetLocationID(map.seriesIndex, map.mapIndex, CheckTypes::Gold);
        index++;
    }
    if (data.settings.targetTimeSetting >= 3.0){
        checks[index] = GetLocationID(map.seriesIndex, map.mapIndex, CheckTypes::Author);
        index++;
    }
    checks[index] = GetLocationID(map.seriesIndex, map.mapIndex, CheckTypes::Target);
    index++;
    SendLocationChecks(checks, index);
}

array<string> GetMapTags(const string &in bla){
    Json::Value@ json = Json::Parse(bla);
    array<string> tags = array<string>(json.Length);
    for (uint i = 0; i < json.Length; i++){
        tags[i] = json[i];
    }
    return tags;
}