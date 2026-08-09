PihProductionOverviewFrame = {}
local PihProductionOverviewFrame_mt = Class(PihProductionOverviewFrame, TabbedMenuFrameElement)

PihProductionOverviewFrame.SECTION_FRUITS = 1
PihProductionOverviewFrame.SECTION_OTHERS = 2

function PihProductionOverviewFrame.register(modDirectory)
    local controller = PihProductionOverviewFrame.new()
    g_gui:loadGui(modDirectory .. "gui/PIH_ProductionOverviewFrame.xml", "PihProductionOverviewFrame", controller, true)
    return controller
end

function PihProductionOverviewFrame.new(target, subclass_mt)
    local self = TabbedMenuFrameElement.new(target, subclass_mt or PihProductionOverviewFrame_mt)
    self.sections = { {}, {} }
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
end

function PihProductionOverviewFrame:getNumberOfSections(list)
    if list == self.overviewList then
        return #self.sections
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
    end
    return nil
end

function PihProductionOverviewFrame:getNumberOfItemsInSection(list, section)
    if list == self.overviewList then
        return #self.sections[section]
    end
    return 0
end

function PihProductionOverviewFrame:populateCellForItemInSection(list, section, index, cell)
    if list == self.overviewList then
        local entry = self.sections[section][index]
        cell:getAttribute("title"):setText(entry.title)
        cell:getAttribute("value"):setText(g_i18n:formatNumber(entry.maxTotalAmount, 0))
    end
end

function PihProductionOverviewFrame:onListSelectionChanged(list, section, index)
end
