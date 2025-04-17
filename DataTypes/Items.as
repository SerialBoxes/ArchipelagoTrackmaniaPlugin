class Items{
    int bronzeMedals;
    int silverMedals;
    int goldMedals;
    int authorMedals;
    int skips;
    int filler;

    int lastProcessedIndex;

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