PIH_Display_DrawBox = {};

function PIH_Display_DrawBox.setBox(args)
-- ProductionInfoHud.DebugTable("PIH_Display_DrawBox.setBox", args);
    if args == nil or type(args) ~= "table" or args.typPos == nil or args.inArea == nil then return;end;
    local box = g_currentMission.hlHudSystem.box[args.typPos];
    if box == nil then return;end;
    if ProductionInfoHud.CurrentProductionItems == nil then return;end;

    local currentProductionItems;
    local isLoadedCargoFilterActive = false;
    local isLoadedCargoFilterBySupportedTypes = false;
    local isLoadedCargoFilterHasDeliver = false;
    local isLoadedCargoFilterHasRefill = false;

    -- Gefilterte Liste cachen: nur neu bauen wenn sich die Rohdaten geändert haben (alle 5s), ein Filter angeklickt wurde,
    -- oder bei aktivem LoadedCargoFilter mindestens 1s seit der letzten Prüfung vergangen ist (Ladung ändert sich ohne Klick).
    local needsFilterRebuild = box.filterCacheDirty
        or box.filterCacheSourceItems ~= ProductionInfoHud.CurrentProductionItems
        or (box.ownTable.LoadedCargoFilter and (box.filterCacheLastCargoCheckTime == nil or getTimeSec() - box.filterCacheLastCargoCheckTime >= 1));

    if not needsFilterRebuild then
        currentProductionItems = box.filterCacheItems;
        isLoadedCargoFilterActive = box.filterCacheIsLoadedCargoFilterActive;
        isLoadedCargoFilterBySupportedTypes = box.filterCacheIsLoadedCargoFilterBySupportedTypes;
        isLoadedCargoFilterHasDeliver = box.filterCacheIsLoadedCargoFilterHasDeliver;
        isLoadedCargoFilterHasRefill = box.filterCacheIsLoadedCargoFilterHasRefill;
    else
        currentProductionItems = {};
        if box.ownTable.fillTypeFilterIds ~= nil then
            -- Angeklickt wurde eine Zeile für mehrere Sorten, gesucht sind alle Einträge zu diesen Sorten.
            -- Eine Summenzeile gibt es hier nicht: verschiedene Waren zusammenzuzählen ergibt keine Aussage.
            -- Andere Filter werden wie beim Titel-Filter bewusst nicht berücksichtigt.
            for _, productionItem in pairs(ProductionInfoHud.CurrentProductionItems) do
                if ProductionInfoHud.MatchesFillTypeFilter(productionItem, box.ownTable.fillTypeFilterIds)
                    and ProductionInfoHud.GetIsStorageItemVisible(productionItem, box.ownTable.ShowStorage, true, false) then
                    table.insert(currentProductionItems, productionItem);
                end
            end

            -- fallback
            if #currentProductionItems == 0 then
                currentProductionItems = ProductionInfoHud.CurrentProductionItems;
            end
        elseif box.ownTable.fillTypeFilter ~= nil then
            -- summary item erstellen
            local sumItem = {};
            sumItem.name = "-";
            sumItem.fillTypeTitle = "Total";
            sumItem.fillLevel = 0;
            sumItem.productionPerHour = 0;

            -- hier werden keine anderen Filter berücksichtigt und das soll so
            for _, productionItem in pairs(ProductionInfoHud.CurrentProductionItems) do
                if string.gsub(productionItem.fillTypeTitle, "*", "") == box.ownTable.fillTypeFilter
                    and ProductionInfoHud.GetIsStorageItemVisible(productionItem, box.ownTable.ShowStorage, true, false) then
                    table.insert(currentProductionItems, productionItem);
                    sumItem.productionPerHour = sumItem.productionPerHour + productionItem.productionPerHour;
                end
            end

            -- fallback
            if #currentProductionItems == 0 then
                currentProductionItems = ProductionInfoHud.CurrentProductionItems;
            else
                if box.ownTable.dataViewMode == 3 then
                    -- sum item einfügen, wenn mode production per hour ist
                    table.insert(currentProductionItems, sumItem);
                end
            end
        elseif box.ownTable.nameFilter ~= nil then
            -- hier werden keine anderen Filter berücksichtigt und das soll so
            for _, productionItem in pairs(ProductionInfoHud.CurrentProductionItems) do
                if productionItem.name == box.ownTable.nameFilter
                    and ProductionInfoHud.GetIsStorageItemVisible(productionItem, box.ownTable.ShowStorage, true, false) then
                    table.insert(currentProductionItems, productionItem);
                end
            end
            -- fallback
            if #currentProductionItems == 0 then
                currentProductionItems = ProductionInfoHud.CurrentProductionItems;
            end
        else
            -- hier alle klickbaren Filter kombinieren
            local deliverFillTypes = nil;
            local refillFillTypes = nil;
            local pickupFillTypes = nil;
            if box.ownTable.LoadedCargoFilter then
                local deliver, refill, pickup, isBySupportedTypes = ProductionInfoHud.GetCargoFilterFillTypes();
                -- beide Richtungen leer (z.B. ein Paletten- oder Ballenanhänger) -> Filter ignorieren statt alles auszublenden
                if next(deliver) ~= nil or next(refill) ~= nil then
                    deliverFillTypes = deliver;
                    refillFillTypes = refill;
                    pickupFillTypes = pickup;
                    isLoadedCargoFilterHasDeliver = next(deliver) ~= nil;
                    isLoadedCargoFilterHasRefill = next(refill) ~= nil;
                    isLoadedCargoFilterBySupportedTypes = isBySupportedTypes;
                end
            end
            isLoadedCargoFilterActive = deliverFillTypes ~= nil;
            local isFilteringByLoadedCargo = isLoadedCargoFilterActive and not isLoadedCargoFilterBySupportedTypes;

            -- Eine Lagerzeile beantwortet nur die Frage nach einem Abladeort oder einer Nachfüllstelle, sie hat keine
            -- Restzeit und drängt sich in der normalen Liste nur vor. Sie erscheint deshalb allein beim Fracht-Filter.
            -- Ein Lager ohne Bestand hilft dabei nur beim Abladen, und auch das nur wenn wirklich etwas geladen ist.
            local isStorageDataVisible = isLoadedCargoFilterActive;

            for _, productionItem in pairs(ProductionInfoHud.CurrentProductionItems) do
                local skipItem = false;
                if not skipItem and box.ownTable.ShowAnimal ~= nil and box.ownTable.ShowAnimal == false and productionItem.IsAnimal then
                    skipItem = true;
                end
                if not skipItem and box.ownTable.ShowProduction ~= nil and box.ownTable.ShowProduction == false and productionItem.IsProduction then
                    skipItem = true;
                end
                if not skipItem and box.ownTable.AutoDeliverFilter ~= nil and box.ownTable.AutoDeliverFilter == false and productionItem.isAutoDeliver == true then
                    skipItem = true;
                end
                if not skipItem and not ProductionInfoHud.GetIsStorageItemVisible(productionItem, box.ownTable.ShowStorage, isStorageDataVisible, isFilteringByLoadedCargo) then
                    skipItem = true;
                end
                -- Die Zuordnung gilt nur für den aktuellen Durchlauf, deshalb vorher zurücksetzen
                productionItem.cargoMatchFillTypeId = nil;
                productionItem.cargoDirection = nil;
                if not skipItem and deliverFillTypes ~= nil and refillFillTypes ~= nil then
                    local matchingFillTypeId = nil;
                    -- Ein Lager nimmt an und gibt ab, passt also zu beiden Richtungen. Gefragt ist dann der Bestand:
                    -- wer eine Ware verbraucht, sucht Nachschub, und abladen kann er sie zur Not auch woanders.
                    -- Als Nachfüllstelle taugt ohnehin nur, wo die Ware tatsächlich liegt.
                    if productionItem.isOutput and (productionItem.fillLevel or 0) > 0 then
                        matchingFillTypeId = ProductionInfoHud.GetMatchingOwnFillType(productionItem, refillFillTypes);

                        -- Ein leeres Fahrzeug sucht auch Ladung: was es transportieren kann und gerade irgendwo anfällt.
                        -- Ein Lager bleibt dabei außen vor, es läuft nicht voll und würde die Liste nur mit jeder
                        -- eingelagerten Sorte überschwemmen.
                        if matchingFillTypeId == nil and not productionItem.IsStorage then
                            matchingFillTypeId = ProductionInfoHud.GetMatchingOwnFillType(productionItem, pickupFillTypes);
                        end

                        if matchingFillTypeId ~= nil then
                            productionItem.cargoDirection = ProductionInfoHud.CARGO_DIRECTION_REFILL;
                        end
                    end

                    -- Ein Lager taugt nur als Abladeort, wenn wirklich etwas geladen ist. Steht dahinter nur die
                    -- Transportfähigkeit, wäre jedes Lager mit freiem Platz dabei, und ohne Restzeit auch noch
                    -- an jedem Zeitfilter vorbei.
                    if matchingFillTypeId == nil and productionItem.isInput
                        and (not productionItem.IsStorage or isFilteringByLoadedCargo) then
                        matchingFillTypeId = ProductionInfoHud.GetMatchingTargetFillType(productionItem, deliverFillTypes);
                        if matchingFillTypeId ~= nil then
                            productionItem.cargoDirection = ProductionInfoHud.CARGO_DIRECTION_DELIVER;
                        end
                    end

                    if matchingFillTypeId == nil then
                        skipItem = true;
                    else
                        -- Zeilen für mehrere Sorten sortieren und beschriften sich über die Sorte, die zur Ware passt
                        productionItem.cargoMatchFillTypeId = matchingFillTypeId;
                    end
                end
                -- Bei geladener Ware ("wo bring ich das hin") und bei Nachfüllstellen zählt jeder Treffer, unabhängig vom Zeitfilter.
                -- Ein Lager hat keine Restzeit und fällt damit ohnehin nicht unter den Zeitfilter.
                local isTimeFilterSuspended = isFilteringByLoadedCargo or productionItem.cargoDirection == ProductionInfoHud.CARGO_DIRECTION_REFILL;
                if not skipItem and not isTimeFilterSuspended and productionItem.hoursLeft ~= nil and box.ownTable.TimeFilter ~= nil and box.ownTable.TimeFilter ~= 1 then
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

            if isFilteringByLoadedCargo or isLoadedCargoFilterHasRefill then
                -- bei geladener Ware und bei Nachfüllstellen nach Sorte gruppieren statt nach Restzeit; filtert nur die Fahrzeug-Fähigkeit, bleibt die normale Sortierung
                table.sort(currentProductionItems, ProductionInfoHud.compProductionTableByFillTypeAndFreeCapacity);
            end
        end

        box.filterCacheItems = currentProductionItems;
        box.filterCacheIsLoadedCargoFilterActive = isLoadedCargoFilterActive;
        box.filterCacheIsLoadedCargoFilterBySupportedTypes = isLoadedCargoFilterBySupportedTypes;
        box.filterCacheIsLoadedCargoFilterHasDeliver = isLoadedCargoFilterHasDeliver;
        box.filterCacheIsLoadedCargoFilterHasRefill = isLoadedCargoFilterHasRefill;
        box.filterCacheSourceItems = ProductionInfoHud.CurrentProductionItems;
        box.filterCacheDirty = false;
        if box.ownTable.LoadedCargoFilter then
            box.filterCacheLastCargoCheckTime = getTimeSec();
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

    local function needsUpdate()
        if box.needsUpdate or box.ownTable.lineHeight == nil then
            box.ownTable.lineHeight = getTextHeight(size, utf8Substr("Äg", 0))+distance.textLine;
            box.ownTable.iconWidth, box.ownTable.iconHeight = box:getOptiWidthHeight( {typ="icon", height=box.ownTable.lineHeight-distance.textLine-(difH), width=w-(difW*2)} );
            box.ownTable.iconSpace = (box.ownTable.iconWidth/1.3) + (2*difW);
            box.ownTable.timeWidth = getTextWidth(size, utf8Substr(" 99 Tage 23:23", 0));
            -- Der Platz fürs Icon gehört mit in die Spaltenbreite: gezeichnet wird der Text mit fillTypeWidth abzüglich dieses Platzes,
            -- ohne ihn passt gerade der längste Titel nicht hinein, obwohl er die Spalte bemisst.
            box.ownTable.fillTypeWidth = getTextWidth(size, utf8Substr(ProductionInfoHud.longestFillTypeTitle, 0)) + box.ownTable.iconSpace;
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
    local iconSpace = box.ownTable.iconSpace;
    local iconHeightS = iconHeight/1.3;
    local nextPosX = x+(difW*3);
    local nextPosY = y;
    local nextIconPosX = x+difW;
    local nextLeftPosX = nextPosX+difW;
    local nextRightPosX = nextPosX;
    local timeFilterText = ProductionInfoHud.i18n:getText("pih_timeFilterOne");
    if g_currentMission.environment.daysPerPeriod ~= 1 then timeFilterText = ProductionInfoHud.i18n:getText("pih_timeFilterTwo"); end
    nextPosY = nextPosY+(h)-(box.ownTable.lineHeight)-difH;
    box.screen.bounds[4] = #currentProductionItems; -- +1 for Imaginäre Line wenn untergruppe an ist (viewAmountStorages/viewBestPriceStations etc.
    if box.viewExtraLine then box.screen.bounds[4] = box.screen.bounds[4]+1;end;
    if isLoadedCargoFilterActive then box.screen.bounds[4] = box.screen.bounds[4]+1;end; -- +1 für den nicht-scrollenden Cargo-Filter-Hinweis


    local function setInfoHelpText(txt, maxLine, txtColor)
        if box.isSetting and box.settingTyp == 1 and g_currentMission.hlHudSystem.infoDisplay.on then --insert more text
            box:setMoreInfo(tostring(txt));
        else
            g_currentMission.hlHudSystem:addTextDisplay( {txt=tostring(txt), maxLine=maxLine, txtColor=txtColor} );
        end;
    end;


    if box.screen.bounds[1] > 0 then
        --warningLine--
        local function setWarningLineIcon()
            overlay = overlayDefaultGroup[overlayDefaultByName["right"]];
            if overlay == nil then return; end;
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
        local function viewExtraLineSetting()
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
        local function viewExtraLine()
            if nextPosY < y then return;end;
            local setWarningLine = false;
            local inIconArea = false;
            local function setOverlay(whereClick, color, marked)
                if overlay == nil then return; end;
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

            --storage filter--
            if nextIconPosX+iconWidth < x+w then
                overlay = overlayDefaultGroup[overlayDefaultByName["fillamount"]];
                if overlay ~= nil then
                    if box.ownTable.ShowStorage then iconColor = box.overlays.color.on;end;
                    setOverlay("storageFilter_", iconColor);
                    if inIconArea and box.isHelp then setInfoHelpText(ProductionInfoHud.i18n:getText("pih_storageFilter"), 0);end;
                end;
            else
                setWarningLine = true;
            end;
            --storage filter--

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

            --AutoDeliverFilter filter--
            --etwas rüber rutschen damit von den anderen filtern getrennt
            nextIconPosX = nextIconPosX+iconWidth+difW;
            if nextIconPosX+iconWidth < x+w then
                overlay = overlayDefaultGroup[overlayDefaultByName["production_directdeliver"]];
                if overlay ~= nil then
                    if box.ownTable.AutoDeliverFilter then iconColor = box.overlays.color.on;end;
                    setOverlay("autoDeliverFilter_", iconColor);
                    if inIconArea and box.isHelp then setInfoHelpText(ProductionInfoHud.i18n:getText("pih_autoDeliverFilter"), 0);end;
                end;
            else
                setWarningLine = true;
            end;
            --AutoDeliverFilter filter--

            --LoadedCargoFilter filter--
            if nextIconPosX+iconWidth < x+w then
                overlay = overlayDefaultGroup[overlayDefaultByName["trailerfull"]];
                if overlay ~= nil then
                    if box.ownTable.LoadedCargoFilter then iconColor = box.overlays.color.on;end;
                    setOverlay("loadedCargoFilter_", iconColor);
                    if inIconArea and box.isHelp then setInfoHelpText(ProductionInfoHud.i18n:getText("pih_loadedCargoFilter"), 0);end;
                end;
            else
                setWarningLine = true;
            end;
            --LoadedCargoFilter filter--

            if setWarningLine then
                setWarningLineIcon();
            end;
            nextPosY = nextPosY-box.ownTable.lineHeight;
        end;

        if box.viewExtraLine and not box.isSetting then viewExtraLine();elseif box.viewExtraLine and box.isSetting then viewExtraLineSetting();end;
        --viewExtraLine--

        --loadedCargoFilterHint--
        if isLoadedCargoFilterActive and nextPosY >= y then
            local hintKey;
            if isLoadedCargoFilterHasDeliver and isLoadedCargoFilterHasRefill then
                hintKey = "pih_cargoFilterBothActive";
            elseif isLoadedCargoFilterHasRefill then
                hintKey = "pih_refillFilterActive";
            elseif isLoadedCargoFilterBySupportedTypes then
                hintKey = "pih_vehicleCapabilityFilterActive";
            else
                hintKey = "pih_loadedCargoFilterActive";
            end
            local hintText = g_currentMission.hlUtils.getTxtToWidth(tostring(ProductionInfoHud.i18n:getText(hintKey)), size, w-(difW*2), false, ".");
            setTextBold(true);
            setTextColor(unpack(g_currentMission.hlUtils.getColor(box.overlays.color.on, true)));
            renderText(nextLeftPosX, nextPosY, size, tostring(hintText));
            setTextBold(false);
            setTextColor(1, 1, 1, 1);
            nextPosY = nextPosY-box.ownTable.lineHeight;
        end;
        --loadedCargoFilterHint--

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

                    if box.ownTable.nameFilter ~= nil then
                        setTextColor(unpack(colorOn));
                    else
                        setTextColor(unpack(color));
                    end
                    setTextAlignment(0);
                    local text = g_currentMission.hlUtils.getTxtToWidth(tostring(productionItem.name), size, box.ownTable.textWidth, false, ".");
                    renderText(nextRightPosX, nextPosY, size, tostring(text));
                    setTextBold(false);
                    setTextColor(1, 1, 1, 1);
                    setTextAlignment(0);
                    if not g_currentMission.hlUtils:disableInArea() and inArea then box:setClickArea( {nextRightPosX, nextRightPosX+box.ownTable.timeWidth, nextPosY, nextPosY+box.ownTable.lineHeight, onClick=PIH_Display_MouseKeyEventsBox.onClickArea, whatClick="PIH_Display_Box", typPos=boxNumber, whereClick="nameColumn_", ownTable={ name = productionItem.name, target = productionItem.target}} );end;
                    lineWidth = lineWidth+box.ownTable.textWidth;
                    nextRightPosX = nextRightPosX+box.ownTable.textWidth;
                    canNextView = lineWidth > iconWidth;
                end;
                ---Production place---

                ---Filltype---
                if canNextView then
                    if isLoadedCargoFilterActive and productionItem.cargoDirection ~= nil then
                        -- Zeigt der Fracht-Filter beide Richtungen gleichzeitig, muss die Zeile selbst sagen welche sie meint:
                        -- zur Nachfüllstelle fährt man um zu holen, zum Abladeort um zu bringen.
                        if productionItem.cargoDirection == ProductionInfoHud.CARGO_DIRECTION_REFILL then
                            overlay = overlayDefaultGroup[overlayDefaultByName["bying"]];
                        else
                            overlay = overlayDefaultGroup[overlayDefaultByName["selling"]];
                        end
                    elseif productionItem.IsStorage then
                        -- Ein Lager kauft und verkauft nicht, es liegt nur da: eigenes Symbol statt eines Pfeils,
                        -- passend zu der Zahl daneben - Bestand oder freier Platz.
                        -- Ein Palettenlager zählt Stellplätze statt Liter und ist deshalb an seinem eigenen Symbol zu erkennen.
                        if productionItem.IsObjectStorage then
                            overlay = overlayDefaultGroup[overlayDefaultByName["pallet_empty"]];
                        elseif isLoadedCargoFilterActive then
                            overlay = overlayDefaultGroup[overlayDefaultByName["fillempty"]];
                        else
                            overlay = overlayDefaultGroup[overlayDefaultByName["fillamount"]];
                        end
                        -- Der Filter-Knopf der Filterzeile benutzt dasselbe Overlay und färbt es pro Bild um,
                        -- die Zeile stellt ihre eigene Farbe deshalb jedes Mal wieder her.
                        if overlay ~= nil then
                            g_currentMission.hlUtils.setBackgroundColor(overlay, overlay.colorState);
                        end
                    elseif productionItem.productionPerHour < 0 then
                        overlay = overlayDefaultGroup[overlayDefaultByName["selling"]];
                    else
                        overlay = overlayDefaultGroup[overlayDefaultByName["bying"]];
                    end
                    if overlay ~= nil then
                        g_currentMission.hlUtils.setOverlay(overlay, nextRightPosX + difW, nextPosY, iconWidthS, iconHeightS);
                        overlay:render();
                    end

                    nextRightPosX = nextRightPosX + iconSpace;

                    if box.ownTable.fillTypeFilter ~= nil or box.ownTable.fillTypeFilterIds ~= nil then
                        setTextColor(unpack(colorOn));
                    else
                        setTextColor(unpack(color));
                    end
                    setTextAlignment(0);
                    local text = g_currentMission.hlUtils.getTxtToWidth(ProductionInfoHud.GetItemFillTypeTitle(productionItem), size, box.ownTable.fillTypeWidth - iconSpace, false, ".");
                    renderText(nextRightPosX, nextPosY, size, tostring(text));
                    setTextBold(false);
                    setTextColor(1, 1, 1, 1);
                    setTextAlignment(0);
                    if not g_currentMission.hlUtils:disableInArea() and inArea then box:setClickArea( {nextRightPosX, nextRightPosX+box.ownTable.timeWidth, nextPosY, nextPosY+box.ownTable.lineHeight, onClick=PIH_Display_MouseKeyEventsBox.onClickArea, whatClick="PIH_Display_Box", typPos=boxNumber, whereClick="fillTypeColumn_", ownTable={ fillType = productionItem.fillTypeTitle, fillTypeIds = productionItem.mixFillTypeIds }} );end;
                    lineWidth = lineWidth+box.ownTable.fillTypeWidth;
                    nextRightPosX = nextRightPosX + box.ownTable.fillTypeWidth - iconSpace;
                    canNextView = lineWidth > iconWidth;
                end;
                ---Filltype---

                ---data column---
                if canNextView then
                    local dataString = "";
                    if isLoadedCargoFilterActive then
                        -- bei aktivem Cargo-Filter Zeit UND Kapazität kombiniert+abgekürzt anzeigen, statt ständig zwischen beidem umschalten zu müssen
                        local cargoAmount = productionItem.capacityData;
                        if productionItem.cargoDirection == ProductionInfoHud.CARGO_DIRECTION_REFILL then
                            cargoAmount = productionItem.fillLevel;
                        end
                        dataString = tostring(productionItem.TimeShortString) .. " (" .. ProductionInfoHud.FormatShortAmount(cargoAmount) .. ")";
                    elseif box.ownTable.dataViewMode == 1 then
                        -- mode 1 = Time left
                        dataString = tostring(productionItem.TimeLeftString);
                    elseif box.ownTable.dataViewMode == 2 then
                        -- mode 2 = Capacity left, bei einem Lager stattdessen der Bestand: gefragt ist, wieviel dort noch liegt
                        if productionItem.IsStorage then
                            dataString = string.format("%d", productionItem.fillLevel);
                        else
                            dataString = string.format("%d", productionItem.capacityData);
                        end
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
                    -- Umschalten der Spalte ergibt bei kombinierter Anzeige keinen Sinn mehr, daher Klick währenddessen deaktiviert
                    if not isLoadedCargoFilterActive and not g_currentMission.hlUtils:disableInArea() and inArea then box:setClickArea( {nextRightPosX, nextRightPosX+box.ownTable.timeWidth, nextPosY, nextPosY+box.ownTable.lineHeight, onClick=PIH_Display_MouseKeyEventsBox.onClickArea, whatClick="PIH_Display_Box", typPos=boxNumber, whereClick="dataColumn_", ownTable={}} );end;
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