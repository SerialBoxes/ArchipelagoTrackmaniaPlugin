class SaveFile{
    //I rly thought this was gonna be more complicated tbh
    private string folder_location = IO::FromStorageFolder("saves");
    protected string file_location = folder_location;

    Files(const string &in seed, int teamI, int playerI) {
        if (!IO::FolderExists(folder_location))
            IO::CreateFolder(folder_location);

        file_location = folder_location + "/" + seed + "_" + teamI + "_" + playerI + ".json";
    }

    void Exists(){
        return IO::FileExists(file_location);
    }

    Json::Value@ Load(){
        if (IO::FileExists(file_location)) {
            Json::Value@ content = Json::FromFile(file_location);
            return content;
        }else{
            return null;
        }
    }

    void Save(SaveData@ saveData){
        Json::ToFile(file_location, saveData.ToJson());
    }
}