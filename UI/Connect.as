
void RenderConnectUI(){

    //UI::SetNextWindowSize(600, 400, UI::Cond::Always);
    UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
    UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(12, 12));
    UI::PushStyleVar(UI::StyleVar::WindowRounding, 16.0);
    UI::PushStyleVar(UI::StyleVar::FrameRounding, 8.0);
    int flags = UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking | UI::WindowFlags::AlwaysAutoResize;
    if (UI::Begin("Archipelago - Connect", isOpen, flags)){
        
#if TMNEXT
        if (!Permissions::PlayLocalMap()){
            UI::Text("Club Access is required to use this plugin, sorry!");
            EndConnectUI();
            return;
        }
#elif MP4
        if (CurrentTitlePack().Length <= 0){
            UI::Text("Please Enter a Titlepack!");
            EndConnectUI();
            return;
        }
#endif

        if (!socket.NotDisconnected()){
            if (UI::ButtonColored(	Icons::Kenney::SignIn + " Connect to Archipelago Client!", 0.33)){
                StartConnection();
            }
            if (Setting_ConnectionOptions){
                bool changed = false;
                Setting_ConnectionAddress = UI::InputText("Local Address", Setting_ConnectionAddress, changed);
                if (changed){
                    socket.SetAddress(Setting_ConnectionAddress);
                }
            }
        }else{
            UI::Text("Connecting...");
            if (UI::ButtonColored(Icons::Times+" Cancel", 0.0)){
                socket.Close();
            }
        }
    }
    EndConnectUI();
}

void EndConnectUI(){
    UI::End();
    UI::PopStyleVar(4);
}