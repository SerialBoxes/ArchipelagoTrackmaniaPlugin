void RenderMainMenu(){

    //UI::SetNextWindowSize(600, 400, UI::Cond::Always);
    UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
    UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(12, 12));
    UI::PushStyleVar(UI::StyleVar::WindowRounding, 16.0);
    UI::PushStyleVar(UI::StyleVar::FrameRounding, 8.0);
    int flags = UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking | UI::WindowFlags::AlwaysAutoResize;
    if (UI::Begin("Archipelago - Menu", isOpen, flags)){

        if (data is null){
            UI::Text("Awaiting Server Connection...");
        }else{
            vec2 viewSize = vec2(500,700);
            float manMarn = 4;
            bool seriesInitializing = false;
            UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(4, 8));
            UI::BeginChild("Serieses", viewSize);
            if (!shownBefore){
                shownBefore = true;
                UI::SetScrollHereY();
            }
            UI::NewLine();
            for (uint i = 0; i < data.world.Length; i++){
                UI::Separator();
                MoveCursor(vec2(0,manMarn));
                UI::PushFont(fontHeader);
                UI::Text ("Series " + (i+1));
                UI::PopFont();
                MoveCursor(vec2(0,manMarn));
                if (data.world[i].IsUnlocked() && data.world[i].initialized){
                    for (int j = 0; j < data.world[i].mapCount; j++){

                        auto startPos = UI::GetCursorPos() + UI::GetWindowPos() -
                        vec2(8, 8) - vec2(0, UI::GetScrollY());

                        UI::BeginGroup();
                        float lineHeight = 100;
                        MapState@ map = data.world[i].maps[j];

                        vec2 cursorStart = UI::GetCursorPos();
                        UI::Text("Map "+(j+1)+" Hello!!! :)");
                        vec2 cursorEnd = UI::GetCursorPos();
                        if (data.locations.GotAllChecks(map.seriesIndex, map.mapIndex) || map.skipped){
                            vec2 centerPos = cursorStart + vec2(lineHeight/2,viewSize.x/2);
                            UI::SetCursorPos(centerPos);
                            vec4 iconColor = vec4(0.1,0.6,0.12,1.0);
                            if (map.skipped) iconColor = vec4(0.1,0.12,0.6,1.0);
                            UI::PushStyleColor(UI::Col::Text,iconColor);
                            RenderTextCentered(Icons::Circle,fontHuge);
                            UI::PopStyleColor();
                            UI::SetCursorPos(centerPos);
                            MoveCursor(vec2(4,8));
                            if (map.skipped){
                                RenderTextCentered(Icons::Refresh,fontHeader);
                            }else{
                                RenderTextCentered(Icons::Check,fontHeader);
                            }

                            UI::SetCursorPos(cursorEnd);
                        }

                        // UI::BeginChild("##Map Name" + j, vec2(cellSize, UI::GetTextLineHeight()));
                        // UI::Text("Map "+(j+1) /*+ ": " + data.world[i].maps[j].mapInfo.Name*/);
                        // UI::EndChild();

                        UI::EndGroup();

                        auto size = UI::GetCursorPos() + UI::GetWindowPos() + vec2(0, 8) - startPos -vec2(0, UI::GetScrollY());
                        vec4 rect = vec4(startPos.x, startPos.y, 50, size.y);
                        //UI::GetWindowDrawList().AddRectFilled(rect, vec4(.0, .6, .6, 0.1));

                        if (UI::IsItemHovered()){
                            RenderTooltip(data.world[i].maps[j]);
                        }
                        if(UI::IsItemClicked()){
                            LoadMapByIndex(i,j);
                        }
                    }
                }else if (!data.world[i].IsUnlocked()){
                    UI::NewLine();
                    MoveCursor(vec2(viewSize.x/2,0));
                    RenderTextCentered(Icons::Lock, fontHeader);
                    MoveCursor(vec2(-viewSize.x/2,0));
                    UI::NewLine();
                    UI::NewLine();
                }else{
                    if (data.world[i].initializing || seriesInitializing){
                        seriesInitializing = true;
                        UI::Indent();
                        UI::Text("Rolling Maps...");
                        UI::NewLine();
                        UI::Unindent();
                    }else{
                        UI::Indent();
                        UI::Text("Maps could not been rolled.");
                        UI::Unindent();
                        if (UI::ButtonColored("Force Load Maps", 0)){
                            startnew(CoroutineFunc(data.world[i].Initialize));
                        }
                    }
                    UI::NewLine();
                    UI::NewLine();
                    UI::NewLine();
                }
                MoveCursor(vec2(0,manMarn));
                UI::Separator();
                MoveCursor(vec2(0,manMarn));

                uint nextSeries = i+1;
                int count = data.items.GetProgressionMedalCount();
                int total = (nextSeries < data.world.Length) ? data.world[nextSeries].medalRequirement : data.victoryRequirement;
                int size = 60;
                float medalOffset = (viewSize.x/2)-((size+Draw::MeasureString(""+count+"/"+total,fontHeaderSub).x)/2+16*UI::GetScale());
                RenderSeriesLine(nextSeries,viewSize,40,4,8);
                MoveCursor(vec2(medalOffset,-15.0));
                RenderMedalProgress(GetProgressionTex(),size,count,total);
                MoveCursor(vec2(-medalOffset,-15.0));
                RenderSeriesLine(nextSeries,viewSize,40,4,8);
                MoveCursor(vec2(0,manMarn));
                if (nextSeries >= data.world.Length){
                    MoveCursor(vec2(0,10));
                    string text = "Victory";
                    if (count >= total) text = "Victory!!!!! :D";
                    UI::PushFont(fontHeader);
                    vec4 color = vec4(0.5,0.5,0.5,1.0);
                    if (count >= total){
                        color = (vec4(0.0,1.0,0.1,1.0));
                    }
                    UI::PushStyleColor(UI::Col::Text,color);
                    vec2 stringSize = Draw::MeasureString(text,fontHeader);
                    float textOffset = (viewSize.x/2)-(stringSize.x/2);
                    MoveCursor(vec2(textOffset,0.0));
                    UI::Text(text);
                    MoveCursor(vec2(-textOffset,0.0));
                    UI::PopStyleColor();
                    UI::PopFont();
                    UI::NewLine();
                }
            }
            UI::EndChild();
            UI::PopStyleVar(1);
            UI::Separator();

            // int total = data.victoryRequirement;
            // UI::Text("Victory Progress: ");
            // UI::Indent();
            // RenderMedalProgress(GetProgressionTex(),60, data.items.GetProgressionMedalCount(),total);
            // UI::Unindent();
            // UI::Separator();

            if (UI::ButtonColored(Icons::Times+" Disconnect", 0.0)){
                socket.Close();
            }
        }
    }
    UI::End();
    UI::PopStyleVar(4);
        
}


void RenderMainMenuThumbnail(){

    //UI::SetNextWindowSize(600, 400, UI::Cond::Always);
    UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
    UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(12, 12));
    UI::PushStyleVar(UI::StyleVar::WindowRounding, 16.0);
    UI::PushStyleVar(UI::StyleVar::FrameRounding, 8.0);
    int flags = UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking | UI::WindowFlags::AlwaysAutoResize;
    if (UI::Begin("Archipelago - Menu", isOpen, flags)){

        if (data is null){
            UI::Text("Awaiting Server Connection...");
        }else{
            vec2 viewSize = vec2(500,700);
            float manMarn = 4;
            bool seriesInitializing = false;
            UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(4, 8));
            UI::BeginChild("Serieses", viewSize);
            if (!shownBefore){
                shownBefore = true;
                UI::SetScrollHereY();
            }
            UI::NewLine();
            for (uint i = 0; i < data.world.Length; i++){
                UI::Separator();
                MoveCursor(vec2(0,manMarn));
                UI::PushFont(fontHeader);
                UI::Text ("Series " + (i+1));
                UI::PopFont();
                MoveCursor(vec2(0,manMarn));
                if (data.world[i].IsUnlocked() && data.world[i].initialized){
                    UI::PushStyleVar(UI::StyleVar::CellPadding, vec2(8, 8));
                    UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(4, 4));
                    UI::BeginTable("Series_Table_"+i, 5);
                    for (int j = 0; j < data.world[i].mapCount; j++){
                        UI::TableNextColumn();

                        auto startPos = UI::GetCursorPos() + UI::GetWindowPos() -
                        vec2(8, 8) - vec2(0, UI::GetScrollY());

                        UI::BeginGroup();
                        float cellSize = (viewSize.x-8) /5 - 8;
                        MapState@ map = data.world[i].maps[j];

                        vec2 cursorStart = UI::GetCursorPos();
                        vec2 thumbnailSize = vec2(cellSize, cellSize);
                        if (map.thumbnail !is null) {
                            UI::Image(map.thumbnail, thumbnailSize);
                        } else {
                            UI::Dummy(thumbnailSize);
                        }
                        vec2 cursorEnd = UI::GetCursorPos();
                        if (data.locations.GotAllChecks(map.seriesIndex, map.mapIndex) || map.skipped){
                            vec2 centerPos = cursorStart + vec2(cellSize/2,cellSize/2);
                            UI::SetCursorPos(centerPos);
                            vec4 iconColor = vec4(0.1,0.6,0.12,1.0);
                            if (map.skipped) iconColor = vec4(0.1,0.12,0.6,1.0);
                            UI::PushStyleColor(UI::Col::Text,iconColor);
                            RenderTextCentered(Icons::Circle,fontHuge);
                            UI::PopStyleColor();
                            UI::SetCursorPos(centerPos);
                            MoveCursor(vec2(4,8));
                            if (map.skipped){
                                RenderTextCentered(Icons::Refresh,fontHeader);
                            }else{
                                RenderTextCentered(Icons::Check,fontHeader);
                            }

                            UI::SetCursorPos(cursorEnd);
                        }

                        UI::BeginChild("##Map Name" + j, vec2(cellSize, UI::GetTextLineHeight()));
                        UI::Text("Map "+(j+1) /*+ ": " + data.world[i].maps[j].mapInfo.Name*/);
                        UI::EndChild();

                        UI::EndGroup();

                        auto size = UI::GetCursorPos() + UI::GetWindowPos() + vec2(0, 8) - startPos -vec2(0, UI::GetScrollY());
                        vec4 rect = vec4(startPos.x, startPos.y, 50, size.y);
                        //UI::GetWindowDrawList().AddRectFilled(rect, vec4(.0, .6, .6, 0.1));

                        if (UI::IsItemHovered()){
                            RenderTooltip(data.world[i].maps[j]);
                        }
                        if(UI::IsItemClicked()){
                            LoadMapByIndex(i,j);
                        }
                    }
                    UI::EndTable();
                    UI::PopStyleVar(2);
                }else if (!data.world[i].IsUnlocked()){
                    UI::NewLine();
                    MoveCursor(vec2(viewSize.x/2,0));
                    RenderTextCentered(Icons::Lock, fontHeader);
                    MoveCursor(vec2(-viewSize.x/2,0));
                    UI::NewLine();
                    UI::NewLine();
                }else{
                    if (data.world[i].initializing || seriesInitializing){
                        seriesInitializing = true;
                        UI::Indent();
                        UI::Text("Rolling Maps...");
                        UI::NewLine();
                        UI::Unindent();
                    }else{
                        UI::Indent();
                        UI::Text("Maps could not been rolled.");
                        UI::Unindent();
                        if (UI::ButtonColored("Force Load Maps", 0)){
                            startnew(CoroutineFunc(data.world[i].Initialize));
                        }
                    }
                    UI::NewLine();
                    UI::NewLine();
                    UI::NewLine();
                }
                MoveCursor(vec2(0,manMarn));
                UI::Separator();
                MoveCursor(vec2(0,manMarn));

                uint nextSeries = i+1;
                int count = data.items.GetProgressionMedalCount();
                int total = (nextSeries < data.world.Length) ? data.world[nextSeries].medalRequirement : data.victoryRequirement;
                int size = 60;
                float medalOffset = (viewSize.x/2)-((size+Draw::MeasureString(""+count+"/"+total,fontHeaderSub).x)/2+16*UI::GetScale());
                RenderSeriesLine(nextSeries,viewSize,40,4,8);
                MoveCursor(vec2(medalOffset,-15.0));
                RenderMedalProgress(GetProgressionTex(),size,count,total);
                MoveCursor(vec2(-medalOffset,-15.0));
                RenderSeriesLine(nextSeries,viewSize,40,4,8);
                MoveCursor(vec2(0,manMarn));
                if (nextSeries >= data.world.Length){
                    MoveCursor(vec2(0,10));
                    string text = "Victory";
                    if (count >= total) text = "Victory!!!!! :D";
                    UI::PushFont(fontHeader);
                    vec4 color = vec4(0.5,0.5,0.5,1.0);
                    if (count >= total){
                        color = (vec4(0.0,1.0,0.1,1.0));
                    }
                    UI::PushStyleColor(UI::Col::Text,color);
                    vec2 stringSize = Draw::MeasureString(text,fontHeader);
                    float textOffset = (viewSize.x/2)-(stringSize.x/2);
                    MoveCursor(vec2(textOffset,0.0));
                    UI::Text(text);
                    MoveCursor(vec2(-textOffset,0.0));
                    UI::PopStyleColor();
                    UI::PopFont();
                    UI::NewLine();
                }
            }
            UI::EndChild();
            UI::PopStyleVar(1);
            UI::Separator();

            // int total = data.victoryRequirement;
            // UI::Text("Victory Progress: ");
            // UI::Indent();
            // RenderMedalProgress(GetProgressionTex(),60, data.items.GetProgressionMedalCount(),total);
            // UI::Unindent();
            // UI::Separator();

            if (UI::ButtonColored(Icons::Times+" Disconnect", 0.0)){
                socket.Close();
            }
        }
    }
    UI::End();
    UI::PopStyleVar(4);
        
}

void RenderTooltip(MapState@ map){
    UI::BeginTooltip();
    UI::Text(map.mapInfo.Name);
    UI::Indent();
    UI::Text("by "+map.mapInfo.Username);
    DrawTags(map, false);
    UI::Unindent();
    UI::Text("Checks Left:");
    UI::Indent();
    DrawChecksRemaining(map.seriesIndex, map.mapIndex);
    UI::Unindent();

    UI::EndTooltip();
}

void RenderSeriesLine(uint seriesI, vec2 viewSize, float height, float width, float margin){
    vec2 cursorPos = UI::GetCursorPos();
    cursorPos.x = 0;
    UI::SetCursorPos(cursorPos);
    MoveCursor(vec2(0,margin));
    vec2 starPos = UI::GetCursorPos() +UI::GetWindowPos() - vec2(0, UI::GetScrollY())+ vec2(viewSize.x/2,0.0);
    MoveCursor(vec2(0,height));
    vec2 endPos = UI::GetCursorPos() +UI::GetWindowPos() - vec2(0, UI::GetScrollY())+ vec2(viewSize.x/2,0.0);
    vec4 rect = vec4(starPos.x - (width/2),starPos.y,width,endPos.y - starPos.y);
    MoveCursor(vec2(0,margin));

    int total = (seriesI < data.world.Length) ? data.world[seriesI].medalRequirement : data.victoryRequirement;
    int count = data.items.GetProgressionMedalCount();
    vec4 color = vec4(0.35,0.35,0.35,1.0);
    if (count >= total){
        color = vec4(0.0,1.0,0.1,1.0);
    }
    UI::GetWindowDrawList().AddRectFilled(rect, color,width/2);
}