//this code is mostly yoinked from the warrior medals plugin.
//thank you ezio!

uint FrameConfirmQuit = 0;
const float stdRatio = 16.0f / 9.0f;

void DrawOverUI() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    NGameLoadProgress_SMgr@ LoadProgress = App.LoadProgress;
    if (LoadProgress !is null && LoadProgress.State != NGameLoadProgress::EState::Disabled)
        return;

    CDx11Viewport@ Viewport = cast<CDx11Viewport@>(App.Viewport);
    if (Viewport is null || Viewport.Overlays.Length == 0)
        return;

    for (int i = Viewport.Overlays.Length - 1; i >= 0; i--) {
        CHmsZoneOverlay@ Overlay = Viewport.Overlays[i];
        if (false
            || Overlay is null
            || Overlay.m_CorpusVisibles.Length == 0
            || Overlay.m_CorpusVisibles[0] is null
            || Overlay.m_CorpusVisibles[0].Item is null
            || Overlay.m_CorpusVisibles[0].Item.SceneMobil is null
        )
            continue;

        if (FrameConfirmQuit > 0 && FrameConfirmQuit == Overlay.m_CorpusVisibles[0].Item.SceneMobil.Id.Value)
            return;

        if (Overlay.m_CorpusVisibles[0].Item.SceneMobil.IdName == "FrameConfirmQuit") {
            FrameConfirmQuit = Overlay.m_CorpusVisibles[0].Item.SceneMobil.Id.Value;
            return;
        }
    }

    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo@>(Network.ServerInfo);

    if (GetIsOnMap()) {
        if (false
            || !UI::IsGameUIVisible()
            || loadedMap is null
            || GetLoadedMapUid() != loadedMap.mapInfo.MapUid
        ){
            return;
        }

        CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
        if (false
            || CMAP is null
            || CMAP.UILayers.Length < 23
            || CMAP.UI is null
        )
            return;

        const bool endSequence = CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound;

        const bool startSequence = false
            || CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::Intro
            || CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::RollingBackgroundIntro
            || endSequence
        ;

        const bool lookForBanner = ServerInfo.CurGameModeStr.Contains("_Online") || ServerInfo.CurGameModeStr.Contains("PlayMap");

        CGameManialinkPage@ ScoresTable;
        CGameManialinkPage@ Record;
        CGameManialinkPage@ Start;
        CGameManialinkPage@ Pause;
        CGameManialinkPage@ End;

        for (uint i = 0; i < CMAP.UILayers.Length; i++) {
            const bool pauseDisplayed = Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed;

            if (true
                && !(Record is null && lookForBanner)
                && !(Start  is null && startSequence)
                && !(Pause  is null && pauseDisplayed)
                && !(End    is null && endSequence)
            )
                break;

            CGameUILayer@ Layer = CMAP.UILayers[i];
            if (false
                || Layer is null
                || !Layer.IsVisible
                || (true
                    && Layer.Type != CGameUILayer::EUILayerType::Normal
                    && Layer.Type != CGameUILayer::EUILayerType::InGameMenu
                )
                || Layer.ManialinkPageUtf8.Length == 0
            )
                continue;

            const int start = Layer.ManialinkPageUtf8.IndexOf("<");
            const int end = Layer.ManialinkPageUtf8.IndexOf(">");
            if (start == -1 || end == -1)
                continue;
            const string pageName = Layer.ManialinkPageUtf8.SubStr(start, end);

            if (true
                && pauseDisplayed
                && ScoresTable is null
                && Layer.Type == CGameUILayer::EUILayerType::Normal
                && pageName.Contains("_Race_ScoresTable")
            ) {
                @ScoresTable = Layer.LocalPage;
                continue;
            }

            if (true
                && lookForBanner
                && !startSequence
                && Record is null
                && Layer.Type == CGameUILayer::EUILayerType::Normal
                && pageName.Contains("_Race_Record")
            ) {
                @Record = Layer.LocalPage;
                continue;
            }

            if (true
                && startSequence
                && Start is null
                && Layer.Type == CGameUILayer::EUILayerType::Normal
                && pageName.Contains("_StartRaceMenu")
            ) {
                @Start = Layer.LocalPage;
                continue;
            }

            if (true
                && Pause is null
                && Layer.Type == CGameUILayer::EUILayerType::InGameMenu
                && pageName.Contains("_PauseMenu")
            ) {
                @Pause = Layer.LocalPage;
                continue;
            }

            if (true
                && endSequence
                && End is null
                && Layer.Type == CGameUILayer::EUILayerType::Normal
                && pageName.Contains("_EndRaceMenu")
            ) {
                @End = Layer.LocalPage;
                continue;
            }
        }

        DrawOverPlaygroundPage(Record, PlaygroundPageType::Record);
        DrawOverPlaygroundPage(Start, PlaygroundPageType::Start);
        DrawOverPlaygroundPage(Pause, PlaygroundPageType::Pause, ScoresTable);
        DrawOverPlaygroundPage(End, PlaygroundPageType::End);
    }
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

        CGameManialinkFrame@ Global = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-global"));
        if (Global is null || !Global.Visible)
            return;
    }

    const bool banner = type == PlaygroundPageType::Record;

    CGameManialinkControl@ Medal = Page.GetFirstChild(banner ? "quad-medal" : "ComponentMedalStack_frame-global");
    if (false
        || Medal is null
        || !Medal.Visible
        || (banner && (false
            || !Medal.Parent.Visible  // not visible in campaign mode, probably others
            || Medal.AbsolutePosition_V3.x < -170.0f  // off screen
        ))
    )
        return;

    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const float hUnit  = h / 180.0f;
    const vec2  scale  = vec2((w / h > stdRatio) ? hUnit : w / 320.0f, -hUnit);
    const vec2  size   = vec2(banner ? 21.9f : 19.584f) * hUnit;
    const vec2  offset = vec2(banner ? -size.x * 0.5f : 0.0f, -size.y * 0.5f);
    const vec2  coords = center + offset + scale * (Medal.AbsolutePosition_V3 + vec2(banner ? 0.0f : 12.16f, 0.0f));

    const bool end = type == PlaygroundPageType::End;

    CGameManialinkFrame@ MenuContent;
    if (end)
        @MenuContent = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-menu-content"));

    if (false
        || !end
        || (MenuContent !is null && MenuContent.Visible)
    ) {
        nvg::BeginPath();
        nvg::FillPaint(nvg::TexturePattern(coords, size, 0.0f, authorTexNVG, 1.0f));
        nvg::Fill();
    }

    CGameManialinkFrame@ NewMedal = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-new-medal"));
    if (NewMedal is null || !NewMedal.Visible)
        return;

    CGameManialinkQuad@ QuadMedal = cast<CGameManialinkQuad@>(NewMedal.GetFirstChild("quad-medal-anim"));
    if (false
        || QuadMedal is null
        || !QuadMedal.Visible
        || QuadMedal.AbsolutePosition_V3.x > -85.0f  // end race menu still hidden
    )
        return;

    const vec2 quadMedalOffset = vec2(-size.x, -size.y) * 1.15f;
    const vec2 quadMedalCoords = center + quadMedalOffset + scale * QuadMedal.AbsolutePosition_V3;
    const vec2 quadMedalSize   = vec2(45.0f * hUnit);

    nvg::BeginPath();
    nvg::FillPaint(nvg::TexturePattern(quadMedalCoords, quadMedalSize, 0.0f, authorTexNVG, 1.0f));
    nvg::Fill();
}