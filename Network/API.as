namespace API
{
    Net::HttpRequest@ Get(const string &in url)
    {
        auto ret = Net::HttpRequest();
        ret.Method = Net::HttpMethod::Get;
        ret.Url = url;
        Log::Trace("Get: " + url);
        ret.Start();
        return ret;
    }

    Json::Value GetAsync(const string &in url)
    {
        auto req = Get(url);
        while (!req.Finished()) {
            yield();
        }
        string res = req.String();
        if (IS_DEV_MODE) Log::Trace("Code: " + req.ResponseCode() + " - Get Res: " + res);
        return req.Json();
    }

    void GetAsyncImg(ref@ requestData)
    {
        NetRequest@ data = cast<NetRequest@>(requestData);
        if (data.delayMS > 0){
            sleep(data.delayMS);
        }
        auto req = Get(data.url);
        while (!req.Finished()) {
            yield();
        }
        if (IS_DEV_MODE) Log::Trace("Code: " + req.ResponseCode());
        data.callback(req);
    }

    Net::HttpRequest@ Post(const string &in url, const string &in body)
    {
        auto ret = Net::HttpRequest();
        ret.Method = Net::HttpMethod::Post;
        ret.Url = url;
        ret.Body = body;
        ret.Headers.Set("Content-Type", "application/json");
        Log::Trace("Post: " + url);
        ret.Start();
        return ret;
    }

    Json::Value PostAsync(const string &in url, const string &in body)
    {
        auto req = Post(url, body);
        while (!req.Finished()) {
            yield();
        }
        string res = req.String();
        if (IS_DEV_MODE) Log::Trace("Code: " + req.ResponseCode() + " - Post Res: " + res);
        return req.Json();
    }

    funcdef void NetworkCallback(Net::HttpRequest@ request);

    class NetRequest{
        string url;
        NetworkCallback@ callback;
        int delayMS = 0;
        NetRequest(const string &in url, NetworkCallback@ callback){
            this.url = url;
            @this.callback = callback;
        }
    }
}