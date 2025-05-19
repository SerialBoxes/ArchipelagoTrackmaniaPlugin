[Setting name="Show Archipelago Messages in Game"]
bool Setting_ShowToasts = true;

[Setting name="Advanced Connection Options"]
bool Setting_ConnectionOptions;

[Setting hidden]
string Setting_ConnectionAddress = "localhost";

bool isOpen = false;
bool shownBefore = false;
bool loadingFinished = false;

SaveData@ data = null;
WebSocket@ socket = null;
MapState@ loadedMap = null;
SaveFile@ saveFile = null;

void Main(){
    @socket = WebSocket(Setting_ConnectionAddress,22422);
    initTags();
    startnew(LoadUIAssets);
    //startnew(Celebrate);
    DrawPlaygroundUI();
}

void RenderMenu(){
    if (UI::MenuItem("\\$d5b"+Icons::Kenney::Key + "\\$z" + " Archipelago","", isOpen)) {
        isOpen = !isOpen;
    }
}

void Render(){
    if (isOpen && loadingFinished){
        if (!socket.IsConnected()){
            RenderConnectUI();
        }else{
            if (GetIsOnMap()){
                RenderMapUI();
                //DrawPlaygroundUI();
            }else{
                RenderMainMenu();
            }
        }
        CelebrationRender();
    }else{
        if (socket.NotDisconnected()){
            socket.Close();
        }
    }
    //CelebrationRender();
    //DrawPlaygroundUI();
}

void Update(float dt){
    if (isOpen && loadingFinished){
        CelebrationUpdate(dt);
    }
    //CelebrationUpdate(dt);
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