PIH_Display_MouseKeyEventsBox = {};



function PIH_Display_MouseKeyEventsBox.onClickArea(args)
    if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return;end;

    if args.isDown then
        if g_currentMission.hlUtils.dragDrop.on then return;end;
        if args.button == Input.MOUSE_BUTTON_LEFT then
            local box = args.box;
            if box ~= nil then
--         print("onClickArea")
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
                    if args.clickAreaTable.whereClick == "animalFilter_" then
                        box.ownTable.ShowAnimal = not box.ownTable.ShowAnimal;
                        box:setUpdateState(true);
                        return;
                    end;
                    if args.clickAreaTable.whereClick == "productionFilter_" then
                        box.ownTable.ShowProduction = not box.ownTable.ShowProduction;
                        box:setUpdateState(true);
                        return;
                    end;
                    if args.clickAreaTable.whereClick == "timeFilter_" then
                        box.ownTable.TimeFilter = box.ownTable.TimeFilter + 1;
                        if box.ownTable.TimeFilter == 2 and g_currentMission.environment.daysPerPeriod == 1 then
                            -- skip 24h setting when one day per month
                            box.ownTable.TimeFilter = 3
                        end
                        if box.ownTable.TimeFilter == 4 then
                            box.ownTable.TimeFilter = 1
                        end
                        box:setUpdateState(true);
                        return;
                    end;
                end;
                if args.clickAreaTable.whereClick == "dataColumn_" then
                    local newValue = box.ownTable.dataViewMode + 1;
                    if newValue == 4 then
                        newValue = 1;
                    end;
                    box.ownTable.dataViewMode = newValue;
                    return;
                end;
                if args.clickAreaTable.whereClick == "filTypeColumn_" then
                    if box.ownTable.fillTypeFilter == nil then
                        box.ownTable.fillTypeFilter = string.gsub(args.clickAreaTable.ownTable.fillType, "*", "");
                    else
                        box.ownTable.fillTypeFilter = nil;
                    end;
                    return;
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