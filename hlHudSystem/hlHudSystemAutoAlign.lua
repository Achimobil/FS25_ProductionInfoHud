hlHudSystemAutoAlign = {};

function hlHudSystemAutoAlign:getTables()
	local tables = {
		wtmHud={alignRight={},alignLeft={},alignUp={},alignDown={}};
		minimapHud={alignRight={},alignLeft={},alignUp={},alignDown={}};
		speedMeterHud={alignRight={},alignLeft={},alignUp={},alignDown={}};
		vehicleSchemaHud={alignRight={},alignLeft={},alignUp={},alignDown={}};
		helpHud={alignRight={},alignLeft={},alignUp={},alignDown={}};
		fillLevelHud={alignRight={},alignLeft={},alignUp={},alignDown={}};
		sideNotificationsHud={alignRight={},alignLeft={},alignUp={},alignDown={}};
	};
	return tables;
end;

function hlHudSystemAutoAlign:setAlign(args)
	if not g_currentMission.hud.isVisible then return;end;
	if args == nil or type(args) ~= "table" or args.typ == nil or args.typ.typ == nil or args.alignPos == nil then return;end;
	if args.typ.typ == "hud" then return;end;
	local typ = args.typ;
	local alignTyp = args.alignTyp;
	if g_currentMission.hlHudSystem.autoAlign[alignTyp] == nil then return;end;	
	local alignX, alignY, alignW, alignH, alignPos = 0,0,0,0,args.alignPos;
	if alignPos == nil or (alignPos ~= "alignLeft" and alignPos ~= "alignRight" and alignPos ~= "alignUp" and alignPos ~= "alignDown") then return;end;
	
	if #g_currentMission.hlHudSystem.autoAlign[alignTyp][alignPos] > 0 and g_currentMission.hlHudSystem.autoAlign[alignTyp][alignPos][1] ~= typ then
		return false, g_currentMission.hlHudSystem.autoAlign[alignTyp][alignPos][1];
	else
		if alignTyp == "wtmHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.backgroundOverlay.overlay);
		elseif alignTyp == "minimapHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.ingameMap.overlay);
		elseif alignTyp == "helpHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.inputHelp.backgroundOverlay.overlay);
		elseif alignTyp == "sideNotificationsHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.sideNotifications.overlay);
		elseif alignTyp == "fillLevelHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.fillLevelsDisplay.backgroundOverlay.overlay);
		elseif alignTyp == "vehicleSchemaHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.vehicleSchema.backgroundOverlay.overlay);
		elseif alignTyp == "speedMeterHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.speedMeter.backgroundOverlay.overlay);
		else alignX = nil;end;
	end;			
	
	if alignX ~= nil and alignY ~= nil and alignW ~= nil and alignH ~= nil and alignPos ~= nil then
		if g_currentMission.hlHudSystem.autoAlign[alignTyp][alignPos][1] == nil then
			table.insert(g_currentMission.hlHudSystem.autoAlign[alignTyp][alignPos], typ); 
		end;
		local difW = g_currentMission.hlHudSystem.screen.pixelW*1;
		local difH = g_currentMission.hlHudSystem.screen.pixelH*1;
		local x, y, w, h = typ:getScreen();
		local newX = x;
		local newY = y;
		if alignPos == "alignLeft" then
			if alignX-w-difW ~= newX then
				newX = alignX-w-difW;
			end;
			if alignY+alignH ~= newY+h then
				newY = alignY+alignH-h;
			end;			
		elseif alignPos == "alignRight" then			
			if alignX+alignW+difW ~= newX then
				newX = alignX+alignW+difW;
			end;
			if alignY+alignH ~= newY+h then
				newY = alignY+alignH-h;
			end;			
		elseif alignPos == "alignUp" then			
			if alignX ~= newX then
				newX = alignX;
			end;
			if alignY+alignH+difH+h ~= newY then
				newY = alignY+alignH+difH+h;
			end;			
		elseif alignPos == "alignDown" then			
			if alignX ~= newX then
				newX = alignX;
			end;
			if alignY-difH ~= newY then
				newY = alignY-difH;
			end;			
		end;
		if newX ~= x or newY ~= y then
			typ:setPosition(newX, newY);
		end;
		return true;
	end;
	return;
end;

function hlHudSystemAutoAlign:removeAlign(args)
	if g_currentMission.hlHudSystem.autoAlign[alignTyp] == nil or g_currentMission.hlHudSystem.autoAlign[args.alignTyp][args.alignPos] == nil or #g_currentMission.hlHudSystem.autoAlign[args.alignTyp][args.alignPos] <= 0 then return;end;	
	g_currentMission.hlHudSystem.autoAlign[args.alignTyp][args.alignPos][1] = nil;
end;

function hlHudSystemAutoAlign:getAlign(args)
	if not g_currentMission.hud.isVisible then return;end;	
	if args == nil or type(args) ~= "table" or args.typ == nil or args.alignTyp == nil then return;end;
	local typ = args.typ;
	local alignTyp = args.alignTyp;
	if g_currentMission.hlHudSystem.autoAlign[alignTyp] == nil then return;end;	
	local alignX, alignY, alignW, alignH = 0,0,0,0;
	if alignTyp == "wtmHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.gameInfoDisplay.backgroundOverlay.overlay);
	elseif alignTyp == "minimapHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.ingameMap.overlay);
	elseif alignTyp == "helpHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.inputHelp.backgroundOverlay.overlay);
	elseif alignTyp == "sideNotificationsHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.sideNotifications.overlay);
	elseif alignTyp == "fillLevelHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.fillLevelsDisplay.backgroundOverlay.overlay);
	elseif alignTyp == "vehicleSchemaHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.vehicleSchema.backgroundOverlay.overlay);
	elseif alignTyp == "speedMeterHud" then alignX, alignY, alignW, alignH = g_currentMission.hlUtils.getOverlay(g_currentMission.hud.speedMeter.backgroundOverlay.overlay);end;
	return alignX, alignY, alignW, alignH;
end;