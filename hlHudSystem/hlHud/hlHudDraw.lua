hlHudDraw = {};

function hlHudDraw:show()
	local ingameMapLarge = g_currentMission.hlUtils.getIngameMap();
	local drawIsIngameMapLarge = not ingameMapLarge or (ingameMapLarge and g_currentMission.hlHudSystem.drawIsIngameMapLarge);
	if #g_currentMission.hlHudSystem.hud > 0 and drawIsIngameMapLarge then				
		local distance = g_currentMission.hlHudSystem.screen:getSize( {"distance"} ); --default
		local difW = distance.width --default width
		local difH = distance.height; --default height
		local showHuds = 0;
		local viewInfoFrames = g_currentMission.hlHudSystem.isSetting.viewFrame and g_currentMission.hlHudSystem.isSetting.hud;
		local viewInfoFramesTimer = viewInfoFrames and g_currentMission.hlUtils.runsTimer("1sec", true);
		local hudDragDrop = g_currentMission.hlUtils.isMouseCursor and g_currentMission.hlUtils.dragDrop.on and g_currentMission.hlUtils.dragDrop.what == "_hlHud_" and g_currentMission.hlUtils.dragDrop.system == "hlHudSystem";
		local thisDragDrop = hudDragDrop and g_currentMission.hlUtils.dragDrop.where == "dragDrop_";
		local thisDragDropWH = hudDragDrop and g_currentMission.hlUtils.dragDrop.where == "dragDropWH_";
		if thisDragDrop or thisDragDropWH then
			if thisDragDrop then
				g_currentMission.hlHudSystem.screen:setDragDropPosition( {difHeight=-g_currentMission.hlHudSystem.screen.height} );
				--g_currentMission.hlHudSystem.isSetting.hud = false;
			elseif thisDragDropWH then
				g_currentMission.hlHudSystem.screen:setDragDropWidthHeight( {} );			
			end;			
		end;
		local bgSettingW, bgSettingH = 0,0;
		local lastShowHud = g_currentMission.hlHudSystem.hlHud:getLastShowHud();
		for pos=1, #g_currentMission.hlHudSystem.hud do
			local hud = g_currentMission.hlHudSystem.hud[pos];
			if hud ~= nil then hud.clickAreas = {};end;
			if hud ~= nil and hud.show and not hud.isHidden() then				
				hud.moreInfo = "";							
				local setHudClickArea = false; --total Hud
				showHuds = showHuds+1;
				function setHudArea() --set only if not mouse in Master SettingAreas Icons (DragDrop,DragDropWH,Setting)
					if not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {hud.overlays.bg.x, hud.overlays.bg.x+hud.overlays.bg.width, hud.overlays.bg.y, hud.overlays.bg.y+hud.overlays.bg.height, whatClick="_hlHud_", whereClick="hud_", typPos=pos} );end;
				end;				
				local x, y, w, h = hud:getScreen();
				if bgSettingW == 0 or bgSettingH == 0 then bgSettingW, bgSettingH = hud:getOptiWidthHeight( {typ="hud", height=g_currentMission.hlHudSystem.screen.size.settingIcon[2]} );end;
				g_currentMission.hlUtils.setOverlay(hud.overlays.bg, x, y, w, h);
				g_currentMission.hlUtils.setOverlay(hud.overlays.bgFrame, x, y, w, h);
				if hud.overlays.bg.visible then hud.overlays.bg:render();end;				
				local inArea = hud.mouseInArea(hud);
				if viewInfoFramesTimer then hud.overlays.bgFrame:render();end;
				if not g_currentMission.hlHudSystem.isSetting.hud or inArea then g_currentMission.hlHudSystem.isSetting.viewFrame = false;end;
				if not thisDragDrop and not g_currentMission.hlHudSystem.isSetting.hud then
					if inArea then
						g_currentMission.hlUtils.setOverlay(hud.overlays.inArea, x, y-(hud.screen.size.inArea[1]/2), w, hud.screen.size.inArea[1]);
						hud.overlays.inArea:render();
						setHudClickArea = true;						
						hud.isSelect = true;						
					else
						hud.isSelect = false;						
					end;
					if hud.onDraw ~= nil and type(hud.onDraw) == "function" then hud.onDraw( {inArea=inArea, typPos=pos} );end;
					if hud.isSelect then
						g_currentMission.hlUtils.setOverlay(hud.overlays.selectArea, x, y-(hud.screen.size.selectArea[1]/2), w, hud.screen.size.selectArea[1]);
						hud.overlays.selectArea:render();
					end;					
				elseif not thisDragDrop and g_currentMission.hlHudSystem.isSetting.hud then
					if inArea then setHudClickArea = true;end;
					if hud.onDraw ~= nil and type(hud.onDraw) == "function" then hud.onDraw( {inArea=inArea, typPos=pos} );end;									
				end;
				if showHuds ~= 1 then 				
					local separator = hud.overlays.separator;					
					if separator ~= nil then
						g_currentMission.hlUtils.setOverlay(separator, x-(hud.screen.size.separator[1]/2), y+(h/2)-((h/hud.screen.size.separator[2])/2), hud.screen.size.separator[1], h/hud.screen.size.separator[2]);
						if hud.viewSeparator or g_currentMission.hlHudSystem.isSetting.hud then 
							if not hud.viewSeparator and g_currentMission.hlHudSystem.isSetting.hud then g_currentMission.hlUtils.setBackgroundColor(separator, g_currentMission.hlUtils.getColor(hud.overlays.color.off, true));else g_currentMission.hlUtils.setBackgroundColor(separator, g_currentMission.hlUtils.getColor(hud.overlays.color.separator, true));end;
							separator:render();							
						end;
					end;
					---view Hud separator On/Off---
					if g_currentMission.hlHudSystem.isSetting.hud and hud.overlays.settingIcons ~= nil then
						local view = hud.overlays.settingIcons.view;
						if view ~= nil then							
							local iconWidth = bgSettingW;
							local iconHeight = bgSettingH;
							g_currentMission.hlUtils.setOverlay(view, x-(iconWidth/2), y+(h)-(iconHeight/2), iconWidth, iconHeight);
							local inIconArea = view.mouseInArea();
							local canIconDraw = inArea or inIconArea or hud.isSetting;
							if inIconArea then setHudClickArea = false;end;
							if hud.viewSeparator then g_currentMission.hlUtils.setBackgroundColor(view, g_currentMission.hlUtils.getColor(hud.overlays.color.on, true));else g_currentMission.hlUtils.setBackgroundColor(view, g_currentMission.hlUtils.getColor(hud.overlays.color.off, true));end;
							if canIconDraw then view:render();
							if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(hud:getI18n("hl_infoDisplay_separator"), "HUD")} );end;
							if inIconArea and not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {view.x, view.x+view.width, view.y, view.y+view.height, whatClick="_hlHud_", whereClick="settingInHud_", areaClick="viewSeparatorIcon_", typPos=pos} );end;end;
						end;
					end;
					---view Hud separator On/Off---
				end;				
				if showHuds == 1 then 
					---setting Global(On/Off) - dragDrop Global(Position)---
					if g_currentMission.hlHudSystem.overlays.settingIcons ~= nil and not thisDragDrop and g_currentMission.hlUtils.isMouseCursor then 
						local bgSetting = g_currentMission.hlHudSystem.overlays.settingIcons.bgRoundBlack;
						if bgSetting ~= nil then							
							local iconWidth = bgSettingW-(g_currentMission.hlHudSystem.screen.pixelW*0.5);
							local iconHeight = bgSettingH-(g_currentMission.hlHudSystem.screen.pixelH*0.5);
							local dragDrop = g_currentMission.hlHudSystem.overlays.settingIcons.dragDrop;
							if dragDrop ~= nil and not thisDragDropWH then
								g_currentMission.hlUtils.setOverlay(bgSetting, x-(bgSettingW/3), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);	
								g_currentMission.hlUtils.setOverlay(dragDrop, bgSetting.x+(bgSettingW/2)-(iconWidth/2), bgSetting.y+(bgSettingH/2)-(iconHeight/2), iconWidth, iconHeight);
								local inIconArea = bgSetting.mouseInArea();
								local canIconDraw = not thisDragDrop and inIconArea;
								if bgSetting.visible and canIconDraw then bgSetting:render();end;
								if inIconArea then setHudClickArea = false;end;
								if canIconDraw then									
									g_currentMission.hlUtils.setBackgroundColor(dragDrop, g_currentMission.hlUtils.getColor(hud.overlays.color.on, true));
									dragDrop:render();									
									if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(hud:getI18n("hl_infoDisplay_dragDrop"), "HUDS", "HUDS")} );end;
								end;	
								if not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick="_hlHud_", whereClick="dragDrop_", areaClick="dragDropIcon_", typPos=pos, overlay=dragDrop} );end;								
							end;														
						end;
					end;
					---setting Global(On/Off) - dragDrop Global(Position)---
				end;				
				---save Global and dragDropWH Global/Hud (Width/Height Global), Hud setting On/Off, Hud show position---
				if not thisDragDrop and hud.overlays.settingIcons ~= nil and g_currentMission.hlHudSystem.overlays ~= nil and (lastShowHud == pos or g_currentMission.hlHudSystem.isSetting.hud) then
					local bgSetting = g_currentMission.hlHudSystem.overlays.settingIcons.bgRoundBlack;					
					if bgSetting ~= nil then						
						local iconWidth = bgSettingW-(g_currentMission.hlHudSystem.screen.pixelW*0.5);
						local iconHeight = bgSettingH-(g_currentMission.hlHudSystem.screen.pixelH*0.5);
						local iconWidthS = bgSettingW-(g_currentMission.hlHudSystem.screen.pixelW*1.2);
						local iconHeightS = bgSettingH-(g_currentMission.hlHudSystem.screen.pixelH*1.2);
						local sizeWidthHeight = hud.overlays.settingIcons.sizeWidthHeight;
						---hud width/height and global height in last hud---
						if sizeWidthHeight ~= nil and g_currentMission.hlUtils.isMouseCursor then
							g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y-(bgSettingH/3), bgSettingW, bgSettingH);
							g_currentMission.hlUtils.setOverlay(sizeWidthHeight, bgSetting.x+(bgSettingW/2)-(iconWidthS/2), bgSetting.y+(bgSettingH/2)-(iconHeightS/2), iconWidthS, iconHeightS);									
							g_currentMission.hlUtils.setBackgroundColor(sizeWidthHeight, g_currentMission.hlUtils.getColor(hud.overlays.color.on, true));
							local inIconArea = bgSetting.mouseInArea();
							local canIconDraw = not thisDragDropWH and (inArea or inIconArea or hud.isSetting);
							local canIconGlobalDraw = not thisDragDropWH and not g_currentMission.hlHudSystem.isSetting.hud and lastShowHud == pos;
							if inIconArea then setHudClickArea = false;end;						
							local renderIcon = false;
							if canIconDraw then								
								if canIconGlobalDraw then
									if inIconArea then
										bgSetting:render();
										sizeWidthHeight:render();
										renderIcon = true;
									end;
								else									
									if inIconArea then 
										if bgSetting.visible then bgSetting:render();end;
										hlHudDraw:setBlinking(sizeWidthHeight);
									else 
										if bgSetting.visible then bgSetting:render();end;
										sizeWidthHeight:render();
									end;
									renderIcon = true;
								end;
								if g_currentMission.hlHudSystem.infoDisplay.on and renderIcon and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=hud:getI18n("hl_infoDisplay_dragDropHudsWH"), maxLine=0} );end;
							end;	
							if inIconArea and not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick="_hlHud_", whereClick="dragDropWH_", areaClick="dragDropWHIcon_", typPos=pos, overlay=sizeWidthHeight} );end;								
						end;						
						---hud width/height and global height in last hud---											
						if hud.viewSettingIcons and g_currentMission.hlHudSystem.isSetting.hud then
							local leftRight = hud.overlays.settingIcons.leftRight;
							if leftRight ~= nil and leftRight.visible and #g_currentMission.hlHudSystem.hud > 1 then
								g_currentMission.hlUtils.setOverlay(bgSetting, x+(w/2)-(bgSettingW/2), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
								g_currentMission.hlUtils.setOverlay(leftRight, bgSetting.x+(bgSettingW/2)-(iconWidth/2), bgSetting.y+(bgSettingH/2)-(iconHeight/2), iconWidth, iconHeight);
								local inIconArea = bgSetting.mouseInArea();
								local canIconDraw = inArea or inIconArea or hud.isSetting;
								if bgSetting.visible and canIconDraw then bgSetting:render();end;								
								if inIconArea then setHudClickArea = false;end;				
								if canIconDraw then if inIconArea then hlHudDraw:setBlinking(leftRight);else leftRight:render();end;end;
								if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=hud:getI18n("hl_infoDisplay_positionHud")} );end;
								if not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick="_hlHud_", whereClick="settingInHud_", areaClick="leftRightIcon_", typPos=pos} );end;
							end;
							local setting = hud.overlays.settingIcons.setting;
							if setting ~= nil and setting.visible then								
								--g_currentMission.hlUtils.setOverlay(bgSetting, x+(difW*1.2), y+(h/2)-(bgSettingH/2), bgSettingW, bgSettingH); --middle left in a hud								
								g_currentMission.hlUtils.setOverlay(bgSetting, x+(w/2)-(bgSettingW/2), y-(bgSettingH/3), bgSettingW, bgSettingH);
								g_currentMission.hlUtils.setOverlay(setting, bgSetting.x+(bgSettingW/2)-(iconWidth/2), bgSetting.y+(bgSettingH/2)-(iconHeight/2), iconWidth, iconHeight);
								local inIconArea = bgSetting.mouseInArea();
								local canIconDraw = inArea or inIconArea or hud.isSetting;
								if bgSetting.visible and canIconDraw then bgSetting:render();end;
								if hud.isSetting then g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(hud.overlays.color.settingOn, true));else g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(hud.overlays.color.settingOff, true));end;
								if inIconArea then setHudClickArea = false;end;
								if canIconDraw then if inIconArea then hlHudDraw:setBlinking(setting);else setting:render();end;end;
								if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(hud:getI18n("hl_infoDisplay_setting"), "HUD"), maxLine=0} );end;
								if inIconArea and not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick="_hlHud_", whereClick="settingInHud_", areaClick="settingIcon_", typPos=pos} );end;
							end;
						end;
					end;					
				end;				
				---save Global and dragDropWH Global/Hud (Width/Height Global), Hud setting On/Off, Hud show position---
				---hud creator/scrollUpDown Info---
				if not thisDragDrop and g_currentMission.hlHudSystem.isSetting.hud then					
					if setHudClickArea and not hud.isSetting and hud.settingTyp == 1 and inArea and not thisDragDropWH and g_currentMission.hlHudSystem.infoDisplay.on then
						local zoomOutInInfo = "";
						if hud.autoZoomOutIn:len() >= 4 and (hud.autoZoomOutIn == "icon" or hud.autoZoomOutIn) == "text" then zoomOutInInfo = "\n-".. string.format(hud:getI18n("hl_infoDisplay_zoomOutIn"), "HUD", "HUD");end;						
						g_currentMission.hlHudSystem:addTextDisplay( {txt="Creator: ".. tostring(hud.info).. zoomOutInInfo.. hud.moreInfo, maxLine=0, warning=string.find(hud.info, "Unknown Mod Creator Info")} );
					end;					
				end;
				---hud creator/scrollUpDown Info---
				if setHudClickArea then setHudArea();end;
				if not g_currentMission.hlUtils.isMouseCursor or thisDragDrop then
					hud.isSetting = false;
				end;
				hlHudDraw:checkCorrectBounds(hud);
			end;		
		end;		
		if not g_currentMission.hlUtils.isMouseCursor then
			g_currentMission.hlHudSystem.isSetting.hud = false;
			if g_currentMission.hlHudSystem.infoDisplay.on then g_currentMission.hlUtils.deleteTextDisplay();end; --delete Hud Creator Info		
		end;	
	end;
end;

function hlHudDraw:setBlinking(overlay, sec)
	local sec = sec or 1;
	if g_currentMission.hlUtils.runsTimer(tostring(sec).. "sec", true) then
		overlay:render();
	end;
end;

function hlHudDraw:checkBounds(hud)
	if not hud.screen.canBounds.on or hud.isSetting or g_currentMission.hlHudSystem.isSetting.hud then return;end;
	if hud.screen.bounds[1] == -1 then
		hud.screen:generateBounds();
	else
		hud.screen:checkCorrectBounds();
	end;
end;

function hlHudDraw:checkCorrectBounds(hud)
	hud.screen:checkCorrectBounds();
end;

function hlHudDraw:clickAreas(args)		
	if g_currentMission.hlHudSystem.areas[args.whatClick] == nil then g_currentMission.hlHudSystem.areas[args.whatClick] = {};end;
	g_currentMission.hlHudSystem.areas[args.whatClick][#g_currentMission.hlHudSystem.areas[args.whatClick]+1] = {
		args[1]; --posX
		args[2]; --posX1
		args[3]; --posY
		args[4]; --posY1		
		whatClick = args.whatClick;			
		whereClick = args.whereClick;
		areaClick = args.areaClick;		
		overlay = args.overlay;
		typ = args.typ or "hud";
		typPos = args.typPos or 0;
		ownTable = args.ownTable;
	};	
end;