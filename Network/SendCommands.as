void SendConnectionPacket(){

    // This Connect packet isn't actually sent to the server itself, but is used by the AP client
    // We only need the first two fields, but if we don't have the rest the packet gets rejected as invalid 
    Json::Value@ json = Json::Object();
    json["cmd"] = "Connect";
    json["game"] = "Trackmania";

    json["name"] = "";
    json["password"] = "";
    json["uuid"] = "";
    json["seed_name"] = "";

    json["items_handling"] = 7;
    json["slot_data"] = true;
    
    Json::Value@ jsonVersion = Json::Object();
    jsonVersion["major"] = "0";
    jsonVersion["minor"] = "4";
    jsonVersion["build"] = "1";
    jsonVersion["class"] = "Version";
    json["version"] = jsonVersion;
    Json::Value@ tags = Json::Array();
    tags.Add("AP");
    json["tags"] = tags;

    Json::Value@ parent = Json::Array();//commands expected as an array
    parent.Add(json);
    
    string message  = Json::Write(parent);
    print(message);
    socket.SendWebsocketPacket(message);
}

void SendLocationChecks(array<int> locationIds, int count){
    Json::Value@ json = Json::Object();
    json["cmd"] = "LocationChecks";
    Json::Value@ locationList = Json::Array();
    for (int i = 0; i < count; i++){
        locationList.Add(locationIds[i]);
    }
    json["locations"] = locationList;

    Json::Value@ parent = Json::Array();
    parent.Add(json);

    string message  = Json::Write(parent);
    socket.SendWebsocketPacket(message);
}

void SendLocationScouts(array<int> locationIds, int count){
    Json::Value@ json = Json::Object();
    json["cmd"] = "LocationScouts";
    Json::Value@ locationList = Json::Array();
    for (int i = 0; i < count; i++){
        locationList.Add(locationIds[i]);
    }
    json["locations"] = locationList;
    json["create_as_hint"] = 0;

    Json::Value@ parent = Json::Array();
    parent.Add(json);

    string message  = Json::Write(parent);
    socket.SendWebsocketPacket(message);
}

void SendStatusUpdate(ClientStatus status){
    Json::Value@ json = Json::Object();
    json["cmd"] = "StatusUpdate";
    json["status"] = int(status);
    Json::Value@ parent = Json::Array();
    parent.Add(json);
    string message  = Json::Write(parent);
    socket.SendWebsocketPacket(message);
}