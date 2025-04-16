class SaveData{
    string seedName;//unique id for the generation
    string playerName;//slot name for player

    //yaml settings
    int seriesCount;
    int mapsInSeries;
    int medalRequirement;
    float targetTimeSetting;
    array<string> tags;
    bool tagsInclusive;
    array<string> etags;

    //world
    array<SeriesState@> world;

    
}