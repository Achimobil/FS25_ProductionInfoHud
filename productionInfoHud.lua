--[[
Copyright (C) Achimobil, seit 2022

Author: Achimobil

Contact:
https://github.com/Achimobil/FS25_ProductionInfoHud


Important:
No copy and use in own mods allowed.

Das verändern und wiederöffentlichen, auch in Teilen, ist untersagt und wird abgemahnt.
]]

ProductionInfoHud = {}
ProductionInfoHud.Debug = false;
ProductionInfoHud.isInit = false;
ProductionInfoHud.timePast = 0;
ProductionInfoHud.longestFillTypeTitle = "";

ProductionInfoHud.metadata = {
    title = "ProductionInfoHud",
    notes = "Erweiterung des Infodisplays für Silos und Produktionen",
    author = "Achimobil",
    info = "Das verändern und wiederöffentlichen, auch in Teilen, ist untersagt und wird abgemahnt.",
    languageVersion = 1,
    xmlVersion = 1,
    version = 1
};
ProductionInfoHud.modDir = g_currentModDirectory;

--- Print the given Table to the log
-- @param string text parameter Text before the table
-- @param table myTable The table to print
-- @param integer? maxDepth depth of print, default 2
function ProductionInfoHud.DebugTable(text, myTable, maxDepth)
    if not ProductionInfoHud.Debug then return end
    if myTable == nil then
        print("ProductionInfoHudDebug: " .. text .. " is nil");
    else
        print("ProductionInfoHudDebug: " .. text)
        DebugUtil.printTableRecursively(myTable,"_",0, maxDepth or 2);
    end
end

---Print the text to the log. Example: ProductionInfoHud.DebugText("Alter: %s", age)
-- @param string text the text to print formated
-- @param any ... format parameter
function ProductionInfoHud.DebugText(text, ...)
    if not ProductionInfoHud.Debug then return end
    print("ProductionInfoHudDebug: " .. string.format(text, ...));
end

--- Menge abgekürzt formatieren für die kombinierte Zeit+Menge-Anzeige beim Cargo-Filter. Abgeschnitten, nicht gerundet ("mindestens noch X").
-- @param float amount
-- @return string shortAmount
function ProductionInfoHud.FormatShortAmount(amount)
    amount = amount or 0;
    if amount >= 1000000 then
        return math.floor(amount / 1000000) .. " " .. ProductionInfoHud.i18n:getText("pih_millionShort");
    elseif amount >= 1000 then
        return math.floor(amount / 1000) .. "k";
    end
    return string.format("%d", amount);
end

function ProductionInfoHud:loadMap(mapName)
    print("---loading ".. tostring(ProductionInfoHud.metadata.title).. " ".. tostring(ProductionInfoHud.metadata.version).. "(#".. tostring(ProductionInfoHud.metadata.build).. ") ".. tostring(ProductionInfoHud.metadata.author).. "---")
    if not ProductionInfoHud:getDetiServer() then
        Mission00.onStartMission = Utils.appendedFunction(Mission00.onStartMission, ProductionInfoHud.RegisterDisplaySystem);
    end;
    ProductionInfoHud:registerActionEvent();
end;

function ProductionInfoHud:registerActionEvent()
    PlayerInputComponent.registerGlobalPlayerActionEvents = Utils.appendedFunction(
        PlayerInputComponent.registerGlobalPlayerActionEvents,
        function(self, _)
            local inputAction = InputAction["PIH_ONOFFDISPLAY"];
            local callbackTarget = self;
            local callbackFunc = self.pihSystemActionCallback;
            local triggerUp = false;
            local triggerDown = true;
            local triggerAlways = false;
            local startActive = true;

            local _, eventId = g_inputBinding:registerActionEvent(inputAction, callbackTarget, callbackFunc, triggerUp, triggerDown, triggerAlways, startActive, nil, true);

            g_inputBinding:setActionEventTextVisibility(eventId, false);
            local action = g_inputBinding.nameActions[InputAction["PIH_ONOFFDISPLAY"]];
            if action ~= nil then
                action.displayCategory = "HL Hud System";
                action.displayNamePositive = tostring(g_i18n:getText("input_TOGGLE_GUI_on"));
                action.displayNameNegative = tostring(g_i18n:getText("input_TOGGLE_GUI_off"));
            end;
    end)
    ---@diagnostic disable-next-line: unused-local
    function PlayerInputComponent:pihSystemActionCallback(actionName, inputValue, callbackState, isAnalog, isMouse, deviceCategory)
        if not g_currentMission.hlUtils.dragDrop.on then
            if actionName == "PIH_ONOFFDISPLAY" then
                if g_currentMission.hlHudSystem.hlBox ~= nil then
                    local box = g_currentMission.hlHudSystem.hlBox:getData("PIH_Display_Box");
                    if box.show ~= nil then
                        box.show = not box.show;
                        box:setUpdateState(true);

                        ProductionInfoHud.UpdateProductionNeedings();
                    end
                end
            end;
        end;
    end;
end;

--- here all what needs to be initialized on first call
function ProductionInfoHud:init()

    ProductionInfoHud.i18n = g_i18n;
    ProductionInfoHud.fillTypeManager = g_fillTypeManager;

    ProductionInfoHud.isInit = true;

    -- ProductionChainManager
    ProductionInfoHud.chainManager = g_currentMission.productionChainManager;
end

--- Register the Display System from HappyLooser
function ProductionInfoHud:RegisterDisplaySystem()
    if ProductionInfoHud:getDetiServer() then return;end;

    ProductionInfoHud.i18n = g_i18n;
    ProductionInfoHud.fillTypeManager = g_fillTypeManager;

    g_currentMission.hlUtils.modLoad("FS25_ProductionInfoHud");
    PIH_DisplaySetGet:setGlobalFunctions();
    if g_currentMission.hlHudSystem ~= nil and g_currentMission.hlHudSystem.hlHud ~= nil and g_currentMission.hlHudSystem.hlHud.generate ~= nil then --check is HL Hud System ready !

        -- box erstellen
        PIH_Display_XmlBox:loadBox("PIH_Display_Box", true)
    else
        ProductionInfoHud.loadError = true; --optional for !
        g_currentMission.hlUtils.modUnLoad("FS25_ProductionInfoHud");
        print("#WARNING: ".. tostring(ProductionInfoHud.metadata.title).. " CAN NOT GENERATE Hud/Pda/Box ! MISSING --> HL Hud System ! Check/Search: ? Corrupt Mod with integrated HL Hud System ? ")
    end;
end

---Update
-- @param float dt time since last call in ms
function ProductionInfoHud:update(dt)

    if ProductionInfoHud:getDetiServer() then return; end;

    if not ProductionInfoHud.isInit then ProductionInfoHud:init(); end;


    ProductionInfoHud.timePast = ProductionInfoHud.timePast + dt;

    if ProductionInfoHud.timePast >= 5000 then
        ProductionInfoHud.timePast = 0;

        -- update lists only when the system is visible
        if g_currentMission.hlHudSystem.hlBox ~= nil then
            local box = g_currentMission.hlHudSystem.hlBox:getData("PIH_Display_Box");
            if box.show == true then

                -- update all info tables for display
                ProductionInfoHud:refreshProductionsTable();
            end
        end
    end

end

---Add the given item to the list after calculating some stuff
-- @param table myProductionItems The list where it will be added to
-- @param table productionItem What should be added
function ProductionInfoHud:AddProductionItemToList(myProductionItems, productionItem)
    -- time factor for calcualting hours left based on days per Period
    local timeFactor = (1 / g_currentMission.environment.daysPerPeriod);

    -- restzeit berechnen
    if productionItem.productionPerHour ~= 0 then
        if productionItem.productionPerHour < 0 then
            -- wenn productionPerHour negativ, dann wird verbraucht, aber die Stunden sollten alle positiv sein
            productionItem.hoursLeft = productionItem.fillLevel / (productionItem.productionPerHour * timeFactor * -1);
            productionItem.capacityData = (productionItem.capacity - productionItem.fillLevel);
        else
            -- wenn productionPerHour positiv, dann wird produziert, also Restzeit basiert auf bis lager voll ist
            productionItem.hoursLeft = (productionItem.capacity - productionItem.fillLevel) / (productionItem.productionPerHour * timeFactor);
            productionItem.capacityData = productionItem.fillLevel;
        end
        -- pro stunde noch umrechnen anhand des timefactor
        productionItem.productionPerHour = productionItem.productionPerHour * timeFactor;
    end

    if productionItem.hoursLeft ~= nil then
        local days = math.floor(productionItem.hoursLeft / 24);
        local hoursLeft = productionItem.hoursLeft - (days * 24);
        local hours = math.floor(hoursLeft);
        hoursLeft = hoursLeft - hours;

        local minutes = math.floor(hoursLeft * 60);
        local minutesString = tostring(minutes);
        if(minutes <= 9) then minutesString = 0 .. minutes end;
        local hoursString = tostring(hours);
        if(hours <= 9) and (days ~= 0) then hoursString = "0" .. hours end;

        local timeString = "";
        if (days ~= 0) then
            timeString = ProductionInfoHud.i18n:formatNumDay(days) .. " ";
        end
        if (days < 100) then
            -- die Zeit nur einfügen wenn es weniger als 100 Tage sind
            timeString = timeString .. hoursString .. ":" .. minutesString;
        end

        -- wenn restzeit 0:00 ist, dann ist leer oder voll
        if days == 0 and hours == 0 and minutes <= 2 then
            if productionItem.isInput then
--                 ProductionInfoHud.DebugTable("productionItem", productionItem)
                if productionItem.isOutput and productionItem.capacityLevel >= 0.05 then
                    -- Wenn es input und output ist, kann es voll oder leer sein, wenn es mehr als 5% level hat, ist es wohl voll
                    timeString = ProductionInfoHud.i18n:getText("Full");
                else
                    timeString = ProductionInfoHud.i18n:getText("Empty");
                end
            else
                -- output but capacity 0 then target storage is missing
                if productionItem.capacity == 0 then
                    if productionItem.isPallet ~= nil and productionItem.isPallet then
                        -- Palettengröße vom Spawnpaltz kann nicht ausgelesen werden und wenn kein Lager im Stall ist, dann nur Paletts als Zeit anzeigen
                        timeString = ProductionInfoHud.i18n:getText("OnlyPallets");
                        productionItem.hoursLeft = math.huge;
                    else
                        timeString = ProductionInfoHud.i18n:getText("StorageMissing");
                    end
                else
                    timeString = ProductionInfoHud.i18n:getText("Full");
                end
            end
        end

        productionItem.TimeLeftString = timeString;

        -- kurze/ungefähre Variante (nur Tage ODER nur Stunden, keine Minuten) für die kombinierte Zeit+Menge-Anzeige beim Cargo-Filter
        if days == 0 and hours == 0 and minutes <= 2 then
            productionItem.TimeShortString = timeString; -- Full/Empty/StorageMissing/OnlyPallets
        elseif days > 0 then
            productionItem.TimeShortString = ProductionInfoHud.i18n:formatNumDay(days);
        else
            productionItem.TimeShortString = hours .. " " .. ProductionInfoHud.i18n:getText(hours == 1 and "pih_hourSingular" or "pih_hourPlural");
        end
    else
        productionItem.TimeLeftString = "";
        productionItem.TimeShortString = "";
    end

    -- ProductionInfoHud.DebugTable("productionItem", productionItem);
    if productionItem.productionPerHour ~= 0 then
        -- nur items mit einem Stundenwert einfügen, da für die Verteilliste eine eigene Liste gemacht wird
        table.insert(myProductionItems, productionItem)

        -- längsten filltypetitel für box behalten
        local textWidth = getTextWidth(10, utf8Substr(productionItem.fillTypeTitle, 0));
        if ProductionInfoHud.longestFillTypeTitleWidth == nil or ProductionInfoHud.longestFillTypeTitleWidth < textWidth then
            ProductionInfoHud.longestFillTypeTitleWidth = textWidth;
            ProductionInfoHud.longestFillTypeTitle = productionItem.fillTypeTitle;
        end
    end
end

---refresh all the products table
function ProductionInfoHud:refreshProductionsTable()
    local startTime = getTimeSec();

    local farmId = g_currentMission:getFarmId();
    local myProductionItems = {}

    -- TEMP-DEBUG für #28: aufgeschlüsselte Zeitmessung, um zu sehen wo innerhalb der 5ms die Zeit hingeht
    local productionPointsStartTime = getTimeSec();
    local myProductionPoints = self.chainManager:getProductionPointsForFarmId(farmId);
    for _, productionPoint in pairs(myProductionPoints) do
        -- hiddenOnUI is only available on GTX ExtendedProductionPoint and the production should only be added when this is nil or false
        if productionPoint.hiddenOnUI == nil or productionPoint.hiddenOnUI == false then
            self:AddProductionPoint(myProductionItems, productionPoint);
        end
    end
    local productionPointsTime = (getTimeSec() - productionPointsStartTime) * 1000;

    local factoriesStartTime = getTimeSec();
    local myFactories = self.chainManager:getFactoriesForFarmId(farmId);
    for _, factory in pairs(myFactories) do
        self:AddFactory(myProductionItems, factory);
    end
    local factoriesTime = (getTimeSec() - factoriesStartTime) * 1000;

    local husbandriesStartTime = getTimeSec();
    local myHusbandries = g_currentMission.husbandrySystem:getPlaceablesByFarm(farmId);
    for _, husbandry in pairs(myHusbandries) do
        self:AddHusbandry(myProductionItems, husbandry);
    end
    local husbandriesTime = (getTimeSec() - husbandriesStartTime) * 1000;

    local sortStartTime = getTimeSec();
    table.sort(myProductionItems, ProductionInfoHud.compPrductionTable)
    local sortTime = (getTimeSec() - sortStartTime) * 1000;

    ProductionInfoHud.CurrentProductionItems = myProductionItems;

--     ProductionInfoHud.DebugTable("CurrentProductionItems", ProductionInfoHud.CurrentProductionItems, 1);
--     ProductionInfoHud.DebugTable("myProductionPoints", myProductionPoints);

    ProductionInfoHud.DebugText("refreshProductionsTable: %.2f ms total (%d Items) | ProductionPoints: %.2f ms (%d) | Factories: %.2f ms (%d) | Husbandries: %.2f ms (%d) | Sort: %.2f ms",
        (getTimeSec() - startTime) * 1000, #myProductionItems,
        productionPointsTime, table.size(myProductionPoints),
        factoriesTime, table.size(myFactories),
        husbandriesTime, table.size(myHusbandries),
        sortTime);
end

--- Get the fillTypeIds currently loaded (fillLevel > 0) in the vehicle the player is sitting in and all its attached implements/trailers, inklusive mit Spanngurten befestigter Paletten. Betriebsstoffe wie Diesel/AdBlue/Luft werden nicht mitgezählt.
-- @return table set of fillTypeId -> true
function ProductionInfoHud.getCurrentlyLoadedFillTypes()
    local loadedFillTypes = {};
    if g_localPlayer == nil then
        return loadedFillTypes;
    end

    local vehicle = g_localPlayer:getCurrentVehicle();
    if vehicle == nil then
        return loadedFillTypes;
    end

    local collector = {};
    function collector.addFillLevel(_, fillType, fillLevel)
        if fillLevel ~= nil and fillLevel > 0 and fillType ~= nil and fillType ~= FillType.UNKNOWN then
            loadedFillTypes[fillType] = true;
        end
    end

    vehicle:getRootVehicle():getFillLevelInformation(collector);

    return loadedFillTypes;
end

--- Get the fillTypeIds the vehicle the player is sitting in and all its attached implements/trailers could carry (unabhängig vom aktuellen Füllstand). Betriebsstoffe wie Diesel/AdBlue/Luft werden nicht mitgezählt. Bei Paletten-/Ballenanhängern (feste Fracht wird nur über Spanngurte gehalten, nicht über eine feste Filltype-Liste) bleibt das Ergebnis leer.
-- @return table set of fillTypeId -> true
function ProductionInfoHud.getVehicleSupportedFillTypes()
    local supportedFillTypes = {};
    if g_localPlayer == nil then
        return supportedFillTypes;
    end

    local vehicle = g_localPlayer:getCurrentVehicle();
    if vehicle == nil then
        return supportedFillTypes;
    end

    local rootVehicle = vehicle:getRootVehicle();
    for _, childVehicle in ipairs(rootVehicle:getChildVehicles()) do
        if childVehicle.spec_fillUnit ~= nil then
            for _, fillUnit in pairs(childVehicle:getFillUnits()) do
                if fillUnit.showOnHud and fillUnit.supportedFillTypes ~= nil then
                    for fillTypeId, _ in pairs(fillUnit.supportedFillTypes) do
                        supportedFillTypes[fillTypeId] = true;
                    end
                end
            end
        end
    end

    return supportedFillTypes;
end

--- Get the set of fillTypeIds that should count as a match for the given fillTypeId when filtering by loaded/supported cargo:
--- der type selbst, plus alle types die über einen Converter (BaleUnloadTrigger/PalletUnloadTrigger/UnloadTrigger/WoodUnloadTrigger
--- an der unloadingStation dieses Produktionspunkts) zu diesem type konvertiert werden. Gleiches Muster wie in UpdateProductionNeedings.
-- @param table place ProductionPoint oder Factory, dessen unloadingStation (falls vorhanden) nach Convertern durchsucht wird
-- @param integer fillTypeId der eigentliche (Lager-)FillType
-- @return table set of fillTypeId -> true
function ProductionInfoHud.GetMatchFillTypeIds(place, fillTypeId)
    local matchFillTypeIds = {};
    matchFillTypeIds[fillTypeId] = true;

    if place ~= nil and place.unloadingStation ~= nil and place.unloadingStation.unloadTriggers ~= nil then
        for _, unloadTrigger in pairs(place.unloadingStation.unloadTriggers) do
            for incommingFillTypeId, fillTypeConversion in pairs(unloadTrigger.fillTypeConversions) do
                if fillTypeConversion.outgoingFillType == fillTypeId then
                    matchFillTypeIds[incommingFillTypeId] = true;
                end
            end
        end
    end

    return matchFillTypeIds;
end

--- Returns true if productionItem's matchFillTypeIds (das eigene FillType plus ggf. Converter-Alternativen bzw. beim Futter alle zulässigen Futter-Sorten) mind. eine der geladenen/unterstützten fillTypeIds enthält
-- @param table matchFillTypeIds set of fillTypeId -> true (kann nil sein, wenn noch nicht berechnet)
-- @param table fillTypeIds set of fillTypeId -> true, gegen das geprüft wird (geladene/unterstützte Ware)
-- @return boolean matches
function ProductionInfoHud.MatchesAnyFillType(matchFillTypeIds, fillTypeIds)
    if matchFillTypeIds == nil then return false; end
    for fillTypeId, _ in pairs(matchFillTypeIds) do
        if fillTypeIds[fillTypeId] then
            return true;
        end
    end
    return false;
end

---Add the given husbandry to the list
-- @param table myProductionItems The list where it will be added to
-- @param PlaceableHusbandry husbandry What should be added
function ProductionInfoHud:AddHusbandry(myProductionItems, husbandry)
--     ProductionInfoHud.DebugTable("husbandry", husbandry);

    -- Food ist da, also Food Item erstellen
    local spec = husbandry.spec_husbandryFood;
    if spec ~= nil then
        -- item für produktionsliste erstellen.
        local productionItem = {}
        productionItem.name = husbandry:getName();
        -- negative when more used than produced. calculated on one day per month as giants always does
        productionItem.productionPerHour = spec.litersPerHour * -1;
         -- time until full or empty, nil when not changing
        productionItem.hoursLeft = nil;
        productionItem.fillLevel = husbandry:getTotalFood();
        productionItem.capacity = husbandry:getFoodCapacity();
        productionItem.isInput = true;
        productionItem.isOutput = false;
        productionItem.IsAnimal = true;
        productionItem.target = husbandry;

        if productionItem.capacity == 0 then
            productionItem.capacityLevel = 0
        elseif productionItem.capacity == nil then
            productionItem.capacityLevel = 0
            print("Error: No storage for 'Food' in productionPoint but defined to used. Has to be fixed in '" .. husbandry.owningPlaceable.customEnvironment .."'.")
        else
            productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
        end
        productionItem.fillTypeTitle = spec.info.title;

        -- alle fillTypeIds eintragen, die für die Tierart dieses Stalls laut animalFoodSystem als Futter zulässig sind (mehrere Gruppen möglich,
        -- z.B. Totalmischration/Heu/Silage/Gras), damit der Fracht-Filter unabhängig von der gerade geladenen Futtersorte matcht
        local animalTypeIndex = husbandry.spec_husbandryAnimals ~= nil and husbandry.spec_husbandryAnimals.animalTypeIndex or nil;
        local animalFood = animalTypeIndex ~= nil and g_currentMission.animalFoodSystem:getAnimalFood(animalTypeIndex) or nil;
        if animalFood ~= nil then
            local matchFillTypeIds = {};
            for _, group in pairs(animalFood.groups) do
                for _, groupFillTypeId in pairs(group.fillTypes) do
                    matchFillTypeIds[groupFillTypeId] = true;
                end
            end
            productionItem.matchFillTypeIds = matchFillTypeIds;
        end

        -- Weide einbeziehen
        local specMeadow = husbandry.spec_husbandryMeadow;
        if specMeadow ~= nil then
            -- wenn normales futter leer, anzeige auf Weide umschalten
            if productionItem.fillLevel == 0 then
                productionItem.fillTypeTitle = specMeadow.info.title;
                productionItem.fillLevel = specMeadow.info.value;
            end

            -- title anpassen für die Anzeige
            productionItem.fillTypeTitle = productionItem.fillTypeTitle .. "*";
        end

        self:AddProductionItemToList(myProductionItems, productionItem);
    end

    -- liguid manure ist da, also Item erstellen
    spec = husbandry.spec_husbandryLiquidManure;
    if spec ~= nil then
        -- item für produktionsliste erstellen.
        local productionItem = {}
        productionItem.name = husbandry:getName();
        productionItem.fillTypeId = spec.fillType;
        -- negative when more used than produced. calculated on one day per month as giants always does
        productionItem.productionPerHour = spec.litersPerHour;
         -- time until full or empty, nil when not changing
        productionItem.hoursLeft = nil;
        productionItem.fillLevel = spec:getHusbandryFillLevel(spec.fillType)
        productionItem.capacity = spec:getHusbandryCapacity(spec.fillType)
        productionItem.isInput = false;
        productionItem.isOutput = true;
        productionItem.IsAnimal = true;
        productionItem.target = husbandry;

        if productionItem.capacity == 0 then
            productionItem.capacityLevel = 0
        elseif productionItem.capacity == nil then
            productionItem.capacityLevel = 0
            print("Error: No storage for 'Food' in productionPoint but defined to used. Has to be fixed in '" .. husbandry.owningPlaceable.customEnvironment .."'.")
        else
            productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
        end

        productionItem.fillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(spec.fillType);

        self:AddProductionItemToList(myProductionItems, productionItem);
    end

    -- milch ist da, also Item erstellen
    spec = husbandry.spec_husbandryMilk;
    if spec ~= nil then
        -- milch hat eine liste von Filltypes, könnten also mehrere sein
        for _, fillType in ipairs(spec.fillTypes) do
            local litersPerHour = spec.litersPerHour[fillType]

            -- item für produktionsliste erstellen.
            local productionItem = {}
            productionItem.name = husbandry:getName();
            productionItem.fillTypeId = fillType;
            -- negative when more used than produced. calculated on one day per month as giants always does
            productionItem.productionPerHour = litersPerHour * husbandry.spec_husbandry.globalProductionFactor;
             -- time until full or empty, nil when not changing
            productionItem.hoursLeft = nil;
            productionItem.fillLevel = spec:getHusbandryFillLevel(fillType)
            productionItem.capacity = spec:getHusbandryCapacity(fillType)
            productionItem.isInput = false;
            productionItem.isOutput = true;
            productionItem.IsAnimal = true;
            productionItem.target = husbandry;

            productionItem.fillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(fillType);

            if productionItem.capacity == 0 then
                productionItem.capacityLevel = 0
            elseif productionItem.capacity == nil then
                productionItem.capacityLevel = 0
                print("Error: No storage for '" .. productionItem.fillTypeTitle .. "' in productionPoint but defined to used. Has to be fixed in '" .. husbandry.owningPlaceable.customEnvironment .."'.")
            else
                productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
            end

            self:AddProductionItemToList(myProductionItems, productionItem);
        end
    end

    -- stroh ist da, also Item erstellen
    spec = husbandry.spec_husbandryStraw;
    if spec ~= nil then
        -- input item für produktionsliste erstellen.
        local productionItem = {}
        productionItem.name = husbandry:getName();
        productionItem.fillTypeId = spec.inputFillType;
        -- negative when more used than produced. calculated on one day per month as giants always does
        productionItem.productionPerHour = spec.inputLitersPerHour * -1;
         -- time until full or empty, nil when not changing
        productionItem.hoursLeft = nil;
        productionItem.fillLevel = spec:getHusbandryFillLevel(spec.inputFillType)
        productionItem.capacity = spec:getHusbandryCapacity(spec.inputFillType)
        productionItem.isInput = true;
        productionItem.isOutput = false;
        productionItem.IsAnimal = true;
        productionItem.target = husbandry;

        if productionItem.capacity == 0 then
            productionItem.capacityLevel = 0
        elseif productionItem.capacity == nil then
            productionItem.capacityLevel = 0
            print("Error: No storage for 'Food' in productionPoint but defined to used. Has to be fixed in '" .. husbandry.owningPlaceable.customEnvironment .."'.")
        else
            productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
        end

        productionItem.fillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(spec.inputFillType);

        self:AddProductionItemToList(myProductionItems, productionItem);

        -- output item für produktionsliste erstellen.
        local productionItemOutput = {}
        productionItemOutput.name = husbandry:getName();
        productionItemOutput.fillTypeId = spec.outputFillType;
        -- negative when more used than produced. calculated on one day per month as giants always does
        productionItemOutput.productionPerHour = spec.outputLitersPerHour;
         -- time until full or empty, nil when not changing
        productionItemOutput.hoursLeft = nil;
        productionItemOutput.fillLevel = spec:getHusbandryFillLevel(spec.outputFillType)
        productionItemOutput.capacity = spec:getHusbandryCapacity(spec.outputFillType)
        productionItemOutput.isInput = false;
        productionItemOutput.isOutput = true;
        productionItemOutput.IsAnimal = true;
        productionItemOutput.target = husbandry;
        productionItemOutput.fillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(spec.outputFillType);

        if productionItemOutput.capacity == 0 then
            productionItemOutput.capacityLevel = 0
        elseif productionItemOutput.capacity == nil then
            productionItemOutput.capacityLevel = 0
            print("Error: No storage for '" .. productionItemOutput.fillTypeTitle .. "' in productionPoint but defined to used. Has to be fixed in '" .. husbandry.owningPlaceable.customEnvironment .."'.")
        else
            productionItemOutput.capacityLevel = productionItemOutput.fillLevel / productionItemOutput.capacity;
        end

        self:AddProductionItemToList(myProductionItems, productionItemOutput);
    end

    -- wasser ist da, also Item erstellen, wenn nicht automatisch
    spec = husbandry.spec_husbandryWater;
    if spec ~= nil and not spec.automaticWaterSupply then
        -- item für produktionsliste erstellen.
        local productionItem = {}
        productionItem.name = husbandry:getName();
        productionItem.fillTypeId = spec.fillType;
        -- negative when more used than produced. calculated on one day per month as giants always does
        productionItem.productionPerHour = spec.litersPerHour * -1;
         -- time until full or empty, nil when not changing
        productionItem.hoursLeft = nil;
        productionItem.fillLevel = spec:getHusbandryFillLevel(spec.fillType)
        productionItem.capacity = spec:getHusbandryCapacity(spec.fillType)
        productionItem.isInput = true;
        productionItem.isOutput = false;
        productionItem.IsAnimal = true;
        productionItem.target = husbandry;

        if productionItem.capacity == 0 then
            productionItem.capacityLevel = 0
        elseif productionItem.capacity == nil then
            productionItem.capacityLevel = 0
            print("Error: No storage for 'Water' in productionPoint but defined to used. Has to be fixed in '" .. husbandry.owningPlaceable.customEnvironment .."'.")
        else
            productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
        end

        productionItem.fillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(spec.fillType);

        self:AddProductionItemToList(myProductionItems, productionItem);
    end

    -- pallets sind da, also Item erstellen, wenn nicht automatisch
    spec = husbandry.spec_husbandryPallets;
    if spec ~= nil then
        -- pallets hat eine liste von Filltypes, könnten also mehrere sein
        for _, fillType in ipairs(spec.fillTypes) do
            local litersPerHour = spec.litersPerHour[fillType]

            -- item für produktionsliste erstellen.
            local productionItem = {}
            productionItem.name = husbandry:getName();
            productionItem.fillTypeId = fillType;
            -- negative when more used than produced. calculated on one day per month as giants always does
            productionItem.productionPerHour = litersPerHour * husbandry.spec_husbandry.globalProductionFactor;
             -- time until full or empty, nil when not changing
            productionItem.hoursLeft = nil;
            productionItem.fillLevel = spec:getHusbandryFillLevel(fillType)
            productionItem.capacity = spec:getHusbandryCapacity(fillType)
            productionItem.isInput = false;
            productionItem.isOutput = true;
            productionItem.isPallet = true;
            productionItem.IsAnimal = true;
            productionItem.target = husbandry;

            productionItem.fillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(fillType);

            if productionItem.capacity == 0 then
                productionItem.capacityLevel = 0
            elseif productionItem.capacity == nil then
                productionItem.capacityLevel = 0
                print("Error: No storage for '" .. productionItem.fillTypeTitle .. "' in productionPoint but defined to used. Has to be fixed in '" .. husbandry.owningPlaceable.customEnvironment .."'.")
            else
                productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
            end

            self:AddProductionItemToList(myProductionItems, productionItem);
        end
    end
end

---Add the given factory to the list
-- @param table myProductionItems The list where it will be added to
-- @param PlaceableFactory factory What should be added
function ProductionInfoHud:AddFactory(myProductionItems, factory)
    for fillTypeId, _ in pairs(factory.spec_factory.storage.fillLevels) do
        -- item für produktionsliste erstellen. Ein Item pro fillType
        local productionItem = {}
        productionItem.name = factory:getName();
        productionItem.fillTypeId = fillTypeId;
        productionItem.productionPerHour = 0; -- negative when more used than produced. calculated on one day per month as giants always does
        productionItem.hoursLeft = nil; -- time until full or empty, nil when not changing
        productionItem.fillLevel = factory:getFillLevel(fillTypeId);
        productionItem.capacity = factory:getCapacity(fillTypeId);
        productionItem.isInput = false;
        productionItem.isOutput = false;
        productionItem.IsProduction = true;
        productionItem.target = factory;

        if productionItem.capacity == 0 then
            productionItem.capacityLevel = 0
        elseif productionItem.capacity == nil then
            productionItem.capacityLevel = 0
        else
            productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
        end

        productionItem.fillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(fillTypeId);

        -- factories have only one production, so no loop needed here and only inputs are from interest
        for _, fillTypeId2 in pairs(factory.spec_factory.inputs) do
            if fillTypeId2.fillType.index == fillTypeId then
                productionItem.isInput = true;
                productionItem.productionPerHour = productionItem.productionPerHour - (fillTypeId2.usagePerSecond*60*60);
            end
        end

        if productionItem.isInput then
            productionItem.matchFillTypeIds = ProductionInfoHud.GetMatchFillTypeIds(factory, fillTypeId);
        end

        self:AddProductionItemToList(myProductionItems, productionItem);
    end
end

---Add the given production point to the list
-- @param table myProductionItems The list where it will be added to
-- @param ProductionPoint productionPoint What should be added
function ProductionInfoHud:AddProductionPoint(myProductionItems, productionPoint)
    -- is the point shared, then the amounts needs to be divided
    local productionPointMultiplicator = 1;
    if productionPoint.sharedThroughputCapacity and #productionPoint.activeProductions ~= 0 then
        productionPointMultiplicator = 1 / #productionPoint.activeProductions;
    end

    -- Name ist pro Produktionspunkt gleich, daher nur ein Mal statt pro FillType berechnen
    local productionName = productionPoint.owningPlaceable:getName();
    if productionName ~= nil then
        productionName = string.gsub(productionName, "%(Leasing%) ", "");
    end

    -- Einmal pro Produktionspunkt statt pro FillType über alle aktiven Produktionen laufen und direkt pro FillType einsortieren
    -- (gleiche Bedingungen wie vorher: MISSING_INPUTS und DirectSell-Outputs werden nicht mitgezählt)
    local productionPerHourDeltaByFillType = {};
    local isInputByFillType = {};
    local isOutputByFillType = {};
    for _, production in pairs(productionPoint.activeProductions) do
        for _, inputItem in pairs(production.inputs) do
            isInputByFillType[inputItem.type] = true;
            productionPerHourDeltaByFillType[inputItem.type] = (productionPerHourDeltaByFillType[inputItem.type] or 0) - (production.cyclesPerHour * inputItem.amount * productionPointMultiplicator);
        end

        if production.status ~= ProductionPoint.PROD_STATUS.MISSING_INPUTS then
            for _, outputItem in pairs(production.outputs) do
                if productionPoint.outputFillTypeIdsDirectSell[outputItem.type] == nil then
                    isOutputByFillType[outputItem.type] = true;
                    productionPerHourDeltaByFillType[outputItem.type] = (productionPerHourDeltaByFillType[outputItem.type] or 0) + (production.cyclesPerHour * outputItem.amount * productionPointMultiplicator);
                end
            end
        end
    end

    for fillTypeId, _ in pairs(productionPoint.storage.fillLevels) do

        -- item für produktionsliste erstellen. Ein Item pro fillType
        local productionItem = {}
        productionItem.name = productionName;
        productionItem.fillTypeId = fillTypeId;
        productionItem.productionPerHour = 0; -- negative when more used than produced. calculated on one day per month as giants always does
        productionItem.hoursLeft = nil; -- time until full or empty, nil when not changing
        productionItem.fillLevel = productionPoint:getFillLevel(fillTypeId);
        productionItem.capacity = productionPoint:getCapacity(fillTypeId);
        productionItem.isInput = false;
        productionItem.isOutput = false;
        productionItem.IsProduction = true;
        productionItem.target = productionPoint;
        productionItem.isAutoDeliver = productionPoint.outputFillTypeIdsAutoDeliver[fillTypeId];

        -- prüfen ob input type
        if productionPoint.inputFillTypeIds[fillTypeId] ~= nil then
            productionItem.isInput = productionPoint.inputFillTypeIds[fillTypeId];
        end
        -- prüfen ob output type
        if productionPoint.outputFillTypeIds[fillTypeId] ~= nil then
            productionItem.isOutput = productionPoint.outputFillTypeIds[fillTypeId];
        end

        if productionItem.capacity == 0 then
            productionItem.capacityLevel = 0
        elseif productionItem.capacity == nil then
            productionItem.capacityLevel = 0
        else
            productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
        end

        productionItem.fillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(fillTypeId);

        -- oben einmal pro Produktionspunkt vorberechnet, siehe productionPerHourDeltaByFillType/isInputByFillType/isOutputByFillType
        if isInputByFillType[fillTypeId] then
            productionItem.isInput = true;
        end
        if isOutputByFillType[fillTypeId] then
            productionItem.isOutput = true;
        end
        productionItem.productionPerHour = productionItem.productionPerHour + (productionPerHourDeltaByFillType[fillTypeId] or 0);

        if productionItem.isInput then
            productionItem.matchFillTypeIds = ProductionInfoHud.GetMatchFillTypeIds(productionPoint, fillTypeId);
        end

        self:AddProductionItemToList(myProductionItems, productionItem);
    end
end

---Returns true if production items are in the right order
-- @param table a part a to check
-- @param table b part b to check
-- @return boolean rightOrder returns true if parts are in right order
function ProductionInfoHud.compPrductionTable(a,b)
    -- Zum Sortieren der Ausgabeliste nach Zeit
    if a.hoursLeft == nil then
        return false;
    elseif b.hoursLeft == nil then
        return true;
    elseif a.hoursLeft == b.hoursLeft and a.name < b.name then
        return true;
    elseif a.hoursLeft < b.hoursLeft then
        return true;
    end
    return false;
end

--- Zum Sortieren bei aktivem LoadedCargoFilter: FillTypes gruppieren, innerhalb der Gruppe nach freier Kapazität (wieviel passt noch rein, absteigend)
function ProductionInfoHud.compProductionTableByFillTypeAndFreeCapacity(a, b)
    if a.fillTypeId ~= b.fillTypeId then
        -- Futter-Einträge (Kuhstall etc.) haben keine einzelne fillTypeId, da mehrere Sorten zulässig sind - ans Ende sortieren statt Vergleichsfehler
        if a.fillTypeId == nil then return false; end
        if b.fillTypeId == nil then return true; end
        return a.fillTypeId < b.fillTypeId;
    end
    local freeCapacityA = (a.capacity or 0) - (a.fillLevel or 0);
    local freeCapacityB = (b.capacity or 0) - (b.fillLevel or 0);
    return freeCapacityA > freeCapacityB;
end

---Simple check if this is server and not client
-- @return boolean isDediServer
function ProductionInfoHud:getDetiServer()
    return g_server ~= nil and g_client ~= nil and g_dedicatedServer ~= nil;
end;

function ProductionInfoHud.UpdateProductionNeedings()
    -- Alle Produktionen auslesen mit gesamtbedarf für Tabelle
    local farmId = g_currentMission:getFarmId();
    local newProductionNeedings = {}

    local myProductionPoints = ProductionInfoHud.chainManager:getProductionPointsForFarmId(farmId);
    for _, productionPoint in pairs(myProductionPoints) do

        local productionName = productionPoint.owningPlaceable:getName();
        -- replace the long leasing text
        if productionName ~= nil then
            productionName = string.gsub(productionName, "%(Leasing%) ", "");
        end

        local productionImageFilename = productionPoint.owningPlaceable:getImageFilename();

        -- is the point shared, then the amounts needs to be divided
        local productionPointMultiplicatorActive = 1;
        if productionPoint.sharedThroughputCapacity and #productionPoint.activeProductions ~= 0 then
            productionPointMultiplicatorActive = 1 / #productionPoint.activeProductions;
        end
        local productionPointMultiplicatorAll = 1;
        if productionPoint.sharedThroughputCapacity and #productionPoint.productions ~= 0 then
            productionPointMultiplicatorAll = 1 / #productionPoint.productions;
        end

--         ProductionInfoHud.DebugTable("productionPoint.unloadingStation", productionPoint.unloadingStation, 4);

        --normale Produktionen einfügen, deaktivierte Produktionslinien werden komplett übersprungen
        for _, production in pairs(productionPoint.productions) do
            if production.status ~= ProductionPoint.PROD_STATUS.INACTIVE then
                for _, inputItem in pairs(production.inputs) do
                    local changedAmountPerMonth = production.cyclesPerHour * inputItem.amount * 24 * -1;

                    local maxTotalAmount = changedAmountPerMonth * productionPointMultiplicatorAll;
                    local minTotalAmount = maxTotalAmount;

                    local maxActiveAmount = changedAmountPerMonth * productionPointMultiplicatorActive;
                    local minActiveAmount = maxActiveAmount;

                    -- Wenn es einen Konverter gibt, dann wird minAmount nicht hochgesetzt, aber maxAmount für alle eingetragenen converts
                    -- converter können eingetragen sein in BaleUnloadTrigger, PalletUnloadTrigger, UnloadTrigger, WoodUnloadTrigger
                    -- UnloadTrigger ist die basis und die hat fillTypeConversions[fillTypeId] mit outgoingFillType und ratio und stecken in unloadingStation
                    -- also muss ich prüfen ob in der Liste ein outgoingFillType drin ist der mit dem aktuellen übereinstimmt und diese dann ebenfalls in die liste legen
                    local alternativeFillTypes;
                    if productionPoint.unloadingStation ~= nil and productionPoint.unloadingStation.unloadTriggers ~= nil then

                        -- nur der erste converter eines types darf hinzugefügt werden, sonst wird alles pro trigger und converter mehrfach eingefügt.
                        -- wir ignorieren hier, dass die verschiedenen Trigger unterschiedliche ratio haben könnten
                        local alreadyAddedIncommingFillTypeIds = {};

                        for _, unloadTrigger in pairs(productionPoint.unloadingStation.unloadTriggers) do
                            for incommingFillTypeId, fillTypeConversion in pairs(unloadTrigger.fillTypeConversions) do
                                if fillTypeConversion.outgoingFillType == inputItem.type then
                                    -- Die min Amounts nicht setzen für den aktuellen type, aber den input type nur mit max einfügen
                                    minTotalAmount = 0;
                                    minActiveAmount = 0;

                                    -- amounts mit ratio bestimmen
                                    local maxTotalAmountConversion = maxTotalAmount / fillTypeConversion.ratio;
                                    local maxActiveAmountConversion = maxActiveAmount / fillTypeConversion.ratio;

                                    if alreadyAddedIncommingFillTypeIds[incommingFillTypeId] ~= true then
                                        ProductionInfoHud.AddAmountToProductionNeedings(newProductionNeedings, incommingFillTypeId, 0, maxActiveAmountConversion, 0, maxTotalAmountConversion, productionName, production.name, nil, inputItem.type, nil, productionImageFilename);
                                        alreadyAddedIncommingFillTypeIds[incommingFillTypeId] = true;
                                    end

                                    if alternativeFillTypes == nil then
                                        alternativeFillTypes = {};
                                    end

                                    alternativeFillTypes[incommingFillTypeId] =
                                    {
                                        title = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(incommingFillTypeId),
                                        ratio = fillTypeConversion.ratio
                                    }
                                end
                            end
                        end
                    end

                    ProductionInfoHud.AddAmountToProductionNeedings(newProductionNeedings, inputItem.type, minActiveAmount, maxActiveAmount, minTotalAmount, maxTotalAmount, productionName, production.name, alternativeFillTypes, nil, nil, productionImageFilename);
                end

                for _, outputItem in pairs(production.outputs) do
                    local changedAmountPerMonth = production.cyclesPerHour * outputItem.amount * 24;

                    local maxTotalAmount = changedAmountPerMonth * productionPointMultiplicatorAll;
                    local maxActiveAmount = changedAmountPerMonth * productionPointMultiplicatorActive;

                    local outputMode = nil;
                    if productionPoint.getOutputDistributionMode ~= nil then
                        outputMode = productionPoint:getOutputDistributionMode(outputItem.type);
                    end

                    ProductionInfoHud.AddAmountToProductionNeedings(newProductionNeedings, outputItem.type, maxActiveAmount, maxActiveAmount, maxTotalAmount, maxTotalAmount, productionName, production.name, nil, nil, outputMode, productionImageFilename);
                end
            end
        end
    end

    return newProductionNeedings;
end


function ProductionInfoHud.AddAmountToProductionNeedings(newProductionNeedings, fillTypeId, minActiveAmount, maxActiveAmount, minTotalAmount, maxTotalAmount, productionName, productionLineName, alternativeFillTypes, alternativeForFillTypeId, outputMode, productionImageFilename)
    -- neues Element erstellen, wenn noch keins vorhanden ist
    local newProductionNeeding = newProductionNeedings[fillTypeId];
    if newProductionNeedings[fillTypeId] == nil then
        newProductionNeeding = {};
        newProductionNeeding.fillTypeId = fillTypeId;
        newProductionNeeding.title = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(fillTypeId);
        newProductionNeeding.hudOverlayFilename = ProductionInfoHud.fillTypeManager:getFillTypeByIndex(fillTypeId).hudOverlayFilename;
        newProductionNeeding.isFruit = g_fruitTypeManager:getFruitTypeIndexByFillTypeIndex(fillTypeId) ~= nil;
        newProductionNeeding.maxActiveAmount = 0; -- Benötigte Menge pro Monat für aktive Produktionen, wenn dieser Filltype benutzt wird
        newProductionNeeding.minActiveAmount = 0; -- Benötigte Menge pro Monat für aktive Produktionen, wenn alternative Filltypes benutzt werden
        newProductionNeeding.maxTotalAmount = 0; -- Benötigte Menge pro Monat für alle Produktionen, wenn dieser Filltype benutzt wird
        newProductionNeeding.minTotalAmount = 0; -- Benötigte Menge pro Monat für alle Produktionen, wenn alternative Filltypes benutzt werden
        newProductionNeeding.ProductionDetails = {} -- Liste der Details welche Produktionslinen von welchen Produktionen wieviel benötigen

        newProductionNeedings[fillTypeId] = newProductionNeeding;
    end

    newProductionNeeding.maxActiveAmount = newProductionNeeding.maxActiveAmount + math.round(maxActiveAmount);
    newProductionNeeding.minActiveAmount = newProductionNeeding.minActiveAmount + math.round(minActiveAmount);
    newProductionNeeding.maxTotalAmount = newProductionNeeding.maxTotalAmount + math.round(maxTotalAmount);
    newProductionNeeding.minTotalAmount = newProductionNeeding.minTotalAmount + math.round(minTotalAmount);

    local usageDetailInfoItem = {}
    usageDetailInfoItem.productionName = productionName;
    usageDetailInfoItem.productionLineName = productionLineName;
    usageDetailInfoItem.activeAmount = math.round(maxActiveAmount); -- aktuell benötigte Menge pro Monat
    usageDetailInfoItem.totalAmount = math.round(maxTotalAmount); -- benötigte Menge pro Monat wenn aktiv
    usageDetailInfoItem.outputMode = outputMode; -- Verteilmodus (Behalten/Verteilen/Verkaufen) nur bei Outputs gesetzt
    usageDetailInfoItem.productionImageFilename = productionImageFilename; -- Icon des Gebäudes für die Anzeige
    usageDetailInfoItem.alternativeFillTypes = alternativeFillTypes; -- alternativen über converter
    if alternativeForFillTypeId ~= nil then
        usageDetailInfoItem.alternativeForFillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(alternativeForFillTypeId); -- alternative für welchen Filltype in dieser Produktionslinie
    end

    table.insert(newProductionNeeding.ProductionDetails, usageDetailInfoItem);
end

addModEventListener(ProductionInfoHud);