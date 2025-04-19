class SeriesState{
    int medalRequirement; // progression medals required to unlock
    int mapCount; // maps in the series
    array<MapState@> maps;
    bool initialized;
    bool initializing;

    //derived data
    float targetTimeSetting;
    int seriesIndex;

    SeriesState(int medalRequirement, int mapCount, float targetTimeSetting, int seriesIndex){
        this.medalRequirement = medalRequirement;
        this.mapCount = mapCount;
        this.targetTimeSetting = targetTimeSetting;
        this.seriesIndex = seriesIndex;
        maps = array<MapState@>(mapCount);
        initialized = false;
        initializing = false;
    }

    void Initialize(){
        if (initialized) return;
        initializing = true;
        int checksPerMap = int(Math::Round(targetTimeSetting - Math::Floor(targetTimeSetting))) + 2;
        array<int> ids = array<int>(checksPerMap * mapCount);
        int index = 0;
        for(int i = 0; i < mapCount; i++){
            string URL = BuildRandomMapQueryURL();
            MapInfo@ mapRoll = QueryForRandomMap(URL);
            @maps[i] = MapState(mapRoll, targetTimeSetting, seriesIndex, i);

            int bronzeId = GetLocationID(seriesIndex, i, CheckTypes::Bronze);
            ids[index] = bronzeId;
            index++;
            for (int j = 1; j < checksPerMap-1; j++){
                ids[index] = bronzeId + j;
                index++;
            }
            ids[index] = GetLocationID(seriesIndex, i, CheckTypes::Target);
            index++;
        }
        //SendLocationScouts(ids, index);
        initialized = true;
        initializing = false;
    }

}