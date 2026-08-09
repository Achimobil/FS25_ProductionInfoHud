PihProductionOverviewFrame = {}
local PihProductionOverviewFrame_mt = Class(PihProductionOverviewFrame, TabbedMenuFrameElement)

PihProductionOverviewFrame.SECTION_FRUITS = 1
PihProductionOverviewFrame.SECTION_OTHERS = 2

PihProductionOverviewFrame.SECTION_PRODUCERS = 1
PihProductionOverviewFrame.SECTION_CONSUMERS = 2

function PihProductionOverviewFrame.register(modDirectory)
    local controller = PihProductionOverviewFrame.new()
    g_gui:loadGui(modDirectory .. "gui/PIH_ProductionOverviewFrame.xml", "PihProductionOverviewFrame", controller, true)
    return controller
end

function PihProductionOverviewFrame.new(target, subclass_mt)
    local self = TabbedMenuFrameElement.new(target, subclass_mt or PihProductionOverviewFrame_mt)
    self.sections = { {}, {} }
    self.detailSections = { {}, {} }
    return self
end

function PihProductionOverviewFrame:onFrameOpen()
    PihProductionOverviewFrame:superClass().onFrameOpen(self)
    self:updateOverviewData()
end

function PihProductionOverviewFrame:onFrameClose()
    PihProductionOverviewFrame:superClass().onFrameClose(self)
end

-- Behalten/Verteilt/Verkauft/Verbraucht/Rest für einen Filltype-Eintrag berechnen (nur aktive Mengen)
local function calculateSummary(entry)
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
            else
                consumed = consumed + detail.activeAmount
            end
        end
    end

    local rest = kept + distributed + consumed

    return kept, distributed, sold, consumed, rest
end

function PihProductionOverviewFrame:updateOverviewData()
    local productionNeedings = ProductionInfoHud.UpdateProductionNeedings()

    local fruitEntries = {}
    local otherEntries = {}
    for _, entry in pairs(productionNeedings) do
        local _, _, _, _, rest = calculateSummary(entry)
        entry.rest = rest

        if entry.isFruit then
            table.insert(fruitEntries, entry)
        else
            table.insert(otherEntries, entry)
        end
    end

    local function sortByTitle(a, b)
        return a.title < b.title
    end
    table.sort(fruitEntries, sortByTitle)
    table.sort(otherEntries, sortByTitle)

    self.sections[PihProductionOverviewFrame.SECTION_FRUITS] = fruitEntries
    self.sections[PihProductionOverviewFrame.SECTION_OTHERS] = otherEntries

    self.overviewList:reloadData()
    self:updateDetailData(nil)
end

local function sortByProductionNames(a, b)
    if a.productionName ~= b.productionName then
        return a.productionName < b.productionName
    end
    return a.productionLineName < b.productionLineName
end

local function setValueTextColor(textElement, value)
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
        return
    end

    local kept, distributed, sold, consumed, rest = calculateSummary(entry)

    self.summaryKeptText:setText(string.format("Behalten: %s", g_i18n:formatNumber(kept, 0)))
    self.summaryDistributedText:setText(string.format("Verteilt: %s", g_i18n:formatNumber(distributed, 0)))
    self.summarySoldText:setText(string.format("Verkauft: %s", g_i18n:formatNumber(sold, 0)))
    self.summaryConsumedText:setText(string.format("Verbrauch: %s", g_i18n:formatNumber(consumed, 0)))
    self.summaryRestText:setText(string.format("Rest: %s", g_i18n:formatNumber(rest, 0)))
    setValueTextColor(self.summaryRestText, rest)
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

    table.sort(producers, sortByProductionNames)
    table.sort(directConsumers, sortByProductionNames)
    table.sort(converterConsumers, sortByProductionNames)

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
            return "Feldfrüchte"
        else
            return "Andere Filltypes"
        end
    elseif list == self.detailList then
        if section == PihProductionOverviewFrame.SECTION_PRODUCERS then
            return "Produzenten"
        else
            return "Verbraucher"
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

function PihProductionOverviewFrame:populateCellForItemInSection(list, section, index, cell)
    if list == self.overviewList then
        local entry = self.sections[section][index]
        cell:getAttribute("title"):setText(entry.title)
        local valueText = cell:getAttribute("value")
        valueText:setText(g_i18n:formatNumber(entry.rest, 0))
        setValueTextColor(valueText, entry.rest)
    elseif list == self.detailList then
        local detail = self.detailSections[section][index]
        local title = detail.productionName .. " - " .. detail.productionLineName
        if section == PihProductionOverviewFrame.SECTION_PRODUCERS then
            if detail.outputMode == ProductionPoint.OUTPUT_MODE.DIRECT_SELL then
                title = title .. " (Verkauft)"
            elseif detail.outputMode == ProductionPoint.OUTPUT_MODE.AUTO_DELIVER then
                title = title .. " (Verteilt)"
            elseif ProductionPoint.OUTPUT_MODE.STORE ~= nil and detail.outputMode == ProductionPoint.OUTPUT_MODE.STORE then
                title = title .. " (Eingelagert)"
            else
                title = title .. " (Behalten)"
            end
        end
        cell:getAttribute("title"):setText(title)
        cell:getAttribute("value"):setText(g_i18n:formatNumber(detail.activeAmount, 0))
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
