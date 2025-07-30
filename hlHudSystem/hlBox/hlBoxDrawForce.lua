hlBoxDrawForce = {};

function hlBoxDrawForce:show(pos)
	local ingameMapLarge = false;
	if #g_currentMission.hlHudSystem.box > 0 and pos ~= nil then	
		local boxDragDrop = g_currentMission.hlUtils.isMouseCursor and g_currentMission.hlUtils.dragDrop.on and g_currentMission.hlUtils.dragDrop.what == "_hlBox_" and g_currentMission.hlUtils.dragDrop.system == "hlHudSystem";		
		local box = g_currentMission.hlHudSystem.box[pos];			
		if box ~= nil then box.clickAreas = {};end;
		if box ~= nil and box.show and not box.isHidden() and box.canDraw( {typPos=pos}, true ) then					
			local setAutoClose = not g_currentMission.hlUtils.isMouseCursor and box.autoClose and box.canAutoClose;
			if not setAutoClose then
				box.moreInfo = "";
				hlBoxDraw:checkBounds(box);									
				if not ingameMapLarge or (ingameMapLarge and box.drawIsIngameMapLarge) then
					local setBoxClickArea = false; --total Box
					function setBoxArea() --set only if not mouse in Master SettingAreas Icons (DragDrop,DragDropWH,Setting,Close,Save ...)
						if not g_currentMission.hlUtils:disableInArea() then hlBoxDraw:clickAreas( {box.overlays.bg.x, box.overlays.bg.x+box.overlays.bg.width, box.overlays.bg.y, box.overlays.bg.y+box.overlays.bg.height, whatClick="_hlBox_", whereClick="box_", typPos=pos} );end;
					end;							
					local x, y, w, h = box:getScreen();
					g_currentMission.hlUtils.setOverlay(box.overlays.bg, x, y, w, h);
					if box.overlays.bg.visible then box.overlays.bg:render();end;
					local thisDragDrop = boxDragDrop and g_currentMission.hlUtils.dragDrop.where == "dragDrop_" and g_currentMission.hlUtils.dragDrop.typPos == pos;				
					local thisDragDropWH = boxDragDrop and g_currentMission.hlUtils.dragDrop.where == "dragDropWH_" and g_currentMission.hlUtils.dragDrop.typPos == pos;
					local inArea = box.mouseInArea(box, true);
					if thisDragDrop or thisDragDropWH then
						if thisDragDrop then
							g_currentMission.hlHudSystem.screen:setDragDropPosition( {difHeight=-h} );
						elseif thisDragDropWH then
							g_currentMission.hlHudSystem.screen:setDragDropWidthHeight( {} );						
							if box.onDraw ~= nil and type(box.onDraw) == "function" then box.onDraw( {inArea=inArea, typPos=pos}, true );end;
						end;
					elseif not thisDragDrop then
						if inArea then						
							setPdaClickArea = true;											
						end;
						if box.onDraw ~= nil and type(box.onDraw) == "function" then box.onDraw( {inArea=inArea, typPos=pos}, true );end;					
						hlHudSystemDraw:showBoundsInfo( {typ=box, typName="box"}, true );
						if g_currentMission.hlUtils.isMouseCursor then
							setBoxClickArea = hlHudSystemDraw:showSettingIcons( {typ=box, typName="box", typPos=pos, inArea=inArea}, true );								
							---hud creator/scrollUpDown Info---
							if setBoxClickArea and box.isSetting and box.settingTyp == 1 and inArea and g_currentMission.hlHudSystem.infoDisplay.on then
								local zoomOutInInfo = "";
								if box.autoZoomOutIn:len() >= 4 and (box.autoZoomOutIn == "icon" or box.autoZoomOutIn == "text") then zoomOutInInfo = "\n-".. string.format(box:getI18n("hl_infoDisplay_zoomOutIn"), "BOX", "BOX");end;
								g_currentMission.hlHudSystem:addTextDisplay( {txt="Creator: ".. tostring(box.info).. zoomOutInInfo.. box.moreInfo, maxLine=0, warning=string.find(box.info, "Unknown Mod Creator Info")}, true );							
							end;
							---hud creator/scrollUpDown Info---
						end;
						if inArea and setBoxClickArea then setBoxArea();end;					
					end;
				end;
				hlBoxDraw:checkCorrectBounds(box);
			else
				box.isSetting = false;
			end;				
		end;		
		if not g_currentMission.hlUtils.isMouseCursor then
			g_currentMission.hlHudSystem.isSetting.box = false;
			if g_currentMission.hlHudSystem.infoDisplay.on then g_currentMission.hlUtils.deleteTextDisplay();end; --delete Box Creator Info		
		end;	
	end;
end;