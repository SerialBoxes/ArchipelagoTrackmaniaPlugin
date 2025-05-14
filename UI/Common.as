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

//jeepers
nvg::Texture@ bronzeTexNVG;
nvg::Texture@ silverTexNVG;
nvg::Texture@ goldTexNVG;
nvg::Texture@ authorTexNVG;
nvg::Texture@ archipelagoTexNVG;
nvg::Texture@ bronzeTexNVGMed;
nvg::Texture@ silverTexNVGMed;
nvg::Texture@ goldTexNVGMed;
nvg::Texture@ authorTexNVGMed;
nvg::Texture@ archipelagoTexNVGMed;
nvg::Texture@ bronzeTexNVGSmol;
nvg::Texture@ silverTexNVGSmol;
nvg::Texture@ goldTexNVGSmol;
nvg::Texture@ authorTexNVGSmol;
nvg::Texture@ archipelagoTexNVGSmol;
nvg::Texture@ shadowTexNVG;

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
        case ItemTypes::Filler:
            return archipelagoTexNVGMed;
        default:
            return archipelagoTexNVGMed;
    }
}

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
        case ItemTypes::Filler:
            return archipelagoTexNVG;
        default:
            return archipelagoTexNVG;
    }
}

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

void LoadUIAssets(){
    @fontHeader = UI::LoadFont("DroidSans-Bold.ttf", 26, -1, -1, true, true, true);
    @fontHeaderSub = UI::LoadFont("DroidSans.ttf", 22, -1, -1, true, true, true);
    yield();
    @fontHuge = UI::LoadFont("DroidSans.ttf", 40, -1, -1, true, true, true);
    @fontTime = UI::LoadFont("Fonts/digital-7.mono.ttf", 18, -1, -1, true, true, true);
    NvgFont = nvg::LoadFont("DroidSans.ttf");
    yield();

    @bronzeTex = UI::LoadTexture("Images/bronzeMed.png");
    @silverTex = UI::LoadTexture("Images/silverMed.png");
    @goldTex = UI::LoadTexture("Images/goldMed.png");
    @authorTex = UI::LoadTexture("Images/authorMed.png");
    yield();

    @bronzeTexNVG = nvg::LoadTexture("Images/bronze.png");
    @silverTexNVG = nvg::LoadTexture("Images/silver.png");
    @goldTexNVG = nvg::LoadTexture("Images/gold.png");
    @authorTexNVG = nvg::LoadTexture("Images/author.png");
    @archipelagoTexNVG = nvg::LoadTexture("Images/archipelago.png");
    @bronzeTexNVGMed = nvg::LoadTexture("Images/bronzeMed.png");
    @silverTexNVGMed = nvg::LoadTexture("Images/silverMed.png");
    @goldTexNVGMed = nvg::LoadTexture("Images/goldMed.png");
    yield();
    @authorTexNVGMed = nvg::LoadTexture("Images/authorMed.png");
    @archipelagoTexNVGMed = nvg::LoadTexture("Images/archipelagoMed.png");
    @bronzeTexNVGSmol = nvg::LoadTexture("Images/bronzeSmall.png");
    @silverTexNVGSmol = nvg::LoadTexture("Images/silverSmall.png");
    @goldTexNVGSmol = nvg::LoadTexture("Images/goldSmall.png");
    @authorTexNVGSmol = nvg::LoadTexture("Images/authorSmall.png");
    @archipelagoTexNVGSmol = nvg::LoadTexture("Images/archipelagoSmall.png");
    @shadowTexNVG = nvg::LoadTexture("Images/shadow.png");
    loadingFinished = true;
}