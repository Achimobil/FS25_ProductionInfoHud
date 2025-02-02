hlHudSystemDraw = {};
source(hlHudSystem.modDir.."hlHudSystem/hlHud/hlHudDraw.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlPda/hlPdaDraw.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlBox/hlBoxDraw.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlGuiBox/hlGuiBoxDraw.lua");

source(hlHudSystem.modDir.."hlHudSystem/hlHud/hlHudOwnDraw.lua");

function hlHudSystemDraw.showHuds()
		
	local mpOff = g_currentMission.missionDynamicInfo.isMultiplayer and g_currentMission.hlHudSystem.ownData.mpOff;
		
	g_currentMission.hlHudSystem.areas["_hlHud_"] = {};
	hlHudSystemDraw:showOwnIcons();
	
	if not g_currentMission.hlHudSystem.ownData.isHidden and not mpOff then
		hlHudDraw:show();
	end;
	
	g_currentMission.hlHudSystem.areas["_hlPda_"] = {};
	if not mpOff then hlPdaDraw.show();end;
	
	g_currentMission.hlHudSystem.areas["_hlBox_"] = {};
	if not mpOff then hlBoxDraw.show();end;
	
	g_currentMission.hlHudSystem.areas["_hlGuiBox_"] = {};
	if not mpOff then hlGuiBoxDraw.show();end;	
	
	g_currentMission.hlHudSystem.areas["_hlTextTicker_"] = {};
	
end;

function hlHudSystemDraw:showOwnIconsNew() --over ls weather hud	
	
end;

function hlHudSystemDraw:showOwnIcons() --over ls weather hud	
	if not g_currentMission.hlUtils.isMouseCursor then return;end;
	
	--local bgX, bgY, bgW, bgH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.backgroundOverlay.overlay); --ls22
	--ls25--
	local bgX, bgY, bgW, bgH = 0,0,0,0;
	function setFirstIconPos()		
		bgX = g_currentMission.hud.gameInfoDisplay.x;
		bgY = g_currentMission.hud.gameInfoDisplay.y-g_currentMission.hud.gameInfoDisplay.infoBgScale.height;
		bgW = g_currentMission.hud.gameInfoDisplay.spacing;
		bgH = g_currentMission.hud.gameInfoDisplay.infoBgScale.height;
	end;
	setFirstIconPos();	
	if g_currentMission.hlHudSystem.ownData.iconWidth == nil then
		g_currentMission.hlHudSystem.ownData.iconWidth, g_currentMission.hlHudSystem.ownData.iconHeight = g_currentMission.hlHudSystem.screen:getOptiWidthHeight( {typ="icon", height=bgH/4.3, width=bgW} ); --max 8 icons		
	end;	
	if g_currentMission.hlHudSystem.overlays.settingIcons ~= nil then
		local bg = g_currentMission.hlHudSystem.overlays.bg;
		if bg ~= nil then
			g_currentMission.hlUtils.setOverlay(bg, bgX+g_currentMission.hlHudSystem.screen.difWidth, bgY, g_currentMission.hlHudSystem.ownData.iconWidth*2, bgH);
			bg:render();		
			local mpOff = g_currentMission.missionDynamicInfo.isMultiplayer and g_currentMission.hlHudSystem.ownData.mpOff;
			local setting = g_currentMission.hlHudSystem.overlays.settingIcons.settingO;
			if setting ~= nil and not mpOff then
				g_currentMission.hlUtils.setOverlay(setting, bgX+g_currentMission.hlHudSystem.screen.difWidth, bgY+bgH-g_currentMission.hlHudSystem.ownData.iconHeight-g_currentMission.hlHudSystem.screen.difHeight, g_currentMission.hlHudSystem.ownData.iconWidth, g_currentMission.hlHudSystem.ownData.iconHeight);
				local inIconArea = setting.mouseInArea();			
				if inIconArea then
					g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.inArea, true));
				elseif g_currentMission.hlHudSystem.isSetting.hud then 
					g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.globalSettingOn, true));
				else 
					g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.globalSettingOff, true));
				end;
				setting:render();
				if inIconArea then
					local moreTxt = "";
					local txt = "";
					
					moreTxt = "\n".. g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_settingHlHudSystem");
					
					
					txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_settingGlobal"); 
					
					g_currentMission.hlHudSystem:addTextDisplay( {txt=tostring(txt).. tostring(moreTxt), maxLine=0 } );
				end;				
				if inIconArea and not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {setting.x, setting.x+setting.width, setting.y, setting.y+setting.height, whatClick="_hlHud_", whereClick="settingAllHud_", areaClick="settingIcon_"} );end;								
			end;		
			local save = g_currentMission.hlHudSystem.overlays.settingIcons.save;						
			if save ~= nil and (not mpOff or not g_currentMission.hlHudSystem.isSave) then
				local inIconArea = save.mouseInArea();
				g_currentMission.hlUtils.setOverlay(save, bgX+g_currentMission.hlHudSystem.screen.difWidth+g_currentMission.hlHudSystem.ownData.iconWidth, bgY+bgH-(g_currentMission.hlHudSystem.ownData.iconHeight/1.2)-g_currentMission.hlHudSystem.screen.difHeight, g_currentMission.hlHudSystem.ownData.iconWidth/1.2, g_currentMission.hlHudSystem.ownData.iconHeight/1.2);
				if not g_currentMission.hlHudSystem.isSave then 
					g_currentMission.hlUtils.setBackgroundColor(save, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.warning, true));
				else 
					g_currentMission.hlUtils.setBackgroundColor(save, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.on, true));
				end;			
				if inIconArea or not g_currentMission.hlHudSystem.isSave then save:render();end;
				
				local autoSaveText = "";
				if g_currentMission.hlHudSystem.guiMenu.ownTable.autoSave[1] > 1 then
					autoSaveText = "\n".. g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveOn").. "\n".. string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveTimer"), g_currentMission.hlHudSystem.guiMenu.ownTable.autoSaveTimer[1]);
				else
					autoSaveText = "\n".. g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_autoSaveOff");
				end;			
				if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_saveAll").. autoSaveText, maxLine=0} );end;
				if inIconArea and not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {save.x, save.x+save.width, save.y, save.y+save.height, whatClick="_hlHud_", whereClick="settingAllHud_", areaClick="saveIcon_"} );end;
			end;
			if g_currentMission.missionDynamicInfo.isMultiplayer then
				local view = g_currentMission.hlHudSystem.overlays.settingIcons.view;
				if view ~= nil then
					local iconWidth = g_currentMission.hlHudSystem.ownData.iconWidth;
					local iconHeight = g_currentMission.hlHudSystem.ownData.iconHeight;
					local inIconArea = view.mouseInArea();
					if not mpOff and save ~= nil then
						g_currentMission.hlUtils.setOverlay(view, bgX+g_currentMission.hlHudSystem.screen.difWidth, bgY+bgH-(g_currentMission.hlHudSystem.screen.difHeight*2)-(iconHeight*2), iconWidth, iconHeight);
					else
						g_currentMission.hlUtils.setOverlay(view, bgX+g_currentMission.hlHudSystem.screen.difWidth, bgY+bgH-(iconHeight)-g_currentMission.hlHudSystem.screen.difHeight, iconWidth, iconHeight);
					end;
					if g_currentMission.hlHudSystem.ownData.mpOff then
						g_currentMission.hlUtils.setBackgroundColor(view, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.warning, true));
					else
						g_currentMission.hlUtils.setBackgroundColor(view, g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.on, true));
					end;					
					view:render();
					if inIconArea then
						g_currentMission.hlHudSystem:addTextDisplay( {txt=g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_viewMpOff"), maxLine=0} );
						if not g_currentMission.hlUtils:disableInArea() then hlHudDraw:clickAreas( {view.x, view.x+view.width, view.y, view.y+view.height, whatClick="_hlHud_", whereClick="settingAllHud_", areaClick="viewIcon_"} );end;
					end;					
				end;
			end;
			if g_currentMission.hlHudSystem:getAutoDriveState() then
				local mouse = g_currentMission.hlHudSystem.overlays.settingIcons.mouse;
				if mouse ~= nil then
					local iconWidth = g_currentMission.hlHudSystem.ownData.iconWidth*1.5;
					local iconHeight = g_currentMission.hlHudSystem.ownData.iconHeight*1.5;
					g_currentMission.hlUtils.setOverlay(mouse, bg.x+(bg.width/2)-(iconWidth/2), bgY+(g_currentMission.hlHudSystem.screen.difHeight*2), iconWidth, iconHeight);
					local inIconArea = mouse.mouseInArea();
					if g_currentMission.hlUtils.runsTimer("1sec", true) then mouse:render();end;
					if inIconArea then 
						local text = "AutoDrive Editor ".. g_i18n:getText("ui_aiSettingsMode").. ": ".. g_i18n:getText("ui_on").. "\nHL Hud System: ".. g_i18n:getText("ui_mouse").. " (".. g_i18n:getText("ui_action").. ") ".. g_i18n:getText("ui_paused");
						g_currentMission.hlHudSystem.showInfoBox( {text, 2000, g_currentMission.hlUtils.getColor("orangeRed", true)} );
					end;					
				end;
			else
				
			end;
		end;
	end;
end;

function hlHudSystemDraw:showSettingIcons(args) --Pda,Box
	local setClickArea = true;
	local typ = args.typ;
	local typName = args.typName;
	local whatClick = "_hlPda_"
	local whereClick = "settingInPda_";
	local whichAreaClick = nil;
	if typName == "pda" then 
		whichAreaClick = hlPdaDraw;		
	else 
		whichAreaClick = hlBoxDraw;
		whatClick = "_hlBox_";
		whereClick = "settingInBox_";
	end;	
	if typ.overlays.settingIcons ~= nil and typ.viewSettingIcons then
		local x, y, w, h = typ:getScreen();
		local bgSettingW, bgSettingH = typ:getOptiWidthHeight( {typ=typName, height=typ.screen.size.settingIcon[2]} );
		local iconWidth = bgSettingW-(typ.screen.pixelW*0.5);
		local iconHeight = bgSettingH-(typ.screen.pixelH*0.5);
		local iconWidthS = bgSettingW-(typ.screen.pixelW*1.2);
		local iconHeightS = bgSettingH-(typ.screen.pixelH*1.2);
		local bgSetting = typ.overlays.settingIcons.bgRoundBlack;
		local maxIconWidth = g_currentMission.hlUtils.getMaxIconWidth(w+bgSettingW, bgSettingW, true);
		if bgSetting ~= nil then
			local viewIcon = {dragDrop=false,extraLine=false,close=false,save=false,help=false,setting=false,dragDropWH=false,autoClose=false};
			---position up Setting Icons---
			---dragDrop---			
			local dragDrop = typ.overlays.settingIcons.dragDrop;
			if dragDrop ~= nil and dragDrop.visible then
				maxIconWidth = maxIconWidth-1;
				viewIcon.dragDrop = true;
				g_currentMission.hlUtils.setOverlay(bgSetting, x-(bgSettingW/3), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);								
				g_currentMission.hlUtils.setOverlay(dragDrop, bgSetting.x+(bgSettingW/2)-(iconWidth/2), bgSetting.y+(bgSettingH/2)-(iconHeight/2), iconWidth, iconHeight);								
				local inIconArea = bgSetting.mouseInArea();
				if inIconArea then setClickArea = false;end;
				if inIconArea then									
					if bgSetting.visible then bgSetting:render();end;
					local moreTxt = "";
					if typ.canDragDrop then
						g_currentMission.hlUtils.setBackgroundColor(dragDrop, g_currentMission.hlUtils.getColor(typ.overlays.color.on, true));
					else
						g_currentMission.hlUtils.setBackgroundColor(dragDrop, g_currentMission.hlUtils.getColor(typ.overlays.color.off, true));
						moreTxt = " *".. g_i18n:getText("ui_off").. "*";
					end;
					dragDrop:render();
					if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_dragDrop"), typName:upper(), typName:upper()).. moreTxt, maxLine=0} );end;
				end;
				if typ.canDragDrop and inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick="dragDrop_", areaClick="dragDropIcon_", typPos=args.typPos, overlay=dragDrop} );end;
			end;
			---dragDrop---
			---close---			
			if typ.canClose then
				local closeTyp = typ.overlays.settingIcons.close;
				if closeTyp ~= nil and closeTyp.visible then
					maxIconWidth = maxIconWidth-1;
					viewIcon.close = true;
					g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);								
					g_currentMission.hlUtils.setOverlay(closeTyp, bgSetting.x+(bgSettingW/2)-(iconWidthS/2), bgSetting.y+(bgSettingH/2)-(iconHeightS/2), iconWidthS, iconHeightS);								
					local inIconArea = bgSetting.mouseInArea();								
					if inIconArea then setClickArea = false;end;
					if inIconArea then									
						if bgSetting.visible then bgSetting:render();end;
						closeTyp:render();
						if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_close"), typName:upper())} );end;
					end;
					if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="closeIcon_", typPos=args.typPos} );end;
				end;
			end;			
			---close---	
			---save---
			if typ.canSave then
				local saveTyp = typ.overlays.settingIcons.save;
				if saveTyp ~= nil and saveTyp.visible then
					maxIconWidth = maxIconWidth-1;
					viewIcon.save = true;					
					if not viewIcon.close then
						g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
					else
						g_currentMission.hlUtils.setOverlay(bgSetting, x+w-bgSettingW-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);					
					end;
					g_currentMission.hlUtils.setOverlay(saveTyp, bgSetting.x+(bgSettingW/2)-(iconWidthS/2), bgSetting.y+(bgSettingH/2)-(iconHeightS/2), iconWidthS, iconHeightS);
					local inIconArea = bgSetting.mouseInArea();	
					if inIconArea then setClickArea = false;end;
					if inIconArea or not typ.isSave then
						if bgSetting.visible then bgSetting:render();end;
						if typ.isSave then g_currentMission.hlUtils.setBackgroundColor(saveTyp, g_currentMission.hlUtils.getColor(typ.overlays.color.on, true));else g_currentMission.hlUtils.setBackgroundColor(saveTyp, g_currentMission.hlUtils.getColor(typ.overlays.color.warning, true));end;
						saveTyp:render();
						local autoSaveText = "";
						if g_currentMission.hlHudSystem.guiMenu.ownTable.autoSave[1] > 1 then 
							if typ.autoSave then
								autoSaveText = "\n".. typ:getI18n("hl_infoDisplay_autoSaveOn").. "\n".. string.format(typ:getI18n("hl_infoDisplay_autoSaveTimer"), g_currentMission.hlHudSystem.guiMenu.ownTable.autoSaveTimer[1]);								
							else
								autoSaveText = "\n".. string.format(typ:getI18n("hl_infoDisplay_autoSaveTypOff"), typName:upper());
							end;
						else
							autoSaveText = "\n".. typ:getI18n("hl_infoDisplay_autoSaveOff");
						end;
						if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_save"), typName:upper()).. autoSaveText, maxLine=0} );end;
					end;	
					if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="saveIcon_", typPos=args.typPos} );end;
				end;
			end;			
			---save---
			---up/down for extraLine---			
			local up = typ.overlays.settingIcons.up;
			local down = typ.overlays.settingIcons.down;
			if up ~= nil and down ~= nil and up.visible and down.visible then
				if not viewIcon.dragDrop then
					g_currentMission.hlUtils.setOverlay(bgSetting, x-(bgSettingW/3), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
				else
					g_currentMission.hlUtils.setOverlay(bgSetting, x+bgSettingW-(bgSettingW/3), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
				end;
				maxIconWidth = maxIconWidth-1;
				viewIcon.extraLine = true;
				g_currentMission.hlUtils.setOverlay(up, bgSetting.x, bgSetting.y, bgSettingW, bgSettingH);
				g_currentMission.hlUtils.setOverlay(down, bgSetting.x, bgSetting.y, bgSettingW, bgSettingH);
				local inIconArea = bgSetting.mouseInArea();
				if inIconArea then setClickArea = false;end;				
				if inIconArea or args.inArea then									
					if bgSetting.visible then bgSetting:render();end;
					if typ.viewExtraLine then
						up:render();
					else
						down:render();
					end;
					if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_extraLine"), typName:upper()), maxLine=0} );end;
				end;
				if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="viewExtraLine_", typPos=args.typPos} );end;
			end;			
			---up/down for extraLine---
			---position up Setting Icons---
			
			---position other Setting Icons---
			---help---
			local help = typ.overlays.settingIcons.help;
			if help ~= nil and help.visible then				
				if not viewIcon.close and not not viewIcon.save then
					g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
				elseif (viewIcon.close and not viewIcon.save) or (not viewIcon.close and viewIcon.save) then
					g_currentMission.hlUtils.setOverlay(bgSetting, x+w-bgSettingW-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
				elseif maxIconWidth > 4 then
					g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW*2)-(bgSettingW/1.5), y+h-(bgSettingH/1.5), bgSettingW, bgSettingH);
				else
					g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y+h-bgSettingH-(bgSettingH/1.5), bgSettingW, bgSettingH);
				end;
				g_currentMission.hlUtils.setOverlay(help, bgSetting.x, bgSetting.y, bgSettingW, bgSettingH);
				if typ.isHelp then g_currentMission.hlUtils.setBackgroundColor(help, g_currentMission.hlUtils.getColor(typ.overlays.color.warning, true));else g_currentMission.hlUtils.setBackgroundColor(help, g_currentMission.hlUtils.getColor(typ.overlays.color.notActive, true));end;
				local inIconArea = bgSetting.mouseInArea();								
				if inIconArea then setClickArea = false;end;
				if inIconArea or (typ.isHelp and args.inArea) then
					if bgSetting.visible then bgSetting:render();end;
					help:render();
					if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_help"), typName:upper()), maxLine=0} );end;
				end;
				if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="helpIcon_", typPos=args.typPos} );end;
			end;
			---help---	
			---position other Setting Icons---
			
			---position down Setting Icons---
			---setting---
			local setting = typ.overlays.settingIcons.setting;
			if setting ~= nil and setting.visible then								
				viewIcon.setting = true;
				g_currentMission.hlUtils.setOverlay(bgSetting, x-(bgSettingW/3), y-(bgSettingH/3), bgSettingW, bgSettingH);
				g_currentMission.hlUtils.setOverlay(setting, bgSetting.x+(bgSettingW/2)-(iconWidth/2), bgSetting.y+(bgSettingH/2)-(iconHeight/2), iconWidth, iconHeight);								
				if typ.isSetting then g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(typ.overlays.color.settingOn, true));else g_currentMission.hlUtils.setBackgroundColor(setting, g_currentMission.hlUtils.getColor(typ.overlays.color.settingOff, true));end;
				local inIconArea = bgSetting.mouseInArea();
				if inIconArea then setClickArea = false;end;
				if inIconArea or typ.isSetting then
					if bgSetting.visible then bgSetting:render();end;
					setting:render();					
					if inIconArea then
						g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_setting"), typName:upper()), maxLine=0} );
					end;
				end;
				if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="settingIcon_", typPos=args.typPos} );end;
			end;			
			---setting---
			---autoClose---
			local autoClose = typ.overlays.settingIcons.autoClose;
			if typ.canAutoClose and autoClose ~= nil and autoClose.visible then
				if not viewIcon.setting then
					g_currentMission.hlUtils.setOverlay(bgSetting, x-(bgSettingW/3), y-(bgSettingH/3), bgSettingW, bgSettingH);
				else
					g_currentMission.hlUtils.setOverlay(bgSetting, x+bgSettingW-(bgSettingW/3), y-(bgSettingH/3), bgSettingW, bgSettingH);
				end;
				g_currentMission.hlUtils.setOverlay(autoClose, bgSetting.x+(bgSettingW/2)-(iconWidth/2), bgSetting.y+(bgSettingH/2)-(iconHeight/2), iconWidth, iconHeight);
				if typ.autoClose then g_currentMission.hlUtils.setBackgroundColor(autoClose, g_currentMission.hlUtils.getColor(typ.overlays.color.off, true));else g_currentMission.hlUtils.setBackgroundColor(autoClose, g_currentMission.hlUtils.getColor(typ.overlays.color.notActive, true));end;
				local inIconArea = bgSetting.mouseInArea();	
				if inIconArea then setClickArea = false;end;
				if inIconArea then									
					if bgSetting.visible then bgSetting:render();end;
					autoClose:render();
					if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=typ:getI18n("hl_infoDisplay_autoClose"), maxLine=0} );end;
					if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick=whereClick, areaClick="autoCloseIcon_", typPos=args.typPos} );end;
				end;	
			end;
			---autoClose---
			---dragDropWH---
			local sizeWidthHeight = typ.overlays.settingIcons.sizeWidthHeight;							
			if sizeWidthHeight ~= nil and sizeWidthHeight.visible then
				g_currentMission.hlUtils.setOverlay(bgSetting, x+w-(bgSettingW/1.5), y-(bgSettingH/3), bgSettingW, bgSettingH);
				g_currentMission.hlUtils.setOverlay(sizeWidthHeight, bgSetting.x+(bgSettingW/2)-(iconWidthS/2), bgSetting.y+(bgSettingH/2)-(iconHeightS/2), iconWidthS, iconHeightS);
				local inIconArea = bgSetting.mouseInArea();	
				if inIconArea then setClickArea = false;end;
				if inIconArea then									
					if bgSetting.visible then bgSetting:render();end;
					local moreTxt = "";
					if typ.canDragDropWidth and typ.canDragDropHeight then
						g_currentMission.hlUtils.setBackgroundColor(sizeWidthHeight, g_currentMission.hlUtils.getColor(typ.overlays.color.on, true));
					elseif not typ.canDragDropWidth and not typ.canDragDropHeight then
						g_currentMission.hlUtils.setBackgroundColor(sizeWidthHeight, g_currentMission.hlUtils.getColor(typ.overlays.color.off, true));
						moreTxt = " *".. g_i18n:getText("ui_off").. "*";
					else
						g_currentMission.hlUtils.setBackgroundColor(sizeWidthHeight, g_currentMission.hlUtils.getColor(typ.overlays.color.warning, true));
						moreTxt = " ".. typ:getI18n("hl_infoDisplay_dragDropLimitedWH");
					end;
					sizeWidthHeight:render();
					if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_dragDropWH"), typName:upper()).. moreTxt, maxLine=0} );end;
				end;
				if (typ.canDragDropWidth or typ.canDragDropHeight) and inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {bgSetting.x, bgSetting.x+bgSetting.width, bgSetting.y, bgSetting.y+bgSetting.height, whatClick=whatClick, whereClick="dragDropWH_", areaClick="dragDropWHIcon_", typPos=args.typPos, overlay=sizeWidthHeight} );end;
			end;			
			---dragDropWH---
			---position down Setting Icons---
		end;
	end;
	return setClickArea;
end;

function hlHudSystemDraw:showGuiBoxIcons(args) --GuiBox
	if args == nil or type(args) ~= "table" or args.typPos == nil then return;end;
	local setClickArea = true;
	local whatClick = "_hlGuiBox_";
	local whereClickS = "settingInGuiBox_";
	local whereClick = "guiBox_";
	local whichAreaClick = hlGuiBoxDraw;
	local guiBox = args.typ;
	if guiBox ~= nil then
		local inArea = args.inArea;
		local x, y, w, h = guiBox:getScreen();
		local overlayGroup = guiBox.overlays["defaultIcons"]["guiBox"];
		local overlayByName = guiBox.overlays.byName["defaultIcons"]["guiBox"];
		local dragDrop = overlayGroup[overlayByName["dragDrop"]];
		local sizeWidthHeight = overlayGroup[overlayByName["sizeWidthHeight"]];
		local closeOverlay = overlayGroup[overlayByName["close"]];		
		local iconWidth = guiBox.iconWidth/1.3; 
		local iconHeight = guiBox.iconHeight/1.3;
		g_currentMission.hlUtils.setOverlay(closeOverlay, x+w-(iconWidth), y+h-(iconHeight), iconWidth, iconHeight);
		local inIconArea = inArea and closeOverlay.mouseInArea();
		if inIconArea then setClickArea = false;end;
		closeOverlay:render();
		if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(guiBox:getI18n("hl_infoDisplay_close"), "GUI BOX")} );end;
		if inIconArea and not g_currentMission.hlUtils:disableInArea() then			
			whichAreaClick:clickAreas( {closeOverlay.x, closeOverlay.x+closeOverlay.width, closeOverlay.y, closeOverlay.y+closeOverlay.height, whatClick=whatClick, whereClick=whereClickS, areaClick="closeIcon_", typPos=args.typPos, ownTable={}} );
		end;
		if guiBox.canDragDrop then
			g_currentMission.hlUtils.setOverlay(dragDrop, x, y+h-(iconHeight), iconWidth, iconHeight);
			g_currentMission.hlUtils.setBackgroundColor(dragDrop, g_currentMission.hlUtils.getColor("green", true));
			inIconArea = inArea and dragDrop.mouseInArea();
			if inIconArea then setClickArea = false;end;
			dragDrop:render();
			if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(guiBox:getI18n("hl_infoDisplay_dragDrop"), "GUI BOX", "GUI BOX"), maxLine=0} );end;
			if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {dragDrop.x, dragDrop.x+dragDrop.width, dragDrop.y, dragDrop.y+dragDrop.height, whatClick=whatClick, whereClick="dragDrop_", areaClick="dragDropIcon_", typPos=args.typPos, overlay=dragDrop} );end;
		end;
		if guiBox.canDragDropWidth or guiBox.canDragDropHeight then
			g_currentMission.hlUtils.setOverlay(sizeWidthHeight, x+w-(iconWidth), y, iconWidth, iconHeight);
			g_currentMission.hlUtils.setBackgroundColor(sizeWidthHeight, g_currentMission.hlUtils.getColor("green", true));
			inIconArea = inArea and sizeWidthHeight.mouseInArea();
			if inIconArea then setClickArea = false;end;			
			sizeWidthHeight:render();
			if g_currentMission.hlHudSystem.infoDisplay.on and inIconArea then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(guiBox:getI18n("hl_infoDisplay_dragDropWH"), "GUI BOX"), maxLine=0} );end;
			if inIconArea and not g_currentMission.hlUtils:disableInArea() then whichAreaClick:clickAreas( {sizeWidthHeight.x, sizeWidthHeight.x+sizeWidthHeight.width, sizeWidthHeight.y, sizeWidthHeight.y+sizeWidthHeight.height, whatClick=whatClick, whereClick="dragDropWH_", areaClick="dragDropWHIcon_", typPos=args.typPos, overlay=sizeWidthHeight} );end;
		end;
	end;
	return setClickArea;
end;