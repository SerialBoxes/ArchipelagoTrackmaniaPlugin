
bool isOpen = false;
bool shownBefore = false;

SaveData@ data = null;
WebSocket socket = WebSocket("localhost",22422);
MapState@ loadedMap = null;
SaveFile@ saveFile = null;

void Main(){
    initTags();

    startnew(LoadUIAssets);
}

void RenderMenu(){
    if (UI::MenuItem("\\$d5b"+Icons::Kenney::Key + "\\$z" + " Archipelago","", isOpen)) {
        isOpen = !isOpen;
    }
}

void Render(){
    if (isOpen){
        if (!socket.IsConnected()){
            RenderConnectUI();
        }else{
            if (GetIsOnMap()){
                RenderMapUI();
                DrawPlaygroundUI();
            }else{
                RenderMainMenu();
            }
        }
    }else{
        if (socket.NotDisconnected()){
            socket.Close();
        }
    }
}

void StartConnection(){
    socket.OpenSocket();
    startnew(CoroutineFunc(ConnectedLoop));
}

int lastRaceTime = -1;
void ConnectedLoop(){
    while (socket.NotDisconnected()){
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
    shownBefore = false;
    @data = null;
    @loadedMap = null;
    @saveFile = null;
}