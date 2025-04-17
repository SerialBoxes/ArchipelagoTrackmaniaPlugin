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

    //create new save data from scratch
    SaveData(const string &in seedName, int teamIndex, int playerTeamIndex, YamlSettings@ settings){
        this.seedName = seedName;
        this.teamIndex = teamIndex;
        this.playerTeamIndex = playerTeamIndex;
        @this.settings = settings;

        @this.items = Items();

        world = array<SeriesState@>(settings.seriesCount);
        for (int i = 0; i < world.length; i++){
            world[i] = new SeriesState(settings.medalRequirement * i, settings.mapCount, settings.targetTimeSetting,i);
        }

        world[0].Initialize(settings);

    }

    MapState@ GetMap(int seriesIndex, int mapIndex){
        return world[seriesIndex].maps[mapIndex];
    }


}