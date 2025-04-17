
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
    for(int i = 0; i < data.world.length; i++){
        if (IsSeriesUnlocked(i)){
            if (data.world[i].initialized){
                for (int j = 0; j < data.world[i].maps.length; j++){
                    if (UI::ButtonColored("Load Series "+i+" Map "+j, 0.8)){
                        LoadMap(i,j);
                    }
                }
            }else{
                UI::Text("Series " + i + " Loading...");
            }
        }
    }
}

void RenderMapHUD(){
    string loadedMapUid = GetLoadedMapUid();
    UI::Text("BWoah ur in a map!!!");
    if (loadedMap != null && loadedMap.mapInfo.MapUid == loadedMapUid){

    }else{
        //they went and loaded another map :O 
    }

    if (UI::ButtonColored(Icons::Circle + "Back to Map Selection!", 0.66)){
        ClosePauseMenu();
        BackToMainMenu();
    }
}