
bool isOpen = true;

SaveData@ data = null;
WebSocket socket = WebSocket("localhost",22422);
MapState@ loadedMap = null;
SaveFile@ saveFile = null;

void Main(){
    initTags();
}

void RenderMenu(){
    if (UI::MenuItem(Icons::Cloud + " \\$z" + "Archipelago","", isOpen)) {
        isOpen = !isOpen;
    }
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
                    loadedMap.UpdatePB(raceTime);
                    //autosave as well!
                    saveFile.Save(data);
                }
            }
            lastRaceTime = raceTime;
        }

        yield();
    }

    if (saveFile !is null && data !is null){
        saveFile.Save(data);
    }
    @data = null;
    @loadedMap = null;
    @saveFile = null;
}