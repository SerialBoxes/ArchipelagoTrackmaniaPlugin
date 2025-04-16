void SendConnectionPacket(){
    
    // if (FullyConnected)
    // 	return;
    
    // ConnectingToAP = true;
    // CurrentMessage.Length = 0;
    
    // This Connect packet isn't actually sent to the server itself, but is used by the AP client
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

    Json::Value@ parent = Json::Array();//commands expected as an array for some reason
    parent.Add(json);
    
    string message  = Json::Write(parent);
    print(message);

    SendWebsocketPacket(message);
}