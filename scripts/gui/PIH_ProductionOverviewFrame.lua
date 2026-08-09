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

function PihProductionOverviewFrame:updateOverviewData()
    local productionNeedings = ProductionInfoHud.UpdateProductionNeedings()

    local fruitEntries = {}
    local otherEntries = {}
    for _, entry in pairs(productionNeedings) do
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

function PihProductionOverviewFrame:updateDetailData(entry)
    local producers = {}
    local directConsumers = {}
    local converterConsumers = {}

    if entry ~= nil then
        for _, detail in ipairs(entry.ProductionDetails) do
            if detail.totalAmount >= 0 then
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
        cell:getAttribute("value"):setText(g_i18n:formatNumber(entry.maxTotalAmount, 0))
    elseif list == self.detailList then
        local detail = self.detailSections[section][index]
        cell:getAttribute("title"):setText(detail.productionName .. " - " .. detail.productionLineName)
        cell:getAttribute("value"):setText(g_i18n:formatNumber(detail.totalAmount, 0))
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
