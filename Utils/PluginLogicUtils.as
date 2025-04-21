
int MapIndicesToId(int seriesI, int mapI, CheckTypes checkType){
    int mapBase = BASE_ID + seriesI * (MAX_MAP_LOCATIONS * MAX_MAPS_IN_SERIES) + mapI * (MAX_MAP_LOCATIONS);
    return mapBase + int(checkType);
}

vec3 MapIdToIndices(int id){
    id = id - BASE_ID;
    int series = id / (MAX_MAP_LOCATIONS * MAX_MAPS_IN_SERIES);
    int map = (id % MAX_MAP_LOCATIONS * MAX_MAPS_IN_SERIES) / MAX_MAP_LOCATIONS; 
    int check = id % MAX_MAP_LOCATIONS;
    return vec3(series, map, check);
}