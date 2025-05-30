PIH_DisplaySetGet = {};

function PIH_DisplaySetGet:setGlobalFunctions()
    g_currentMission.hlUtils.globalFunction["FS25_ProductionInfoHud"] = {
        getProductionItems =  function(args)return PIH_DisplaySetGet:ProductionItems(args);end;
    };
end;


function PIH_DisplaySetGet:ProductionItems(sort)
    return ProductionInfoHud.CurrentProductionItems;
end;

function PIH_DisplaySetGet:loadBoxIcons(box)
    if box.overlays.icons == nil then box.overlays.icons = {byName={}};end;

    g_currentMission.hlUtils.insertIcons( {xmlTagName="pih_display.otherIcons", modDir=ProductionInfoHud.modDir, iconFile="hlHudSystem/icons/otherIcons.dds", xmlFile="icons_PIH/icons.xml", modName="defaultIcons", groupName="box", fileFormat={32,256,512}, iconTable=box.overlays.icons} );
    g_currentMission.hlUtils.insertIcons( {xmlTagName="pih_display.boxOther1Icons", modDir=ProductionInfoHud.modDir, iconFile="hlHudSystem/icons/other1Icons.dds", xmlFile="icons_PIH/icons.xml", modName="defaultIcons", groupName="box", fileFormat={32,256,512}, iconTable=box.overlays.icons} );
    g_currentMission.hlUtils.insertIcons( {xmlTagName="pih_display.boxIcons", modDir=ProductionInfoHud.modDir, iconFile="hlHudSystem/icons/icons.dds", xmlFile="icons_PIH/icons.xml", modName="defaultIcons", groupName="box", fileFormat={64,512,1024}, iconTable=box.overlays.icons} );
--     ProductionInfoHud.DebugText("firstIcon %s, lastIcon %s", firstIcon, lastIcon)

--     ProductionInfoHud.DebugTable("loadBoxIcons", box.overlays.icons, 4)
end;