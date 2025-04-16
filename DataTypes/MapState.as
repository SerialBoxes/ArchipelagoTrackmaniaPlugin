class MapState{
    int targetTime;
    int personalBestTime;
    MapInfo@ mapInfo;

    MapState(MapInfo@ mapInfo, float targetTimeSetting){
        @this.mapInfo = mapInfo;
        this.targetTime = CalculateTargetTime(targetTimeSetting);
    }

    private int CalculateTargetTime(float targetTimeSetting){
        int medalI = int(Math::Floor(targetTimeSetting));
        int nextMedalI = medalI + 1;
        float factor = targetTimeSetting - Math::Floor(targetTimeSetting);//no frac function imma cry ;-;
        array<int> medalTimes = {mapInfo.BronzeTime, mapInfo.SilverTime, mapInfo.GoldTime, mapInfo.AuthorTime, mapInfo.AuthorTime};
        float interpolatedTime = Math::Lerp(medalTimes[medalI],medalTimes[nextMedalI], factor);
        return int(Math::Round(interpolatedTime));
    }
}