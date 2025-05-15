class SaveData{
    string seedName;//unique id for the generation
    int teamIndex;
    int playerTeamIndex;

    //yaml settings
    YamlSettings@ settings;

    //items
    Items@ items;

    //locations
    LocationChecks@ locations;

    //world
    array<SeriesState@> world;
    int victoryRequirement;

    // stored as a dictionary because checking if key exists should be O(1)
    dictionary previouslySeenMaps;

    bool hasGoal;
    // tagsOverride -> world[i].searchBuilder.forceSafeURL (per series, not global)

    //load a save file from disk
    SaveData(const string &in seedName, int teamIndex, int playerTeamIndex, const Json::Value &in json, bool isSlot = false){
        this.seedName = seedName;
        this.teamIndex = teamIndex;
        this.playerTeamIndex = playerTeamIndex;

        try {
            if (isSlot){
                @this.settings = YamlSettings(json, true);
                @this.items = Items(this);
                @this.locations = LocationChecks(this, settings.seriesCount);
                hasGoal = false;

                Json::Value seriesData = json["SeriesData"];
                victoryRequirement = 0;
                world = array<SeriesState@>(seriesData.Length);
                for (uint i = 0; i < world.Length; i++){
                    @world[i] = SeriesState(this, seriesData[i], i,victoryRequirement, true);
                    victoryRequirement += world[i].medalTotal;
                }
            }else{
                if (json["version"] is null || json["version"] != 1.2){
                    Log::Error("Outdated save file not supported in this plugin version");
                    socket.Close();
                    return;
                }else if (json["version"] == 1.2){
                    ReadJsonV1_2(json);
                }
            }
        } catch {
           Log::Error("Error parsing save data" "\nReason: " + getExceptionInfo(), true);
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
            json["settings"] = settings.ToJson();
            json["items"] = items.ToJson();
            json["locations"] = locations.ToJson();

            Json::Value seriesArray = Json::Array();
            for (uint i = 0; i < world.Length; i++) {
                seriesArray.Add(world[i].ToJson());
            }
            json["world"] = seriesArray;

            Json::Value mapsArray = Json::Array();
            auto mapsKeys = previouslySeenMaps.GetKeys();
            for (uint i = 0; i < mapsKeys.Length; i++) {
                mapsArray.Add(mapsKeys[i]);
            }
            json["previouslySeenMaps"] = mapsArray;
        } catch {
            Log::Error("Error converting Save Data to JSON", true);
        }
        return json;
    }

    void ReadJsonV1_2(const Json::Value &in json){
        hasGoal = json["hasGoal"] == "true" ? true : false;
        @this.settings = YamlSettings(json["settings"]);
        @this.items = Items(this, json["items"]);
        @this.locations = LocationChecks(this,json["locations"]);

        const Json::Value@ worldObjects = json["world"];
        victoryRequirement = 0;
        world = array<SeriesState@>(worldObjects.Length);
        for (uint i = 0; i < worldObjects.Length; i++) {
            @world[i] = SeriesState(this, worldObjects[i], i, victoryRequirement);
            victoryRequirement += world[i].medalTotal;
        }

        const Json::Value@ mapsSeen = json["previouslySeenMaps"];
        for (uint i = 0; i < mapsSeen.Length; i++) {
            previouslySeenMaps.Set(mapsSeen[i], true);
        }
    }


}