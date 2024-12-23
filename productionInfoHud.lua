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

ProductionInfoHud.metadata = {
    title = "ProductionInfoHud",
    notes = "Erweiterung des Infodisplays für Silos und Produktionen",
    author = "Achimobil",
    info = "Das verändern und wiederöffentlichen, auch in Teilen, ist untersagt und wird abgemahnt.",
    languageVersion = 1,
    xmlVersion = 1
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

--- here all what needs to be initialized on first call
function ProductionInfoHud:init()

    ProductionInfoHud.isInit = true;
    ProductionInfoHud.currentMission = g_currentMission;
    ProductionInfoHud.i18n = g_i18n;
    ProductionInfoHud.isClient = ProductionInfoHud.currentMission:getIsClient();

    -- ProductionChainManager
    ProductionInfoHud.chainManager = ProductionInfoHud.currentMission.productionChainManager;

    -- Anzeigesystem Initialisieren
    ProductionInfoHud:RegisterDisplaySystem();
end

--- Register the Display System from HappyLooser
function ProductionInfoHud:RegisterDisplaySystem()
    if ProductionInfoHud:getDetiServer() then return;end;
    ProductionInfoHud.currentMission.hlUtils.modLoad("FS25_ProductionInfoHud");
    PIH_DisplaySetGet:setGlobalFunctions();
--     PIH_Display.lastPlayerFarmId = ProductionInfoHud.currentMission.hlUtils.getPlayerFarmId();
--     ProductionInfoHud.DebugTable("ProductionInfoHud.currentMission.hlHudSystem", ProductionInfoHud.currentMission.hlHudSystem);
    if ProductionInfoHud.currentMission.hlHudSystem ~= nil and ProductionInfoHud.currentMission.hlHudSystem.hlHud ~= nil and ProductionInfoHud.currentMission.hlHudSystem.hlHud.generate ~= nil then --check is HL Hud System ready !

        -- box erstellen
        PIH_Display_XmlBox:loadBox("PIH_Display_Box", true)

    -- das hier ist für das Hud mit dem Icon zum ein und ausblenden
--        print("#Info: ".. tostring(ProductionInfoHud.metadata.title).. " generate Hud --> for HL Hud System (".. tostring(ProductionInfoHud.currentMission.hlHudSystem.metadata.version).. ")")
--        local hud = ProductionInfoHud.currentMission.hlHudSystem.hlHud.generate( {name="PIH_Display_Hud", width=40, info="Production Info Hud Mod\n(PIH Display)", hiddenMod="ProductionInfoHud", ownTable={}} ); --loadDefaultIcons=true
--        if hud ~= nil then
            --ProductionInfoHud.currentMission.hlUtils.loadLanguage( {modTitle=tostring(ProductionInfoHud.metadata.title), class="FS25_ProductionInfoHud", modDir=ProductionInfoHud.modDir.. "scripte_PIH/", xmlDir="FS25_ProductionInfoHud", xmlVersion=ProductionInfoHud.metadata.languageVersion} );
--             PIH_DisplaySetGet:loadFillTypesIcons();
--             PIH_DisplaySetGet:loadHudIcons(hud);
--             PIH_Display:loadSource(2);
--             hud.onDraw = PIH_Display_DrawHud.setHud;
--             hud.onClick = PIH_Display_MouseKeyEventsHud.onClick;
--             hud.onSaveXml = PIH_Display_XmlHud.onSaveXml;
            --PIH_Display_XmlHud:onLoadXml(hud, hud:getXml()); --own hud load over Xml
            --if hud.ownTable.viewHudTyp == 1 then hud.autoZoomOutIn = "text";else hud.autoZoomOutIn = "";end; --set text zoom is ...typ 1
            --if ProductionInfoHud.currentMission.hlHudSystem.isAlreadyExistsXml("box", "PIH_Display_Box") then PIH_Display_XmlBox:loadBox("PIH_Display_Box", true);end; --optional load
--        else
--            ProductionInfoHud.loadError = true; --optional for !
--            print("#WARNING: ".. tostring(ProductionInfoHud.metadata.title).. " CAN NOT GENERATE Hud ! Check/Search: ? Mod cause with integrated HL Hud System ? ")
--        end;
    else
        ProductionInfoHud.loadError = true; --optional for !
        ProductionInfoHud.currentMission.hlUtils.modUnLoad("FS25_ProductionInfoHud");
        print("#WARNING: ".. tostring(ProductionInfoHud.metadata.title).. " CAN NOT GENERATE Hud/Pda/Box ! MISSING --> HL Hud System ! Check/Search: ? Corrupt Mod with integrated HL Hud System ? ")
    end;
end

---Update
-- @param float dt time since last call in ms
function ProductionInfoHud:update(dt)

    if not ProductionInfoHud.isInit then ProductionInfoHud:init(); end

    if not ProductionInfoHud.isClient then return; end


    ProductionInfoHud.timePast = ProductionInfoHud.timePast + dt;

    if ProductionInfoHud.timePast >= 5000 then
        ProductionInfoHud.timePast = 0;

        -- update all info tables for display
        ProductionInfoHud:refreshProductionsTable();

        -- temporär einfach sichtbar machen, wenn nicht sichtbar
        local box = ProductionInfoHud.currentMission.hlHudSystem.hlBox:getData("PIH_Display_Box");
        box.show = true;
    end

end

---refresh all the products table
function ProductionInfoHud:refreshProductionsTable()
    local farmId = ProductionInfoHud.currentMission:getFarmId();
    local myProductionItems = {}

    -- time factor for calcualting hours left based on days per Period
    local timeFactor = (1 / ProductionInfoHud.currentMission.environment.daysPerPeriod);

    local myProductionPoints = self.chainManager:getProductionPointsForFarmId(farmId);

    for _, productionPoint in pairs(myProductionPoints) do

        -- is the point shared, then the amounts needs to be divided
        local productionPointMultiplicator = 1;
        if productionPoint.sharedThroughputCapacity then
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
            productionItem.productionPoint = productionPoint;

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

            productionItem.fillTypeTitle = g_fillTypeManager:getFillTypeTitleByIndex(fillTypeId);

            -- loop through all active productions to see if the fillType is produced or consumed
            for _, production in pairs(productionPoint.activeProductions) do
                for _, fillTypeId2 in pairs(production.inputs) do
                    if fillTypeId2.type == fillTypeId then
                        productionItem.isInput = true;
                        productionItem.productionPerHour = productionItem.productionPerHour - (production.cyclesPerHour * fillTypeId2.amount * productionPointMultiplicator);
                    end
                end
                for _, fillTypeId2 in pairs(production.outputs) do
                    if fillTypeId2.type == fillTypeId then
                        productionItem.isInput = true;
                        productionItem.productionPerHour = productionItem.productionPerHour + (production.cyclesPerHour * fillTypeId2.amount * productionPointMultiplicator);
                    end
                end
--                 ProductionInfoHud.DebugTable("production", production, 2);
            end

            -- restzeit berechnen
            if productionItem.productionPerHour ~= 0 then
                if productionItem.productionPerHour < 0 then
                    -- wenn productionPerHour negativ, dann wird verbraucht, aber die Stunden sollten alle positiv sein
                    productionItem.hoursLeft = productionItem.fillLevel / (productionItem.productionPerHour * timeFactor * -1);
                else
                    -- wenn productionPerHour positiv, dann wird produziert, also Restzeit basiert auf bis lager voll ist
                    productionItem.hoursLeft = (productionItem.capacity - productionItem.fillLevel) / (productionItem.productionPerHour * timeFactor);
                end
            end

            -- alle items einfügen, da auch rest platz angezeigt werden soll wenn linie aus ist
            table.insert(myProductionItems, productionItem)
        end
    end

    table.sort(myProductionItems, ProductionInfoHud.compPrductionTable)

    ProductionInfoHud.CurrentProductionItems = myProductionItems;

--     ProductionInfoHud.DebugTable("CurrentProductionItems", ProductionInfoHud.CurrentProductionItems, 1);
--     ProductionInfoHud.DebugTable("myProductionPoints", myProductionPoints);
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
function ProductionInfoHud:getDetiServer()
    return g_server ~= nil and g_client ~= nil and g_dedicatedServer ~= nil;
end;

addModEventListener(ProductionInfoHud);