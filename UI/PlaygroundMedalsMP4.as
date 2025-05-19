
#if MP4

uint FrameConfirmQuit = 0;
const float stdRatio = 16.0f / 9.0f;

void DrawPlaygroundUI() {
    //okay listen up girls and boys heres the situ
    //I want to cry
    //CControlContainer@ root = GetApp().CurrentPlayground.Interface.InterfaceRoot;

    if (!GetIsOnMap() || !UI::IsGameUIVisible()) return;
    //if (data is null || !socket.NotDisconnected()) return;
    //if (loadedMap is null || GetLoadedMapUid() != loadedMap.mapInfo.MapUid) return;

    // nvg::BeginPath();
    // nvg::Scissor(250, 200, 100, 100);
    // nvg::FillPaint(nvg::TexturePattern(vec2(200,200), vec2(150,200), 0.0f, goldTexNVGBowTie, 1.0f));
    // nvg::Fill();
    // nvg::ResetScissor();
    // nvg::ClosePath();
}

void DrawMedalSelection(CGameManialinkPage@ Page){
    if (Page is null) return;
    auto all = cast<CGameManialinkFrame@>(Page.GetFirstChild("Frame-All"));
    if (all is null) return;
    auto root = all.Parent;
    if (root is null || !root.Visible) return;
    print("pog");
}

void DrawBigMedals(CGameManialinkPage@ Page){

}

void DrawOverPlaygroundPage(CGameManialinkPage@ Page, PlaygroundPageType type, CGameManialinkPage@ ScoresTable = null) {
    if (Page is null)
        return;

    if (type == PlaygroundPageType::Pause) {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());
        CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
        if (!Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
            return;

        if (ScoresTable !is null) {
            CGameManialinkFrame@ TableLayer = cast<CGameManialinkFrame@>(ScoresTable.GetFirstChild("frame-scorestable-layer"));
            if (TableLayer !is null && TableLayer.Visible)
                return;
        }

        const string[] frames = {
            "frame-help",
            "frame-map-list",
            "frame-options",
            "frame-prestige",
            "frame-profile",
            "frame-report-system",
            "frame-server",
            "frame-settings",
            "frame-teams",
            "popupmultichoice-leave-match"
        };

        for (uint i = 0; i < frames.Length; i++) {
            CGameManialinkFrame@ Frame = cast<CGameManialinkFrame@>(Page.GetFirstChild(frames[i]));
            if (Frame !is null && Frame.Visible)
                return;
        }

    } else {
        if (type == PlaygroundPageType::Start) {
            CGameManialinkFrame@ OpponentsList = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-more-opponents-list"));
            if (OpponentsList !is null && OpponentsList.Visible)
                return;
        }
    }

    const bool banner = type == PlaygroundPageType::Record;

    CGameManialinkControl@ Medal = Page.GetFirstChild(banner ? "quad-medal" : "ComponentMedalStack_frame-global");
    if (Medal !is null && Medal.Visible && !banner){
        const bool end = type == PlaygroundPageType::End;

        CGameManialinkFrame@ MenuContent;
        if (end)
            @MenuContent = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-menu-content"));

        if (!end || (MenuContent !is null && MenuContent.Visible) || IS_DEV_MODE) {
            CGameManialinkFrame@ Global = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-global"));
            if (Global !is null && Global.Visible){
                Medal.Parent.Hide();
                //DrawMedals(Medal.AbsolutePosition_V3, type);
            }
        }
    }

    CGameManialinkFrame@ NewMedal = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-new-medal"));
    if (NewMedal is null || !NewMedal.Visible)
        return;

    CGameManialinkQuad@ QuadMedalOld = cast<CGameManialinkQuad@>(NewMedal.GetFirstChild("quad-medal"));
    if (QuadMedalOld !is null && QuadMedalOld.Visible){
        DrawHugeMedal(QuadMedalOld.AbsolutePosition_V3, QuadMedalOld.AbsoluteScale, QuadMedalOld.ImageUrl);
    }

    CGameManialinkQuad@ QuadMedalNew = cast<CGameManialinkQuad@>(NewMedal.GetFirstChild("quad-medal-anim"));
    if (QuadMedalNew !is null && QuadMedalNew.Visible && QuadMedalNew.ImageUrl.Length > 0 && QuadMedalNew.ImageUrl != QuadMedalOld.ImageUrl){
        DrawHugeMedal(QuadMedalNew.AbsolutePosition_V3, QuadMedalNew.AbsoluteScale, QuadMedalNew.ImageUrl);
    }
}
void DrawHugeMedal(vec2 medalPos, float medalScale, const string &in imageURL){
    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const float hUnit  = h / 180.0f;
    const vec2  scale  = vec2((w / h > stdRatio) ? hUnit : w / 320.0f, -hUnit);
    const vec2  size   = vec2(19.4f) * hUnit;
    const vec2 quadMedalOffset = vec2(-size.x, -size.y) * 1.15f;
    const vec2 quadMedalCoords = center + quadMedalOffset + scale * medalPos;
    const vec2 quadMedalSize   = vec2(45.0f * hUnit * medalScale);

    nvg::Texture@ tex = archipelagoTexNVG;
    if (imageURL.Contains("Bronze") && data.locations.GotCheck(loadedMap.seriesIndex,loadedMap.mapIndex,CheckTypes::Bronze)){
        @tex = GetNthTex(loadedMap.itemTypes[4]);
    }else if (imageURL.Contains("Silver") && data.locations.GotCheck(loadedMap.seriesIndex,loadedMap.mapIndex,CheckTypes::Silver)){
        @tex = GetNthTex(loadedMap.itemTypes[3]);
    }else if (imageURL.Contains("Gold") && data.locations.GotCheck(loadedMap.seriesIndex,loadedMap.mapIndex,CheckTypes::Gold)){
        @tex = GetNthTex(loadedMap.itemTypes[2]);
    }else{
        if (data.settings.targetTimeSetting < 3 && data.locations.GotCheck(loadedMap.seriesIndex,loadedMap.mapIndex,CheckTypes::Target)){
            @tex = GetNthTex(loadedMap.itemTypes[0]);
        }else if (data.settings.targetTimeSetting >= 3 && data.locations.GotCheck(loadedMap.seriesIndex,loadedMap.mapIndex,CheckTypes::Author)){
            @tex = GetNthTex(loadedMap.itemTypes[1]);
        }
    }

    nvg::BeginPath();
    nvg::FillPaint(nvg::TexturePattern(quadMedalCoords, quadMedalSize, 0.0f, tex, 1.0f));
    nvg::Fill();
}
#endif
