void Main() {
    
}

bool isOpen = true;

SaveData@ data = null;
WebSocket socket = WebSocket("localhost",22422);

void RenderMenu(){
    if (UI::MenuItem(Icons::Cloud + " \\$z" + "Archipelago","", isOpen)) {
        isOpen = !isOpen;
    }
}

int lastRaceTime = -1;
void Update(float dt){
    // if (clientConnected && !isNextMapLoading && gameState !is null && gameState.GetMap() !is null){
    //     int raceTime = GetCurrentMapTime();
    //     if (raceTime > 0 && raceTime != lastRaceTime){
    //         gameState.UpdateChecksForNewTime(raceTime);
    //         if (raceTime < gameState.targetTime){
    //             gameState.completedTracks += 1;
    //             startnew(LoadNextMap);
    //         }
    //     }
    //     lastRaceTime = raceTime;
    // }
    string msg;
    while ((msg = socket.PopMessage()) != ""){
        ProcessMessage(msg);
    }
}