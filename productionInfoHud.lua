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
ProductionInfoHud.Debug = true;
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

function ProductionInfoHud:loadMap(mapName)
    print("---loading ".. tostring(ProductionInfoHud.metadata.title).. " ".. tostring(ProductionInfoHud.metadata.version).. "(#".. tostring(ProductionInfoHud.metadata.build).. ") ".. tostring(ProductionInfoHud.metadata.author).. "---")
    if not ProductionInfoHud:getDetiServer() then
        Mission00.onStartMission = Utils.appendedFunction(Mission00.onStartMission, ProductionInfoHud.RegisterDisplaySystem);
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

        -- update all info tables for display
        ProductionInfoHud:refreshProductionsTable();

        -- temporär einfach sichtbar machen, wenn nicht sichtbar
        if g_currentMission.hlHudSystem.hlBox ~= nil then
            local box = g_currentMission.hlHudSystem.hlBox:getData("PIH_Display_Box");
            if box.show ~= nil then
                box.show = true;
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
            productionItem.capacityData = productionItem.fillLevel;
        else
            -- wenn productionPerHour positiv, dann wird produziert, also Restzeit basiert auf bis lager voll ist
            productionItem.hoursLeft = (productionItem.capacity - productionItem.fillLevel) / (productionItem.productionPerHour * timeFactor);
            productionItem.capacityData = (productionItem.capacity - productionItem.fillLevel);
        end
    end

    if productionItem.hoursLeft ~= nil then
        local days = math.floor(productionItem.hoursLeft / 24);
        local hoursLeft = productionItem.hoursLeft - (days * 24);
        local hours = math.floor(hoursLeft);
        hoursLeft = hoursLeft - hours;

        local minutes = math.floor(hoursLeft * 60);
        local minutesString = minutes;
        if(minutes <= 9) then minutesString = 0 .. minutes end;
        local hoursString = hours;
        if(hours <= 9) and (days ~= 0) then hoursString = "0" .. hours end;

        local timeString = "";
        if (days ~= 0) then
            timeString = ProductionInfoHud.i18n:formatNumDay(days) .. " ";
        end
        timeString = timeString .. hoursString .. ":" .. minutesString;

        -- wenn restzeit 0:00 ist, dann ist leer oder voll
        if days == 0 and hours == 0 and minutes <= 2 then
            if productionItem.isInput then
                timeString = ProductionInfoHud.i18n:getText("Empty");
            else
                -- output but capacity 0 then target storage is missing
                if productionItem.capacity == 0 then
                    timeString = ProductionInfoHud.i18n:getText("StorageMissing");
                else
                    timeString = ProductionInfoHud.i18n:getText("Full");
                end
            end
        end

        productionItem.TimeLeftString = timeString;
    else
        productionItem.TimeLeftString = "";
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
    local farmId = g_currentMission:getFarmId();
    local myProductionItems = {}

    local myProductionPoints = self.chainManager:getProductionPointsForFarmId(farmId);
    for _, productionPoint in pairs(myProductionPoints) do
        self:AddProductionPoint(myProductionItems, productionPoint);
    end

    local myFactories = self.chainManager:getFactoriesForFarmId(farmId);
    for _, factory in pairs(myFactories) do
        self:AddFactory(myProductionItems, factory);
    end

    local myHusbandries = g_currentMission.husbandrySystem:getPlaceablesByFarm(farmId);
    for _, husbandry in pairs(myHusbandries) do
        self:AddHusbandry(myProductionItems, husbandry);
    end

    table.sort(myProductionItems, ProductionInfoHud.compPrductionTable)

    ProductionInfoHud.CurrentProductionItems = myProductionItems;

--     ProductionInfoHud.DebugTable("CurrentProductionItems", ProductionInfoHud.CurrentProductionItems, 1);
--     ProductionInfoHud.DebugTable("myProductionPoints", myProductionPoints);
end

---Add the given husbandry to the list
-- @param table myProductionItems The list where it will be added to
-- @param Husbandry husbandry What should be added
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

        if productionItem.capacity == 0 then
            productionItem.capacityLevel = 0
        elseif productionItem.capacity == nil then
            productionItem.capacityLevel = 0
            print("Error: No storage for 'Food' in productionPoint but defined to used. Has to be fixed in '" .. husbandry.owningPlaceable.customEnvironment .."'.")
        else
            productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
        end
        productionItem.fillTypeTitle = spec.info.title;

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
        productionItemOutput.productionPerHour = spec.inputLitersPerHour;
         -- time until full or empty, nil when not changing
        productionItemOutput.hoursLeft = nil;
        productionItemOutput.fillLevel = spec:getHusbandryFillLevel(spec.outputFillType)
        productionItemOutput.capacity = spec:getHusbandryCapacity(spec.outputFillType)
        productionItemOutput.isInput = false;
        productionItemOutput.isOutput = true;
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
end

---Add the given factory to the list
-- @param table myProductionItems The list where it will be added to
-- @param Factory factory What should be added
function ProductionInfoHud:AddFactory(myProductionItems, factory)
    for fillTypeId, fillLevel in pairs(factory.spec_factory.storage.fillLevels) do
        -- item für produktionsliste erstellen. Ein Item pro fillType
        local productionItem = {}
        productionItem.name = factory:getName();
        productionItem.fillTypeId = fillTypeId;
        productionItem.productionPerHour = 0; -- negative when more used than produced. calculated on one day per month as giants always does
        productionItem.hoursLeft = nil; -- time until full or empty, nil when not changing
        productionItem.fillLevel = factory:getFillLevel(fillTypeId);
        productionItem.capacity = factory:getCapacity(fillTypeId);
        productionItem.isInput = true;
        productionItem.isOutput = false;

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

    for fillTypeId, fillLevel in pairs(productionPoint.storage.fillLevels) do

        -- item für produktionsliste erstellen. Ein Item pro fillType
        local productionItem = {}
        productionItem.name = productionPoint.owningPlaceable:getName();
        productionItem.fillTypeId = fillTypeId;
        productionItem.productionPerHour = 0; -- negative when more used than produced. calculated on one day per month as giants always does
        productionItem.hoursLeft = nil; -- time until full or empty, nil when not changing
        productionItem.fillLevel = productionPoint:getFillLevel(fillTypeId);
        productionItem.capacity = productionPoint:getCapacity(fillTypeId);
        productionItem.isInput = false;
        productionItem.isOutput = false;

        -- replace the long leasing text
        if productionItem.name ~= nil then
            productionItem.name = string.gsub(productionItem.name, "%(Leasing%) ", "");
        end

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

        -- loop through all active productions to see if the fillType is produced or consumed
        for _, production in pairs(productionPoint.activeProductions) do
            for _, fillTypeId2 in pairs(production.inputs) do
                if fillTypeId2.type == fillTypeId then
                    productionItem.isInput = true;
                    productionItem.productionPerHour = productionItem.productionPerHour - (production.cyclesPerHour * fillTypeId2.amount * productionPointMultiplicator);
                end
            end

            -- outputs nur einbeziehen, wenn inputs alle da sind, also missing inputs state nicht summieren. Kann ja nicht voll laufen ohne Produktion
            -- Auch die auf direktverkaufen müssen hier ausgeblendet werden
            if production.status ~= ProductionPoint.PROD_STATUS.MISSING_INPUTS and productionPoint.outputFillTypeIdsDirectSell[fillTypeId] == nil then
                for _, fillTypeId2 in pairs(production.outputs) do
                    if fillTypeId2.type == fillTypeId then
                        productionItem.isInput = true;
                        productionItem.productionPerHour = productionItem.productionPerHour + (production.cyclesPerHour * fillTypeId2.amount * productionPointMultiplicator);
                    end
                end
            end
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

---Simple check if this is server and not client
-- @return boolean isDediServer
function ProductionInfoHud:getDetiServer()
    return g_server ~= nil and g_client ~= nil and g_dedicatedServer ~= nil;
end;

addModEventListener(ProductionInfoHud);