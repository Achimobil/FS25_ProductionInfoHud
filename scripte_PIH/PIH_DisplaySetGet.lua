PIH_DisplaySetGet = {};

function PIH_DisplaySetGet:setGlobalFunctions()
    ProductionInfoHud.currentMission.hlUtils.globalFunction["FS25_ProductionInfoHud"] = {
        getProductionItems =  function(args)return PIH_DisplaySetGet:ProductionItems(args);end;
    };
end;


function PIH_DisplaySetGet:ProductionItems(sort)
    return ProductionInfoHud.CurrentProductionItems;
end;

function PIH_DisplaySetGet:loadBoxIcons(box)
    if box.overlays.icons == nil then box.overlays.icons = {byName={}};end;
    local firstIcon, lastIcon = ProductionInfoHud.currentMission.hlUtils.insertIcons( {xmlTagName="pih_display.boxIcons", modDir=ProductionInfoHud.modDir, iconFile="hlHudSystem/icons/icons.dds", xmlFile="hlHudSystem/icons/icons.xml", modName="defaultIcons", groupName="box", fileFormat={64,512,1024}, iconTable=box.overlays.icons} );

    firstIcon, lastIcon = ProductionInfoHud.currentMission.hlUtils.insertIcons( {xmlTagName="pih_display.boxOther1Icons", modDir=ProductionInfoHud.modDir, iconFile="hlHudSystem/icons/other1Icons.dds", xmlFile="hlHudSystem/icons/icons.xml", modName="defaultIcons", groupName="box", fileFormat={32,256,512}, iconTable=box.overlays.icons} );

    firstIcon, lastIcon = ProductionInfoHud.currentMission.hlUtils.insertIcons( {xmlTagName="pih_display.boxOtherIcons", modDir=ProductionInfoHud.modDir, iconFile="hlHudSystem/icons/otherIcons.dds", xmlFile="hlHudSystem/icons/icons.xml", modName="defaultIcons", groupName="box", fileFormat={32,256,512}, iconTable=box.overlays.icons} );

end;