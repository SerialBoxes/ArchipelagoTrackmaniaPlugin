void Main() {
    
}

bool isOpen = true;

SaveData@ data = null;
WebSocket socket = WebSocket("localhost",22422);
MapState@ loadedMap = null;

void RenderMenu(){
    if (UI::MenuItem(Icons::Cloud + " \\$z" + "Archipelago","", isOpen)) {
        isOpen = !isOpen;
    }
}

//int lastRaceTime = -1;
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
}

void StartConnection(){
    socket.OpenSocket();
    startnew(CoroutineFunc(ConnectedLoop));
}

int lastRaceTime = -1;
void ConnectedLoop(){
    while (socket.NotDisconnected()){
        //read in any messages in the socket
        // string msg;
        // while ((msg = socket.PopMessage()) != ""){
        //     ProcessMessage(msg);
        // }

        //check for personal best times
        if (loadedMap !is null && loadedMap.mapInfo.MapUid == GetLoadedMapUid()){
            //were on *da map*
            int raceTime = GetCurrentMapTime();
            if (raceTime > 0 && raceTime != lastRaceTime){
                if (raceTime < loadedMap.personalBestTime){
                    print("pb!!!");
                    UpdatePBOnLoadedMap(raceTime);
                }
            }
            lastRaceTime = raceTime;
        }

        yield();
    }
    //we disconnected, reset state
    //write data to disk if not null
    @data = null;
}