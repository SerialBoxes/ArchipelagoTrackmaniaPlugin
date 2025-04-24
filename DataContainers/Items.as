class Items{
    int bronzeMedals; //24000
    int silverMedals; //24001
    int goldMedals;   //24002
    int authorMedals; //24003
    int skips;        //24004
    int filler;       //24005

    int skipsUsed;

    int itemsRecieved;

    SaveData@ saveData;

    Items(SaveData@ saveData){
        bronzeMedals = 0;
        silverMedals = 0;
        goldMedals = 0;
        authorMedals = 0;
        skips = 0;
        filler = 0;

        skipsUsed = 0;

        itemsRecieved = 0;

        @this.saveData = saveData;
    }

    Items(SaveData@ saveData, const Json::Value &in json){
        @this.saveData = saveData;
        try {
            bronzeMedals = json["bronzeMedals"];
            silverMedals = json["silverMedals"];
            goldMedals = json["goldMedals"];
            authorMedals = json["authorMedals"];
            skips = json["skips"];
            filler = json["filler"];
            skipsUsed = json["skipsUsed"];
            itemsRecieved = json["itemsRecieved"];
        } catch {
            Log::Warn("Error parsing Items"+ "\nReason: " + getExceptionInfo(), true);
        }
    }

    int GetProgressionMedalCount(){
        float targetTimeSetting = saveData.settings.targetTimeSetting;
        if (targetTimeSetting < 1.0){
            return bronzeMedals;
        }else if (targetTimeSetting < 2.0){
            return silverMedals;
        }else if (targetTimeSetting < 3.0){
            return goldMedals;
        }else {
            return authorMedals;
        }
    }

    void AddItem (int itemID, int itemCount = 1) {
        switch (itemID){
            case ItemTypes::BronzeMedal:
                bronzeMedals += itemCount;
                break;
            case ItemTypes::SilverMedal:
                silverMedals += itemCount;
                break;
            case ItemTypes::GoldMedal:
                goldMedals += itemCount;
                break;
            case ItemTypes::AuthorMedal:
                authorMedals += itemCount;
                break;
            case ItemTypes::Skip:
                skips += itemCount;
                break;
            // case ItemTypes::Filler:
            //     filler += itemCount;
            //     break;
            default:
                filler += itemCount;
                break;
        }
        itemsRecieved += itemCount;
    }

    void Reset(){
        bronzeMedals = 0;
        silverMedals = 0;
        goldMedals = 0;
        authorMedals = 0;
        skips = 0;
        filler = 0;
        itemsRecieved = 0;
    }

    Json::Value ToJson(){
        Json::Value json = Json::Object();
        try {
            json["bronzeMedals"] = bronzeMedals;
            json["silverMedals"] = silverMedals;
            json["goldMedals"] = goldMedals;
            json["authorMedals"] = authorMedals;
            json["skips"] = skips;
            json["filler"] = filler;
            json["skipsUsed"] = skipsUsed;
            json["itemsRecieved"] = itemsRecieved;
        } catch {
            Log::Error("Error converting Items to JSON", true);
        }
        return json;
    }
}