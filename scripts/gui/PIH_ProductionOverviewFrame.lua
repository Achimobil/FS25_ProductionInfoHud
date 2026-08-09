PihProductionOverviewFrame = {}
local PihProductionOverviewFrame_mt = Class(PihProductionOverviewFrame, TabbedMenuFrameElement)

PihProductionOverviewFrame.SECTION_FRUITS = 1
PihProductionOverviewFrame.SECTION_OTHERS = 2

PihProductionOverviewFrame.SECTION_PRODUCERS = 1
PihProductionOverviewFrame.SECTION_CONSUMERS = 2

PihProductionOverviewFrame.MODE_HOUR = 1
PihProductionOverviewFrame.MODE_DAY = 2
PihProductionOverviewFrame.MODE_MONTH = 3
PihProductionOverviewFrame.MODE_YEAR = 4

function PihProductionOverviewFrame.register(modDirectory)
    local controller = PihProductionOverviewFrame.new()
    g_gui:loadGui(modDirectory .. "gui/PIH_ProductionOverviewFrame.xml", "PihProductionOverviewFrame", controller, true)
    controller:initialize()
    return controller
end

function PihProductionOverviewFrame.new(target, subclass_mt)
    local self = TabbedMenuFrameElement.new(target, subclass_mt or PihProductionOverviewFrame_mt)
    self.sections = { {}, {} }
    self.detailSections = { {}, {} }
    self.displayMode = PihProductionOverviewFrame.MODE_MONTH
    self.hasCustomMenuButtons = true
    return self
end

function PihProductionOverviewFrame:initialize()
    PihProductionOverviewFrame:superClass().initialize(self)

    self.backButtonInfo = {
        inputAction = InputAction.MENU_BACK
    }
    self.nextPageButtonInfo = {
        inputAction = InputAction.MENU_PAGE_NEXT,
        text = g_i18n:getText("ui_ingameMenuNext"),
        callback = self.onPageNext
    }
    self.prevPageButtonInfo = {
        inputAction = InputAction.MENU_PAGE_PREV,
        text = g_i18n:getText("ui_ingameMenuPrev"),
        callback = self.onPagePrevious
    }
    self.toggleModeButtonInfo = {
        inputAction = InputAction.MENU_ACTIVATE,
        text = g_i18n:getText("pih_toggleModeButton"),
        callback = function()
            self:onButtonToggleMode()
        end
    }
end

function PihProductionOverviewFrame:onFrameOpen()
    PihProductionOverviewFrame:superClass().onFrameOpen(self)
    self:updateOverviewData()
    self:updateMenuButtons()
end

function PihProductionOverviewFrame:onFrameClose()
    PihProductionOverviewFrame:superClass().onFrameClose(self)
end

function PihProductionOverviewFrame:updateMenuButtons()
    self.menuButtonInfo = { self.backButtonInfo, self.nextPageButtonInfo, self.prevPageButtonInfo, self.toggleModeButtonInfo }
    self:setMenuButtonInfoDirty()
end

-- Beschriftung der aktuell gewählten Zeiteinheit
function PihProductionOverviewFrame:getModeLabel()
    if self.displayMode == PihProductionOverviewFrame.MODE_HOUR then
        return g_i18n:getText("pih_mode_hour")
    elseif self.displayMode == PihProductionOverviewFrame.MODE_DAY then
        return g_i18n:getText("pih_mode_day")
    elseif self.displayMode == PihProductionOverviewFrame.MODE_YEAR then
        return g_i18n:getText("pih_mode_year")
    end
    return g_i18n:getText("pih_mode_month")
end

-- Umrechnungsfaktor von unserem intern gespeicherten Monatswert auf die aktuelle Zeiteinheit
function PihProductionOverviewFrame:getDisplayFactor()
    local daysPerPeriod = g_currentMission.environment.daysPerPeriod
    if self.displayMode == PihProductionOverviewFrame.MODE_HOUR then
        return 1 / (24 * daysPerPeriod)
    elseif self.displayMode == PihProductionOverviewFrame.MODE_DAY then
        return 1 / daysPerPeriod
    elseif self.displayMode == PihProductionOverviewFrame.MODE_YEAR then
        return 12
    end
    return 1
end

function PihProductionOverviewFrame:getDisplayDecimals()
    if self.displayMode == PihProductionOverviewFrame.MODE_HOUR or self.displayMode == PihProductionOverviewFrame.MODE_DAY then
        return 2
    end
    return 0
end

function PihProductionOverviewFrame:updateTitle()
    self.dialogTitleText:setText(string.format(g_i18n:getText("pih_dialogTitle"), self:getModeLabel()))
end

function PihProductionOverviewFrame:onButtonToggleMode()
    local daysPerPeriod = g_currentMission.environment.daysPerPeriod

    if self.displayMode == PihProductionOverviewFrame.MODE_HOUR then
        if daysPerPeriod > 1 then
            self.displayMode = PihProductionOverviewFrame.MODE_DAY
        else
            self.displayMode = PihProductionOverviewFrame.MODE_MONTH
        end
    elseif self.displayMode == PihProductionOverviewFrame.MODE_DAY then
        self.displayMode = PihProductionOverviewFrame.MODE_MONTH
    elseif self.displayMode == PihProductionOverviewFrame.MODE_MONTH then
        self.displayMode = PihProductionOverviewFrame.MODE_YEAR
    else
        self.displayMode = PihProductionOverviewFrame.MODE_HOUR
    end

    self:updateTitle()
    self.overviewList:reloadData()
    self.detailList:reloadData()
end

-- Behalten/Verteilt/Verkauft/Verbraucht/Rest für einen Filltype-Eintrag berechnen (nur aktive Mengen, unabhängig von der Zeiteinheit)
function PihProductionOverviewFrame.calculateSummary(entry)
    local kept, distributed, sold, consumed = 0, 0, 0, 0

    if entry ~= nil then
        for _, detail in ipairs(entry.ProductionDetails) do
            if detail.activeAmount >= 0 then
                if detail.outputMode == ProductionPoint.OUTPUT_MODE.DIRECT_SELL then
                    sold = sold + detail.activeAmount
                elseif detail.outputMode == ProductionPoint.OUTPUT_MODE.AUTO_DELIVER then
                    distributed = distributed + detail.activeAmount
                else
                    kept = kept + detail.activeAmount
                end
            elseif detail.alternativeForFillTypeTitle == nil then
                consumed = consumed + detail.activeAmount
            end
        end
    end

    local rest = kept + distributed + consumed

    return kept, distributed, sold, consumed, rest
end

-- Jahresertrag pro m² für einen Feldfrucht-Filltype ermitteln (nil, wenn nicht anwendbar, z.B. Stroh)
function PihProductionOverviewFrame.getFruitLiterPerSqm(fillTypeId)
    if fillTypeId == FillType.STRAW then
        return nil
    end

    local fruitDesc = g_fruitTypeManager:getFruitTypeByFillTypeIndex(fillTypeId)
    if fruitDesc == nil then
        return nil
    end

    if g_fruitTypeManager:isFillTypeWindrow(fillTypeId) then
        return fruitDesc.windrowLiterPerSqm or fruitDesc.literPerSqm
    end

    return fruitDesc.literPerSqm
end

function PihProductionOverviewFrame.sortByTitle(a, b)
    return a.title < b.title
end

function PihProductionOverviewFrame:updateOverviewData()
    local productionNeedings = ProductionInfoHud.UpdateProductionNeedings()

    local fruitEntries = {}
    local otherEntries = {}
    for _, entry in pairs(productionNeedings) do
        local _, _, _, _, rest = PihProductionOverviewFrame.calculateSummary(entry)
        entry.rest = rest

        if entry.isFruit then
            table.insert(fruitEntries, entry)
        else
            table.insert(otherEntries, entry)
        end
    end

    table.sort(fruitEntries, PihProductionOverviewFrame.sortByTitle)
    table.sort(otherEntries, PihProductionOverviewFrame.sortByTitle)

    self.sections[PihProductionOverviewFrame.SECTION_FRUITS] = fruitEntries
    self.sections[PihProductionOverviewFrame.SECTION_OTHERS] = otherEntries

    self:updateTitle()
    self.overviewList:reloadData()

    if #fruitEntries > 0 then
        self.overviewList:setSelectedItem(PihProductionOverviewFrame.SECTION_FRUITS, 1, true)
    elseif #otherEntries > 0 then
        self.overviewList:setSelectedItem(PihProductionOverviewFrame.SECTION_OTHERS, 1, true)
    else
        self:updateDetailData(nil)
    end
end

function PihProductionOverviewFrame.sortByProductionNames(a, b)
    if a.productionName ~= b.productionName then
        return a.productionName < b.productionName
    end
    return a.productionLineName < b.productionLineName
end

function PihProductionOverviewFrame.setValueTextColor(textElement, value)
    if value < 0 then
        textElement:setTextColor(0.9, 0.15, 0.15, 1)
    else
        textElement:setTextColor(1, 1, 1, 1)
    end
end

function PihProductionOverviewFrame:updateSummaryDisplay(entry)
    if entry == nil then
        self.summaryKeptText:setText("")
        self.summaryDistributedText:setText("")
        self.summarySoldText:setText("")
        self.summaryConsumedText:setText("")
        self.summaryRestText:setText("")
        self.summaryAreaText:setText("")
        return
    end

    local kept, distributed, sold, consumed, rest = PihProductionOverviewFrame.calculateSummary(entry)
    local factor = self:getDisplayFactor()
    local decimals = self:getDisplayDecimals()

    self.summaryKeptText:setText(string.format("%s: %s", g_i18n:getText("pih_word_kept"), g_i18n:formatNumber(kept * factor, decimals)))
    self.summaryDistributedText:setText(string.format("%s: %s", g_i18n:getText("pih_word_distributed"), g_i18n:formatNumber(distributed * factor, decimals)))
    self.summarySoldText:setText(string.format("%s: %s", g_i18n:getText("pih_word_sold"), g_i18n:formatNumber(sold * factor, decimals)))
    self.summaryConsumedText:setText(string.format("%s: %s", g_i18n:getText("pih_word_consumed"), g_i18n:formatNumber(consumed * factor, decimals)))
    self.summaryRestText:setText(string.format("%s: %s", g_i18n:getText("pih_word_rest"), g_i18n:formatNumber(rest * factor, decimals)))
    PihProductionOverviewFrame.setValueTextColor(self.summaryRestText, rest)

    -- Flächenbedarf bezieht sich immer aufs Jahr, unabhängig von der gewählten Zeiteinheit
    local literPerSqm = entry.isFruit and PihProductionOverviewFrame.getFruitLiterPerSqm(entry.fillTypeId) or nil
    if literPerSqm ~= nil and literPerSqm > 0 then
        local yearlyDemand = math.max(0, -rest) * 12
        local areaNeeded = yearlyDemand / (literPerSqm * 10000)
        self.summaryAreaText:setText(string.format(g_i18n:getText("pih_summary_areaNeeded"), g_i18n:formatNumber(areaNeeded, 2)))
    else
        self.summaryAreaText:setText("")
    end
end

function PihProductionOverviewFrame:updateDetailData(entry)
    local producers = {}
    local directConsumers = {}
    local converterConsumers = {}

    if entry ~= nil then
        for _, detail in ipairs(entry.ProductionDetails) do
            if detail.activeAmount >= 0 then
                table.insert(producers, detail)
            elseif detail.alternativeForFillTypeTitle ~= nil then
                table.insert(converterConsumers, detail)
            else
                table.insert(directConsumers, detail)
            end
        end
    end

    table.sort(producers, PihProductionOverviewFrame.sortByProductionNames)
    table.sort(directConsumers, PihProductionOverviewFrame.sortByProductionNames)
    table.sort(converterConsumers, PihProductionOverviewFrame.sortByProductionNames)

    local consumers = {}
    for _, detail in ipairs(directConsumers) do
        table.insert(consumers, detail)
    end
    for _, detail in ipairs(converterConsumers) do
        table.insert(consumers, detail)
    end

    self.detailSections[PihProductionOverviewFrame.SECTION_PRODUCERS] = producers
    self.detailSections[PihProductionOverviewFrame.SECTION_CONSUMERS] = consumers

    self:updateSummaryDisplay(entry)

    self.detailList:reloadData()
end

function PihProductionOverviewFrame:getNumberOfSections(list)
    if list == self.overviewList then
        return #self.sections
    elseif list == self.detailList then
        return #self.detailSections
    end
    return 1
end

function PihProductionOverviewFrame:getTitleForSectionHeader(list, section)
    if list == self.overviewList then
        if section == PihProductionOverviewFrame.SECTION_FRUITS then
            return g_i18n:getText("pih_section_fruits")
        else
            return g_i18n:getText("pih_section_others")
        end
    elseif list == self.detailList then
        if section == PihProductionOverviewFrame.SECTION_PRODUCERS then
            return g_i18n:getText("pih_section_producers")
        else
            return g_i18n:getText("pih_section_consumers")
        end
    end
    return nil
end

function PihProductionOverviewFrame:getNumberOfItemsInSection(list, section)
    if list == self.overviewList then
        return #self.sections[section]
    elseif list == self.detailList then
        return #self.detailSections[section]
    end
    return 0
end

function PihProductionOverviewFrame.setCellIcon(cell, imageFilename)
    local icon = cell:getAttribute("icon")
    if icon == nil then
        return
    end
    icon:setVisible(imageFilename ~= nil)
    if imageFilename ~= nil then
        icon:setImageFilename(imageFilename)
    end
end

function PihProductionOverviewFrame:populateCellForItemInSection(list, section, index, cell)
    if list == self.overviewList then
        local entry = self.sections[section][index]
        cell:getAttribute("title"):setText(entry.title)
        PihProductionOverviewFrame.setCellIcon(cell, entry.hudOverlayFilename)
        local valueText = cell:getAttribute("value")
        valueText:setText(g_i18n:formatNumber(entry.rest * self:getDisplayFactor(), self:getDisplayDecimals()))
        PihProductionOverviewFrame.setValueTextColor(valueText, entry.rest)
    elseif list == self.detailList then
        local detail = self.detailSections[section][index]
        PihProductionOverviewFrame.setCellIcon(cell, detail.productionImageFilename)
        local title = detail.productionName .. " - " .. detail.productionLineName
        if section == PihProductionOverviewFrame.SECTION_PRODUCERS then
            if detail.outputMode == ProductionPoint.OUTPUT_MODE.DIRECT_SELL then
                title = string.format("%s (%s)", title, g_i18n:getText("pih_word_sold"))
            elseif detail.outputMode == ProductionPoint.OUTPUT_MODE.AUTO_DELIVER then
                title = string.format("%s (%s)", title, g_i18n:getText("pih_word_distributed"))
            elseif ProductionPoint.OUTPUT_MODE.STORE ~= nil and detail.outputMode == ProductionPoint.OUTPUT_MODE.STORE then
                title = string.format("%s (%s)", title, g_i18n:getText("pih_word_stored"))
            else
                title = string.format("%s (%s)", title, g_i18n:getText("pih_word_kept"))
            end
        end
        cell:getAttribute("title"):setText(title)
        cell:getAttribute("value"):setText(g_i18n:formatNumber(detail.activeAmount * self:getDisplayFactor(), self:getDisplayDecimals()))
        if detail.alternativeForFillTypeTitle ~= nil then
            cell:getAttribute("title"):setTextColor(1, 0.6, 0, 1)
            cell:getAttribute("value"):setTextColor(1, 0.6, 0, 1)
        else
            cell:getAttribute("title"):setTextColor(1, 1, 1, 1)
            cell:getAttribute("value"):setTextColor(1, 1, 1, 1)
        end
    end
end

function PihProductionOverviewFrame:onListSelectionChanged(list, section, index)
    if list == self.overviewList then
        local entry = self.sections[section][index]
        self:updateDetailData(entry)
    end
end
