hlPdaDraw = {};

function hlPdaDraw.show()
	local ingameMapLarge = g_currentMission.hlUtils.getIngameMap();
	if #g_currentMission.hlHudSystem.pda > 0 then
		local pdaDragDrop = g_currentMission.hlUtils.isMouseCursor and g_currentMission.hlUtils.dragDrop.on and g_currentMission.hlUtils.dragDrop.what == "_hlPda_" and g_currentMission.hlUtils.dragDrop.system == "hlHudSystem";
		for pos=1, #g_currentMission.hlHudSystem.pda do
			local pda = g_currentMission.hlHudSystem.pda[pos];			
			if pda ~= nil then pda.clickAreas = {};end;
			if pda ~= nil and pda.show and not pda.isHidden() and pda.canDraw( {typPos=pos} ) then				
				local setAutoClose = not g_currentMission.hlUtils.isMouseCursor and pda.autoClose and pda.canAutoClose;
				if not setAutoClose then
					pda.moreInfo = "";
					hlPdaDraw:checkBounds(pda);					
					if not ingameMapLarge or (ingameMapLarge and pda.drawIsIngameMapLarge) then						
						local setPdaClickArea = false; --total Pda
						function setPdaArea() --set only if not mouse in Master SettingAreas Icons (DragDrop,DragDropWH,Setting,Close,Save ...)
							if not g_currentMission.hlUtils:disableInArea() then hlPdaDraw:clickAreas( {pda.overlays.bg.x, pda.overlays.bg.x+pda.overlays.bg.width, pda.overlays.bg.y, pda.overlays.bg.y+pda.overlays.bg.height, whatClick="_hlPda_", whereClick="pda_", typPos=pos} );end;
						end;							
						local x, y, w, h = pda:getScreen();
						g_currentMission.hlUtils.setOverlay(pda.overlays.bg, x, y, w, h);
						if pda.overlays.bg.visible then pda.overlays.bg:render();end;
						local thisDragDrop = pdaDragDrop and g_currentMission.hlUtils.dragDrop.where == "dragDrop_" and g_currentMission.hlUtils.dragDrop.typPos == pos;				
						local thisDragDropWH = pdaDragDrop and g_currentMission.hlUtils.dragDrop.where == "dragDropWH_" and g_currentMission.hlUtils.dragDrop.typPos == pos;
						local inArea = pda.mouseInArea(pda);
						if thisDragDrop or thisDragDropWH then
							if thisDragDrop then
								g_currentMission.hlHudSystem.screen:setDragDropPosition( {difHeight=-h} );
								--pda.isSetting = false;
								--g_currentMission.hlHudSystem.isSetting.pda = false;
							elseif thisDragDropWH then
								g_currentMission.hlHudSystem.screen:setDragDropWidthHeight( {} );						
								if pda.onDraw ~= nil and type(pda.onDraw) == "function" then pda.onDraw( {inArea=inArea, typPos=pos} );end;
							end;
						elseif not thisDragDrop then					
							if inArea then						
								setPdaClickArea = true;											
							end;
							if pda.onDraw ~= nil and type(pda.onDraw) == "function" then pda.onDraw( {inArea=inArea, typPos=pos} );end;					
							hlHudSystemDraw:showBoundsInfo( {typ=pda, typName="pda"} );
							if g_currentMission.hlUtils.isMouseCursor then
								setPdaClickArea = hlHudSystemDraw:showSettingIcons( {typ=pda, typName="pda", typPos=pos, inArea=inArea} );			
								---hud creator/scrollUpDown Info---
								if setPdaClickArea and pda.isSetting and pda.settingTyp == 1 and inArea and g_currentMission.hlHudSystem.infoDisplay.on then
									local zoomOutInInfo = "";
									if pda.autoZoomOutIn:len() >= 4 and (pda.autoZoomOutIn == "icon" or pda.autoZoomOutIn == "text") then zoomOutInInfo = "\n-".. string.format(pda:getI18n("hl_infoDisplay_zoomOutIn"), "PDA", "PDA");end;
									g_currentMission.hlHudSystem:addTextDisplay( {txt="Creator: ".. tostring(pda.info).. zoomOutInInfo.. pda.moreInfo, maxLine=0, warning=string.find(pda.info, "Unknown Mod Creator Info")} );							
								end;
								---hud creator/scrollUpDown Info---
							end;
							if inArea and setPdaClickArea then setPdaArea();end;
						end;
					end;
					hlPdaDraw:checkCorrectBounds(pda);
				else
					pda.isSetting = false;
				end;
			end;
		end;
		if not g_currentMission.hlUtils.isMouseCursor then
			g_currentMission.hlHudSystem.isSetting.pda = false;
			if g_currentMission.hlHudSystem.infoDisplay.on then g_currentMission.hlUtils.deleteTextDisplay();end; --delete Pda Creator Info		
		end;
	end;
end;

function hlPdaDraw:checkBounds(pda)
	if not pda.screen.canBounds.on or pda.isSetting or g_currentMission.hlHudSystem.isSetting.pda then return;end;
	if pda.screen.bounds[1] == -1 then
		pda.screen:generateBounds();
	else
		pda.screen:checkCorrectBounds();
	end;
end;

function hlPdaDraw:checkCorrectBounds(pda)
	pda.screen:checkCorrectBounds();
end;

function hlPdaDraw:clickAreas(args)		
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
		typ = args.typ or "pda";
		typPos = args.typPos or 0;
		ownTable = args.ownTable;
	};	
end;