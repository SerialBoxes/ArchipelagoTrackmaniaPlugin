int roomID;


void RenderInterface(){
    if (isOpen){
        UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(10, 10));
        UI::PushStyleVar(UI::StyleVar::WindowRounding, 10.0);
        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(10, 6));
        UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
        UI::SetNextWindowSize(600, 400, UI::Cond::FirstUseEver);
        int flags = UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking | UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize;
        if (UI::Begin("Archipelago", isOpen, flags)){
            if (!clientConnected){
                roomID = UI::InputInt("Room ID", roomID, -1);
                // if (UI::ButtonColored(Icons::Circle + "\"Connect\" to a game haha", 0.33)){
                //     CreateOrResumeGame(roomID);
                // }
                if (UI::ButtonColored(Icons::Circle + "\"Connect\" to client MonkaS", 0.33)){
                    OpenSocket();
                }
            }else{
                UI::Text("Target Time: " + Time::Format(gameState.targetTime));
                UI::Text("Completed Tracks: " + gameState.completedTracks);
                TrackCheck@ track = gameState.GetTrackChecks(gameState.completedTracks);
                if (track !is null){
                    UI::Text("Bronze Check: " + track.bronzeTarget);
                    UI::Text("Silver Check: " + track.silverTarget);
                    UI::Text("Gold Check: " + track.goldTarget);
                    UI::Text("Author Check: " + track.authorTarget);
                }else{
                    UI::Text("Bronze Check: false");
                    UI::Text("Silver Check: false");
                    UI::Text("Gold Check: false");
                    UI::Text("Author Check: false");
                }
            }
            // if (UI::ButtonColored(Icons::Circle + " Load a Random Map!", 0.33)){
            //     startnew(LoadNextMap);
            // }
        }
        UI::End();
        UI::PopStyleVar(4);
    }
}