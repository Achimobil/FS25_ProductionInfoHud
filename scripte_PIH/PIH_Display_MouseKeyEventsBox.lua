PIH_Display_MouseKeyEventsBox = {};



function PIH_Display_MouseKeyEventsBox.onClickArea(args)
    if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return;end;

    if args.isDown then
        if g_currentMission.hlUtils.dragDrop.on then return;end;
        if args.button == Input.MOUSE_BUTTON_LEFT then
            local box = args.box;
            if box ~= nil then
                if box.viewExtraLine then
                    if args.clickAreaTable.whereClick == "settingLineDistance_" then
                        local maxDistance = box.screen.pixelH*8;
                        if box.screen.size.distance.textLine+(box.screen.pixelH/2) <= maxDistance then
                            box.screen.size.distance.textLine = box.screen.size.distance.textLine+(box.screen.pixelH/2);
                            box:setUpdateState(true);
                        end;
                        return;
                    end;
                    if args.clickAreaTable.whereClick == "settingTextSize_" then
                        box.screen.size.zoomOutIn.text[1] = box.screen.size.zoomOutIn.text[1] + 0.001;
                        box:setUpdateState(true);
                        return;
                    end;
                end;
            end;
        elseif args.button == Input.MOUSE_BUTTON_RIGHT then
            local box = args.box;
            if box ~= nil then
                if box.viewExtraLine then
                    if args.clickAreaTable.whereClick == "settingLineDistance_" then
                        local minDistance = box.screen.pixelH*1;
                        if box.screen.size.distance.textLine-(box.screen.pixelH/2) >= minDistance then
                            box.screen.size.distance.textLine = box.screen.size.distance.textLine-(box.screen.pixelH/2);
                            box:setUpdateState(true);
                        end;
                        return;
                    end;
                    if args.clickAreaTable.whereClick == "settingTextSize_" then
                        box.screen.size.zoomOutIn.text[1] = box.screen.size.zoomOutIn.text[1] - 0.001;
                        box:setUpdateState(true);
                        return;
                    end;
                end;
            end;
        elseif args.button == Input.MOUSE_BUTTON_MIDDLE then
            local box = args.box;
            if box ~= nil then
                if args.clickAreaTable.whereClick == "balesObject_" then --map hotspot
                    local fillType = FTAP_DisplaySetGet.fillTypes[args.clickAreaTable.ownTable[1]];
                    if fillType ~= nil and fillType.bales.nodeId ~= nil then
                        g_currentMission.hlHudSystem.setMapHotspot(fillType.bales.nodeId);
                    end;
                end;
            end;
        end;
    end;
end;