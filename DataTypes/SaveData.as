class SaveData{
    string seedName;//unique id for the generation
    int teamIndex;
    int playerTeamIndex;

    //yaml settings
    YamlSettings@ settings;

    //items
    Items@ items;

    //world
    array<SeriesState@> world;

    bool hasGoal;

    //create new save data from scratch
    SaveData(const string &in seedName, int teamIndex, int playerTeamIndex, YamlSettings@ settings){
        this.seedName = seedName;
        this.teamIndex = teamIndex;
        this.playerTeamIndex = playerTeamIndex;
        @this.settings = settings;

        @this.items = Items();

        hasGoal = false;

        world = array<SeriesState@>(settings.seriesCount);
        for (uint i = 0; i < world.Length; i++){
            @world[i] = SeriesState(settings.medalRequirement * i, settings.mapsInSeries, settings.targetTimeSetting,i);
        }
    }

    MapState@ GetMap(int seriesIndex, int mapIndex){
        return world[seriesIndex].maps[mapIndex];
    }


}