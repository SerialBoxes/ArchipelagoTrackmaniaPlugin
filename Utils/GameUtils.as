
bool handledRun = false;
int GetCurrentMapTime()
{
    auto app = cast<CTrackMania>(GetApp());
    auto map = app.RootMap;
    int medal = -1;

    if (map !is null) {
        // int authorTime = map.TMObjective_AuthorTime;
        // int goldTime = map.TMObjective_GoldTime;
        // int silverTime = map.TMObjective_SilverTime;
        // int bronzeTime = map.TMObjective_BronzeTime;
        int raceTime = -1;

#if MP4
        CGameCtnPlayground@ playground = cast<CGameCtnPlayground>(app.CurrentPlayground);

        if (playground !is null && playground.PlayerRecordedGhost !is null) {
            raceTime = playground.PlayerRecordedGhost.RaceTime;
        }
#elif TMNEXT
        CGamePlayground@ playground = cast<CGamePlayground>(app.CurrentPlayground);
        CSmArenaRulesMode@ script = cast<CSmArenaRulesMode>(app.PlaygroundScript);

        if (playground !is null && script !is null && playground.GameTerminals.Length > 0) {
            CSmPlayer@ player = cast<CSmPlayer>(playground.GameTerminals[0].ControlledPlayer);

            if (player !is null) {
                auto UISequence = playground.GameTerminals[0].UISequence_Current;
                bool finished = UISequence == SGamePlaygroundUIConfig::EUISequence::Finish || UISequence == SGamePlaygroundUIConfig::EUISequence::UIInteraction;

                if (handledRun && !finished) {
                    handledRun = false;
                } else if (!handledRun && finished) {
                    handledRun = true;
                    CSmScriptPlayer@ playerScriptAPI = cast<CSmScriptPlayer>(player.ScriptAPI);
                    auto ghost = script.Ghost_RetrieveFromPlayer(playerScriptAPI);

                    if (ghost !is null) {
                        if (ghost.Result.Time > 0 && ghost.Result.Time < uint(-1)) raceTime = ghost.Result.Time;
                        script.DataFileMgr.Ghost_Release(ghost.Id);
                    }
                }
            }
        }
#endif
        return raceTime;
    }else{
        return -1;
    }
}

bool GetIsOnMap(){
    auto app = cast<CTrackMania>(GetApp());
    auto map = app.RootMap;
    return map !is null;
}

string GetLoadedMapUid(){
    auto app = cast<CTrackMania>(GetApp());
    auto map = app.RootMap;
    if (map !is null){
        map.MapInfo.MapUid;
    }else{
        return "";
    }
}

string CurrentTitlePack(){
    CTrackMania@ app = cast<CTrackMania>(GetApp());
    if (app.LoadedManiaTitle is null) return "";
    string titleId = app.LoadedManiaTitle.TitleId;
#if MP4
    return titleId.SubStr(0, titleId.IndexOf("@"));
#else
    return titleId;
#endif
}

void ClosePauseMenu(){
#if TMNEXT
    CTrackMania@ app = cast<CTrackMania>(GetApp());
    if (app.ManiaPlanetScriptAPI.ActiveContext_InGameMenuDisplayed){//if pause menu open
        CSmArenaClient@ playground = cast<CSmArenaClient>(app.CurrentPlayground);//close it!
        if(playground !is null) {
            playground.Interface.ManialinkScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Resume);
        }
    }
#endif
}

void BackToMainMenu(){
    CTrackMania@ app = cast<CTrackMania>(GetApp());
    app.BackToMainMenu();
}