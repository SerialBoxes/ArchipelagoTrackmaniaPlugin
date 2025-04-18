class MapState{
    int targetTime;
    int personalBestTime;
    MapInfo@ mapInfo;
    array<ItemTypes> itemTypes;//type of item in each of the 5 slots for a map. might not all be populated.

    //derived data
    int seriesIndex;
    int mapIndex;

    MapState(MapInfo@ mapInfo, float targetTimeSetting, int seriesIndex, int mapIndex){
        @this.mapInfo = mapInfo;
        this.targetTime = CalculateTargetTime(targetTimeSetting);
        itemTypes = new array<ItemTypes>(5);
    }

    private int CalculateTargetTime(float targetTimeSetting){
        int medalI = int(Math::Floor(targetTimeSetting));
        int nextMedalI = medalI + 1;
        float factor = targetTimeSetting - Math::Floor(targetTimeSetting);//no frac function imma cry ;-;
        array<int> medalTimes = {mapInfo.BronzeTime, mapInfo.SilverTime, mapInfo.GoldTime, mapInfo.AuthorTime, mapInfo.AuthorTime};
        float interpolatedTime = Math::Lerp(medalTimes[medalI],medalTimes[nextMedalI], factor);
        return int(Math::Round(interpolatedTime));
    }

    void SetItemType(ItemTypes itemType, CheckTypes checkLocation){
        itemTypes[int(checkLocation)] = itemType;
    }

    
}