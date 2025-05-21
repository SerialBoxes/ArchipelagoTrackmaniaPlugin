UI::Font@ fontHuge;
UI::Font@ fontHeader;
UI::Font@ fontHeaderSub;
UI::Font@ fontTime;
int NvgFont;

UI::Texture@ bronzeTex;
UI::Texture@ silverTex;
UI::Texture@ goldTex;
UI::Texture@ authorTex;
UI::Texture@ archipelagoTex;

Audio::Sample@ victoryClip;

//jeepers
nvg::Texture@ bronzeTexNVG;
nvg::Texture@ silverTexNVG;
nvg::Texture@ goldTexNVG;
nvg::Texture@ authorTexNVG;
nvg::Texture@ archipelagoTexNVG;

#if TMNEXT
nvg::Texture@ bronzeTexNVGSmol;
nvg::Texture@ silverTexNVGSmol;
nvg::Texture@ goldTexNVGSmol;
nvg::Texture@ authorTexNVGSmol;
nvg::Texture@ archipelagoTexNVGSmol;
nvg::Texture@ shadowTexNVG;
nvg::Texture@ bronzeTexNVGMed;
nvg::Texture@ silverTexNVGMed;
nvg::Texture@ goldTexNVGMed;
nvg::Texture@ authorTexNVGMed;
nvg::Texture@ archipelagoTexNVGMed;

#elif MP4
nvg::Texture@ bronzeTexNVGBowTie;
nvg::Texture@ silverTexNVGBowTie;
nvg::Texture@ goldTexNVGBowTie;
nvg::Texture@ authorTexNVGBowTie;
nvg::Texture@ archipelagoTexNVGBowTie;
nvg::Texture@ bronzeTexNVGBottom;
nvg::Texture@ silverTexNVGBottom;
nvg::Texture@ goldTexNVGBottom;
nvg::Texture@ authorTexNVGBottom;
nvg::Texture@ archipelagoTexNVGBottom;
#endif

void RenderInventory(){
    UI::Text("Progression Medals: " + data.items.GetProgressionMedalCount() + "/"+(data.victoryRequirement));
    UI::Text("Inventory: ");
    UI::BeginTable("Inventory", 5);
    UI::TableNextColumn();
    UI::Text("Bronzes: " + data.items.bronzeMedals);
    UI::TableNextColumn();
    UI::Text("Silvers: " + data.items.silverMedals);
    UI::TableNextColumn();
    UI::Text("Golds: " + data.items.goldMedals);
    UI::TableNextColumn();
    UI::Text("Authors: " + data.items.authorMedals);
    UI::TableNextColumn();
    UI::Text("Skips: " + (data.items.skips-data.items.skipsUsed)+"/"+data.items.skips);
    UI::EndTable();
}

void RenderMedalProgress(UI::Texture@ tex, float size, int count, int total){
    float texSize = size;
    UI::Image(tex,vec2(texSize,texSize));
    UI::SameLine();
    UI::PushFont(fontHeaderSub);
    MoveCursor(vec2(0.0,texSize*0.5-11));
    UI::Text(""+count+"/"+total);
    UI::PopFont();
}

void RenderTextCentered(const string &in text, UI::Font@ font){
    vec2 size = Draw::MeasureString(text, font);
    if (font !is null) size = Draw::MeasureString(text, font,30);
    MoveCursor(size/-2);
    if (font !is null) UI::PushFont(font);
    UI::Text(text);
    if (font !is null) UI::PopFont();
    MoveCursor(size/2);
}

void MoveCursor(vec2 offset){
    vec2 curs = UI::GetCursorPos();
    curs += offset;
    UI::SetCursorPos(curs);
}

UI::Texture@ GetProgressionTex(){
    float timeSetting = data.settings.targetTimeSetting;
    if (timeSetting < 1){
        return bronzeTex;
    }else if (timeSetting < 2){
        return silverTex;
    }else if (timeSetting < 3){
        return goldTex;
    }else{
        return authorTex;
    }
}

#if TMNEXT
nvg::Texture@ GetNthSmolTex(ItemTypes type){
    switch (type){
        case ItemTypes::BronzeMedal:
            return bronzeTexNVGSmol;
        case ItemTypes::SilverMedal:
            return silverTexNVGSmol;
        case ItemTypes::GoldMedal:
            return goldTexNVGSmol;
        case ItemTypes::AuthorMedal:
            return authorTexNVGSmol;
        case ItemTypes::Archipelago:
            return archipelagoTexNVGSmol;
        case ItemTypes::Skip:
            return archipelagoTexNVGSmol;
        case ItemTypes::Discount:
            return archipelagoTexNVGSmol;
        case ItemTypes::Trap:
            return archipelagoTexNVGSmol;
        case ItemTypes::Filler:
            return archipelagoTexNVGSmol;
        default:
            return archipelagoTexNVGSmol;
    }
}

nvg::Texture@ GetNthMedTex(ItemTypes type){
    switch (type){
        case ItemTypes::BronzeMedal:
            return bronzeTexNVGMed;
        case ItemTypes::SilverMedal:
            return silverTexNVGMed;
        case ItemTypes::GoldMedal:
            return goldTexNVGMed;
        case ItemTypes::AuthorMedal:
            return authorTexNVGMed;
        case ItemTypes::Archipelago:
            return archipelagoTexNVGMed;
        case ItemTypes::Skip:
            return archipelagoTexNVGMed;
        case ItemTypes::Discount:
            return archipelagoTexNVGMed;
        case ItemTypes::Trap:
            return archipelagoTexNVGMed;
        case ItemTypes::Filler:
            return archipelagoTexNVGMed;
        default:
            return archipelagoTexNVGMed;
    }
}
#endif

nvg::Texture@ GetNthTex(ItemTypes type){
    switch (type){
        case ItemTypes::BronzeMedal:
            return bronzeTexNVG;
        case ItemTypes::SilverMedal:
            return silverTexNVG;
        case ItemTypes::GoldMedal:
            return goldTexNVG;
        case ItemTypes::AuthorMedal:
            return authorTexNVG;
        case ItemTypes::Archipelago:
            return archipelagoTexNVG;
        case ItemTypes::Skip:
            return archipelagoTexNVG;
        case ItemTypes::Discount:
            return archipelagoTexNVG;
        case ItemTypes::Trap:
            return archipelagoTexNVG;
        case ItemTypes::Filler:
            return archipelagoTexNVG;
        default:
            return archipelagoTexNVG;
    }
}

#if MP4
nvg::Texture@ GetNthBottomTex(ItemTypes type){
    switch (type){
        case ItemTypes::BronzeMedal:
            return bronzeTexNVGBottom;
        case ItemTypes::SilverMedal:
            return silverTexNVGBottom;
        case ItemTypes::GoldMedal:
            return goldTexNVGBottom;
        case ItemTypes::AuthorMedal:
            return authorTexNVGBottom;
        case ItemTypes::Archipelago:
            return archipelagoTexNVGBottom;
        case ItemTypes::Skip:
            return archipelagoTexNVGBottom;
        case ItemTypes::Discount:
            return archipelagoTexNVGBottom;
        case ItemTypes::Trap:
            return archipelagoTexNVGBottom;
        case ItemTypes::Filler:
            return archipelagoTexNVGBottom;
        default:
            return archipelagoTexNVGBottom;
    }
}

nvg::Texture@ GetNthBowTieTex(ItemTypes type){
    switch (type){
        case ItemTypes::BronzeMedal:
            return bronzeTexNVGBowTie;
        case ItemTypes::SilverMedal:
            return silverTexNVGBowTie;
        case ItemTypes::GoldMedal:
            return goldTexNVGBowTie;
        case ItemTypes::AuthorMedal:
            return authorTexNVGBowTie;
        case ItemTypes::Archipelago:
            return archipelagoTexNVGBowTie;
        case ItemTypes::Skip:
            return archipelagoTexNVGBowTie;
        case ItemTypes::Discount:
            return archipelagoTexNVGBowTie;
        case ItemTypes::Trap:
            return archipelagoTexNVGBowTie;
        case ItemTypes::Filler:
            return archipelagoTexNVGBowTie;
        default:
            return archipelagoTexNVGBowTie;
    }
}

#endif

void DrawChecksRemaining(int seriesI, int mapI){
    string render = "";
    if (!data.locations.GotCheck(seriesI, mapI, CheckTypes::Target)){
        render += "\\$fff"+Icons::Circle + "\\$z ";
    }
    if (!data.locations.GotCheck(seriesI, mapI, CheckTypes::Author) && data.settings.DoingAuthor()){
        render += "\\$0a6"+Icons::Circle + "\\$z ";
    }
    if (!data.locations.GotCheck(seriesI, mapI, CheckTypes::Gold) && data.settings.DoingGold()){
        render += "\\$fc4"+Icons::Circle + "\\$z ";
    }
    if (!data.locations.GotCheck(seriesI, mapI, CheckTypes::Silver) && data.settings.DoingSilver()){
        render += "\\$888"+Icons::Circle + "\\$z ";
    }
    if (!data.locations.GotCheck(seriesI, mapI, CheckTypes::Bronze) && data.settings.DoingBronze()){
        render += "\\$964"+Icons::Circle + "\\$z ";
    }
    if (data.locations.GotAllChecks(seriesI, mapI)){
        render += "None! :D";
    }
    UI::Text(render);
}

void DrawTags(MapState@ mapState, bool wrap = true){
    string render = "";
    MapInfo@ map = mapState.mapInfo;
    for(uint i = 0; i < map.Tags.Length; i++){
        render += map.Tags[i].Name;
        if (i < map.Tags.Length-1){
            render += ", ";
        }
    }
    if (render.Length > 0){
        if (wrap){
            UI::TextWrapped(render);
        }else{
            UI::Text(render);
        }
    }

}

void LoadUIAssets(){
    @victoryClip = Audio::LoadSample("Sounds/Victory.wav");
    yield();

    @fontHeader = UI::LoadFont("DroidSans-Bold.ttf", 26, -1, -1, true, true, true);
    @fontHeaderSub = UI::LoadFont("DroidSans.ttf", 22, -1, -1, true, true, true);
    yield();
    @fontHuge = UI::LoadFont("DroidSans.ttf", 40, -1, -1, true, true, true);
    @fontTime = UI::LoadFont("Fonts/digital-7.mono.ttf", 18, -1, -1, true, true, true);
    NvgFont = nvg::LoadFont("Fonts/RacingSansOne-Regular.ttf");
    yield();

#if TMNEXT
    @bronzeTex = UI::LoadTexture("Images/TMNEXT/bronzeMed.png");
    @silverTex = UI::LoadTexture("Images/TMNEXT/silverMed.png");
    @goldTex = UI::LoadTexture("Images/TMNEXT/goldMed.png");
    @authorTex = UI::LoadTexture("Images/TMNEXT/authorMed.png");
    yield();
#elif MP4
    @bronzeTex = UI::LoadTexture("Images/MP4/bronzeTopMedMP4.png");
    @silverTex = UI::LoadTexture("Images/MP4/silverTopMedMP4.png");
    @goldTex = UI::LoadTexture("Images/MP4/goldTopMedMP4.png");
    @authorTex = UI::LoadTexture("Images/MP4/authorTopMedMP4.png");
    yield();
#endif

#if TMNEXT
    @bronzeTexNVG = nvg::LoadTexture("Images/TMNEXT/bronze.png");
    @silverTexNVG = nvg::LoadTexture("Images/TMNEXT/silver.png");
    @goldTexNVG = nvg::LoadTexture("Images/TMNEXT/gold.png");
    yield();
    @authorTexNVG = nvg::LoadTexture("Images/TMNEXT/author.png");
    @archipelagoTexNVG = nvg::LoadTexture("Images/TMNEXT/archipelago.png");
    yield();
    @bronzeTexNVGMed = nvg::LoadTexture("Images/TMNEXT/bronzeMed.png");
    @silverTexNVGMed = nvg::LoadTexture("Images/TMNEXT/silverMed.png");
    @goldTexNVGMed = nvg::LoadTexture("Images/TMNEXT/goldMed.png");
    @authorTexNVGMed = nvg::LoadTexture("Images/TMNEXT/authorMed.png");
    @archipelagoTexNVGMed = nvg::LoadTexture("Images/TMNEXT/archipelagoMed.png");
    yield();
    @bronzeTexNVGSmol = nvg::LoadTexture("Images/TMNEXT/bronzeSmall.png");
    @silverTexNVGSmol = nvg::LoadTexture("Images/TMNEXT/silverSmall.png");
    @goldTexNVGSmol = nvg::LoadTexture("Images/TMNEXT/goldSmall.png");
    @authorTexNVGSmol = nvg::LoadTexture("Images/TMNEXT/authorSmall.png");
    @archipelagoTexNVGSmol = nvg::LoadTexture("Images/TMNEXT/archipelagoSmall.png");

    @shadowTexNVG = nvg::LoadTexture("Images/TMNEXT/shadow.png");

#elif MP4
    @bronzeTexNVG = nvg::LoadTexture("Images/MP4/bronzeTopMP4.png");
    @silverTexNVG = nvg::LoadTexture("Images/MP4/silverTopMP4.png");
    @goldTexNVG = nvg::LoadTexture("Images/MP4/goldTopMP4.png");
    yield();
    @authorTexNVG = nvg::LoadTexture("Images/MP4/authorTopMP4.png");
    @archipelagoTexNVG = nvg::LoadTexture("Images/MP4/archipelagoTopMP4.png");
    yield();
    @bronzeTexNVGBowTie = nvg::LoadTexture("Images/MP4/bronzeMP4.png");
    @silverTexNVGBowTie = nvg::LoadTexture("Images/MP4/silverMP4.png");
    @goldTexNVGBowTie = nvg::LoadTexture("Images/MP4/goldMP4.png");
    yield();
    @authorTexNVGBowTie = nvg::LoadTexture("Images/MP4/authorMP4.png");
    @archipelagoTexNVGBowTie = nvg::LoadTexture("Images/MP4/archipelagoMP4.png");
    yield();
    @bronzeTexNVGBottom = nvg::LoadTexture("Images/MP4/bronzeBottomMP4.png");
    @silverTexNVGBottom = nvg::LoadTexture("Images/MP4/silverBottomMP4.png");
    @goldTexNVGBottom = nvg::LoadTexture("Images/MP4/goldBottomMP4.png");
    yield();
    @authorTexNVGBottom = nvg::LoadTexture("Images/MP4/authorBottomMP4.png");
    @archipelagoTexNVGBottom = nvg::LoadTexture("Images/MP4/archipelagoBottomMP4.png");
#endif

    loadingFinished = true;
}