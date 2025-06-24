void RenderMapUI(){

    if (!UI::IsGameUIVisible()){
        return;
    }

    UI::SetNextWindowSize(210, -1, UI::Cond::Always);
    UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
    UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(12, 12));
    UI::PushStyleVar(UI::StyleVar::WindowRounding, 16.0);
    UI::PushStyleVar(UI::StyleVar::FrameRounding, 8.0);
    UI::PushStyleVar(UI::StyleVar::Alpha, 0.9);
    int flags = UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking | UI::WindowFlags::NoResize | UI:: WindowFlags::NoTitleBar;
    if (UI::Begin("Archipelago - HUD", isOpen, flags)){

        string loadedMapUid = GetLoadedMapUid();
        if (loadedMap !is null && loadedMap.mapInfo.MapUid == loadedMapUid){
            UI::PushFont(fontHeader);
            UI::Text("Series " + (loadedMap.seriesIndex+1) + " - Map " + (loadedMap.mapIndex+1) + ":");
            UI::PopFont();
            UI::PushFont(fontHeaderSub);
            MoveCursor(vec2(0.0,-3.0));
            UI::TextWrapped(loadedMap.mapInfo.Name);
            UI::PopFont();
            UI::Indent();
            MoveCursor(vec2(0.0,-6.0));
            UI::Text("by "+loadedMap.mapInfo.Username);
            DrawTags(loadedMap);
            UI::Unindent();
            UI::Separator();

            int pb = loadedMap.GetPBTime();
            string pbText = Time::Format(pb);
            string pbDelta = Time::Format(pb - loadedMap.targetTime);
            if (pb == 30000000){
                pbText = "--:--:---";
                pbDelta = "";
            }else if (pb >= loadedMap.targetTime){
                pbDelta = "+"+pbDelta;
            }
            UI::Text("Target Time: ");
            UI::PushFont(fontTime);
            UI::Indent();
            MoveCursor(vec2(0.0,-4.0));
            UI::Text(Time::Format(loadedMap.targetTime));
            UI::Unindent();
            UI::PopFont();
            MoveCursor(vec2(0.0,6.0));
            if (loadedMap.personalBestDiscountTime <= 0){
                UI::Text("Personal Best: ");
            }else{
                UI::PushStyleColor(UI::Col::Text, vec4 (0,1,0,1));
                UI::Text("Personal Best (Discounted): ");
            }
            UI::PushFont(fontTime);
            UI::Indent();
            MoveCursor(vec2(0.0,-4.0));
            UI::Text(pbText);
            UI::Indent();
            UI::PopFont();
            if (loadedMap.personalBestDiscountTime > 0) UI::PopStyleColor();
            vec4 color = vec4(1.0,0.2,0.35,1.0);
            if (loadedMap.GetPBTime() <= loadedMap.targetTime)
                color = vec4(0.2,0.6,1.0,1.0);
            UI::PushStyleColor(UI::Col::Text, color);
            MoveCursor(vec2(0.0,8.0));
            UI::Text(pbDelta);
            UI::PopStyleColor();
            UI::Unindent();
            UI::Unindent();
            MoveCursor(vec2(0.0,2.0));
            UI::Separator();

            int total = data.victoryRequirement;
            UI::Indent();
            RenderMedalProgress(GetProgressionTex(), 60,data.items.GetProgressionMedalCount(), total);
            UI::Unindent();
            UI::Separator();

            bool gotAllChecks = data.locations.GotAllChecks(loadedMap.seriesIndex, loadedMap.mapIndex);
            int skipsAvailable = data.items.skips - data.items.skipsUsed;
            int discountsAvailable = data.items.discounts - data.items.discountsUsed;
            bool canSkip = !loadedMap.skipped && skipsAvailable > 0 && !gotAllChecks;
            UI::BeginDisabled(!canSkip);
            if(UI::ButtonColored(Icons::Repeat+" Skip Map (x"+skipsAvailable+")", 0.5)){
                if (canSkip){
                    loadedMap.Skip();
                }
            }
            UI::EndDisabled();
            bool canDiscount = discountsAvailable > 0 && !gotAllChecks;
            UI::BeginDisabled(!canDiscount);
            string discount = Time::Format(loadedMap.GetDiscountAmount(), true, false, false, false);
            if(UI::ButtonColored(Icons::Tag+" Lower PB by "+ discount +" (x"+discountsAvailable+")", 0.33)){
                if (canDiscount){
                    loadedMap.Discount();
                }
            }
            UI::EndDisabled();
            UI::Separator();

            UI::Text("Checks Left:");
            UI::Indent();
            DrawChecksRemaining(loadedMap.seriesIndex, loadedMap.mapIndex);
            UI::Unindent();
            UI::Separator();


        } else {
            UI::PushFont(fontHeader);
            UI::Text("Non-Game Map");
            UI::PopFont();
            MoveCursor(vec2(0.0,-3.0));
            UI::TextWrapped("Happy Hunting! ^-^");
            UI::Separator();

            if (data !is null){
                uint nextSeriesI = data.LatestUnlockedSeriesI()+1;
                if (nextSeriesI < data.world.Length){
                    UI::Text("Series "+(nextSeriesI+1)+" Unlock Progress:");
                    UI::Indent();
                    RenderMedalProgress(GetProgressionTex(),50,data.items.GetProgressionMedalCount(), data.world[nextSeriesI].medalRequirement);
                    UI::Unindent();
                }
                UI::Text("Victory Progress:");
                UI::Indent();
                int total = data.victoryRequirement;
                RenderMedalProgress(GetProgressionTex(),50,data.items.GetProgressionMedalCount(), total);
                UI::Unindent();
                UI::Separator();
            }
        }

        if (UI::ButtonColored(Icons::Map + " Back to Map Selection!", 0.66)){
            ClosePauseMenu();
            BackToMainMenu();
        }
    }
    UI::End();
    UI::PopStyleVar(5);
}