class PopupText{
    string text;
    vec2 pos;
    float startSize;
    float displaySize;
    float endSize;
    float inDuration;
    float displayDuration;
    float outDuration;
    vec4 color;
    vec4 shadowColor;
    vec2 shadowOffset;
    float shadowBlur;

    float timer;

    PopupText(const string &in text, vec2 pos, float startSize, float displaySize, float endSize, float inDuration, float displayDuration, float outDuration, vec4 color, vec4 shadowColor, vec2 shadowOffset, float shadowBlur){
        this.text = text;
        this.pos = pos;
        this.startSize = startSize;
        this.displaySize = displaySize;
        this.endSize = endSize;
        this.inDuration = inDuration;
        this.displayDuration = displayDuration;
        this.outDuration = outDuration;
        this.color = color;
        this.shadowColor = shadowColor;
        this.shadowOffset = shadowOffset;
        this.shadowBlur = shadowBlur;

        timer = 0;
    }

    void Render(){
        float size = 0;
        float opacity = 0;
        if (timer < inDuration){
            float t = timer/inDuration;
            size = Math::Lerp(startSize,displaySize,t);
            opacity = Math::Lerp(0.0,1.0,t);
        }else if (timer < inDuration + displayDuration){
            float t = (timer-inDuration)/displayDuration;
            size = displaySize;
            opacity = 1;
        }else if (timer < inDuration + displayDuration + outDuration){
            float t = (timer-inDuration-displayDuration)/outDuration;
            size = Math::Lerp(displaySize,endSize,t);
            opacity = Math::Lerp(1.0,0.0,t);
        }else{
            return;
        }
        size = size*Draw::GetHeight()/1080.0;
        nvg::BeginPath();
        nvg::FontSize(size);
        vec2 bounds = nvg::TextBounds(text);
        vec2 textPos = vec2(Draw::GetWidth()*pos.x,Draw::GetHeight()*pos.y)+vec2(-bounds.x/2,bounds.y/4);
        vec2 shadowPos = textPos + vec2(shadowOffset.x*Draw::GetHeight()/1080,shadowOffset.y*Draw::GetHeight()/1080);
        nvg::FillColor(vec4(shadowColor.x,shadowColor.y,shadowColor.z,shadowColor.w*opacity));
        nvg::FontBlur(shadowBlur);
        nvg::Text(shadowPos, text);
        nvg::FillColor(vec4(color.x,color.y,color.z,color.w*opacity));
        nvg::FontBlur(0);
        nvg::Text(textPos, text);
        nvg::ClosePath();
    }

    void Update(float deltaTime){
        timer += deltaTime;
    }
}