const string PLUGIN_NAME                = "Archipelago";
const bool IS_DEV_MODE                  = Meta::IsDeveloperMode();

#if MP4

const string MX_NAME                    = "ManiaExchange";
const string SHORT_MX                   = "MX";
const string MX_COLOR_STR               = "\\$39f";
const vec4   MX_COLOR_VEC               = vec4(0.2, 0.6, 1, 1);
const string MX_URL                     = "tm.mania.exchange";
const string SUPPORTED_MAP_TYPE         = "Race";
const string ETAGS						= "20";//kacky

#elif TMNEXT

const string MX_NAME                    = "TrackmaniaExchange";
const string SHORT_MX                   = "TMX";
const string MX_COLOR_STR               = "\\$9fc";
const vec4   MX_COLOR_VEC               = vec4(0.3, 0.7, 0.4, 1);
const string MX_URL                     = "trackmania.exchange";
const string SUPPORTED_MAP_TYPE         = "TM_Race";
const string ETAGS						= "23,37,40";//Kacky, Royal, and Arena.
#endif

const int MAX_AUTHOR_TIME				        = 300000;
const int MAX_MAPS_IN_SERIES            = 20;
const int MAX_SERIES_COUNT              = 20;
const int MAX_MAP_LOCATIONS             = 5;
const int BASE_ID                       = 24000;
const int BASE_FILLER_ID                = 24500;

const array<string> MAP_FIELDS_ARRAY = {
    "MapId",
    "MapUid",
    "OnlineMapId",
    "Uploader.UserId",
    "Uploader.Name",
    "MapType",
    "UploadedAt",
    "UpdatedAt",
    "Name",
    "GbxMapName",
    "TitlePack",
    "Length",
    "Medals.Author",
    "Medals.Gold",
    "Medals.Silver",
    "Medals.Bronze",
    //"AwardCount",
    //"ServerSizeExceeded",
    "Tags",
    "Exebuild"
};
const string MAP_FIELDS = string::Join(MAP_FIELDS_ARRAY, ",");

enum CheckTypes{ //used for building location IDs
    Bronze = 0,
    Silver = 1,
    Gold = 2,
    Author = 3,
    Target = 4
}

enum CheckFlags{ //used for tracking location checks
    None = 0,
    Bronze = 1,
    Silver = 2,
    Gold = 4,
    Author = 8,
    Target = 16
}

enum ItemTypes{
    BronzeMedal = 24000,
    SilverMedal = 24001,
    GoldMedal = 24002,
    AuthorMedal = 24003,
    Skip = 24004,
    Filler = 24500,
    Archipelago = 99999
}

enum ClientStatus{
    CLIENT_UNKNOWN = 0,
    CLIENT_CONNECTED = 5,
    CLIENT_READY = 10,
    CLIENT_PLAYING = 20,
    CLIENT_GOAL = 30,
}

class PhysicsPatch{
    string exebuild;
    array<string>tags;
    PhysicsPatch(const string &in exebuild, array<string> tags){
        this.exebuild = exebuild;
        this.tags = tags;
    }
}

enum PlaygroundPageType {
    Record,
    Start,
    Pause,
    End
}

//source : https://github.com/st-AR-gazer/tm_Patch-Warner/blob/main/src/Main.as
array<PhysicsPatch@> PHYSICS_PATCHES = {
    PhysicsPatch("2022-09-30_10_13",{"Water"}), //AK4
    //PhysicsPatch("2023-11-15_11_56",{"Wood"}), //This one got an in-game fix
    PhysicsPatch("2020-12-22_13_18",{"Bumper"}),//This is according to AR I had no idea
    PhysicsPatch("2022-05-19_15_03",{"Ice","Bobsleigh"})//AK34
    //PhysicsPatch("2023-04-28_17_34",{"Ice","Bobsleigh"}) //Ice generally got faster with this update, and the changes were somewhat minor, so I'm using the first patch as the cutoff
};

dictionary TMX_DIFFICULTIES = {	
    {"Beginner",0},	
    {"Intermediate",1},	
    {"Advanced",2},	
    {"Expert",3},	
    {"Lunatic",4},
    {"Impossible",5}
};


//this is hard coded on the website anyways so may as well hard code it here and save loading time
//making these dictionarys hardcoded inlines crashes the openplanet extension, so we build them in a loop 

dictionary TMX_TAGS = {};
dictionary TM2_TAGS = {};

#if TMNEXT
dictionary GetTags(){
    return TMX_TAGS;
}
#elif MP4
dictionary GetTags(){
    return TM2_TAGS;
}
#endif

void initTags(){
    //Trackmania 2020
    TMX_TAGS["Race"]             = 1;
    TMX_TAGS["FullSpeed"]        = 2;
    TMX_TAGS["Tech"]             = 3;
    TMX_TAGS["RPG"]              = 4;
    TMX_TAGS["LOL"]              = 5;
    TMX_TAGS["Press Forward"]    = 6;
    TMX_TAGS["SpeedTech"]        = 7;
    TMX_TAGS["MultiLap"]         = 8;
    TMX_TAGS["Offroad"]          = 9;
    TMX_TAGS["Trial"]            = 10;
    TMX_TAGS["ZrT"]              = 11;
    TMX_TAGS["SpeedFun"]         = 12;
    TMX_TAGS["Competitive"]      = 13;
    TMX_TAGS["Ice"]              = 14;
    TMX_TAGS["Dirt"]             = 15;
    TMX_TAGS["Stunt"]            = 16;
    TMX_TAGS["Reactor"]          = 17;
    TMX_TAGS["Platform"]         = 18;
    TMX_TAGS["Slow Motion"]      = 19;
    TMX_TAGS["Bumper"]           = 20;
    TMX_TAGS["Fragile"]          = 21;
    TMX_TAGS["Scenery"]          = 22;
    TMX_TAGS["Kacky"]            = 23;
    TMX_TAGS["Endurance"]        = 24;
    TMX_TAGS["Mini"]             = 25;
    TMX_TAGS["Remake"]           = 26;
    TMX_TAGS["Mixed"]            = 27;
    TMX_TAGS["Nascar"]           = 28;
    TMX_TAGS["SpeedDrift"]       = 29;
    TMX_TAGS["Minigame"]         = 30;
    TMX_TAGS["Obstacle"]         = 31;
    TMX_TAGS["Transitional"]     = 32;
    TMX_TAGS["Grass"]            = 33;
    TMX_TAGS["Backwards"]        = 34;
    TMX_TAGS["EngineOff"]        = 35;
    TMX_TAGS["Signature"]        = 36;
    TMX_TAGS["Royal"]            = 37;
    TMX_TAGS["Water"]            = 38;
    TMX_TAGS["Plastic"]          = 39;
    TMX_TAGS["Arena"]            = 40;
    TMX_TAGS["Freestyle"]        = 41;
    TMX_TAGS["Educational"]      = 42;
    TMX_TAGS["Sausage"]          = 43;
    TMX_TAGS["Bobsleigh"]        = 44;
    TMX_TAGS["Pathfinding"]      = 45;
    TMX_TAGS["FlagRush"]         = 46;
    TMX_TAGS["Puzzle"]           = 47;
    TMX_TAGS["Freeblocking"]     = 48;
    TMX_TAGS["Altered Nadeo"]    = 49;
    TMX_TAGS["SnowCar"]          = 50;
    TMX_TAGS["Wood"]             = 51;
    TMX_TAGS["Underwater"]       = 52;
    TMX_TAGS["Turtle"]           = 53;
    TMX_TAGS["RallyCar"]         = 54;
    TMX_TAGS["MixedCar"]         = 55;
    TMX_TAGS["Bugslide"]         = 56;
    TMX_TAGS["Mudslide"]         = 57;
    TMX_TAGS["Moving Items"]     = 58;
    TMX_TAGS["DesertCar"]        = 59;
    TMX_TAGS["SpeedMapping"]     = 60;
    TMX_TAGS["NoBrake"]          = 61;
    TMX_TAGS["CruiseControl"]    = 62;
    TMX_TAGS["NoSteer"]          = 63;
    TMX_TAGS["RPG-Immersive"]    = 64;
    TMX_TAGS["Pipes"]            = 65;
    TMX_TAGS["Magnet"]           = 66;
    TMX_TAGS["NoGrip"]           = 67;

    //ManiaPlanet
    TM2_TAGS["Race"]             = 1;
    TM2_TAGS["FullSpeed"]        = 2; //called Fullspeed in api
    TM2_TAGS["Tech"]             = 3;
    TM2_TAGS["RPG"]              = 4;
    TM2_TAGS["LOL"]              = 5;
    TM2_TAGS["Press Forward"]    = 6;
    TM2_TAGS["SpeedTech"]        = 7; //called Speedtech in api
    TM2_TAGS["MultiLap"]         = 8; //called Multilap in api
    TM2_TAGS["Offroad"]          = 9;
    TM2_TAGS["Trial"]            = 10;
    TM2_TAGS["Mixed"]            = 11;
    TM2_TAGS["ZrT"]              = 12;
    TM2_TAGS["Nascar"]           = 13;
    TM2_TAGS["SpeedFun"]         = 14;
    TM2_TAGS["Dirt"]             = 15;
    TM2_TAGS["Stunt"]            = 16;
    TM2_TAGS["Platform"]         = 17;
    TM2_TAGS["Bumper"]           = 18;
    TM2_TAGS["Scenery"]          = 19;
    TM2_TAGS["Kacky"]            = 20;
    TM2_TAGS["Endurance"]        = 21;
    TM2_TAGS["Water"]            = 22;
    TM2_TAGS["Remake"]           = 23;
    TM2_TAGS["Mini"]             = 24;
    TM2_TAGS["SpeedDrift"]       = 25;
    TM2_TAGS["Minigame"]         = 26;
    TM2_TAGS["Obstacle"]         = 27;
    TM2_TAGS["Transitional"]     = 28;
    TM2_TAGS["Grass"]            = 29;
    TM2_TAGS["Competitive"]      = 30;
    TM2_TAGS["Ice"]              = 31;
    TM2_TAGS["Glass"]            = 32; //tm2 exclusive
    TM2_TAGS["Backwards"]        = 33;
    TM2_TAGS["EngineOff"]        = 34; //called freewheel in api
    TM2_TAGS["Signature"]        = 35;
    TM2_TAGS["Freestyle"]        = 36;
    TM2_TAGS["Wood"]             = 37;
    TM2_TAGS["Pathfinding"]      = 38;
    TM2_TAGS["Arena"]            = 39;
    TM2_TAGS["Sand"]             = 40; //tm2 exclusive
    TM2_TAGS["Cobblestone"]      = 41; //tm2 exclusive
    TM2_TAGS["Bugslide"]         = 42;
    TM2_TAGS["NoGrip"]           = 43;
    TM2_TAGS["ForceAccel"]       = 44; //tm2 exclusive
    TM2_TAGS["NoSteer"]          = 45;
    TM2_TAGS["Magnet"]           = 46;
    TM2_TAGS["SpeedMapping"]     = 47;
}
