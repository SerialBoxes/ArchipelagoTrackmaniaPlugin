void Main() {
    //QueryForRandomMap();
}

bool isOpen = true;
bool clientConnected = false;

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