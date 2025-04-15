void Main() {
    //QueryForRandomMap();
}

bool isOpen = true;
bool clientConnected = false;

Net::Socket@ socket = Net::Socket();
WorldState@ gameState = null;

void RenderMenu(){
    if (UI::MenuItem(Icons::Cloud + " \\$z" + "Archipelago","", isOpen)) {
        isOpen = !isOpen;
    }
}

void CreateOrResumeGame(int id){
    // bool gameExists = CheckForGame(id);
    // if (gameExists){
    //     gameState = LoadGame(id);
    //     return;
    // }
    //create a new game
    @gameState = WorldState(id, 0, 30, 2.4);
    clientConnected = true;
    startnew(LoadNextMap);
}

void OpenSocket(){
    print("prayge");
    startnew(CoroutineFunc(TryConnect));

}

void TryConnect(){
    bool result = socket.Connect("localhost",22422);
    while (!socket.IsReady()){
        yield();
    }
    if (result){
        ConfigureSocket2();
    }
}

void OnConnected(){
    print("Starting Read Loop");
    SendClientHandshake();
    startnew(ReadLoop);
}

int lastRaceTime = -1;
void Update(float dt){
    if (clientConnected && !isNextMapLoading && gameState !is null && gameState.GetMap() !is null){
        int raceTime = GetCurrentMapTime();
        if (raceTime > 0 && raceTime != lastRaceTime){
            gameState.UpdateChecksForNewTime(raceTime);
            if (raceTime < gameState.targetTime){
                gameState.completedTracks += 1;
                startnew(LoadNextMap);
            }
        }
        lastRaceTime = raceTime;
    }
}

void ReadLoop() {
    RawMessage@ msg;
    // while ((@msg = socket.ReadMsg()) !is null) {
    //     HandleRawMsg(msg);
    // }
    // we disconnected
}

void HandleRawMsg(RawMessage@ msg) {
    print(msg.msgJson);
}