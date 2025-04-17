class SeriesState{
    int medalRequirement; // progression medals required to unlock
    int mapCount; // maps in the series
    array<MapState@> maps;
    bool initialized;

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
    }

    void Initialize(){
        if (initialized) return;
        for(int i = 0; i < mapCount; i++){
            string URL = BuildRandomMapQueryURL();
            MapInfo@ mapRoll = QueryForRandomMap(URL);
            maps[i] = MapState(mapRoll, targetTimeSetting, seriesIndex, i);
        }
        initialized = true;
    }

}