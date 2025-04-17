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

void UpdatePBOnLoadedMap(int raceTime){
    loadedMap.personalBestTime = raceTime;
    //todo: fire off location checks
}

void AddItem(const string &in item, itemCount = 1){
    
}