
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
                RenderMainMenu();
            }else{
                UI::Text("Connected! ^-^");
            }
        }
        UI::End();
        UI::PopStyleVar(4);
    }
}

void RenderMainMenu(){
    if (UI::ButtonColored(Icons::Circle + "Connect to Client!", 0.33)){
        startnew(CoroutineFunc(socket.OpenSocket));
    }
}