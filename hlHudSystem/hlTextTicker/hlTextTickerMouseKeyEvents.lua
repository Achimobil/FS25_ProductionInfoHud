hlTextTickerMouseKeyEvents = {};

function hlTextTickerMouseKeyEvents:setMouse(args)
	local inClickArea = false;
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return inClickArea;end;
	if args.clickAreaTable.whereClick == "textTicker_" then
		if g_currentMission.hlUtils.timers["hlHudSystem_ignoreAreaClick"] ~= nil or g_currentMission.hlUtils.dragDrop.on then return true;end;
		local textTicker = args.clickAreaTable.ownTable;
		if textTicker ~= nil and textTicker.mouseInteraction then			
			if not inClickArea and textTicker.clickAreas ~= nil then
				for k,v in pairs (textTicker.clickAreas) do	
					if inClickArea then break;end;					
					for clickArea=1, #v do
						if inClickArea then break;end;
						if v[clickArea] ~= nil and v[clickArea][1] ~= nil then 
							if g_currentMission.hlUtils.mouseIsInArea(posX, posY, unpack(v[clickArea]))then
								if v[clickArea].onClick ~= nil and type(v[clickArea].onClick) == "function" then
									inClickArea = true;
									args.clickAreaTable=v[clickArea];
									args.trigged = "text ticker click by found areaClick";
									v[clickArea].onClick(args);								
								end;								
							end;
						end;
					end;					
				end;				
			end;		
		end;
	end;
	return inClickArea
end;
