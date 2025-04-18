class Items{
    int bronzeMedals; //24000
    int silverMedals; //24001
    int goldMedals;   //24002
    int authorMedals; //24003
    int skips;        //24004
    int filler;       //24005

    int itemsRecieved;

    Items(){
        bronzeMedals = 0;
        silverMedals = 0;
        goldMedals = 0;
        authorMedals = 0;
        skips = 0;
        filler = 0;

        itemsRecieved = 0;
    }

    int GetProgressionMedalCount(float targetTimeSetting){
        if (targetTimeSetting < 1f){
            return bronzeMedals;
        }else if (targetTimeSetting < 2f){
            return silverMedals;
        }else if (targetTimeSetting < 3f){
            return goldMedals;
        }else {
            return authorMedals;
        }
    }
}