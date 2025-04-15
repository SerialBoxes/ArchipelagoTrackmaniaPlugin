class Checks{
    array<TrackCheck@> trackChecks;

    Checks(int totalTracks){
        trackChecks = array<TrackCheck@>(totalTracks);
    }
}

class TrackCheck{
    bool bronzeTarget;
    bool silverTarget;
    bool goldTarget;
    bool authorTarget;

    TrackCheck(){
        bronzeTarget = false;
        silverTarget = false;
        goldTarget = false;
        authorTarget = false;
    }  
}