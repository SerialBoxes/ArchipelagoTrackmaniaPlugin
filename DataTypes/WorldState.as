class WorldState{
    //ids
    int apGameId;//some unique identifier for an ap server
    int playerId;//identify the player/slot in some way
    //settings. these might need to be pulled from the yaml
    int trackCount;
    float targetTimeSetting;


    //state
    int completedTracks;
    private MX::MapInfo@ currentMap;
    private Items@ recievedItems;
    private array<TrackCheck@> trackChecks;

    //derived data cache
    int targetTime;

    WorldState(int apGameId, int playerId, int trackCount, float targetTimeSetting){
        this.apGameId = apGameId;
        this.playerId = playerId;
        this.trackCount = trackCount;
        this.targetTimeSetting = Math::Clamp(targetTimeSetting,0.0,3.0);

        completedTracks = 0;
        @currentMap = null;
        @recievedItems = Items();
        trackChecks = array<TrackCheck@>(trackCount);
        this.targetTime = -1;
    }

    void SetMap(MX::MapInfo@ newMap){
        @currentMap = newMap;
        print(currentMap.Name);
        targetTime = CalcTargetTime();
    }

    MX::MapInfo@ GetMap(){
        return currentMap;
    }

    TrackCheck@ GetTrackChecks(int trackI){
        return trackChecks[trackI];
    }

    void UpdateChecksForNewTime(int raceTime){
        if (raceTime < 0) return;
        TrackCheck@ track = trackChecks[completedTracks];
        if (track is null){
            @track = TrackCheck();
            @trackChecks[completedTracks] = track;
        }
        if (!track.bronzeTarget && raceTime < currentMap.BronzeTime) {
            track.bronzeTarget = true;
        }
        if (!track.silverTarget && raceTime < currentMap.SilverTime) {
            track.silverTarget = true;
        }
        if (!track.goldTarget && raceTime < currentMap.GoldTime) {
            track.goldTarget = true;
        }
        if (!track.authorTarget && raceTime < currentMap.AuthorTime) {
            track.authorTarget = true;
        }
    }

    int CalcTargetTime(){
        int medalI = int(Math::Floor(targetTimeSetting));
        int nextMedalI = medalI + 1;
        float factor = targetTimeSetting - Math::Floor(targetTimeSetting);//no frac function imma cry ;-;
        array<int> medalTimes = {currentMap.BronzeTime, currentMap.SilverTime, currentMap.GoldTime, currentMap.AuthorTime, currentMap.AuthorTime};
        float interpolatedTime = Math::Lerp(medalTimes[medalI],medalTimes[nextMedalI], factor);
        return int(Math::Round(interpolatedTime));
    }
}