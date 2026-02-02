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
    vec2 shineDir = vec2(Math::Cos(12*Math::PI/180.0),Math::Sin(12*Math::PI/180.0));

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
        vec2 gradientPos = vec2(0.0,0.0);
        //float shineWidthAdj = shineWidth * Display::GetHeight()/1080.0;
        if (timer < inDuration){
            float t = timer/inDuration;
            size = Math::Lerp(startSize,displaySize,t);
            opacity = Math::Lerp(0.0,1.0,t);
        }else if (timer < inDuration + displayDuration){
            float t = (timer-inDuration)/displayDuration;
            size = displaySize;
            nvg::FontSize(size);
            // vec2 b = nvg::TextBounds(text);
            // float start = -b.x/2-shineWidthAdj+Display::GetWidth()*pos.x;
            // float end = b.x/2+shineWidthAdj+Display::GetWidth()*pos.x;
            // gradientPos.x = Math::Lerp(start,end,t);
            // gradientPos.y = 500;
            opacity = 1;

        }else if (timer < inDuration + displayDuration + outDuration){
            float t = (timer-inDuration-displayDuration)/outDuration;
            size = Math::Lerp(displaySize,endSize,t);
            opacity = Math::Lerp(1.0,0.0,t);
        }else{
            return;
        }
        size = size*Display::GetHeight()/1080.0;
        nvg::FontSize(size);
        vec2 bounds = nvg::TextBounds(text);
        vec2 textPos = vec2(Display::GetWidth()*pos.x,Display::GetHeight()*pos.y)+vec2(-bounds.x/2,bounds.y/4);
        vec2 shadowPos = textPos + vec2(shadowOffset.x*Display::GetHeight()/1080,shadowOffset.y*Display::GetHeight()/1080);
        
        nvg::BeginPath();
        nvg::SkewX(-10*Math::PI/180);
        nvg::FillColor(vec4(shadowColor.x,shadowColor.y,shadowColor.z,shadowColor.w*opacity*0.75));
        vec2 boxBounds = bounds + vec2(120,10)*Display::GetHeight()/1080.0;
        vec2 boxPos = vec2(Display::GetWidth()*pos.x,Display::GetHeight()*pos.y)+vec2(-boxBounds.x/2,-boxBounds.y/2);
        boxPos.x += 130*Display::GetHeight()/1080.0;
        nvg::RoundedRectVarying(boxPos,boxBounds,20,0,20,0);
        nvg::Fill();
        nvg::ClosePath();

        nvg::BeginPath();
        nvg::ResetTransform();
        nvg::FillColor(vec4(shadowColor.x,shadowColor.y,shadowColor.z,shadowColor.w*opacity));
        nvg::FontBlur(shadowBlur);
        nvg::FontFace(NvgFont);
        nvg::Text(shadowPos, text);
        nvg::FillColor(vec4(color.x,color.y,color.z,color.w*opacity));
        nvg::FontBlur(0);
        nvg::FontFace(NvgFont);
        nvg::Text(textPos, text);
        nvg::ClosePath();
    }

    void Update(float deltaTime){
        timer += deltaTime;
    }
}