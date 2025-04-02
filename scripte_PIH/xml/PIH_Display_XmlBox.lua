PIH_Display_XmlBox = {};

function PIH_Display_XmlBox:defaultValues(box)
    box.ownTable = {
        dataViewMode=1,
        ShowAnimal=true,
        ShowProduction=true,
        TimeFilter = 1,
        AutoDeliverFilter=true

    }; --own values TimeFilter=1(no fitler), 2(less 24 hours), 3(lee 1 month)
end;

function PIH_Display_XmlBox:onLoadXml(box, Xml, xmlNameTag)
    if box.ownTable.ShowProduction == nil then PIH_Display_XmlBox:defaultValues(box);end;
    if Xml ~= nil and xmlNameTag ~= nil then
        if getXMLBool(Xml, xmlNameTag.."#ShowProduction") ~= nil then
            box.ownTable.ShowProduction = getXMLBool(Xml, xmlNameTag.. "#ShowProduction");
        else
            return; --first config not found
        end;
        if getXMLBool(Xml, xmlNameTag.."#ShowAnimal") ~= nil then
            box.ownTable.ShowAnimal = getXMLBool(Xml, xmlNameTag.. "#ShowAnimal");
        end;
        if getXMLInt(Xml, xmlNameTag.."#dataViewMode") ~= nil then
            box.ownTable.dataViewMode = getXMLInt(Xml, xmlNameTag.. "#dataViewMode");
        end;
        if getXMLInt(Xml, xmlNameTag.."#TimeFilter") ~= nil then
            box.ownTable.TimeFilter = getXMLInt(Xml, xmlNameTag.. "#TimeFilter");
        end;
        if getXMLInt(Xml, xmlNameTag.."#AutoDeliverFilter") ~= nil then
            box.ownTable.AutoDeliverFilter = getXMLBool(Xml, xmlNameTag.. "#AutoDeliverFilter");
        end;
    end;
end;

function PIH_Display_XmlBox.onSaveXml(box, Xml, xmlNameTag)
    setXMLInt(Xml, xmlNameTag.."#version", ProductionInfoHud.metadata.xmlVersion);
    setXMLBool(Xml, xmlNameTag.."#ShowAnimal", box.ownTable.ShowAnimal);
    setXMLBool(Xml, xmlNameTag.."#ShowProduction", box.ownTable.ShowProduction);
    setXMLInt(Xml, xmlNameTag.."#dataViewMode", box.ownTable.dataViewMode);
    setXMLInt(Xml, xmlNameTag.."#TimeFilter", box.ownTable.TimeFilter);
end;

function PIH_Display_XmlBox:loadBox(name, onSave)
    if name == "PIH_Display_Box" then
        local box = g_currentMission.hlHudSystem.hlBox.generate( {name=name, width=250, height=150, info="Production Info Hud Mod\n(PIH Display)", autoZoomOutIn="text", hiddenMod="ProductionInfoHud"} );
        PIH_DisplaySetGet:loadBoxIcons(box); -- später zum laden von eigenen icons
        box:setMinWidth(box.screen.pixelW*120); --set min. width new (default ..pixelW*30)
        box.onDraw = PIH_Display_DrawBox.setBox;
--         box.onClick = PIH_Display_MouseKeyEventsBox.onClick;
        box.screen.canBounds.on = true;
        box.resetBoundsByDragDrop = false;
        box.overlays.settingIcons.up.visible = true; --for viewExtraLine
        box.overlays.settingIcons.down.visible = true; --for viewExtraLine
        box.overlays.settingIcons.save.visible = true; --save over global icon
        box.isHelp = true;
        box.onSaveXml = PIH_Display_XmlBox.onSaveXml;
        PIH_Display_XmlBox:onLoadXml(box, box:getXml()); --own box load over Xml (replace Data)
        if onSave == nil or not onSave then box.viewExtraLine = true;box.ownTable.lastStateExtraLine = true;end;
        if onSave == nil or box.show then
            --first start updates--
--             if box.ownTable.viewAnimals then PIH_DisplaySetGet:setNumOfAnimals();end;
--             if box.ownTable.viewBales then PIH_DisplaySetGet:setBalesAmount();end;
--             if box.ownTable.viewPal then PIH_DisplaySetGet:setPalletsAmount();end;
            --first start updates--
        end;
    end;
end;