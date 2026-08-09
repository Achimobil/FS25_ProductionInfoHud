PihProductionOverviewFrame = {}
local PihProductionOverviewFrame_mt = Class(PihProductionOverviewFrame, TabbedMenuFrameElement)

function PihProductionOverviewFrame.register(modDirectory)
    local controller = PihProductionOverviewFrame.new()
    g_gui:loadGui(modDirectory .. "gui/PIH_ProductionOverviewFrame.xml", "PihProductionOverviewFrame", controller, true)
    return controller
end

function PihProductionOverviewFrame.new(target, subclass_mt)
    local self = TabbedMenuFrameElement.new(target, subclass_mt or PihProductionOverviewFrame_mt)
    return self
end

function PihProductionOverviewFrame:onFrameOpen()
    PihProductionOverviewFrame:superClass().onFrameOpen(self)
end

function PihProductionOverviewFrame:onFrameClose()
    PihProductionOverviewFrame:superClass().onFrameClose(self)
end
