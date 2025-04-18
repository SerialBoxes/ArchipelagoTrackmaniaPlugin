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
    int medalCount = GetProgressionMedalCount();
    for (int i = 0; i < world.length; i++){
        if (world[0].medalRequirement <= medalCount){
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
    if (oldPb == 0) oldPb = 30000000;
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

void AddItem(int itemID, itemCount = 1){
    switch (itemID){
        case 24000:
            data.items.bronzeMedals += itemCount;
            break;
        case 24001:
            data.items.silverMedals += itemCount;
            break;
        case 24002:
            data.items.goldMedals += itemCount;
            break;
        case 24003:
            data.items.authorMedals += itemCount;
            break;
        case 24004:
            data.items.skips += itemCount;
            break;
        case 24005:
            data.items.filler += itemCount;
            break;

        data.items.itemsRecieved += itemCount;
        
        InitializeUpcomingSeries();
    }
}

void InitializeUpcomingSeries(){
    int currentSeries = GetLatestUnlockedSeries();
    if (!world[currentSeries].initialized){
        //this should never happen monkaS!!!!
        world[currentSeries].Initialize();
    }
    if (currentSeries+1 < world.Length && !world[currentSeries+1].initialized){
        world[currentSeries+1].Initialize();
    }
}