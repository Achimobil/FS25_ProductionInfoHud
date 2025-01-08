PIH_Display_DrawBox = {};

function PIH_Display_DrawBox.setBox(args)
-- ProductionInfoHud.DebugTable("PIH_Display_DrawBox.setBox", args);
    if args == nil or type(args) ~= "table" or args.typPos == nil or args.inArea == nil then return;end;
    local box = g_currentMission.hlHudSystem.box[args.typPos];
    if box == nil then return;end;
    if ProductionInfoHud.CurrentProductionItems == nil then return;end;

    local currentProductionItems = {};
    if box.ownTable.fillTypeFilter ~= nil then
        -- hier werden keine anderen Filter berücksichtigt und das soll so
        for _, productionItem in pairs(ProductionInfoHud.CurrentProductionItems) do
            if string.gsub(productionItem.fillTypeTitle, "*", "") == box.ownTable.fillTypeFilter then
                table.insert(currentProductionItems, productionItem);
            end
        end
        -- fallback
        if #currentProductionItems == 0 then
            currentProductionItems = ProductionInfoHud.CurrentProductionItems;
        end
    else
        -- hier alle klickbaren Filter kombinieren
        for _, productionItem in pairs(ProductionInfoHud.CurrentProductionItems) do
            local skipItem = false;
            if not skipItem and box.ownTable.ShowAnimal ~= nil and box.ownTable.ShowAnimal == false and productionItem.IsAnimal then
                skipItem = true;
            end
            if not skipItem and box.ownTable.ShowProduction ~= nil and box.ownTable.ShowProduction == false and productionItem.IsProduction then
                skipItem = true;
            end
            if not skipItem and box.ownTable.TimeFilter ~= nil and box.ownTable.TimeFilter ~= 1 then
                if box.ownTable.TimeFilter == 2 and productionItem.hoursLeft > 24 then
                    skipItem = true;
                elseif box.ownTable.TimeFilter == 3 and productionItem.hoursLeft > (24 * g_currentMission.environment.daysPerPeriod) then
                    skipItem = true;
                end
            end

            if not skipItem then
                table.insert(currentProductionItems, productionItem);
            end
        end
    end

    local inArea = args.inArea
    local boxNumber = args.typPos;

    local x, y, w, h = box:getScreen();

--     local mW = w/2;
--     local mH = h/2;

    local distance = box:getSize( {"distance"} );
    local difW = distance.textWidth --default width
    local difH = distance.textHeight; --default height
    local size = box.screen.size.zoomOutIn.text[1];
--     local difSize = 0.0015;

    local overlayDefaultGroup = box.overlays.icons["defaultIcons"]["box"];
    local overlayDefaultByName = box.overlays.icons.byName["defaultIcons"]["box"];
    local overlay = nil;
    local tempOverlay = nil;

    function needsUpdate()
        if box.needsUpdate or box.ownTable.lineHeight == nil then
            box.ownTable.lineHeight = getTextHeight(size, utf8Substr("Äg", 0))+distance.textLine;
            box.ownTable.iconWidth, box.ownTable.iconHeight = box:getOptiWidthHeight( {typ="icon", height=box.ownTable.lineHeight-distance.textLine-(difH), width=w-(difW*2)} );
            box.ownTable.timeWidth = getTextWidth(size, utf8Substr(" 99 Tage 23:23", 0));
            box.ownTable.fillTypeWidth = getTextWidth(size, utf8Substr(ProductionInfoHud.longestFillTypeTitle, 0));
            box.ownTable.textWidth = (w - box.ownTable.timeWidth - box.ownTable.fillTypeWidth - (difW*6));
            -- Wenn jetzt aber die Textbreite kleiner ist als die breite des Filltypes, dann beides gleich breit machen
            if box.ownTable.textWidth < box.ownTable.fillTypeWidth then
                local both = (box.ownTable.textWidth + box.ownTable.fillTypeWidth)/2
                box.ownTable.textWidth = both;
                box.ownTable.fillTypeWidth = both;
            end
            box:setMinWidth(box.ownTable.timeWidth * 3);
        end;
        box.needsUpdate = false;
    end;
    needsUpdate();

    if not g_currentMission.hlUtils.isMouseCursor then box.isSetting = false;end;

    local iconColor = nil;
    local iconWidth = box.ownTable.iconWidth;
    local iconHeight = box.ownTable.iconHeight;
    local iconWidthS = iconWidth/1.3;
    local iconSpace = iconWidthS + (2*difW);
    local iconHeightS = iconHeight/1.3;
    local nextPosX = x+(difW*3);
    local nextPosY = y;
    local nextIconPosX = x+difW;
    local nextLeftPosX = nextPosX+difW;
    local nextRightPosX = nextPosX;
    local timeFilterText = ProductionInfoHud.i18n:getText("pih_timeFilterOne");
    if g_currentMission.environment.daysPerPeriod ~= 1 then timeFilterText = ProductionInfoHud.i18n:getText("pih_timeFilterTwo"); end
    nextPosY = nextPosY+(h)-(box.ownTable.lineHeight)-difH;
    box.screen.bounds[4] = #currentProductionItems+1; -- +1 for Imaginäre Line wenn untergruppe an ist (viewAmountStorages/viewBestPriceStations etc.
    if box.viewExtraLine then box.screen.bounds[4] = box.screen.bounds[4]+1;end;


    function setInfoHelpText(txt, maxLine, txtColor) --global or mod
        if box.isSetting and box.settingTyp == 1 and g_currentMission.hlHudSystem.infoDisplay.on then --insert more text
            box:setMoreInfo(tostring(txt));
        else
            g_currentMission.hlHudSystem:addTextDisplay( {txt=tostring(txt), maxLine=maxLine, txtColor=txtColor} );
        end;
    end;


    if box.screen.bounds[1] > 0 then
        --warningLine--
        function setWarningLineIcon()
            overlay = overlayDefaultGroup[overlayDefaultByName["right"]];
            g_currentMission.hlUtils.setOverlay(overlay, x+w-((iconWidth/1.5/2)), nextPosY-0.003, iconWidth/1.5, iconHeight/1.5);
            g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(box.overlays.color.warning, true));
            local inIconArea = overlay.mouseInArea();
            if inIconArea and box.isHelp then setInfoHelpText(string.format(box:getI18n("hl_infoDisplay_viewNotAllIcons"), "Box"), 0);end;
            if g_currentMission.hlUtils.runsTimer("1sec", true) then
                overlay:render();
            end;
        end;
        --warningLine--
        --viewExtraLineSetting--
        function viewExtraLineSetting()
            if nextPosY < y then return;end;
            local setWarningLine = false;
            local inIconArea = false;
            --Text up--
            if nextIconPosX+iconWidth < x+w then
                overlay = overlayDefaultGroup[overlayDefaultByName["textUp"]];
                tempOverlay = box.overlays.bgLine;
                if overlay ~= nil and tempOverlay ~= nil then
                    g_currentMission.hlUtils.setOverlay(overlay, nextIconPosX, nextPosY, iconWidth, iconHeight);
                    inIconArea = overlay.mouseInArea();
                    if inIconArea then g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(box.overlays.color.inArea, true));else g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(box.overlays.color.text, true));end;
                    overlay:render();
                    if inIconArea and box.isHelp then setInfoHelpText(string.format(box:getI18n("pih_infoDisplay_textSize"), string.format("%1.0f", box.screen.size.zoomOutIn.text[1]*1000)));end;
                    if not g_currentMission.hlUtils:disableInArea() and inArea and inIconArea then box:setClickArea( {overlay.x, overlay.x+overlay.width, overlay.y, overlay.y+overlay.height, onClick=PIH_Display_MouseKeyEventsBox.onClickArea, whatClick="PIH_Display_Box", typPos=boxNumber, whereClick="settingTextSize_", ownTable={}} );end;
                    nextIconPosX = nextIconPosX+iconWidth+difW;
                end;
            else
                setWarningLine = true;
            end;
            --Text up--

            --line distance--
            if nextIconPosX+iconWidth < x+w then
                overlay = overlayDefaultGroup[overlayDefaultByName["lineHorizontalUpDown"]];
                tempOverlay = box.overlays.bgLine;
                if overlay ~= nil and tempOverlay ~= nil then
                    g_currentMission.hlUtils.setOverlay(overlay, nextIconPosX, nextPosY, iconWidth, iconHeight);
                    inIconArea = overlay.mouseInArea();
                    if inIconArea then g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(box.overlays.color.inArea, true));else g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(box.overlays.color.text, true));end;
                    overlay:render();
                    if inIconArea and box.isHelp then setInfoHelpText(string.format(box:getI18n("hl_infoDisplay_lineDistance"), string.format("%1.2f", box.screen.size.distance.textLine/box.screen.pixelH)));end;
                    if not g_currentMission.hlUtils:disableInArea() and inArea and inIconArea then box:setClickArea( {overlay.x, overlay.x+overlay.width, overlay.y, overlay.y+overlay.height, onClick=PIH_Display_MouseKeyEventsBox.onClickArea, whatClick="PIH_Display_Box", typPos=boxNumber, whereClick="settingLineDistance_", ownTable={}} );end;
                    nextIconPosX = nextIconPosX+iconWidth+difW;
                end;
            else
                setWarningLine = true;
            end;
            --line distance--

            if setWarningLine then
                setWarningLineIcon();
            end;
            nextPosY = nextPosY-box.ownTable.lineHeight;
        end;
        --viewExtraLineSetting--
        --viewExtraLine--
        function viewExtraLine()
            if nextPosY < y then return;end;
            local setWarningLine = false;
            local inIconArea = false;
            function setOverlay(whereClick, color, marked)
                if color == nil then color = box.overlays.color.notActive;end;
                g_currentMission.hlUtils.setOverlay(overlay, nextIconPosX, nextPosY, iconWidth, iconHeight);
                inIconArea = overlay.mouseInArea();
                g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(color, true));
                overlay:render();
                if not g_currentMission.hlUtils:disableInArea() and inArea and inIconArea and whereClick ~= nil then box:setClickArea( {overlay.x, overlay.x+overlay.width, overlay.y, overlay.y+overlay.height, onClick=PIH_Display_MouseKeyEventsBox.onClickArea, whatClick="PIH_Display_Box", typPos=boxNumber, whereClick=whereClick, ownTable={}} );end;
                if marked ~= nil and marked then
                    setTextColor(unpack(g_currentMission.hlUtils.getColor(box.overlays.color.warning, true)));
                    renderText(nextIconPosX, nextPosY+(iconHeight/1.6), size, tostring("*"));
                    setTextColor(1, 1, 1, 1);
                end;
                nextIconPosX = nextIconPosX+iconWidth+difW;
                iconColor = nil;
            end;

            --production filter--
            if nextIconPosX+iconWidth < x+w then
                overlay = overlayDefaultGroup[overlayDefaultByName["production"]];
                if overlay ~= nil then
                    if box.ownTable.ShowProduction then iconColor = box.overlays.color.on;end;
                    setOverlay("productionFilter_", iconColor);
                    if inIconArea and box.isHelp then setInfoHelpText(ProductionInfoHud.i18n:getText("pih_productionFilter"), 0);end;
                end;
            else
                setWarningLine = true;
            end;
            --production filter--

            --animal filter--
            if nextIconPosX+iconWidth < x+w then
                overlay = overlayDefaultGroup[overlayDefaultByName["animals"]];
                if overlay ~= nil then
                    if box.ownTable.ShowAnimal then iconColor = box.overlays.color.on;end;
                    setOverlay("animalFilter_", iconColor);
                    if inIconArea and box.isHelp then setInfoHelpText(ProductionInfoHud.i18n:getText("pih_animalFilter"), 0);end;
                end;
            else
                setWarningLine = true;
            end;
            --animal filter--

            --time filter--
            --etwas rüber rutschen damit von den anderen filtern getrennt
            nextIconPosX = nextIconPosX+iconWidth+difW;
            if nextIconPosX+iconWidth < x+w then
                overlay = overlayDefaultGroup[overlayDefaultByName["clock"]];
                if overlay ~= nil then
                    if box.ownTable.TimeFilter == 1 then iconColor = box.overlays.color.on;end;
                    if box.ownTable.TimeFilter == 2 then iconColor = box.overlays.color.warning;end;
                    setOverlay("timeFilter_", iconColor);
                    if inIconArea and box.isHelp then setInfoHelpText(timeFilterText, 0);end;
                end;
            else
                setWarningLine = true;
            end;
            --time filter--

            if setWarningLine then
                setWarningLineIcon();
            end;
            nextPosY = nextPosY-box.ownTable.lineHeight;
        end;

        if box.viewExtraLine and not box.isSetting then viewExtraLine();elseif box.viewExtraLine and box.isSetting then viewExtraLineSetting();end;
        --viewExtraLine--

        local color = g_currentMission.hlUtils.getColor(box.overlays.color.text, true);
        local colorOn = g_currentMission.hlUtils.getColor(box.overlays.color.on, true);
--         local maxTxtWidth = w-(difW*2);
        local bounds1 = box.screen.bounds[1];
        local bounds2 = box.screen.bounds[2];
        local extraLineBounds = 0;
        for t=bounds1, bounds2 do
            if nextPosY < y then break;end;

            -- Ab hier anzeige der Zeilen - Achim

            if currentProductionItems[t] ~= nil then
                local productionItem = currentProductionItems[t];

                local canNextView = true;
                local lineWidth = w-(difW*2);

                ---Production place---
                if canNextView then
                    setTextBold(true);
                    setTextColor(unpack(color));
                    setTextAlignment(0);
                    local text = g_currentMission.hlUtils.getTxtToWidth(tostring(productionItem.name), size, box.ownTable.textWidth, false, ".");
                    renderText(nextRightPosX, nextPosY, size, tostring(text));
                    setTextBold(false);
                    setTextColor(1, 1, 1, 1);
                    setTextAlignment(0);
                    lineWidth = lineWidth+box.ownTable.textWidth;
                    nextRightPosX = nextRightPosX+box.ownTable.textWidth;
                    canNextView = lineWidth > iconWidth;
                end;
                ---Production place---

                ---Filltype---
                if canNextView then
                    if productionItem.productionPerHour < 0 then
                        overlay = overlayDefaultGroup[overlayDefaultByName["selling"]];
                    else
                        overlay = overlayDefaultGroup[overlayDefaultByName["bying"]];
                    end
                    if overlay ~= nil then
                        g_currentMission.hlUtils.setOverlay(overlay, nextRightPosX + difW, nextPosY, iconWidthS, iconHeightS);
                        overlay:render();
                    end

                    nextRightPosX = nextRightPosX + iconSpace;

                    if box.ownTable.fillTypeFilter ~= nil then
                        setTextColor(unpack(colorOn));
                    else
                        setTextColor(unpack(color));
                    end
                    setTextAlignment(0);
                    local text = g_currentMission.hlUtils.getTxtToWidth(tostring(productionItem.fillTypeTitle), size, box.ownTable.fillTypeWidth - iconSpace, false, ".");
                    renderText(nextRightPosX, nextPosY, size, tostring(text));
                    setTextBold(false);
                    setTextColor(1, 1, 1, 1);
                    setTextAlignment(0);
                    if not g_currentMission.hlUtils:disableInArea() and inArea then box:setClickArea( {nextRightPosX, nextRightPosX+box.ownTable.timeWidth, nextPosY, nextPosY+box.ownTable.lineHeight, onClick=PIH_Display_MouseKeyEventsBox.onClickArea, whatClick="PIH_Display_Box", typPos=boxNumber, whereClick="filTypeColumn_", ownTable={ fillType = productionItem.fillTypeTitle }} );end;
                    lineWidth = lineWidth+box.ownTable.fillTypeWidth;
                    nextRightPosX = nextRightPosX + box.ownTable.fillTypeWidth - iconSpace;
                    canNextView = lineWidth > iconWidth;
                end;
                ---Filltype---

                ---data column---
                if canNextView then
                    local dataString = "";
                    if box.ownTable.dataViewMode == 1 then
                        -- mode 1 = Time left
                        dataString = tostring(productionItem.TimeLeftString);
                    elseif box.ownTable.dataViewMode == 2 then
                        -- mode 2 = Capacity left
                        dataString = string.format("%d", productionItem.capacityData);
                    elseif box.ownTable.dataViewMode == 3 then
                        -- mode 3 = production amount
                        dataString = string.format("%1.1f", productionItem.productionPerHour);
                    end

                    setTextColor(unpack(color));
                    setTextAlignment(2);
                    renderText(nextRightPosX + box.ownTable.timeWidth, nextPosY, size, dataString);
                    setTextBold(false);
                    setTextColor(1, 1, 1, 1);
                    setTextAlignment(0);
                    if not g_currentMission.hlUtils:disableInArea() and inArea then box:setClickArea( {nextRightPosX, nextRightPosX+box.ownTable.timeWidth, nextPosY, nextPosY+box.ownTable.lineHeight, onClick=PIH_Display_MouseKeyEventsBox.onClickArea, whatClick="PIH_Display_Box", typPos=boxNumber, whereClick="dataColumn_", ownTable={}} );end;
                    lineWidth = lineWidth+box.ownTable.timeWidth;
                    nextRightPosX = nextRightPosX+box.ownTable.timeWidth;
                    canNextView = lineWidth > iconWidth;
                end;
                ---data column---

                nextPosY = nextPosY-box.ownTable.lineHeight;
                nextRightPosX = nextPosX;
            elseif #currentProductionItems == 0 then
                local moreTxt = "";
                if not box.viewExtraLine and box.searchFilter:len() > 0 then moreTxt = tostring(ProductionInfoHud.i18n:getText("searchFilter_On"));end;
                local text = g_currentMission.hlUtils.getTxtToWidth(tostring(ProductionInfoHud.i18n:getText("character_option_none")).. moreTxt, size, w-(difW*2), false, ".");
                setTextColor(unpack(g_currentMission.hlUtils.getColor(box.overlays.color.text, true)));
                renderText(nextLeftPosX, nextPosY, size, tostring(text));
                setTextColor(1, 1, 1, 1);
                break;
            end;
            if extraLineBounds+t >= bounds2 then break;end;
        end;
        box.screen.bounds[4] = box.screen.bounds[4]+extraLineBounds;
    end;
end;