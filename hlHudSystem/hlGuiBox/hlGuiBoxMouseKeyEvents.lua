hlGuiBoxMouseKeyEvents = {};

function hlGuiBoxMouseKeyEvents:setMouse(args)
	local inClickArea = false;
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return inClickArea;end;
	if args.clickAreaTable.whereClick == "settingInGuiBox_" then --prio 1
		hlGuiBoxMouseKeyEvents:settingGuiBox(args);
		return true;	
	elseif args.clickAreaTable.whereClick == "guiBox_" then
		if g_currentMission.hlUtils.timers["hlHudSystem_ignoreAreaClick"] ~= nil or g_currentMission.hlUtils.dragDrop.on then return true;end;
		local guiBox = g_currentMission.hlHudSystem.guiBox[args.clickAreaTable.typPos];	
		if guiBox ~= nil and guiBox.show then
			args.guiBox = guiBox;			
			---optional automatic line bounds by HL Hud System---
			local autoSetBounds = guiBox.screen.canBounds.on and guiBox.screen.bounds[1] > 0 and guiBox.screen.bounds[4] > 1;
			if args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_UP and autoSetBounds then
				guiBox.screen:setBounds( {up=true} );
				inClickArea = true;
			elseif args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_DOWN and autoSetBounds then
				guiBox.screen:setBounds( {down=true} );
				inClickArea = true;
			end;
			---optional automatic line bounds by HL Hud System---
			if not inClickArea and guiBox.clickAreas ~= nil then
				for k,v in pairs (guiBox.clickAreas) do	
					if inClickArea then break;end;					
					for clickArea=1, #v do
						if inClickArea then break;end;
						if v[clickArea] ~= nil and v[clickArea][1] ~= nil then 
							if g_currentMission.hlUtils.mouseIsInArea(posX, posY, unpack(v[clickArea]))then
								if v[clickArea].onClick ~= nil and type(v[clickArea].onClick) == "function" then --optional this Gui Box clickAreas --> guiBox:setClickArea(.......)
									inClickArea = true;
									args.clickAreaTable=v[clickArea];
									args.trigged = "gui box click by found areaClick";
									v[clickArea].onClick(args);								
								elseif guiBox.onClick ~= nil and type(guiBox.onClick) == "function" then --optional this Gui Box --> guiBox.onClick --> if clickArea onClick not found
									inClickArea = true;
									args.clickAreaTable=v[clickArea];
									args.trigged = "gui box click by NOT found areaClick (set gui box total area click with clickAreaTable)";
									guiBox.onClick(args);
								end;								
							end;
						end;
					end;					
				end;				
			end;					
		end;			
	end;
	return inClickArea;	
end;

function hlGuiBoxMouseKeyEvents:settingGuiBox(args) --all Gui Box default Setting	
	if args.isDown then			
		if g_currentMission.hlUtils.dragDrop.on then return;end;		
		if args.button == Input.MOUSE_BUTTON_LEFT then			
			local guiBox = g_currentMission.hlHudSystem.guiBox[args.clickAreaTable.typPos];
			if guiBox ~= nil then
				 if args.clickAreaTable.areaClick == "closeIcon_" then					
					guiBox.show = false;
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Gui Box Creator Info										
					return;								
				end;
			end;
		elseif args.button == Input.MOUSE_BUTTON_MIDDLE then
			
		elseif args.button == Input.MOUSE_BUTTON_RIGHT then
			
		end;		
	end;
end;

function hlGuiBoxMouseKeyEvents.onClickOwnGuiBox(args)
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return;end;
	
	function setValue(what, level, up, typTable)		
		if typTable == nil then typTable = g_currentMission.hlHudSystem.textTicker;end;
		if typTable == nil or typTable[what] == nil then return 1;end;
		local lv = level or 1;
		if up == nil or up then
			if typTable[what][1]+lv > typTable[what][3] then
				typTable[what][1] = typTable[what][2];
			else
				typTable[what][1] = typTable[what][1]+lv;
			end;
		else
			if typTable[what][1]-lv < typTable[what][2] then
				typTable[what][1] = typTable[what][3];
			else
				typTable[what][1] = typTable[what][1]-lv;
			end;
		end;
		g_currentMission.hlHudSystem.isSave = false; --global
		return typTable[what][1];		
	end;
	
	function setTextTickerWarningByTimeScale()
		local info = " (<".. tostring(g_currentMission.hlHudSystem.textTicker.maxTimeScale).. ")";
		g_currentMission.hlHudSystem.showInfoBox( {"TextTicker: ".. tostring(g_i18n:getText("input_DECREASE_TIMESCALE")).. info, 2500, g_currentMission.hlUtils.getColor("orangeRed", true)} );	
	end;
	
	if args.isDown then
		if g_currentMission.hlUtils.dragDrop.on then return;end;
		if args.button == Input.MOUSE_BUTTON_LEFT then
			local guiBox = args.guiBox;
			if guiBox ~= nil then				
				if args.clickAreaTable.whereClick == "guiLine_" then
					local line = guiBox.lines[args.clickAreaTable.line];
					if line ~= nil then						
						if args.clickAreaTable.areaClick == "line_" then --line oneClick
							if guiBox.guiLines[args.clickAreaTable.line] == "drawIsIngameMapLarge_" then
								g_currentMission.hlHudSystem.drawIsIngameMapLarge = not g_currentMission.hlHudSystem.drawIsIngameMapLarge;
								g_currentMission.hlHudSystem.isSave = false; --global	
							elseif guiBox.guiLines[args.clickAreaTable.line] == "infoDisplay_" then
								local state = setValue("infoDisplay", 1, true, guiBox.ownTable);
								g_currentMission.hlHudSystem.infoDisplay.on = state > 1;
								if state > 1 then g_currentMission.hlHudSystem:setFirstInfo();end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "autoSave_" then
								local state = setValue("autoSave", 1, true, guiBox.ownTable);
								if g_currentMission.hlUtils.timers["hlHudSystem_autoSave"] ~= nil then g_currentMission.hlUtils.removeTimer("hlHudSystem_autoSave");end;
								if state > 1 then									
									g_currentMission.hlUtils.addTimer( {delay=guiBox.ownTable.autoSaveTimer[1], name="hlHudSystem_autoSave", repeatable=true, ms=false, action=g_currentMission.hlHudSystem.autoSave} );
								end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "saveInfo_" then
								if guiBox.ownTable.autoSave[1] > 1 then
									setValue("saveInfo", 1, true, guiBox.ownTable);
								end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "adEditModusMouseOff_" then
								if not g_currentMission.hlHudSystem.ownData.autoDrive then return;end;
								local state = setValue("adEditModusMouseOff", 1, true, guiBox.ownTable);
								if state > 1 and g_currentMission.hlHudSystem:getAutoDriveState() then g_currentMission.hlHudSystem.setAllGuiBoxOff();end;
								g_currentMission.hlHudSystem.isSave = false; --global
							elseif guiBox.guiLines[args.clickAreaTable.line] == "textTicker_" then
								if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
								g_currentMission.hlHudSystem.textTicker:setOnOff();
								if g_currentMission.hlHudSystem.textTicker.isOn then g_currentMission.hlHudSystem.textTicker:addMsg( {text=g_currentMission.hlHudSystem.textTicker.positionUpdateText, color="ls25active", blinking=true, separator=false} );end;
								g_currentMission.hlHudSystem.ownData.textTickerSaveState = g_currentMission.hlHudSystem.textTicker.isOn;
								g_currentMission.hlHudSystem.isSave = false; --global							
							elseif guiBox.guiLines[args.clickAreaTable.line] == "drawBg_" then
								if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
								g_currentMission.hlHudSystem.textTicker.pos[g_currentMission.hlHudSystem.textTicker.position[1]].drawBg = not g_currentMission.hlHudSystem.textTicker.pos[g_currentMission.hlHudSystem.textTicker.position[1]].drawBg;
								g_currentMission.hlHudSystem.isSave = false; --global
							elseif guiBox.guiLines[args.clickAreaTable.line] == "setInfo_" then
								if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
								local state = setValue("info", 1, true);
								if state > 1 then g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, g_currentMission.hlHudSystem.textTicker.info[5], 3500);end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "setSound_" then
								if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
								local state = setValue("sound", 1, true);
								if state > 1 then g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, "", 100, g_currentMission.hlHudSystem.textTicker.sample[g_currentMission.hlHudSystem.textTicker.soundSample[1]()]);end;
							elseif args.clickAreaTable.lineCallSequence ~= nil and string.find(args.clickAreaTable.lineCallSequence, "modHidder_") then
								if args.clickAreaTable.ownTable[1] ~= nil and g_currentMission.hlHudSystem.ownData.hiddenMods[args.clickAreaTable.ownTable[1]] ~= nil then
									g_currentMission.hlHudSystem.ownData.hiddenMods[args.clickAreaTable.ownTable[1]].isHidden = not g_currentMission.hlHudSystem.ownData.hiddenMods[args.clickAreaTable.ownTable[1]].isHidden;
									g_currentMission.hlHudSystem.isSave = false;
									local info = " is disabled !";
									if not g_currentMission.hlHudSystem.ownData.hiddenMods[args.clickAreaTable.ownTable[1]].isHidden then info = " is enabled !";end;
									g_currentMission.hlHudSystem.hlHud:updatePosition();
									g_currentMission.hlHudSystem.showInfoBox( {"HL Hud System Mod: ".. tostring(args.clickAreaTable.ownTable[1]).. info, 2500} );									
								end;
							elseif args.clickAreaTable.lineCallSequence ~= nil and string.find(args.clickAreaTable.lineCallSequence, "otherGuiBoxOn_") then
								if args.clickAreaTable.ownTable[1] ~= nil then
									local modGuiBox = g_currentMission.hlHudSystem.hlGuiBox:getData(tostring(args.clickAreaTable.ownTable[1]));
									if modGuiBox ~= nil then modGuiBox:setShow(true);end;
								end;
							end;							
						elseif args.clickAreaTable.areaClick == "text1_" then --colum left click
							if guiBox.guiLines[args.clickAreaTable.line] == "setSound_" then
								local state = setValue("sound", 1, true);
								if state > 1 then g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, "", 100, g_currentMission.hlHudSystem.textTicker.sample[g_currentMission.hlHudSystem.textTicker.soundSample[1]]());end;
							end;
						elseif args.clickAreaTable.areaClick == "text2_" then --colum right click
							if guiBox.guiLines[args.clickAreaTable.line] == "autoSaveTimer_" then
								if guiBox.ownTable.autoSave[1] > 1 then
									setValue("autoSaveTimer", guiBox.ownTable.autoSaveTimer[4], true, guiBox.ownTable);
									g_currentMission.hlUtils.removeTimer("hlHudSystem_autoSave");								
									g_currentMission.hlUtils.addTimer( {delay=guiBox.ownTable.autoSaveTimer[1], name="hlHudSystem_autoSave", repeatable=true, ms=false, action=g_currentMission.hlHudSystem.autoSave} );
								end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "position_" then								
								if g_currentMission.hlHudSystem.textTicker.position[3] > 1 and #g_currentMission.hlHudSystem.textTicker.pos > 1 then
									if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
									if not g_currentMission.hlHudSystem.textTicker.isReset then
										local state = setValue("position", 1, true);
										hlOwnTextTicker:updatePositionData();
									end;
								end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "runTimer_" then
								if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
								setValue("runTimer", g_currentMission.hlHudSystem.textTicker.runTimer[4], true);
								hlOwnTextTicker:setRunTimer();
								if #g_currentMission.hlHudSystem.textTicker.msg == 0 then g_currentMission.hlHudSystem.textTicker:addMsg( {text="<<<<<Test>>>>>", color="ls25active", separator=false} );end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "dropWidth_" then
								if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
								setValue("dropWidth", g_currentMission.hlHudSystem.textTicker.dropWidth[4], true);								
								if #g_currentMission.hlHudSystem.textTicker.msg == 0 then g_currentMission.hlHudSystem.textTicker:addMsg( {text="<<<<<Test>>>>>", color="ls25active", separator=false} );end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "setSound_" then								
								if g_currentMission.hlHudSystem.textTicker.sound[1] == 1 then return;end;
								if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
								setValue("soundSample", 1, true);
								g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, "", 100, g_currentMission.hlHudSystem.textTicker.sample[g_currentMission.hlHudSystem.textTicker.soundSample[1]]());								
							end;
						end;						
					end;
				end;
			end;
		elseif args.button == Input.MOUSE_BUTTON_RIGHT then
			local guiBox = args.guiBox;
			if guiBox ~= nil then
				if args.clickAreaTable.whereClick == "guiLine_" then
					local line = guiBox.lines[args.clickAreaTable.line];
					if line ~= nil then
						if args.clickAreaTable.areaClick == "text2_" then --colum right click
							if guiBox.guiLines[args.clickAreaTable.line] == "autoSaveTimer_" then
								if guiBox.ownTable.autoSave[1] > 1 then
									setValue("autoSaveTimer", guiBox.ownTable.autoSaveTimer[4], false, guiBox.ownTable);
									g_currentMission.hlUtils.removeTimer("hlHudSystem_autoSave");								
									g_currentMission.hlUtils.addTimer( {delay=guiBox.ownTable.autoSaveTimer[1], name="hlHudSystem_autoSave", repeatable=true, ms=false, action=g_currentMission.hlHudSystem.autoSave} );
								end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "position_" then
								if g_currentMission.hlHudSystem.textTicker.position[3] > 1 and #g_currentMission.hlHudSystem.textTicker.pos > 1 then
									if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
									if not g_currentMission.hlHudSystem.textTicker.isReset then
										local state = setValue("position", 1, false);
										hlOwnTextTicker:updatePositionData();
									end;
								end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "runTimer_" then
								if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
								setValue("runTimer", g_currentMission.hlHudSystem.textTicker.runTimer[4], false);
								hlOwnTextTicker:setRunTimer();
								if #g_currentMission.hlHudSystem.textTicker.msg == 0 then g_currentMission.hlHudSystem.textTicker:addMsg( {text="<<<<<Test>>>>>", color="ls25active", separator=false} );end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "dropWidth_" then
								if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
								setValue("dropWidth", g_currentMission.hlHudSystem.textTicker.dropWidth[4], false);								
								if #g_currentMission.hlHudSystem.textTicker.msg == 0 then g_currentMission.hlHudSystem.textTicker:addMsg( {text="<<<<<Test>>>>>", color="ls25active", separator=false} );end;
							elseif guiBox.guiLines[args.clickAreaTable.line] == "setSound_" then								
								if g_currentMission.hlHudSystem.textTicker.sound[1] == 1 then return;end;
								if not g_currentMission.hlHudSystem.textTicker:isCorrectTimeScale() then setTextTickerWarningByTimeScale();return;end;
								setValue("soundSample", 1, false);
								g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, "", 100, g_currentMission.hlHudSystem.textTicker.sample[g_currentMission.hlHudSystem.textTicker.soundSample[1]]());
							end;
						end;
					end;
				end;
			end;
		elseif args.button == Input.MOUSE_BUTTON_MIDDLE then
			local guiBox = args.guiBox;
			if guiBox ~= nil then
				
				
			end;
		end;	
	end;
end;