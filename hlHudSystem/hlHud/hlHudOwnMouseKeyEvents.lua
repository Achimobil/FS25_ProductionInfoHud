hlHudOwnMouseKeyEvents = {};

function hlHudOwnMouseKeyEvents.onClick(args) --optional callbacks hud.onClick 
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return;end;
	if args.isDown then		
		if g_currentMission.hlUtils.dragDrop.on then return;end;		
		local hud = args.hud;
		if hud ~= nil then 
			if args.button == Input.MOUSE_BUTTON_LEFT then
				if g_currentMission.hlHudSystem.isSetting.hud and args.clickAreaTable.whereClick == "settingInHud_" and args.clickAreaTable.areaClick == "settingIcon_" then
				
				else
					if hud.ownTable.viewColor[1]+1 > hud.ownTable.viewColor[3] then hud.ownTable.viewColor[1] = hud.ownTable.viewColor[2];else hud.ownTable.viewColor[1] = hud.ownTable.viewColor[1]+1;end;
				end;
			elseif args.button == Input.MOUSE_BUTTON_RIGHT then
				if g_currentMission.hlHudSystem.isSetting.hud and args.clickAreaTable.whereClick == "settingInHud_" and args.clickAreaTable.areaClick == "settingIcon_" then
				
				end;
			end;
		end;
		return;
	end;
end;

function hlHudOwnMouseKeyEvents.onClickArea(args) --hud areas callbacks onClick
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return;end;
	if args.isDown then		
		if g_currentMission.hlUtils.dragDrop.on then return;end;			
		local hud = args.hud;
		if hud ~= nil then 
			
		end;		
	end;
end;