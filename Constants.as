const string PLUGIN_NAME                = "Archipelago";
const bool IS_DEV_MODE                  = Meta::IsDeveloperMode();

#if MP4

const string MX_NAME                    = "ManiaExchange";
const string SHORT_MX                   = "MX";
const string MX_COLOR_STR               = "\\$39f";
const vec4   MX_COLOR_VEC               = vec4(0.2, 0.6, 1, 1);
const string MX_URL                     = "tm.mania.exchange";
const string SUPPORTED_MAP_TYPE         = "Race";
const string ETAGS						= "23,37,40";//Kacky, Royal, and Arena.

#elif TMNEXT

const string MX_NAME                    = "TrackmaniaExchange";
const string SHORT_MX                   = "TMX";
const string MX_COLOR_STR               = "\\$9fc";
const vec4   MX_COLOR_VEC               = vec4(0.3, 0.7, 0.4, 1);
const string MX_URL                     = "trackmania.exchange";
const string SUPPORTED_MAP_TYPE         = "TM_Race";
const string ETAGS						= "23";//kacky
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

enum CheckTypes{
    Bronze = 0,
    Silver = 1,
    Gold = 2,
    Author = 3,
    Target = 4
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
//TMX:
dictionary TMX_TAGS = {
    {"Race", 1},
    {"FullSpeed", 2},
    {"Tech", 3},
    {"RPG", 4},
    {"LOL", 5},
    {"Press Forward", 6},
    {"SpeedTech", 7},
    {"MultiLap", 8},
    {"Offroad", 9},
    {"Trial", 10},
    {"ZrT", 11},
    {"SpeedFun", 12},
    {"Competitive", 13},
    {"Ice", 14},
    {"Dirt", 15},
    {"Stunt", 16},
    {"Reactor", 17},
    {"Platform", 18},
    {"Slow Motion", 19},
    {"Bumper", 20},
    {"Fragile", 21},
    {"Scenery", 22},
    {"Kacky", 23},
    {"Endurance", 24},
    {"Mini", 25},
    {"Remake", 26},
    {"Mixed", 27},
    {"Nascar", 28},
    {"SpeedDrift", 29},
    {"Minigame", 30},
    {"Obstacle", 31},
    {"Transitional", 32},
    {"Grass", 33},
    {"Backwards", 34},
    {"EngineOff", 35},
    {"Signature", 36},
    {"Royal", 37},
    {"Water", 38},
    {"Plastic", 39},
    {"Arena", 40},
    {"Freestyle", 41},
    {"Educational", 42},
    {"Sausage", 43},
    {"Bobsleigh", 44},
    {"Pathfinding", 45},
    {"FlagRush", 46},
    {"Puzzle", 47},
    {"Freeblocking", 48},
    {"Altered Nadeo", 49},
    {"SnowCar", 50},
    {"Wood", 51},
    {"Underwater",52},
    {"Turtle", 53},
    {"RallyCar", 54},
    {"MixedCar", 55},
    {"Bugslide", 56},
    {"Mudslide", 57},
    {"Moving Items", 58},
    {"DesertCar", 59},
    {"SpeedMapping", 60},
    {"NoBrake", 61},
    {"CruiseControl", 62},
    {"NoSteer", 63},
    {"RPG-Immersive", 64},
    {"Pipes", 65},
    {"Magnet", 66},
    {"NoGrip", 67}
};


//mania exchange:
dictionary TM2_TAGS = {
    {"Race", 1},
    {"Fullspeed", 2},
    {"Tech", 3},
    {"RPG", 4},
    {"LOL", 5},
    {"Press Forward", 6},
    {"Speedtech", 7},
    {"Multilap", 8},
    {"Offroad", 9},
    {"Trial", 10},
    {"Mixed", 11},
    {"ZrT", 12},
    {"Nascar", 13},
    {"SpeedFun", 14},
    {"Dirt", 15},
    {"Stunt", 16},
    {"Platform", 17},
    {"Bumper", 18},
    {"Scenery", 19},
    {"Kacky", 20},
    {"Endurance", 21},
    {"Water", 22},
    {"Remake", 23},
    {"Mini", 24},
    {"SpeedDrift", 25},
    {"Minigame", 26},
    {"Obstacle", 27},
    {"Transitional", 28},
    {"Grass", 29},
    {"Competitive", 30},
    {"Ice", 31},
    {"Glass", 32}, //tm2 exclusive
    {"Backwards", 33},
    {"EngineOff", 34},//called freewheel in api
    {"Signature", 35},
    {"Freestyle", 36},
    {"Wood", 37},
    {"Pathfinding", 38},
    {"Arena", 39},
    {"Sand", 40}, //tm2 exclusive
    {"Cobblestone", 41}, //tm2 exclusive
    {"Bugslide", 42},
    {"NoGrip", 43},
    {"ForceAccel", 44}, //tm2 exclusive
    {"NoSteer", 45},
    {"Magnet", 46},
    {"SpeedMapping", 47}
};

#if TMNEXT
    dictionary TAGS_MAP = TMX_TAGS;
#elif MP4
    dictionary TAGS_MAP = TM2_TAGS;
#endif