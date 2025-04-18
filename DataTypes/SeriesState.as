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
        int checksPerMap = int(Math::Round(targetTimeSetting - Math::Floor(targetTimeSetting))) + 2;
        array<int> ids = array<int>(checksPerMap * mapCount);
        int index = 0;
        for(int i = 0; i < mapCount; i++){
            string URL = BuildRandomMapQueryURL();
            MapInfo@ mapRoll = QueryForRandomMap(URL);
            maps[i] = MapState(mapRoll, targetTimeSetting, seriesIndex, i);

            int bronzeId = GetLocationID(seriesIndex, i, CheckTypes::Bronze);
            ids[index] = bronzeId;
            index++;
            for (int i = 1; i < checksPerMap-1; i++){
                ids[index] = bronzeId + i;
                index++;
            }
            ids[index] = GetLocationID(seriesIndex, i, CheckTypes::Target);
            index++;
        }
        //SendLocationScouts(ids, index);
        initialized = true;
    }

}