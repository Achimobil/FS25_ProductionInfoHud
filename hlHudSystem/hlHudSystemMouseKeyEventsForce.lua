hlHudSystemMouseKeyEventsForce = {};

function hlHudSystemMouseKeyEventsForce:setKeyMouse(unicode, sym, modifier, isDownKey, posX, posY, isDown, isUp, button)
	if unicode ~= nil then
		if not g_currentMission.hlUtils.dragDrop.on then
			hlHudSystemMouseKeyEvents:setKey(unicode, sym, modifier, isDownKey);			
		end;
	else
		if g_currentMission.hlUtils.isMouseCursor then			
			if not g_currentMission.hlUtils.dragDrop.on then
				hlHudSystemMouseKeyEventsForce:setMouse(posX, posY, isDown, isUp, button);
			elseif g_currentMission.hlUtils.dragDrop.on then
				hlHudSystemMouseKeyEvents:setDragDropMouse(posX, posY, isDown, isUp, button);
			end;
		end;
	end;
end;

function hlHudSystemMouseKeyEventsForce:setMouse(posX, posY, isDown, isUp, button)	
	local acceptsWhatClick = {_hlBox_=true}; --dragDrop accepts
	local isClickInArea = false;
	if g_currentMission.hlHudSystem.areas ~= nil then		
		for key,value in pairs (g_currentMission.hlHudSystem.areas) do		
			for area=1, #value do
				if value[area] ~= nil and value[area][1] ~= nil then 
					if g_currentMission.hlUtils.mouseIsInArea(posX, posY, unpack(value[area]))then --total Areas Hud or Pda or Box or Menue	
						if button == Input.MOUSE_BUTTON_LEFT and isDown and (acceptsWhatClick[value[area].whatClick] ~= nil and acceptsWhatClick[value[area].whatClick]) and (value[area].whereClick == "dragDrop_" or value[area].whereClick == "dragDropWH_") then
							if not g_currentMission.hlUtils.dragDrop.on then
								g_currentMission.hlUtils.setDragDrop(true,{system="hlHudSystem",what=value[area].whatClick,where=value[area].whereClick,area=value[area].areaClick, typPos=value[area].typPos,overlay=value[area].overlay,typ=value[area].typ});
							end;
							return;
						end;						
						local isClickSettingIcons = false;
						if value[area].whatClick == "_hlBox_" then
							isClickInArea = hlBoxMouseKeyEvents:setMouse( {isDown=isDown, isUp=isUp, button=button, clickAreaTable=value[area], trigged="box click total area"} ); --in a Box Area Total and Click somewhere							
						end;
						if isClickInArea then break;end;
					end;
				end;
			end;
		end;
	end;	
	if not isClickInArea and g_currentMission.hlHudSystem.clickAreas ~= nil and not g_currentMission.hlUtils.dragDrop.on then --free onClick areas somewhere on screen, prio to last
		for key,value in pairs (g_currentMission.hlHudSystem.clickAreas) do		
			for area=1, #value do
				if value[area] ~= nil and value[area][1] ~= nil then 
					if g_currentMission.hlUtils.mouseIsInArea(posX, posY, unpack(value[area]))then
						if value[area].onClick ~= nil and type(value[area].onClick) == "function" then
							value[area].onClick( {isDown=isDown, isUp=isUp, button=button, clickAreaTable=value[area]} );								
						end;
						return;
					end;
				end;
			end;
		end;					
	end;	
end;