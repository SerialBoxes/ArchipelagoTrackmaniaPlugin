
array<ConfettiStrip@> confetti;
PopupText@ popup;
void Celebrate(){
    sleep(100);
    vec2 refRes = vec2(1920, 1080);
    confetti = array<ConfettiStrip@>(100);

    float minWidth = 10;
    float maxWidth = 40;
    float minHeight = 10;
    float maxHeight = 40;
    float minSkew = -5;
    float maxSkew = 5;
    float minSpeed = 5000;
    float maxSpeed = 1000;
    float minAngle = Math::PI*0.1;
    float maxAngle = Math::PI*0.47;
    float minSaturation = 0.5;
    float maxSaturation = 0.85;
    float minValue = 0.85;
    float maxValue = 1.0;
    vec2 gravity = vec2(0,4000);
    float drag = 1.7;

    //left side
    for (uint i = 0; i < uint(confetti.Length/2); i++){
        float angle = Math::Rand(minAngle,maxAngle);
        float speed = Math::Rand(minSpeed, maxSpeed);
        @confetti[i] = ConfettiStrip(
            Math::Rand(minWidth,maxWidth),
            Math::Rand(minHeight,maxHeight),
            Math::Rand(minSkew,maxSkew),
            Math::Rand(0,Math::PI*2),
            0,
            vec2(0,refRes.y),
            vec2(Math::Cos(angle),-Math::Sin(angle))*speed,
            gravity,
            0,
            drag,
            UI::HSV(Math::Rand(0.0,1.0),Math::Rand(minSaturation, maxSaturation),Math::Rand(minValue,maxValue)));
    }

    //right side
    for (uint i = uint(confetti.Length/2); i < confetti.Length; i++){
        float angle = Math::Rand(minAngle,maxAngle);
        float speed = Math::Rand(minSpeed, maxSpeed);
        @confetti[i] = ConfettiStrip(
            Math::Rand(minWidth,maxWidth),
            Math::Rand(minHeight,maxHeight),
            Math::Rand(minSkew,maxSkew),
            Math::Rand(0,Math::PI*2),
            0,
            vec2(refRes.x,refRes.y),
            vec2(-Math::Cos(angle),-Math::Sin(angle))*speed,
            gravity,
            0,
            drag,
            UI::HSV(Math::Rand(0.0,1.0),Math::Rand(minSaturation, maxSaturation),Math::Rand(minValue,maxValue)));
    }

    @popup = PopupText(
        "Victory!",
        vec2(0.5,0.5),
        50,
        200,
        150,
        0.25,
        2.0,
        0.5,
        vec4(1,1,1,1),
        vec4(0.0,0.0,0.0,1.0),
        vec2(7,5),
        10
    );



    sleep(10000);
    confetti = array<ConfettiStrip@>(0);//here comes the garbage man!
    @popup = null;
}

void CelebrationRender(){
    if (popup !is null) popup.Render();
    for (uint i = 0; i < confetti.Length; i++){
        if (confetti[i] !is null) confetti[i].Render();
    }
}

void CelebrationUpdate(float deltaTime){
    if (popup !is null) popup.Update(deltaTime/500.0);
    for(uint i = 0; i < confetti.Length; i++){
        if (confetti[i] !is null) confetti[i].Update(deltaTime/1000.0);
    }
}