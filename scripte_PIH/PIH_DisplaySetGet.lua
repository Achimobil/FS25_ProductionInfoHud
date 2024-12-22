PIH_DisplaySetGet = {};

function PIH_DisplaySetGet:setGlobalFunctions()
    g_currentMission.hlUtils.globalFunction["FS25_ProductionInfoHud"] = {
        getProductionItems =  function(args)return PIH_DisplaySetGet:ProductionItems(args);end;
    };
end;


function PIH_DisplaySetGet:ProductionItems(sort)
    return ProductionInfoHud.CurrentProductionItems;
end;