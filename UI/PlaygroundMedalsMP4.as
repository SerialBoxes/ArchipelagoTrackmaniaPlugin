
#if MP4

uint FrameConfirmQuit = 0;
const float stdRatio = 16.0f / 9.0f;

void DrawPlaygroundUI() {
    //okay listen up girls and boys heres the situ
    //I want to cry

    if (!GetIsOnMap() || !UI::IsGameUIVisible()) return;
    //if (data is null || !socket.NotDisconnected()) return;
    //if (loadedMap is null || GetLoadedMapUid() != loadedMap.mapInfo.MapUid) return;

    CControlContainer@ root = GetApp().CurrentPlayground.Interface.InterfaceRoot;
    CControlContainer@ PageContainer = cast<CControlContainer>(cast<CControlContainer>(root.Childs[2]).Childs[8]);

    CControlContainer@ BigMedals = cast<CControlContainer>(PageContainer.Childs[5]);
    CControlContainer@ RaceEnd = cast<CControlContainer>(PageContainer.Childs[8]);
    CControlContainer@ GhostSelection = cast<CControlContainer>(PageContainer.Childs[9]);
    CControlContainer@ Pause = cast<CControlContainer>(PageContainer.Childs[10]);

    CControlQuad@ MedalRE = cast<CControlQuad>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(RaceEnd.Childs[0]).Childs[1]).Childs[0]).Childs[3]).Childs[0]).Childs[3]).Childs[1]);
    MedalRE.Hide();
    if (RaceEnd.IsVisible && cast<CControlContainer>(cast<CControlContainer>(RaceEnd.Childs[0]).Childs[1]).IsVisible) DrawMedalSelection(MedalRE);

    CControlQuad@ MedalGS = cast<CControlQuad>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(GhostSelection.Childs[0]).Childs[0]).Childs[1]).Childs[3]).Childs[0]).Childs[3]).Childs[1]);
    MedalGS.Hide();
    if (GhostSelection.IsVisible) DrawMedalSelection(MedalGS);

    CControlQuad@ MedalPS = cast<CControlQuad>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(Pause.Childs[0]).Childs[0]).Childs[1]).Childs[3]).Childs[0]).Childs[3]).Childs[1]);
    MedalPS.Hide();
    if (Pause.IsVisible) DrawMedalSelection(MedalPS);

    CControlFrame@ BigMedalsParent = cast<CControlFrame>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(cast<CControlContainer>(BigMedals.Childs[0]).Childs[2]).Childs[2]).Childs[1]).Childs[0]).Childs[1]);
    BigMedalsParent.Hide();
    if(cast<CControlContainer>(cast<CControlContainer>(BigMedals.Childs[0]).Childs[2]).IsVisible) DrawBigMedals(BigMedalsParent);

}

void DrawMedalSelection(CControlQuad@ Medal){
    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const vec2  scale  = vec2(w*-0.3125,h*-0.55555556);

    CControlQuad@ bg = cast<CControlQuad>(Medal.Parent.Parent.Childs[2]);
    vec2 bgpos = vec2(bg.Item.Corpus.Location.tx,bg.Item.Corpus.Location.ty);
    vec2 bgsize = vec2((bg.BoxMax.x-bg.BoxMin.x)/3.2*w,(bg.BoxMax.y-bg.BoxMin.y)/1.8*h);
    vec2 bgcoords = center + scale*bgpos  - vec2(0,bgsize.y/2);

    // int checkCount = data.locations.ChecksGotten(loadedMap.seriesIndex,loadedMap.mapIndex);
    // if (checkCount == 0) return;

    // ItemTypes texI = loadedMap.itemTypes[data.locations.GetNthCheck(loadedMap.seriesIndex,loadedMap.mapIndex, 0)];
    // nvg::Texture@ tex = GetNthMedTex(texI);
    nvg::Texture@ tex = archipelagoTexNVGBowTie;
    vec2 size   = vec2(0.0875*w,0.20555555555555555*h);
    vec2 pos = vec2(Medal.Item.Corpus.Location.tx,Medal.Item.Corpus.Location.ty);
    vec2 coords = center + scale*pos - vec2(0,size.y/2);
    nvg::BeginPath();
    nvg::Scissor(bgcoords.x,bgcoords.y,bgsize.x,bgsize.y);
    nvg::FillPaint(nvg::TexturePattern(coords, size, 0.0f, tex, 0.9f));
    nvg::Fill();
    nvg::ResetScissor();
    nvg::ClosePath();
}

void DrawBigMedals(CControlFrame@ BigMedalsParent){
    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const vec2  scale  = vec2(w*-0.3125,h*-0.55555556);

    CControlQuad@ divider = cast<CControlQuad>(BigMedalsParent.Parent.Parent.Parent.Childs[0]);
    vec2 pos = vec2(divider.Item.Corpus.Location.tx,divider.Item.Corpus.Location.ty);
    vec2 size = vec2((divider.BoxMax.x-divider.BoxMin.x)/3.2*w,(divider.BoxMax.y-divider.BoxMin.y)/1.8*h);
    vec2 coords = center + scale*pos  - vec2(size.x,size.y/2) - vec2(w*0.5,0);
    size = vec2(w*0.5,size.y*1.2);
    nvg::Scissor(coords.x,coords.y,size.x,size.y);

    //DONT FORGET MEEEEEE
    CControlLabel@ newMedal = cast<CControlLabel>(BigMedalsParent.Parent.Childs[0]);
    // int checks = data.locations.ChecksGotten(loadedMap.seriesIndex,loadedMap.mapIndex);
    // if (checks > 0) newMedal.Hide();
    // else newMedal.Show();

    CControlQuad@ bg = cast<CControlQuad>(BigMedalsParent.Childs[0]);
    CControlQuad@ bronze = cast<CControlQuad>(BigMedalsParent.Childs[1]);
    CControlQuad@ silver = cast<CControlQuad>(BigMedalsParent.Childs[2]);
    CControlQuad@ gold = cast<CControlQuad>(BigMedalsParent.Childs[3]);
    CControlQuad@ author = cast<CControlQuad>(BigMedalsParent.Childs[4]);
    CControlQuad@ bowtie = cast<CControlQuad>(BigMedalsParent.Childs[5]);

    bool btb = RoundTo(bronze.Item.Corpus.Location.tx) == RoundTo(bowtie.Item.Corpus.Location.tx);
    bool bts = RoundTo(silver.Item.Corpus.Location.tx) == RoundTo(bowtie.Item.Corpus.Location.tx);
    bool btg = RoundTo(gold.Item.Corpus.Location.tx) == RoundTo(bowtie.Item.Corpus.Location.tx);
    bool bta = RoundTo(author.Item.Corpus.Location.tx) == RoundTo(bowtie.Item.Corpus.Location.tx);

    //print (gold.Item.Corpus.Location.tx + " " + bowtie.Item.Corpus.Location.tx);
    if (btb || bts || btg || bta)
        DrawBowTie(bowtie);
    DrawBigMedal(bronze);
    DrawBigMedal(silver);
    DrawBigMedal(gold);
    DrawBigMedal(author);

    nvg::ResetScissor();
}

void DrawBigMedal (CControlQuad@ Medal){
    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const vec2  scale  = vec2(w*-0.3125,h*-0.55555556);
    mat4 mat = Medal.Item.Corpus.Location;

    // int checkCount = data.locations.ChecksGotten(loadedMap.seriesIndex,loadedMap.mapIndex);
    // if (checkCount == 0) return;

    // ItemTypes texI = loadedMap.itemTypes[data.locations.GetNthCheck(loadedMap.seriesIndex,loadedMap.mapIndex, 0)];
    // nvg::Texture@ tex = GetNthMedTex(texI);
    nvg::Texture@ tex = archipelagoTexNVG;

    //xx = cos(theta)*scale
    //yx = sin(theta)*scale
    float theta = Math::Atan2(mat.yx,mat.xx);
    float mscale = Math::Max(mat.yx/Math::Max(Math::Sin(theta),0.00001),mat.xx/Math::Max(Math::Cos(theta),0.00001));

    vec2 pos = vec2(mat.tx,mat.ty);
    vec2 size = vec2((Medal.BoxMax.x-Medal.BoxMin.x)/3.2*w,(Medal.BoxMax.x-Medal.BoxMin.x)/1.8*h);
    vec2 coords = center + scale*pos  - vec2(size.x/2,size.y/2);

    nvg::BeginPath();
    nvg::Translate(coords+size*0.5);
    nvg::Rotate(theta);
    nvg::Scale(mscale);
    nvg::FillPaint(nvg::TexturePattern(size*-0.5, size, 0.0f, tex, 1.0f));
    nvg::Fill();
    nvg::ResetTransform();
    nvg::ClosePath();
}

void DrawBowTie (CControlQuad@ BowTie){
    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const vec2  scale  = vec2(w*-0.3125,h*-0.55555556);
    mat4 mat = BowTie.Item.Corpus.Location;

    // int checkCount = data.locations.ChecksGotten(loadedMap.seriesIndex,loadedMap.mapIndex);
    // if (checkCount == 0) return;

    // ItemTypes texI = loadedMap.itemTypes[data.locations.GetNthCheck(loadedMap.seriesIndex,loadedMap.mapIndex, 0)];
    // nvg::Texture@ tex = GetNthMedTex(texI);
    nvg::Texture@ tex = archipelagoTexNVGBottom;

    float mscale = mat.xx;

    vec2 pos = vec2(mat.tx,mat.ty);
    float dif = (BowTie.BoxMax.y-BowTie.BoxMin.y)/1.3222748815165877;
    vec2 size = vec2(dif/3.2*w,dif/1.8*1.3222748815165877*h);
    vec2 coords = center + scale*pos  - vec2(size.x/2,size.y/2);

    nvg::BeginPath();
    nvg::Translate(coords+size*0.5);
    nvg::Scale(mscale);
    nvg::FillPaint(nvg::TexturePattern(size*-0.5, size, 0.0f, tex, 1-((mscale-1)*10)));
    nvg::Fill();
    nvg::ResetTransform();
    nvg::ClosePath();
}

void DrawHugeMedal(vec2 medalPos, float medalScale, const string &in imageURL){
    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const float hUnit  = h / 180.0f;
    const vec2  scale  = vec2((w / h > stdRatio) ? hUnit : w / 320.0f, -hUnit);
    const vec2  size   = vec2(19.4f) * hUnit;
    const vec2 quadMedalOffset = vec2(-size.x, -size.y) * 1.15f;
    const vec2 quadMedalCoords = center + quadMedalOffset + scale * medalPos;
    const vec2 quadMedalSize   = vec2(45.0f * hUnit * medalScale);

    nvg::Texture@ tex = archipelagoTexNVG;
    if (imageURL.Contains("Bronze") && data.locations.GotCheck(loadedMap.seriesIndex,loadedMap.mapIndex,CheckTypes::Bronze)){
        @tex = GetNthTex(loadedMap.itemTypes[4]);
    }else if (imageURL.Contains("Silver") && data.locations.GotCheck(loadedMap.seriesIndex,loadedMap.mapIndex,CheckTypes::Silver)){
        @tex = GetNthTex(loadedMap.itemTypes[3]);
    }else if (imageURL.Contains("Gold") && data.locations.GotCheck(loadedMap.seriesIndex,loadedMap.mapIndex,CheckTypes::Gold)){
        @tex = GetNthTex(loadedMap.itemTypes[2]);
    }else{
        if (data.settings.targetTimeSetting < 3 && data.locations.GotCheck(loadedMap.seriesIndex,loadedMap.mapIndex,CheckTypes::Target)){
            @tex = GetNthTex(loadedMap.itemTypes[0]);
        }else if (data.settings.targetTimeSetting >= 3 && data.locations.GotCheck(loadedMap.seriesIndex,loadedMap.mapIndex,CheckTypes::Author)){
            @tex = GetNthTex(loadedMap.itemTypes[1]);
        }
    }

    nvg::BeginPath();
    nvg::FillPaint(nvg::TexturePattern(quadMedalCoords, quadMedalSize, 0.0f, tex, 1.0f));
    nvg::Fill();
}

float RoundTo(float x){
    return Math::Round(x*1000)/1000;
}
#endif
