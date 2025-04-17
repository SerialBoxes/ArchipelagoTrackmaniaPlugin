class SeriesState{
    int medalRequirement; // progression medals required to unlock
    int mapCount; // maps in the series
    array<MapState@> maps;
    bool initialized;

    SeriesState(int medalRequirement, int mapCount){
        this.medalRequirement = medalRequirement;
        this.mapCount = mapCount;
        maps = array<MapState@>(mapCount);
        initialized = false;
    }

    void Initialize(float targetTimeSetting){
        for(int i = 0; i < mapCount; i++){
            string URL = BuildRandomMapQueryURL();
            MapInfo@ mapRoll = QueryForRandomMap(URL);
            maps[i] = MapState(mapRoll, targetTimeSetting);
        }
        initialized = true;
    }

}