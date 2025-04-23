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
    bool tagsOverride;

    //create new save data from scratch
    SaveData(const string &in seedName, int teamIndex, int playerTeamIndex, YamlSettings@ settings){
        this.seedName = seedName;
        this.teamIndex = teamIndex;
        this.playerTeamIndex = playerTeamIndex;
        @this.settings = settings;

        @this.items = Items(this);

        hasGoal = false;
        tagsOverride = false;

        world = array<SeriesState@>(settings.seriesCount);
        for (uint i = 0; i < world.Length; i++){
            @world[i] = SeriesState(this, settings.medalRequirement * i, settings.mapsInSeries,i);
        }
    }

    //load a save file from disk
    SaveData(const string &in seedName, int teamIndex, int playerTeamIndex, const Json::Value &in json){
        this.seedName = seedName;
        this.teamIndex = teamIndex;
        this.playerTeamIndex = playerTeamIndex;

        try {
            @this.settings = YamlSettings(json["settings"]);
            @this.items = Items(this, json["items"]);
            hasGoal = json["hasGoal"] == "true" ? true : false;
            tagsOverride = json["tagsOverride"] == "true" ? true : false;

            const Json::Value@ worldObjects = json["world"];
            world = array<SeriesState@>(worldObjects.Length); //check me toooooo
            for (uint i = 0; i < worldObjects.Length; i++) {
                @world[i] = SeriesState(this, worldObjects[i], i);
            }
        } catch {
            Log::Warn("Error parsing save data" "\nReason: " + getExceptionInfo(), true);
        }
    }

    MapState@ GetMap(int seriesIndex, int mapIndex){
        return world[seriesIndex].maps[mapIndex];
    }
    

    int LatestUnlockedSeriesI(){
        int index = 0;
        int medalCount = items.GetProgressionMedalCount();
        for (uint i = 0; i < world.Length; i++){
            if (world[i].IsUnlocked()){
                index = i;
            }else{
                break;
            }
        }
        return index;
    }

    void InitializeUpcomingSeries(){
        startnew(CoroutineFunc(InitializeUpcomingSeriesAsync));
    }

    private void InitializeUpcomingSeriesAsync(){
        uint currentSeries = data.LatestUnlockedSeriesI();
        print ("Last Unlocked Series: " + currentSeries);

        //wait for first series to finish so the game starts faster
        while (world[0].initializing){
            yield();
        }

        //initialize everything up to and including the next series
        for (uint i = 0; (i <= currentSeries && i < world.Length); i++){
            if (!world[i].initialized && !world[i].initializing){
                startnew(CoroutineFunc(world[i].Initialize));
            }
        }

        //this feels so wrong to put here
        //i dont want to put it here
        //but i cant figure out the syntax to make a callback in angelscript to save me bones so ;-;
        saveFile.Save(this);
    }

    Json::Value ToJson(){
        Json::Value json = Json::Object();
        try {
            json["hasGoal"] = hasGoal? "true" : "false";
            json["tagsOverride"] = tagsOverride? "true" : "false";
            json["settings"] = settings.ToJson();
            json["items"] = items.ToJson();
            Json::Value seriesArray = Json::Array();
            for (uint i = 0; i < world.Length; i++) {
                seriesArray.Add(world[i].ToJson());
            }
            json["world"] = seriesArray;
        } catch {
            Log::Error("Error converting Save Data to JSON", true);
        }
        return json;
    }


}