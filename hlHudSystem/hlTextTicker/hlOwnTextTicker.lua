hlOwnTextTicker = {};

function hlOwnTextTicker:generateData()	
	g_currentMission.hlHudSystem.textTicker.checkPositionData = function() hlOwnTextTicker:checkPositionData();end;
	--g_currentMission.hlHudSystem.textTicker.deleteOverlays = function() hlOwnTextTicker:deleteOverlays();end;
	g_currentMission.hlHudSystem.textTicker.updatePositionData = function() hlOwnTextTicker:updatePositionData();end;
	g_currentMission.hlHudSystem.textTicker.lastModSaying = -1;
	hlOwnTextTicker:setPositionData(g_currentMission.hlHudSystem.textTicker.position[1], false);
	
	g_currentMission.hlHudSystem.textTicker:generateRunTimer(true, 1);	
	if g_currentMission.hlHudSystem.ownData.textTickerSaveState == true and not g_currentMission.hlHudSystem.textTicker.isOn then g_currentMission.hlHudSystem.textTicker:setOnOff(true);end; 
end;

function hlOwnTextTicker:setRunTimer() --set new over GuiBox click
	if g_currentMission.hlHudSystem.textTicker.timer ~= nil then g_currentMission.hlHudSystem.textTicker:setRunTimerDuration();end;	
end;

function hlOwnTextTicker:checkPositionData()
	if g_currentMission.hlHudSystem.textTicker.position[1] == 1 then		
		local x, _, _, _ = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.infoBgLeft);
		if g_currentMission.hlHudSystem.textTicker.pos[1].width ~= g_hudAnchorRight-x then 
			hlOwnTextTicker:setPositionData(1, true);
		end;
	end;
end;

function hlOwnTextTicker:deleteOverlays() --yourself start over ...
	local textTicker = g_currentMission.hlHudSystem.textTicker;
	if textTicker ~= nil then
		textTicker:setOnOff(false);
		if #textTicker.msg > 0 then textTicker:removeMsg(nil, true);end;
		if textTicker.overlays ~= nil then g_currentMission.hlUtils.deleteOverlays(textTicker.overlays, false, "Text Ticker icons over deleteOverlays");end;		
	end;
end;

function hlOwnTextTicker:updatePositionData() --not active,later for more positionen (update over own GuiBox)
	if g_currentMission.hlHudSystem.textTicker.position[1] == 1 then		
		hlOwnTextTicker:setPositionData(1, true, true);		
	end;
end;

function hlOwnTextTicker:setPositionData(position, reset, updateByPlayer)
	local textTicker = g_currentMission.hlHudSystem.textTicker;
	if position == 1 then --ls gameInfoDisplay down
		local x, y, w, h = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.infoBgLeft); --g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.backgroundOverlay.overlay);
		local _, mY, _, _ = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.calendarIcon);		
		local width = g_hudAnchorRight-x;
		textTicker.pos[1].height = g_currentMission.hud.gameInfoDisplay:scalePixelToScreenHeight(15); --mY-(g_currentMission.hud.gameInfoDisplay.y-h); 
		if not reset or textTicker.pos[1].textHeight == 0 then
			local optiSize = g_currentMission.hlUtils.optiHeightSize(textTicker.pos[1].height, "Äg", textTicker.pos[1].size)+0.0015;
			textTicker.pos[1].textHeight = getTextHeight(optiSize, utf8Substr("Äg", 0));
			textTicker.pos[1].size = optiSize;		
			optiSize = g_currentMission.hlUtils.optiHeightSize(textTicker.pos[1].height, "Äg", textTicker.pos[1].size, true)+0.0015;
			textTicker.pos[1].boldTextHeight = g_currentMission.hlUtils.getTextHeight(utf8Substr("Äg", 0), optiSize, true);
			textTicker.pos[1].boldSize = optiSize;
		end;
		textTicker.pos[1].x = x;
		textTicker.pos[1].y = y;
		textTicker.pos[1].width = width;
		if textTicker.pos[1].height < textTicker.pos[1].textHeight then textTicker.pos[1].height = textTicker.pos[1].textHeight;end;		
	end;	
	if reset then textTicker:resetAllMsg(updateByPlayer);else textTicker:setBackgroundData();end;
end;