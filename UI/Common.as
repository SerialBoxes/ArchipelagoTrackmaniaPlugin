UI::Font@ fontHuge;
UI::Font@ fontHeader;
UI::Font@ fontHeaderSub;
UI::Font@ fontTime;

UI::Texture@ bronzeTex;
UI::Texture@ silverTex;
UI::Texture@ goldTex;
UI::Texture@ authorTex;
UI::Texture@ archipelagoTex;

nvg::Texture@ bronzeTexNVG;
nvg::Texture@ silverTexNVG;
nvg::Texture@ goldTexNVG;
nvg::Texture@ authorTexNVG;
nvg::Texture@ archipelagoTexNVG;

void RenderInventory(){
    UI::Text("Progression Medals: " + data.items.GetProgressionMedalCount() + "/"+(data.settings.medalRequirement*data.settings.seriesCount));
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

void DrawChecksRemaining(int seriesI, int mapI){
    if (!data.locations.GotCheck(seriesI, mapI, CheckTypes::Target)){
        UI::SameLine();
        UI::PushStyleColor(UI::Col::Text, vec4(1,1,1,1));
        MoveCursor(vec2(-12,0));
        UI::Text(Icons::Circle);
        UI::PopStyleColor();
    }
    if (!data.locations.GotCheck(seriesI, mapI, CheckTypes::Author)){
        UI::SameLine();
        UI::PushStyleColor(UI::Col::Text, vec4(0,0.6,0.4,1));
        MoveCursor(vec2(-12,0));
        UI::Text(Icons::Circle);
        UI::PopStyleColor();
    }
    if (!data.locations.GotCheck(seriesI, mapI, CheckTypes::Gold)){
        UI::SameLine();
        UI::PushStyleColor(UI::Col::Text, vec4(1,0.8,0.226,1));
        MoveCursor(vec2(-12,0));
        UI::Text(Icons::Circle);
        UI::PopStyleColor();
    }
    if (!data.locations.GotCheck(seriesI, mapI, CheckTypes::Silver)){
        UI::SameLine();
        UI::PushStyleColor(UI::Col::Text, vec4(0.5,0.5,0.5,1));
        MoveCursor(vec2(-12,0));
        UI::Text(Icons::Circle);
        UI::PopStyleColor();
    }
    if (!data.locations.GotCheck(seriesI, mapI, CheckTypes::Bronze)){
        UI::SameLine();
        UI::PushStyleColor(UI::Col::Text, vec4(.578,0.395,0.226,1));
        MoveCursor(vec2(-12,0));
        UI::Text(Icons::Circle);
        UI::PopStyleColor();
    }
    if (data.locations.GotAllChecks(seriesI, mapI)){
        UI::SameLine();
        MoveCursor(vec2(-12,0));
        UI::Text("None! :)");
    }
}

void LoadUIAssets(){
    @fontHeader = UI::LoadFont("DroidSans-Bold.ttf", 26, -1, -1, true, true, true);
    @fontHeaderSub = UI::LoadFont("DroidSans.ttf", 22, -1, -1, true, true, true);
    @fontHuge = UI::LoadFont("DroidSans.ttf", 40, -1, -1, true, true, true);
    @fontTime = UI::LoadFont("Fonts/digital-7.mono.ttf", 18, -1, -1, true, true, true);

    @bronzeTex = UI::LoadTexture("Images/bronze.png");
    @silverTex = UI::LoadTexture("Images/silver.png");
    @goldTex = UI::LoadTexture("Images/gold.png");
    @authorTex = UI::LoadTexture("Images/author.png");

    @bronzeTexNVG = nvg::LoadTexture("Images/bronze.png");
    @silverTexNVG = nvg::LoadTexture("Images/silver.png");
    @goldTexNVG = nvg::LoadTexture("Images/gold.png");
    @authorTexNVG = nvg::LoadTexture("Images/author.png");
}