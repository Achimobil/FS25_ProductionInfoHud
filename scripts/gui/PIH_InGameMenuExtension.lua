PihInGameMenuExtension = {
    MOD_DIR = g_currentModDirectory
}

function PihInGameMenuExtension.overwriteGameFunction(object, funcName, newFunc)
    local oldFunc = object[funcName]
    if oldFunc ~= nil then
        object[funcName] = function(...)
            return newFunc(oldFunc, ...)
        end
    end
end

function PihInGameMenuExtension.moveProductionOverviewPageAfterProduction(inGameMenu)
    local page = inGameMenu.pagePihProductionOverview
    local afterIndex = inGameMenu.pagingElement:getPageMappingIndexByElement(inGameMenu.pageProduction)
    if afterIndex == nil then
        return
    end
    local targetIndex = afterIndex + 1

    for i = 1, #inGameMenu.pagingElement.elements do
        if inGameMenu.pagingElement.elements[i] == page then
            table.remove(inGameMenu.pagingElement.elements, i)
            table.insert(inGameMenu.pagingElement.elements, targetIndex, page)
            break
        end
    end

    for i = 1, #inGameMenu.pagingElement.pages do
        if inGameMenu.pagingElement.pages[i].element == page then
            local pageMapping = table.remove(inGameMenu.pagingElement.pages, i)
            table.insert(inGameMenu.pagingElement.pages, targetIndex, pageMapping)
            break
        end
    end

    for i = 1, #inGameMenu.pageFrames do
        if inGameMenu.pageFrames[i] == page then
            table.remove(inGameMenu.pageFrames, i)
            table.insert(inGameMenu.pageFrames, targetIndex, page)
            break
        end
    end

    inGameMenu:rebuildTabList()
end

function PihInGameMenuExtension.onLoadMapFinished(superFunc, self)
    self.pagePihProductionOverview = PihProductionOverviewFrame.register(PihInGameMenuExtension.MOD_DIR)
    self.pagingElement:addElement(self.pagePihProductionOverview)
    self:exposeControlsAsFields("pagePihProductionOverview")

    superFunc(self)

    self:registerPage(self.pagePihProductionOverview, 99, function()
        return true
    end)

    local iconFileName = Utils.getFilename("gui/icons/PIH_menuIcon.png", PihInGameMenuExtension.MOD_DIR)
    self:addPageTab(self.pagePihProductionOverview, iconFileName, GuiUtils.getUVs({0, 0, 1024, 1024}))
    self.pagePihProductionOverview:updateAbsolutePosition()
    self.pagePihProductionOverview:onGuiSetupFinished()

    PihInGameMenuExtension.moveProductionOverviewPageAfterProduction(self)
end

PihInGameMenuExtension.overwriteGameFunction(InGameMenu, "onLoadMapFinished", PihInGameMenuExtension.onLoadMapFinished)
