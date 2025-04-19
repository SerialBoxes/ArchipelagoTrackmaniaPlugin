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

const int MAX_AUTHOR_TIME				= 300000;

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
	Filler = 24005,
	Archipelago = 99999
}

enum ClientStatus{
    CLIENT_UNKNOWN = 0,
    CLIENT_CONNECTED = 5,
    CLIENT_READY = 10,
    CLIENT_PLAYING = 20,
    CLIENT_GOAL = 30,
}