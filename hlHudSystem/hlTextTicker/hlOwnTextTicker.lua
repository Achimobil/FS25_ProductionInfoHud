hlOwnTextTicker = {};

function hlOwnTextTicker:generateData()	
	g_currentMission.hlHudSystem.textTicker.checkPositionData = function() hlOwnTextTicker:checkPositionData();end;
	--g_currentMission.hlHudSystem.textTicker.deleteOverlays = function() hlOwnTextTicker:deleteOverlays();end;
	g_currentMission.hlHudSystem.textTicker.updatePositionData = function() hlOwnTextTicker:updatePositionData();end;
	g_currentMission.hlHudSystem.textTicker.updateSayings = function() hlOwnTextTicker:updateSayings();end;
	hlOwnTextTicker:loadSayings();
	hlOwnTextTicker:setPositionData(g_currentMission.hlHudSystem.textTicker.position[1], true);
	
	g_currentMission.hlHudSystem.textTicker:generateRunTimer(true);	
	if g_currentMission.hlHudSystem.ownData.textTickerSaveState == true and not g_currentMission.hlHudSystem.textTicker.isOn then g_currentMission.hlHudSystem.textTicker:setOnOff(true);end; 
end;

function hlOwnTextTicker:setRunTimer() --set new over GuiBox click
	if g_currentMission.hlHudSystem.textTicker.timer ~= nil then g_currentMission.hlHudSystem.textTicker:setRunTimerDuration();end;	
end;

function hlOwnTextTicker:checkPositionData()
	if g_currentMission.hlHudSystem.textTicker.position[1] == 1 then		
		if g_currentMission.hlHudSystem.textTicker:isNewUiScale() then 
			g_currentMission.hlHudSystem.textTicker:resetUiScale();
			g_currentMission.hlHudSystem.textTicker:copyAllMsgByPosition();
			hlOwnTextTicker:setPositionData(1, true);
			g_currentMission.hlHudSystem.textTicker:pasteAllMsgByPosition();			
		else
			local x, y, _, _ = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.infoBgLeft);
			if FS25_ExtendedGameInfoDisplay ~= nil and FS25_ExtendedGameInfoDisplay.ExtendedGameInfoDisplay ~= nil then x = x - g_currentMission.hud.gameInfoDisplay:scalePixelToScreenWidth(FS25_ExtendedGameInfoDisplay.ExtendedGameInfoDisplay.STRECH_GAME_INFO_DISPLAY);end; --mod
			if g_currentMission.hlHudSystem.textTicker.pos[1].width ~= g_hudAnchorRight-x or g_currentMission.hlHudSystem.textTicker.pos[1].x ~= x or g_currentMission.hlHudSystem.textTicker.pos[1].y ~= y then 
				g_currentMission.hlHudSystem.textTicker.pos[1].x = x;
				g_currentMission.hlHudSystem.textTicker.pos[1].y = y;
				g_currentMission.hlHudSystem.textTicker.pos[1].width = g_hudAnchorRight-x;
				g_currentMission.hlHudSystem.textTicker:setBackgroundData();
			end;
		end;
	end;
end;

function hlOwnTextTicker:deleteOverlays() --yourself start over ...
	local textTicker = g_currentMission.hlHudSystem.textTicker;
	if textTicker ~= nil then
		textTicker:setOnOff(false);
		if #textTicker.msg > 0 then textTicker:deleteAllMsg();end;
		if textTicker.overlays ~= nil then g_currentMission.hlUtils.deleteOverlays(textTicker.overlays, false, "Text Ticker icons over deleteOverlays");end;		
	end;
end;

function hlOwnTextTicker:updatePositionData() --update over own GuiBox	
	g_currentMission.hlHudSystem.textTicker:copyAllMsgByPosition();
	hlOwnTextTicker:setPositionData(g_currentMission.hlHudSystem.textTicker.position[1], true);
	g_currentMission.hlHudSystem.textTicker:pasteAllMsgByPosition();
	g_currentMission.hlHudSystem.textTicker:addMsgByUpdatePosition();
end;

function hlOwnTextTicker:setPositionData(position, reset)
	local textTicker = g_currentMission.hlHudSystem.textTicker;	
	if position == 1 then --ls gameInfoDisplay down
		local x, y, w, h = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.infoBgLeft); --g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.backgroundOverlay.overlay);
		if FS25_ExtendedGameInfoDisplay ~= nil and FS25_ExtendedGameInfoDisplay.ExtendedGameInfoDisplay ~= nil then x = x - g_currentMission.hud.gameInfoDisplay:scalePixelToScreenWidth(FS25_ExtendedGameInfoDisplay.ExtendedGameInfoDisplay.STRECH_GAME_INFO_DISPLAY);end; --mod
		local width = g_hudAnchorRight-x;
		textTicker.pos[1].height = g_currentMission.hud.gameInfoDisplay:scalePixelToScreenHeight(15);
		if reset or textTicker.pos[1].textHeight == 0 then
			local optiSize = g_currentMission.hlUtils.optiHeightSize(textTicker.pos[1].height, "Äg", textTicker.pos[1].textSize[1])+0.0015;
			textTicker.pos[1].textHeight = getTextHeight(optiSize, utf8Substr("Äg", 0));
			textTicker.pos[1].optiTextSize = optiSize;			
		end;
		textTicker.pos[1].x = x;
		textTicker.pos[1].y = y;
		textTicker.pos[1].width = width;
		if textTicker.pos[1].height < textTicker.pos[1].textHeight then textTicker.pos[1].height = textTicker.pos[1].textHeight;end;
		textTicker.pos[1].iconWidth, textTicker.pos[1].iconHeight = g_currentMission.hlUtils.getOptiIconWidthHeight(textTicker.pos[1].textHeight, g_currentMission.hlHudSystem.screen.pixelW, g_currentMission.hlHudSystem.screen.pixelH);
	elseif position == 2 then
		local minWidth = g_currentMission.hlHudSystem.screen.pixelW*80;
		textTicker.pos[2].height = textTicker.pos[2].textSize[1]; 
		if reset or textTicker.pos[2].textHeight == 0 then
			local optiSize = g_currentMission.hlUtils.optiHeightSize(textTicker.pos[2].height, "Äg", textTicker.pos[2].textSize[1])+0.0015;
			textTicker.pos[2].textHeight = getTextHeight(optiSize, utf8Substr("Äg", 0));
			textTicker.pos[2].optiTextSize = optiSize;
		end;		
		if textTicker.pos[2].height < textTicker.pos[2].textHeight then textTicker.pos[2].height = textTicker.pos[2].textHeight;end;
		textTicker.pos[2].iconWidth, textTicker.pos[2].iconHeight = g_currentMission.hlUtils.getOptiIconWidthHeight(textTicker.pos[2].textHeight, g_currentMission.hlHudSystem.screen.pixelW, g_currentMission.hlHudSystem.screen.pixelH);
		if textTicker.pos[2].loadXml < 2 or textTicker.pos[2].x+textTicker.pos[2].width > 1 or textTicker.pos[2].width < minWidth then
			textTicker.pos[2].width = (1-textTicker.pos[2].x)-textTicker.pos[2].x;
			textTicker.pos[2].y = 1-textTicker.pos[2].height;
		elseif textTicker.pos[2].y+textTicker.pos[2].height > 1 then
			textTicker.pos[2].y = 1-textTicker.pos[2].height;
		elseif textTicker.pos[2].y < 0 then
			textTicker.pos[2].y = 0;
		end;
	elseif position == 3 then
		local minWidth = g_currentMission.hlHudSystem.screen.pixelW*80;
		textTicker.pos[3].height = textTicker.pos[3].textSize[1]; 
		if reset or textTicker.pos[3].textHeight == 0 then
			local optiSize = g_currentMission.hlUtils.optiHeightSize(textTicker.pos[3].height, "Äg", textTicker.pos[3].textSize[1])+0.0015;
			textTicker.pos[3].textHeight = getTextHeight(optiSize, utf8Substr("Äg", 0));
			textTicker.pos[3].optiTextSize = optiSize;
		end;		
		if textTicker.pos[3].height < textTicker.pos[3].textHeight then textTicker.pos[3].height = textTicker.pos[3].textHeight;end;
		textTicker.pos[3].iconWidth, textTicker.pos[3].iconHeight = g_currentMission.hlUtils.getOptiIconWidthHeight(textTicker.pos[3].textHeight, g_currentMission.hlHudSystem.screen.pixelW, g_currentMission.hlHudSystem.screen.pixelH);
		if textTicker.pos[3].loadXml < 2 or textTicker.pos[3].x+textTicker.pos[3].width > 1 or textTicker.pos[3].width < minWidth then
			textTicker.pos[3].width = (1-textTicker.pos[3].x)-textTicker.pos[3].x;
			textTicker.pos[3].y = 0;
		elseif textTicker.pos[3].y+textTicker.pos[3].height > 1 then
			textTicker.pos[3].y = 1-textTicker.pos[3].height;
		elseif textTicker.pos[3].y < 0 then
			textTicker.pos[3].y = 0;
		end;
	end;
	if textTicker.pos[textTicker.position[1]].bgT ~= nil then 
		g_currentMission.hlUtils.setBackgroundColor(textTicker.overlays["bgTextTicker"], {0,0,0,textTicker.pos[textTicker.position[1]].bgT});
	end;
	textTicker:setBackgroundData();
end;

function hlOwnTextTicker:loadSayings()
	local playername = Utils.getNoNil(g_gameSettings.onlinePresenceName, g_i18n:getText("ui_players"));
	local interval = 3600000; -- ~60 min
	g_currentMission.hlHudSystem.textTicker.playWarning = {
		beginTime = g_time;
		interval = interval;
		nextTime = g_time + interval + 450000;
		infoText = " / ".. g_i18n:getText("helpLine_IconOverview_Info").. "... ".. g_i18n:getText("achievement_descBreedSheep");
		tipText = " / ".. g_i18n:getText("setting_hints").. "... ".. g_i18n:getText("input_PAUSE").. "!";
		warningText = tostring(playername).. "... ".. g_i18n:getText("achievement_descHorseRiding");		
		playTimeText1 = g_i18n:getText("ui_mpPlaytime").. ": ";
		playTimeText2 = g_i18n:getText("achievement_descPlayTime").. " ".. g_i18n:getText("ui_mpPlaytime").. ": ";		
	};
	local playWarning = g_currentMission.hlHudSystem.textTicker.playWarning;
	playWarning.formatPlayTime = function(onOff)	
		if onOff ~= nil and onOff then return g_i18n:formatMinutes((g_time-playWarning.beginTime)/1000/60);end;
		return g_i18n:formatMinutes((playWarning.nextTime-450000-playWarning.beginTime)/1000/60);
	end;
	playWarning.canViewText = function() return g_time >= playWarning.nextTime;end;
	playWarning.getViewText = function(what, onOff) 
		local text = "";
		local textColor = "ls22";		
		if what == 0 then return playWarning.playTimeText1.. playWarning.formatPlayTime(onOff), textColor;end;
		if what == 1 then 
			if playWarning.beginTime+(playWarning.interval*2) >= g_time or (onOff ~= nil and onOff) then
				text = playWarning.playTimeText1.. playWarning.formatPlayTime(onOff);
			else				
				text = playWarning.playTimeText2.. playWarning.formatPlayTime(onOff);
			end;
		end;
		if what == 2 and playWarning.beginTime+(playWarning.interval*3) <= g_time then 
			text = playWarning.warningText;
			textColor = "yellow";
			if playWarning.beginTime+(playWarning.interval*4) <= g_time then 
				text = text.. playWarning.tipText;
				if playWarning.beginTime+(playWarning.interval*5) <= g_time then text = text.. playWarning.infoText;end;
			end;
		end;
		return text, textColor;
	end;
	playWarning.setNextTime = function() playWarning.nextTime = playWarning.nextTime + playWarning.interval;end;	
end;

function hlOwnTextTicker:setConnectPlayTime(nextTime, onOff)
	if g_currentMission.hlHudSystem.textTicker.viewConnectPlayTime[1] > 1 then
		if not g_currentMission.hlHudSystem.textTicker.isOn then
			local msg, textColor = g_currentMission.hlHudSystem.textTicker.playWarning.getViewText(0, onOff);
			if nextTime then g_currentMission.hlHudSystem.textTicker.playWarning.setNextTime();end;
			--g_currentMission.hlHudSystem.showInfoBox( {tostring(msg), 3000, g_currentMission.hlUtils.getColor(textColor, true)} );
			g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, tostring(msg), 3000);
		else
			local msg, textColor = g_currentMission.hlHudSystem.textTicker.playWarning.getViewText(1, onOff);
			g_currentMission.hlHudSystem.textTicker:addMsg( {text=msg, textColor=textColor} );
			if nextTime then g_currentMission.hlHudSystem.textTicker.playWarning.setNextTime();end;
			local warningMsg, textColor = g_currentMission.hlHudSystem.textTicker.playWarning.getViewText(2, onOff);		
			if warningMsg ~= nil and warningMsg:len() > 3 then g_currentMission.hlHudSystem.textTicker:addMsg( {text=warningMsg, textColor=textColor} );end;
		end;
	else
		if nextTime then g_currentMission.hlHudSystem.textTicker.playWarning.setNextTime();end;
	end;	
end;

function hlOwnTextTicker:updateSayings()	
	if g_currentMission.hlHudSystem.textTicker.playWarning.canViewText() then
		hlOwnTextTicker:setConnectPlayTime(true);
	end;	
end;