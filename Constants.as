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

/**
 * TCP opcodes.
 * These will be used in the TCPLink client to denote message types to the server
 *
 */
 enum TCPMessageTypes{
	CODE_TEXT_FIN = 129,           // (10000001) - Text frame with FIN bit set (use this for single-fragment text messages)
	CODE_CONTINUATION = 0,         // (00000000) - Continuation frame
	CODE_PING = 137,               // (10001001) - Ping
	CODE_PONG = 138,               // (10001010) - Pong
	CODE_TEXT = 1,                 // (00000001) - Text frame (use CODE_CONTINUATION to continue a text message)
    CODE_CONTINUATION_FIN = 128    // (10000000) - Continuation frame with FIN bit set (ends a multi-fragment message)
 }