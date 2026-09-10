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

-- Kennungen der Zutaten-Gruppen aus dem Datenmodell von Production Revamp: 1 bis 97 sind Gruppen alternativer Zutaten,
-- von denen pro Takt genau eine verbraucht wird, 98 und 99 sind die beiden optionalen Booster.
ProductionInfoHud.MIX_BOOST = 98;
ProductionInfoHud.MIX_MASTER = 99;

-- Weiter als 100 Tage zeigt die Zeitspalte ohnehin keine Uhrzeit mehr an, das ist auch die Grenze der Vorausrechnung.
ProductionInfoHud.MAX_FORECAST_DAYS = 100;


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
                    if box ~= nil and box.show ~= nil then
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
            if box ~= nil and box.show == true then

                -- update all info tables for display
                ProductionInfoHud:refreshProductionsTable();
            end
        end
    end

end

---Prüft, ob die Zeit- und Wettervorgaben der Rezeptlinien im Spielstand überhaupt wirken.
---Die Vorgaben bleiben an den Linien gespeichert, auch wenn ein Admin sie für den Spielstand abgeschaltet hat -
---dann läuft jede Linie rund um die Uhr, und die gespeicherten Öffnungszeiten halten keine Linie mehr an.
---Ohne Production Revamp gibt es die Einstellungen nicht, dann greifen die Vorgaben ohnehin nicht.
---@return boolean isActive
function ProductionInfoHud.GetAreProductionTimeModesActive()
    local revampSettings = ProductionPoint.REVAMP_SETTINGS;

    return revampSettings == nil or revampSettings.weatherModesActive ~= false;
end

---Zählt die Rezeptlinien, die sich die Durchsatzkapazität ihres Produktionspunktes gerade tatsächlich teilen.
---Ohne angehaltene Linien und ohne linieneigenes Flag ist das die Zahl aller aktiven Linien, also genau der Wert,
---mit dem auch das Grundspiel rechnet.
---@param productionPoint table
---@return integer count 0 wenn der Punkt seinen Durchsatz gar nicht teilt
function ProductionInfoHud.CountSharedThroughputLines(productionPoint)
    if not productionPoint.sharedThroughputCapacity then
        return 0;
    end

    local count = 0;
    for _, production in ipairs(productionPoint.activeProductions) do
        if production.modeStatus == nil and production.sharedThroughputCapacity ~= false then
            count = count + 1;
        end
    end

    return count;
end

---Effektiver Takt einer Rezeptlinie in Zyklen pro Spielstunde.
---Wetter- und Master-Faktor stammen aus dem letzten Produktionstakt und fehlen ohne Production Revamp,
---dann bleibt der nominale Wert der Linie stehen.
---@param productionPoint table
---@param production table
---@param numSharedThroughputLines integer Ergebnis von CountSharedThroughputLines
---@return number throughput Takt inklusive Master-Faktor
---@return number throughputWithoutMaster Takt ohne Master-Faktor, mit dem sich der Master-Booster selbst verbraucht
function ProductionInfoHud.GetLineThroughput(productionPoint, production, numSharedThroughputLines)
    local throughput = production.cyclesPerHour;

    if production.weatherFactorCurrent ~= nil then
        throughput = throughput * production.weatherFactorCurrent;
    end

    if numSharedThroughputLines > 0 and production.sharedThroughputCapacity ~= false then
        throughput = throughput / numSharedThroughputLines;
    end

    local throughputWithoutMaster = throughput;
    if production.masterFactor ~= nil then
        throughput = throughput * production.masterFactor;
    end

    return throughput, throughputWithoutMaster;
end

---Prüft, ob eine Rezeptlinie Vorgaben zu Uhrzeit, Monat oder Jahreszeit hat und deshalb stundenweise
---vorausgerechnet werden muss statt mit einem festen Stundenwert.
---@param production table
---@return boolean hasTimeModes
function ProductionInfoHud.GetLineHasTimeModes(production)
    if production.modes == nil or not ProductionInfoHud.GetAreProductionTimeModesActive() then
        return false;
    end

    for _, mode in ipairs(production.modes) do
        if mode == "HOURLY" or mode == "SEASONAL" or mode == "MONTHLY" then
            return true;
        end
    end

    return false;
end

---Prüft, ob eine Rezeptlinie zur angegebenen Spielzeit laufen darf.
---Die Wettervorgaben bleiben dabei außen vor: das Wetter der nächsten Stunden ist nicht vorhersagbar,
---sein aktueller Faktor steckt bereits im Takt der Linie.
---@param production table
---@param hour integer Stunde 0 bis 23
---@param period integer Monat 1 bis 12, wobei 1 der März ist
---@param season integer Jahreszeit 1 bis 4
---@return boolean runs
function ProductionInfoHud.GetLineRunsAtHour(production, hour, period, season)
    if not ProductionInfoHud.GetLineHasTimeModes(production) then
        return true;
    end

    for _, mode in ipairs(production.modes) do
        if mode == "HOURLY" and production.hoursTable ~= nil and not production.hoursTable[hour] then
            return false;
        elseif mode == "SEASONAL" and production.seasonsList ~= nil and not production.seasonsList[season] then
            return false;
        elseif mode == "MONTHLY" and production.monthsList ~= nil and not production.monthsList[period] then
            return false;
        end
    end

    return true;
end

---Anteil eines Tages, an dem eine Rezeptlinie im laufenden Monat arbeiten darf.
---Ohne Zeitvorgaben ist das ein ganzer Tag, bei Öffnungszeiten der Anteil der offenen Stunden,
---und in einem Monat oder einer Jahreszeit, die das Rezept ausschließt, gar nichts.
---@param production table
---@return number share Anteil von 0 bis 1
function ProductionInfoHud.GetLineRunningShareOfDay(production)
    if not ProductionInfoHud.GetLineHasTimeModes(production) then
        return 1;
    end

    local period = g_currentMission.environment.currentPeriod;
    local season = ProductionInfoHud.GetSeasonForPeriod(period);
    local runningHours = 0;

    for hour = 0, 23 do
        if ProductionInfoHud.GetLineRunsAtHour(production, hour, period, season) then
            runningHours = runningHours + 1;
        end
    end

    return runningHours / 24;
end

---Jahreszeit des angegebenen Monats. Je drei Monate bilden eine Jahreszeit, Monat 1 ist der März.
---@param period integer Monat 1 bis 12
---@return integer season Jahreszeit 1 bis 4
function ProductionInfoHud.GetSeasonForPeriod(period)
    return math.floor((period - 1) / 3) + 1;
end

---Summiert die Beiträge aller Rezeptlinien, die zur angegebenen Spielzeit laufen dürfen.
---@param contributions table Liste von { production = table, delta = number }
---@param hour integer Stunde 0 bis 23
---@param period integer Monat 1 bis 12
---@param season integer Jahreszeit 1 bis 4
---@return number delta Menge pro Spielstunde, negativ wenn verbraucht wird
function ProductionInfoHud.GetHourlyDelta(contributions, hour, period, season)
    local delta = 0;

    for _, contribution in ipairs(contributions) do
        if ProductionInfoHud.GetLineRunsAtHour(contribution.production, hour, period, season) then
            delta = delta + contribution.delta;
        end
    end

    return delta;
end

---Durchschnittlicher Stundenwert über einen ganzen Spieltag. Eine Linie mit Zeitvorgaben steht zwischendurch still,
---ihr Beitrag wird deshalb über 24 Stunden gemittelt - sonst hätte eine Bäckerei während ihrer Mittagspause
---keinen Stundenwert und fiele ganz aus der Liste.
---@param contributions table Liste von { production = table, delta = number }
---@return number delta Menge pro Spielstunde im Tagesmittel
function ProductionInfoHud.GetDailyAverageDelta(contributions)
    local period = g_currentMission.environment.currentPeriod;
    local season = ProductionInfoHud.GetSeasonForPeriod(period);
    local total = 0;

    for hour = 0, 23 do
        total = total + ProductionInfoHud.GetHourlyDelta(contributions, hour, period, season);
    end

    return total / 24;
end

---Ermittelt die Sorte, welche eine Gruppe alternativer Zutaten beim angegebenen Bestand gerade gewinnt.
---Der Auswahlmodus gehört der Rezeptlinie und ist im Spiel umstellbar: ASC nimmt die erste bevorratete Sorte
---in Rezept-Reihenfolge, DESC die letzte, MOST die bestbevorratete und LEAST die schwächstbevorratete.
---@param group table Gruppe mit members und amountByFillType
---@param levels table fillTypeId -> Bestand
---@param mixMode string|nil Auswahlmodus der Linie
---@return integer|nil fillTypeId nil wenn keine Sorte der Gruppe bevorratet ist
function ProductionInfoHud.GetMixGroupWinnerFillType(group, levels, mixMode)
    local winner = nil;
    local winnerLevel = nil;

    for _, fillTypeId in ipairs(group.members) do
        local level = levels[fillTypeId] or 0;
        if level > 0 then
            if winner == nil
                or mixMode == "DESC"
                or (mixMode == "MOST" and level > winnerLevel)
                or (mixMode == "LEAST" and level < winnerLevel) then
                winner = fillTypeId;
                winnerLevel = level;
            end
        end
    end

    return winner;
end

---Baut die Rezeptlinien eines Produktionspunktes in eine Form, mit der sich der Verlauf der Lagerbestände nachrechnen lässt.
---Die Mengen stehen darin schon als Menge pro Spielstunde, jeweils mit dem Takt der Linie verrechnet.
---@param productionPoint table
---@param numSharedThroughputLines integer
---@return table lines
function ProductionInfoHud.BuildSimulationLines(productionPoint, numSharedThroughputLines)
    local lines = {};

    for _, production in ipairs(productionPoint.activeProductions) do
        local hasTimeModes = ProductionInfoHud.GetLineHasTimeModes(production);

        -- Eine wegen des Wetters angehaltene Linie bleibt außen vor, eine wegen ihrer Uhrzeit angehaltene kommt mit:
        -- sie läuft später wieder, und genau das soll der Verlauf zeigen.
        if production.modeStatus == nil or hasTimeModes then
            local throughput, throughputWithoutMaster = ProductionInfoHud.GetLineThroughput(productionPoint, production, numSharedThroughputLines);
            local line = {production = production, hasTimeModes = hasTimeModes, required = {}, boosters = {}, groups = {}, outputs = {}};
            local groupsByMix = {};

            for _, inputItem in ipairs(production.inputs) do
                local mix = inputItem.mix or 0;
                local isBooster = mix == ProductionInfoHud.MIX_BOOST or mix == ProductionInfoHud.MIX_MASTER;

                -- Der Master-Booster verbraucht sich mit dem Takt ohne seinen eigenen Faktor, sonst schaukelt er sich selbst hoch
                local lineThroughput = throughput;
                if mix == ProductionInfoHud.MIX_MASTER then
                    lineThroughput = throughputWithoutMaster;
                end

                local amount = inputItem.amount * lineThroughput;
                if inputItem.rngAffected then
                    -- Der Zufall wirkt pro Takt, über eine Spielstunde mittelt er sich auf die Hälfte ein
                    amount = amount * 0.5;
                end

                if isBooster then
                    -- Ein Booster hält die Linie nie an, er fällt bei fehlendem Bestand nur aus.
                    -- Nur ein ausdrückliches false heißt Ausfall, nicht ein noch gar nicht gesetzter Wert.
                    if inputItem.boostSatisfied ~= false then
                        table.insert(line.boosters, {fillTypeId = inputItem.type, amount = amount});
                    end
                elseif mix > 0 then
                    local group = groupsByMix[mix];
                    if group == nil then
                        group = {mix = mix, members = {}, amountByFillType = {}};
                        groupsByMix[mix] = group;
                        table.insert(line.groups, group);
                    end
                    if group.amountByFillType[inputItem.type] == nil then
                        table.insert(group.members, inputItem.type);
                    end
                    group.amountByFillType[inputItem.type] = amount;
                else
                    table.insert(line.required, {fillTypeId = inputItem.type, amount = amount});
                end
            end

            for _, outputItem in ipairs(production.outputs) do
                if productionPoint.outputFillTypeIdsDirectSell[outputItem.type] == nil and not outputItem.sellDirectly then
                    local amount = outputItem.amount * throughput;

                    -- Booster wirken auf die Erzeugnisse: true vervielfacht die Menge, "reverse" verringert sie um denselben Faktor
                    if production.boosterFactor ~= nil and production.boosterFactor ~= 0 then
                        if outputItem.boost == true then
                            amount = amount * production.boosterFactor;
                        elseif outputItem.boost == "reverse" then
                            amount = amount / production.boosterFactor;
                        end
                    end

                    if outputItem.rngAffected then
                        amount = amount * 0.5;
                    end

                    table.insert(line.outputs, {fillTypeId = outputItem.type, amount = amount});
                end
            end

            table.insert(lines, line);
        end
    end

    return lines;
end

---Bestimmt für den angegebenen Zeitpunkt, was pro Spielstunde in jedes Lager fließt und was daraus abgeht.
---Eine Linie zählt nur mit, wenn sie laufen darf und ihre zwingenden Zutaten samt einer Sorte je Zutaten-Gruppe bevorratet sind -
---fehlt eine, steht die Linie und verbraucht auch die übrigen Zutaten nicht.
---@param lines table Ergebnis von BuildSimulationLines
---@param levels table fillTypeId -> Bestand
---@param hour integer Stunde 0 bis 23
---@param period integer Monat 1 bis 12
---@param season integer Jahreszeit 1 bis 4
---@param timeFactor number Umrechnung der Rezeptwerte auf die Länge eines Spieltages
---@param rates table wird geleert und mit fillTypeId -> Menge pro Spielstunde gefüllt
function ProductionInfoHud.ApplySimulationRates(lines, levels, hour, period, season, timeFactor, rates)
    for fillTypeId, _ in pairs(rates) do
        rates[fillTypeId] = nil;
    end

    for _, line in ipairs(lines) do
        if ProductionInfoHud.GetLineRunsAtHour(line.production, hour, period, season) then
            local canRun = true;

            for _, entry in ipairs(line.required) do
                if (levels[entry.fillTypeId] or 0) <= 0 then
                    canRun = false;
                    break;
                end
            end

            local winners = nil;
            if canRun then
                for _, group in ipairs(line.groups) do
                    local winner = ProductionInfoHud.GetMixGroupWinnerFillType(group, levels, line.production.mixMode);
                    if winner == nil then
                        canRun = false;
                        break;
                    end
                    winners = winners or {};
                    winners[winner] = group.amountByFillType[winner];
                end
            end

            if canRun then
                for _, entry in ipairs(line.required) do
                    rates[entry.fillTypeId] = (rates[entry.fillTypeId] or 0) - (entry.amount * timeFactor);
                end

                if winners ~= nil then
                    for fillTypeId, amount in pairs(winners) do
                        rates[fillTypeId] = (rates[fillTypeId] or 0) - (amount * timeFactor);
                    end
                end

                for _, entry in ipairs(line.boosters) do
                    if (levels[entry.fillTypeId] or 0) > 0 then
                        rates[entry.fillTypeId] = (rates[entry.fillTypeId] or 0) - (entry.amount * timeFactor);
                    end
                end

                for _, entry in ipairs(line.outputs) do
                    rates[entry.fillTypeId] = (rates[entry.fillTypeId] or 0) + (entry.amount * timeFactor);
                end
            end
        end
    end
end

---Prüft, welche Einträge ihre Grenze erreicht haben, und schreibt ihnen den erreichten Zeitpunkt hinein.
---@param items table Einträge mit simFillTypeIds und simLimit
---@param levels table fillTypeId -> Bestand
---@param hoursPast number bisher vergangene Spielstunden
---@return integer finished Anzahl der Einträge, die mit diesem Aufruf fertig geworden sind
function ProductionInfoHud.CheckSimulationTargets(items, levels, hoursPast)
    local finished = 0;

    for _, item in ipairs(items) do
        if item.hoursLeft == nil and item.simFillTypeIds ~= nil then
            local reached = true;

            if item.simLimit > 0 then
                reached = (levels[item.simFillTypeIds[1]] or 0) >= item.simLimit;
            else
                -- Eine Zutaten-Gruppe ist erst am Ende, wenn keine ihrer Sorten mehr etwas hergibt
                for _, fillTypeId in ipairs(item.simFillTypeIds) do
                    if (levels[fillTypeId] or 0) > 0 then
                        reached = false;
                        break;
                    end
                end
            end

            if reached then
                item.hoursLeft = hoursPast;
                finished = finished + 1;
            end
        end
    end

    return finished;
end

---Rechnet den Verlauf aller Lagerbestände einer Produktionsstätte gemeinsam voraus und trägt in jeden Eintrag ein,
---wann er seine Grenze erreicht: bei Verbrauch die Leere, bei Erzeugung die Lagerkapazität.
---Gemeinsam statt je Eintrag, weil sich Zutaten-Gruppen und einzelne Zutaten dieselbe Sorte teilen können -
---eine getrennte Rechnung würde denselben Weizen mehrfach verplanen.
---Zwischen zwei Ereignissen (eine Sorte wird leer, ein Zeitfenster wechselt) bleiben alle Mengen gleich,
---deshalb wird von Ereignis zu Ereignis gesprungen statt in Stundenschritten gerechnet.
---Die Erzeugung läuft dabei über die Lagergrenze hinaus weiter: ob eine volle Ausgabe die Linie tatsächlich anhält,
---hängt daran, ob die Ware verteilt oder direkt verkauft wird.
---@param productionPoint table
---@param lines table Ergebnis von BuildSimulationLines
---@param items table Einträge mit simFillTypeIds und simLimit, deren hoursLeft gesetzt wird
---@param timeFactor number Umrechnung der Rezeptwerte auf die Länge eines Spieltages
function ProductionInfoHud.SimulateStorageTimeline(productionPoint, lines, items, timeFactor)
    local environment = g_currentMission.environment;
    local levels = {};
    local hasTimeModes = false;
    local openItems = 0;

    for fillTypeId, _ in pairs(productionPoint.storage.fillLevels) do
        levels[fillTypeId] = productionPoint:getFillLevel(fillTypeId);
    end

    for _, line in ipairs(lines) do
        if line.hasTimeModes then
            hasTimeModes = true;
        end
    end

    for _, item in ipairs(items) do
        if item.simFillTypeIds ~= nil then
            item.hoursLeft = nil;
            openItems = openItems + 1;
        end
    end

    local hour = environment.currentHour;
    local period = environment.currentPeriod;
    local dayInPeriod = environment.currentDayInPeriod;
    local daysPerPeriod = environment.daysPerPeriod;
    local maxHours = ProductionInfoHud.MAX_FORECAST_DAYS * 24;
    -- Die laufende Stunde ist meist schon angebrochen, sonst faengt die Vorausrechnung zu frueh an
    local hourFraction = (environment.currentMinute or 0) / 60;
    local hoursPast = 0;
    local rates = {};

    -- Ein Lager, das jetzt schon leer oder voll ist, hat keine Restzeit und nicht die des ersten Rechenschritts
    openItems = openItems - ProductionInfoHud.CheckSimulationTargets(items, levels, 0);

    while hoursPast < maxHours and openItems > 0 do
        local season = ProductionInfoHud.GetSeasonForPeriod(period);
        ProductionInfoHud.ApplySimulationRates(lines, levels, hour, period, season, timeFactor, rates);

        -- Bis zum nächsten Ereignis bleiben alle Mengen gleich
        local step = maxHours - hoursPast;
        if hasTimeModes then
            step = math.min(step, 1 - hourFraction);
        end

        for fillTypeId, rate in pairs(rates) do
            if rate < 0 then
                local level = levels[fillTypeId] or 0;
                if level > 0 then
                    step = math.min(step, level / -rate);
                end
            end
        end

        for _, item in ipairs(items) do
            if item.hoursLeft == nil and item.simFillTypeIds ~= nil and item.simLimit > 0 then
                local rate = rates[item.simFillTypeIds[1]];
                if rate ~= nil and rate > 0 then
                    local missing = item.simLimit - (levels[item.simFillTypeIds[1]] or 0);
                    if missing > 0 then
                        step = math.min(step, missing / rate);
                    end
                end
            end
        end

        if step <= 0 then
            -- Sicherheitsnetz gegen einen Stillstand, falls ein Ereignis auf der Stelle liegt
            step = 1 / 60;
        end

        for fillTypeId, rate in pairs(rates) do
            local level = (levels[fillTypeId] or 0) + (rate * step);
            if level < 0 then
                level = 0;
            end
            levels[fillTypeId] = level;
        end

        hoursPast = hoursPast + step;
        hourFraction = hourFraction + step;
        while hourFraction >= 1 do
            hourFraction = hourFraction - 1;
            hour = hour + 1;
            if hour > 23 then
                hour = 0;
                dayInPeriod = dayInPeriod + 1;
                if dayInPeriod > daysPerPeriod then
                    dayInPeriod = 1;
                    period = period + 1;
                    if period > Environment.PERIODS_IN_YEAR then
                        period = 1;
                    end
                end
            end
        end

        openItems = openItems - ProductionInfoHud.CheckSimulationTargets(items, levels, hoursPast);
    end

    -- Was in der Vorausrechnung nicht eintritt, reicht mindestens bis an deren Grenze.
    -- Das Kennzeichen unterscheidet diese Untergrenze von einer echten Restzeit, die zufällig genauso lang ist.
    for _, item in ipairs(items) do
        if item.simFillTypeIds ~= nil and item.hoursLeft == nil then
            item.hoursLeft = maxHours;
            item.hoursLeftIsCapped = true;
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
    -- Ein bereits gesetztes hoursLeft stammt aus der gemeinsamen Vorausrechnung der Produktionsstätte und bleibt stehen,
    -- sonst reicht die Division durch den Stundenwert.
    if productionItem.productionPerHour ~= 0 then
        if productionItem.productionPerHour < 0 then
            -- wenn productionPerHour negativ, dann wird verbraucht, aber die Stunden sollten alle positiv sein
            productionItem.capacityData = (productionItem.capacity - productionItem.fillLevel);
            if productionItem.hoursLeft == nil then
                productionItem.hoursLeft = productionItem.fillLevel / (productionItem.productionPerHour * timeFactor * -1);
            end
        else
            -- wenn productionPerHour positiv, dann wird produziert, also Restzeit basiert auf bis lager voll ist
            productionItem.capacityData = productionItem.fillLevel;
            if productionItem.hoursLeft == nil then
                productionItem.hoursLeft = (productionItem.capacity - productionItem.fillLevel) / (productionItem.productionPerHour * timeFactor);
            end
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

        -- Hat die Vorausrechnung ihre Grenze erreicht, ist der Wert keine Prognose sondern eine Untergrenze: mehr als diese Zeit.
        -- Die Tilde für schwankende Werte entfällt dann, neben dem Größerzeichen sagt sie nichts mehr aus.
        -- Bei Voll, Leer und den Hinweistexten bleibt beides weg, dort gibt es nichts zu schätzen.
        if productionItem.hoursLeftIsCapped then
            productionItem.TimeLeftString = "> " .. productionItem.TimeLeftString;
            productionItem.TimeShortString = "> " .. productionItem.TimeShortString;
        elseif productionItem.isVarying and not (days == 0 and hours == 0 and minutes <= 2) then
            productionItem.TimeLeftString = "~" .. productionItem.TimeLeftString;
            productionItem.TimeShortString = "~" .. productionItem.TimeShortString;
        end
    else
        productionItem.TimeLeftString = "";
        productionItem.TimeShortString = "";
    end

    -- ProductionInfoHud.DebugTable("productionItem", productionItem);
    if productionItem.productionPerHour ~= 0 then
        -- nur items mit einem Stundenwert einfügen, da für die Verteilliste eine eigene Liste gemacht wird
        table.insert(myProductionItems, productionItem)

        -- längsten filltypetitel für box behalten.
        -- Die Aufzählung einer Zutaten-Gruppe bleibt dabei außen vor, sie würde die Namensspalte zusammenquetschen - angezeigt wird sie gekürzt.
        if productionItem.mixFillTypeIds == nil then
            local textWidth = getTextWidth(10, utf8Substr(productionItem.fillTypeTitle, 0));
            if ProductionInfoHud.longestFillTypeTitleWidth == nil or ProductionInfoHud.longestFillTypeTitleWidth < textWidth then
                ProductionInfoHud.longestFillTypeTitleWidth = textWidth;
                ProductionInfoHud.longestFillTypeTitle = productionItem.fillTypeTitle;
            end
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
    return ProductionInfoHud.GetMatchingFillType(matchFillTypeIds, fillTypeIds) ~= nil;
end

---Liefert die Sorte, über die ein Eintrag zur geladenen oder transportierbaren Ware passt.
---Eine Zeile, die mehrere Sorten zusammenfasst, wird darüber der passenden Ware zugeordnet.
---@param matchFillTypeIds table set of fillTypeId -> true, kann nil sein wenn noch nicht berechnet
---@param fillTypeIds table set of fillTypeId -> true, gegen das geprüft wird
---@return integer|nil fillTypeId nil wenn keine Sorte passt
function ProductionInfoHud.GetMatchingFillType(matchFillTypeIds, fillTypeIds)
    if matchFillTypeIds == nil then
        return nil;
    end

    for fillTypeId, _ in pairs(matchFillTypeIds) do
        if fillTypeIds[fillTypeId] then
            return fillTypeId;
        end
    end

    return nil;
end

---Prüft, ob ein Eintrag zu einem Filter über einzelne Sorten passt. Eine Zeile, die mehrere Sorten zusammenfasst,
---passt, sobald eine ihrer Sorten gesucht wird.
---@param productionItem table
---@param fillTypeFilterIds table set of fillTypeId -> true
---@return boolean matches
function ProductionInfoHud.MatchesFillTypeFilter(productionItem, fillTypeFilterIds)
    if productionItem.fillTypeId ~= nil and fillTypeFilterIds[productionItem.fillTypeId] then
        return true;
    end

    if productionItem.mixFillTypeIds ~= nil then
        for _, fillTypeId in ipairs(productionItem.mixFillTypeIds) do
            if fillTypeFilterIds[fillTypeId] then
                return true;
            end
        end
    end

    return false;
end

---Beschriftung der FillType-Spalte eines Eintrags. Bei einer Zeile für mehrere Sorten rückt die Sorte nach vorne,
---die zur geladenen Ware passt, damit sie nicht von der Spaltenbreite abgeschnitten wird.
---Hat der Modder der Gruppe einen eigenen Namen gegeben, bleibt dieser unverändert stehen.
---@param productionItem table
---@return string title
function ProductionInfoHud.GetItemFillTypeTitle(productionItem)
    if productionItem.mixFillTypeTitles == nil or productionItem.cargoMatchFillTypeId == nil then
        return tostring(productionItem.fillTypeTitle);
    end

    local titles = {};
    for index, fillTypeId in ipairs(productionItem.mixFillTypeIds) do
        if fillTypeId == productionItem.cargoMatchFillTypeId then
            table.insert(titles, 1, productionItem.mixFillTypeTitles[index]);
        else
            table.insert(titles, productionItem.mixFillTypeTitles[index]);
        end
    end

    return table.concat(titles, ", ");
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

---Hängt den Beitrag einer Rezeptlinie an die Liste ihres FillTypes. Der Beitrag hält seine Linie fest,
---damit die Restzeit später berücksichtigen kann, wann diese Linie überhaupt läuft.
---@param contributionsByFillType table
---@param fillTypeId integer
---@param production table
---@param delta number Menge pro Spielstunde, negativ wenn verbraucht wird
function ProductionInfoHud.AddContribution(contributionsByFillType, fillTypeId, production, delta)
    local contributions = contributionsByFillType[fillTypeId];
    if contributions == nil then
        contributions = {};
        contributionsByFillType[fillTypeId] = contributions;
    end

    table.insert(contributions, {production = production, delta = delta});
end

---Prüft, ob sich ein Lager für diese Sorte wetterabhängig von selbst füllt oder leert, etwa ein Regenfass.
---Wie viel gerade dazukommt, hängt am Wetter der nächsten Stunden und ist von außen nicht lesbar,
---deshalb wird ein solcher Bestand nur als schwankend gekennzeichnet und nicht in die Restzeit gerechnet.
---@param productionPoint table
---@param fillTypeId integer
---@return boolean hasWeatherFilling
function ProductionInfoHud.GetHasWeatherFilling(productionPoint, fillTypeId)
    return productionPoint.weatherModes ~= nil and productionPoint.weatherModes[fillTypeId] ~= nil;
end

---Baut die Zeile für eine Gruppe alternativer Zutaten. Bestand und Kapazität sind die Summe ihrer Sorten,
---verbraucht wird pro Takt aber nur eine davon - die Gruppe reicht deshalb so lange, bis die letzte Alternative leer ist.
---@param productionPoint table
---@param productionName string|nil Name des Gebäudes, den auch die übrigen Zeilen tragen
---@param mixGroup table
---@return table|nil productionItem nil wenn die Gruppe keine Sorte enthält
function ProductionInfoHud.CreateMixGroupItem(productionPoint, productionName, mixGroup)
    if #mixGroup.members == 0 then
        return nil;
    end

    local storage = productionPoint.storage;
    local fillLevel = 0;
    local capacity = 0;
    local hasSharedCapacity = false;
    local hasWeatherFilling = false;
    local titles = {};
    local matchFillTypeIds = {};

    for _, fillTypeId in ipairs(mixGroup.members) do
        fillLevel = fillLevel + productionPoint:getFillLevel(fillTypeId);
        capacity = capacity + productionPoint:getCapacity(fillTypeId);
        table.insert(titles, ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(fillTypeId));

        for matchFillTypeId, _ in pairs(ProductionInfoHud.GetMatchFillTypeIds(productionPoint, fillTypeId)) do
            matchFillTypeIds[matchFillTypeId] = true;
        end

        -- Eine Sorte ohne eigene Kapazitätszeile lebt vom gemeinsamen Topf des Lagers
        if storage ~= nil and storage.supportsMultipleFillTypes and storage.capacities ~= nil and storage.capacities[fillTypeId] == nil then
            hasSharedCapacity = true;
        end

        if ProductionInfoHud.GetHasWeatherFilling(productionPoint, fillTypeId) then
            hasWeatherFilling = true;
        end
    end

    -- Teilen sich Sorten der Gruppe einen gemeinsamen Topf, dürfen sich ihre Kapazitäten nicht über dessen Größe hinaus aufaddieren
    if hasSharedCapacity and storage.capacity ~= nil and capacity > storage.capacity then
        capacity = storage.capacity;
    end

    local productionItem = {};
    productionItem.name = productionName;
    productionItem.fillTypeId = nil; -- die Zeile steht für mehrere Sorten, nicht für eine einzelne
    productionItem.mixFillTypeIds = mixGroup.members;
    productionItem.fillTypeTitle = mixGroup.title or table.concat(titles, ", ");
    if mixGroup.title == nil then
        -- nur die selbst aufgezählten Sorten lassen sich für die geladene Ware umsortieren, ein eigener Gruppenname bleibt wie er ist
        productionItem.mixFillTypeTitles = titles;
    end
    productionItem.fillLevel = fillLevel;
    productionItem.capacity = capacity;
    productionItem.hoursLeft = nil;
    productionItem.isInput = true;
    productionItem.isOutput = false;
    productionItem.IsProduction = true;
    productionItem.target = productionPoint;
    productionItem.matchFillTypeIds = matchFillTypeIds;
    productionItem.isVarying = mixGroup.isVarying or hasWeatherFilling;

    if capacity == 0 then
        productionItem.capacityLevel = 0;
    else
        productionItem.capacityLevel = fillLevel / capacity;
    end

    local contributions = {{production = mixGroup.production, delta = -mixGroup.amount}};
    if mixGroup.hasTimeModes then
        productionItem.productionPerHour = ProductionInfoHud.GetDailyAverageDelta(contributions);
    else
        productionItem.productionPerHour = -mixGroup.amount;
    end

    -- Die Gruppe ist erst am Ende, wenn keine ihrer Sorten mehr etwas hergibt
    if productionItem.productionPerHour ~= 0 then
        productionItem.simFillTypeIds = mixGroup.members;
        productionItem.simLimit = 0;
    end

    return productionItem;
end

---Add the given production point to the list
-- @param table myProductionItems The list where it will be added to
-- @param ProductionPoint productionPoint What should be added
function ProductionInfoHud:AddProductionPoint(myProductionItems, productionPoint)
    -- Name ist pro Produktionspunkt gleich, daher nur ein Mal statt pro FillType berechnen
    local productionName = productionPoint.owningPlaceable:getName();
    if productionName ~= nil then
        productionName = string.gsub(productionName, "%(Leasing%) ", "");
    end

    local numSharedThroughputLines = ProductionInfoHud.CountSharedThroughputLines(productionPoint);

    -- Einmal pro Produktionspunkt statt pro FillType über alle aktiven Produktionen laufen und die Beiträge je FillType einsammeln
    local contributionsByFillType = {};
    local isInputByFillType = {};
    local isOutputByFillType = {};
    local isVaryingByFillType = {};
    local hasTimeModesByFillType = {};
    local mixGroupsByKey = {};
    local mixGroupList = {};
    local mixMemberFillTypes = {};
    local plainFillTypes = {};

    local hasAnyTimeModes = false;

    for _, production in ipairs(productionPoint.activeProductions) do
        local hasTimeModes = ProductionInfoHud.GetLineHasTimeModes(production);
        if hasTimeModes then
            hasAnyTimeModes = true;
        end

        -- Eine wegen des Wetters angehaltene Linie verbraucht und erzeugt nichts. Eine wegen ihrer Uhrzeit, ihres Monats
        -- oder ihrer Jahreszeit angehaltene Linie zählt dagegen mit: sie läuft später wieder, und genau das rechnet die Zeitachse aus.
        if production.modeStatus == nil or hasTimeModes then
            local throughput, throughputWithoutMaster = ProductionInfoHud.GetLineThroughput(productionPoint, production, numSharedThroughputLines);
            -- Ein Wetterfaktor stammt immer aus dem letzten Takt und ändert sich mit dem Wetter
            local isLineVarying = production.weatherFactorCurrent ~= nil;

            for _, inputItem in ipairs(production.inputs) do
                local mix = inputItem.mix or 0;
                local isBooster = mix == ProductionInfoHud.MIX_BOOST or mix == ProductionInfoHud.MIX_MASTER;

                -- Ein Booster verbraucht sich nur, wenn sein Bestand im letzten Takt gereicht hat.
                -- Nur ein ausdrückliches false heißt, dass er ausfällt: ohne gelaufenen Takt steht dort gar nichts,
                -- und dann darf die Sorte nicht stillschweigend aus der Liste fallen.
                if not isBooster or inputItem.boostSatisfied ~= false then
                    -- Der Master-Booster verbraucht sich mit dem Takt ohne seinen eigenen Faktor, sonst schaukelt er sich selbst hoch
                    local lineThroughput = throughput;
                    if mix == ProductionInfoHud.MIX_MASTER then
                        lineThroughput = throughputWithoutMaster;
                    end

                    local amount = inputItem.amount * lineThroughput;
                    local isAmountVarying = isLineVarying;
                    if inputItem.rngAffected then
                        -- Der Zufall wirkt pro Takt, über eine Spielstunde mittelt er sich auf die Hälfte ein
                        amount = amount * 0.5;
                        isAmountVarying = true;
                    end

                    if mix > 0 and not isBooster then
                        -- Gruppe alternativer Zutaten: pro Takt wird nur eine Sorte verbraucht, deshalb bekommt die Gruppe eine gemeinsame Zeile
                        local groupKey = tostring(production.id) .. "#" .. tostring(mix);
                        local mixGroup = mixGroupsByKey[groupKey];
                        if mixGroup == nil then
                            mixGroup = {production = production, members = {}, memberSet = {}, amount = 0, hasWinnerAmount = false, isVarying = false, hasTimeModes = hasTimeModes};
                            if production.mixGroupTitles ~= nil then
                                mixGroup.title = production.mixGroupTitles[mix];
                            end
                            mixGroupsByKey[groupKey] = mixGroup;
                            table.insert(mixGroupList, mixGroup);
                        end

                        if not mixGroup.memberSet[inputItem.type] then
                            mixGroup.memberSet[inputItem.type] = true;
                            table.insert(mixGroup.members, inputItem.type);
                        end
                        mixMemberFillTypes[inputItem.type] = true;

                        -- Verbraucht wird die Menge der Sorte, welche die Gruppe gerade gewinnt.
                        -- Steht noch kein Gewinner fest, bleibt die Menge der ersten Alternative als Anhaltspunkt stehen.
                        local isWinner = production.mixGroupWinnerType ~= nil and production.mixGroupWinnerType[mix] == inputItem.type;
                        if isWinner or not mixGroup.hasWinnerAmount then
                            mixGroup.amount = amount;
                            mixGroup.hasWinnerAmount = isWinner;
                        end
                        if isAmountVarying then
                            mixGroup.isVarying = true;
                        end
                    else
                        isInputByFillType[inputItem.type] = true;
                        plainFillTypes[inputItem.type] = true;
                        ProductionInfoHud.AddContribution(contributionsByFillType, inputItem.type, production, -amount);
                        if isAmountVarying then
                            isVaryingByFillType[inputItem.type] = true;
                        end
                        if hasTimeModes then
                            hasTimeModesByFillType[inputItem.type] = true;
                        end
                    end
                end
            end

            -- Erzeugnisse zählen nur, solange die Linie nicht auf Zutaten wartet
            if production.status ~= ProductionPoint.PROD_STATUS.MISSING_INPUTS then
                for _, outputItem in ipairs(production.outputs) do
                    if productionPoint.outputFillTypeIdsDirectSell[outputItem.type] == nil and not outputItem.sellDirectly then
                        local amount = outputItem.amount * throughput;
                        local isAmountVarying = isLineVarying;

                        -- Booster wirken auf die Erzeugnisse: true vervielfacht die Menge, "reverse" verringert sie um denselben Faktor
                        if production.boosterFactor ~= nil and production.boosterFactor ~= 0 then
                            if outputItem.boost == true then
                                amount = amount * production.boosterFactor;
                            elseif outputItem.boost == "reverse" then
                                amount = amount / production.boosterFactor;
                            end
                        end

                        if outputItem.rngAffected then
                            amount = amount * 0.5;
                            isAmountVarying = true;
                        end

                        isOutputByFillType[outputItem.type] = true;
                        plainFillTypes[outputItem.type] = true;
                        ProductionInfoHud.AddContribution(contributionsByFillType, outputItem.type, production, amount);
                        if isAmountVarying then
                            isVaryingByFillType[outputItem.type] = true;
                        end
                        if hasTimeModes then
                            hasTimeModesByFillType[outputItem.type] = true;
                        end
                    end
                end
            end
        end
    end

    -- Zutaten-Gruppen und Zeitvorgaben machen aus der Restzeit eine Vorausrechnung, und die muss für alle Sorten der Stätte
    -- gemeinsam laufen: Gruppen und einzelne Zutaten teilen sich dieselben Sorten.
    local needsSimulation = #mixGroupList > 0 or hasAnyTimeModes;
    local pendingItems = {};

    for fillTypeId, _ in pairs(productionPoint.storage.fillLevels) do
        -- Eine Sorte, die nur als Alternative in einer Zutaten-Gruppe vorkommt, steht in der Zeile ihrer Gruppe statt in einer eigenen
        if plainFillTypes[fillTypeId] or not mixMemberFillTypes[fillTypeId] then

            -- item für produktionsliste erstellen. Ein Item pro fillType
            local productionItem = {}
            productionItem.name = productionName;
            productionItem.fillTypeId = fillTypeId;
            productionItem.productionPerHour = 0; -- negative when more used than produced. calculated on one day per month as giants always does
            productionItem.hoursLeft = nil; -- time until full or empty, nil when not changing
            productionItem.fillLevel = productionPoint:getFillLevel(fillTypeId);
            productionItem.capacity = productionPoint:getCapacity(fillTypeId);
            productionItem.isInput = productionPoint.inputFillTypeIds[fillTypeId] == true or isInputByFillType[fillTypeId] == true;
            productionItem.isOutput = productionPoint.outputFillTypeIds[fillTypeId] == true or isOutputByFillType[fillTypeId] == true;
            productionItem.IsProduction = true;
            productionItem.target = productionPoint;
            productionItem.isAutoDeliver = productionPoint.outputFillTypeIdsAutoDeliver[fillTypeId];
            -- Ein Lager, das sich wetterabhängig selbst füllt oder leert, macht jede Restzeit ungenau.
            -- Wie viel gerade dazukommt, ist von außen nicht lesbar, deshalb wird nur gekennzeichnet und nichts gerechnet.
            productionItem.isVarying = isVaryingByFillType[fillTypeId] or ProductionInfoHud.GetHasWeatherFilling(productionPoint, fillTypeId);
            productionItem.fillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(fillTypeId);

            if productionItem.capacity == nil or productionItem.capacity == 0 then
                productionItem.capacityLevel = 0
            else
                productionItem.capacityLevel = productionItem.fillLevel / productionItem.capacity;
            end

            local contributions = contributionsByFillType[fillTypeId];
            if contributions ~= nil then
                if hasTimeModesByFillType[fillTypeId] then
                    -- Mit Zeitvorgaben schwankt der Stundenwert über den Tag, angezeigt wird deshalb das Tagesmittel
                    productionItem.productionPerHour = ProductionInfoHud.GetDailyAverageDelta(contributions);
                else
                    for _, contribution in ipairs(contributions) do
                        productionItem.productionPerHour = productionItem.productionPerHour + contribution.delta;
                    end
                end
            end

            if productionItem.isInput then
                productionItem.matchFillTypeIds = ProductionInfoHud.GetMatchFillTypeIds(productionPoint, fillTypeId);
            end

            if needsSimulation and productionItem.productionPerHour ~= 0 then
                productionItem.simFillTypeIds = {fillTypeId};
                if productionItem.productionPerHour < 0 then
                    productionItem.simLimit = 0;
                else
                    productionItem.simLimit = productionItem.capacity;
                end
            end

            table.insert(pendingItems, productionItem);
        end
    end

    for _, mixGroup in ipairs(mixGroupList) do
        local productionItem = ProductionInfoHud.CreateMixGroupItem(productionPoint, productionName, mixGroup);
        if productionItem ~= nil then
            table.insert(pendingItems, productionItem);
        end
    end

    if needsSimulation then
        local lines = ProductionInfoHud.BuildSimulationLines(productionPoint, numSharedThroughputLines);
        ProductionInfoHud.SimulateStorageTimeline(productionPoint, lines, pendingItems, 1 / g_currentMission.environment.daysPerPeriod);
    end

    for _, productionItem in ipairs(pendingItems) do
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
    -- Eine Zeile für mehrere Sorten (Futter, Zutaten-Gruppe) hat keine einzelne fillTypeId. Passt eine davon zur geladenen Ware,
    -- sortiert sie über diese Sorte mit ein und steht damit bei den übrigen Zeilen derselben Ware.
    local fillTypeIdA = a.fillTypeId or a.cargoMatchFillTypeId;
    local fillTypeIdB = b.fillTypeId or b.cargoMatchFillTypeId;
    if fillTypeIdA ~= fillTypeIdB then
        -- ohne jede Sorte ans Ende sortieren statt Vergleichsfehler
        if fillTypeIdA == nil then return false; end
        if fillTypeIdB == nil then return true; end
        return fillTypeIdA < fillTypeIdB;
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
                -- Öffnungszeiten und Monatsvorgaben gehen anteilig in den Monatsbedarf ein:
                -- eine Linie, die nur acht der 24 Stunden arbeitet, braucht auch nur ein Drittel der Zutaten.
                local runningShare = ProductionInfoHud.GetLineRunningShareOfDay(production);

                for _, inputItem in pairs(production.inputs) do
                    local changedAmountPerMonth = production.cyclesPerHour * inputItem.amount * 24 * runningShare * -1;

                    local maxTotalAmount = changedAmountPerMonth * productionPointMultiplicatorAll;
                    local minTotalAmount = maxTotalAmount;

                    local maxActiveAmount = changedAmountPerMonth * productionPointMultiplicatorActive;
                    local minActiveAmount = maxActiveAmount;

                    -- Eine Zutat aus einer Gruppe von Alternativen und ein Booster sind nicht zwingend nötig,
                    -- sie zählen deshalb nur in den Höchst-, nicht in den Mindestbedarf.
                    local isOptionalInput = (inputItem.mix or 0) ~= 0;
                    if isOptionalInput then
                        minTotalAmount = 0;
                        minActiveAmount = 0;
                    end

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

                    ProductionInfoHud.AddAmountToProductionNeedings(newProductionNeedings, inputItem.type, minActiveAmount, maxActiveAmount, minTotalAmount, maxTotalAmount, productionName, production.name, alternativeFillTypes, nil, nil, productionImageFilename, isOptionalInput);
                end

                for _, outputItem in pairs(production.outputs) do
                    local changedAmountPerMonth = production.cyclesPerHour * outputItem.amount * 24 * runningShare;

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


function ProductionInfoHud.AddAmountToProductionNeedings(newProductionNeedings, fillTypeId, minActiveAmount, maxActiveAmount, minTotalAmount, maxTotalAmount, productionName, productionLineName, alternativeFillTypes, alternativeForFillTypeId, outputMode, productionImageFilename, isOptional)
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
    usageDetailInfoItem.isOptional = isOptional; -- Zutat aus einer Gruppe von Alternativen oder ein Booster, also nicht zwingend
    if alternativeForFillTypeId ~= nil then
        usageDetailInfoItem.alternativeForFillTypeTitle = ProductionInfoHud.fillTypeManager:getFillTypeTitleByIndex(alternativeForFillTypeId); -- alternative für welchen Filltype in dieser Produktionslinie
    end

    table.insert(newProductionNeeding.ProductionDetails, usageDetailInfoItem);
end

addModEventListener(ProductionInfoHud);