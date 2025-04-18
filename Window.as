
void RenderInterface(){
    if (isOpen){
        UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(10, 10));
        UI::PushStyleVar(UI::StyleVar::WindowRounding, 10.0);
        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(10, 6));
        UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
        UI::SetNextWindowSize(600, 400, UI::Cond::FirstUseEver);
        int flags = UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking | UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize;
        if (UI::Begin("Archipelago", isOpen, flags)){
            if (!socket.IsConnected()){
                RenderConnectMenu();
            }else{
                if (GetIsOnMap()){
                    RenderMapHUD();
                }else{
                    RenderMainMenu();
                }
            }
        }
        UI::End();
        UI::PopStyleVar(4);
    }
}

void RenderConnectMenu(){
    if (!socket.NotDisconnected()){
        if (UI::ButtonColored(Icons::Circle + "Connect to Client!", 0.33)){
            StartConnection();
        }
    }else{
        UI::Text("Connecting...");
    }
}

void RenderMainMenu(){
    if (data is null){
        UI::Text("Rolling Maps for Series 1...");
    }else{
        UI::BeginChild("Serieses", vec2(450,200));
        for (uint i = 0; i < data.world.Length; i++){
            if (IsSeriesUnlocked(i)){
                if (data.world[i].initialized){
                    UI::Text ("Series " + (i+1));
                    UI::BeginTable("Series_Table_"+i, 5);
                    for (int j = 0; j < data.world[i].mapCount; j++){
                        UI::TableNextColumn();

                        UI::BeginGroup();
                        if (UI::ButtonColored("Map "+(j+1), 0.8)){
                            LoadMap(i,j);
                        }
                        UI::EndGroup();
                    }
                    UI::EndTable();
                }else{
                    UI::Text("Series " + (i+1) + " Loading...");
                }
            }
        }
        UI::EndChild();

        RenderInventory();
    }
        
}

void RenderMapHUD(){
    string loadedMapUid = GetLoadedMapUid();
    if (loadedMap !is null && loadedMap.mapInfo.MapUid == loadedMapUid){
        UI::Text("Series " + (loadedMap.seriesIndex+1) + " Map " + (loadedMap.mapIndex+1));
        int pb = loadedMap.personalBestTime;
        string pbText = Time::Format(pb);
        if (pb == 30000000) pbText = "--:---";
        UI::Text("Target Time: " + Time::Format(loadedMap.targetTime));
        UI::Text("Personal Best: " + pbText);

    } else {
        UI::Text("Happy Hunting!");
    }

    RenderInventory();

    if (UI::ButtonColored(Icons::Circle + "Back to Map Selection!", 0.66)){
        ClosePauseMenu();
        BackToMainMenu();
    }
}

void RenderInventory(){
    UI::Text("Progression Medals: " + data.items.GetProgressionMedalCount(data.settings.targetTimeSetting));
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
    UI::Text("Skips: " + data.items.skips);
    UI::EndTable();
    
}