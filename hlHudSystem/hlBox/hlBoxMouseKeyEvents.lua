hlBoxMouseKeyEvents = {};

function hlBoxMouseKeyEvents:setMouse(args)
	local inClickArea = false;
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return inClickArea;end;
	if args.clickAreaTable.whereClick == "settingInBox_" then --prio 1
		hlBoxMouseKeyEvents:settingBox(args);
		return true;	
	elseif args.clickAreaTable.whereClick == "box_" then
		if g_currentMission.hlUtils.timers["hlHudSystem_ignoreAreaClick"] ~= nil or g_currentMission.hlUtils.dragDrop.on then return true;end;
		local box = g_currentMission.hlHudSystem.box[args.clickAreaTable.typPos];	
		if box ~= nil and box.show then
			args.box = box;
			---optional automatic setZoomOutIn icon or text by HL Hud System---
			local autoSetZoomOutIn = (args.clickAreaTable.areaClick == nil or args.clickAreaTable.areaClick ~= "menueArea_") and box.isSetting and box.settingTyp == 1 and box.autoZoomOutIn:len() >= 4 and (box.autoZoomOutIn == "icon" or box.autoZoomOutIn == "text");
			if args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_UP and autoSetZoomOutIn then
				box:setZoomOutIn( {typ=box.autoZoomOutIn, up=true} );
				inClickArea = true;
			elseif args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_DOWN and autoSetZoomOutIn then
				box:setZoomOutIn( {typ=box.autoZoomOutIn, down=true} );
				inClickArea = true;
			end;
			---optional automatic setZoomOutIn icon or text by HL Hud System---
			---optional automatic line bounds icon or text by HL Hud System---
			local autoSetBounds = (not box.isSetting or (box.isSetting and box.settingTyp > 1)) and box.screen.canBounds.on and box.screen.bounds[1] > 0 and box.screen.bounds[4] > 1;
			if args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_UP and autoSetBounds then
				box.screen:setBounds( {up=true} );
				inClickArea = true;
			elseif args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_DOWN and autoSetBounds then
				box.screen:setBounds( {down=true} );
				inClickArea = true;
			end;
			---optional automatic line bounds icon or text by HL Hud System---
			if not inClickArea and box.clickAreas ~= nil then
				for k,v in pairs (box.clickAreas) do	
					if inClickArea then break;end;					
					for clickArea=1, #v do
						if inClickArea then break;end;
						if v[clickArea] ~= nil and v[clickArea][1] ~= nil then 
							if g_currentMission.hlUtils.mouseIsInArea(posX, posY, unpack(v[clickArea]))then
								if v[clickArea].onClick ~= nil and type(v[clickArea].onClick) == "function" then --optional this Box clickAreas --> box:setClickArea(.......)
									inClickArea = true;
									args.clickAreaTable=v[clickArea];
									args.trigged = "box click by found areaClick";
									v[clickArea].onClick(args);								
								elseif box.onClick ~= nil and type(box.onClick) == "function" then --optional this Box --> box.onClick --> if clickArea onClick not found
									inClickArea = true;
									args.clickAreaTable=v[clickArea];
									args.trigged = "box click by NOT found areaClick (set box total area click with clickAreaTable)";
									box.onClick(args);
								end;								
							end;
						end;
					end;					
				end;				
			end;
			if not inClickArea and box.onClick ~= nil and type(box.onClick) == "function" then 
				inClickArea = true;				
				box.onClick(args);
			end;		
		end;			
	end;
	return inClickArea;	
end;

function hlBoxMouseKeyEvents:settingBox(args) --all Box default Setting	
	if args.isDown then	
		if g_currentMission.hlUtils.dragDrop.on then return;end;		
		if args.button == Input.MOUSE_BUTTON_LEFT then			
			local box = g_currentMission.hlHudSystem.box[args.clickAreaTable.typPos];
			if box ~= nil then
				if args.clickAreaTable.areaClick == "settingIcon_" then					
					box.isSetting = not box.isSetting;
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Box Creator Info					
					args.box = box;
					if box.onSettingClick ~= nil and type(box.onSettingClick) == "function" then box.onSettingClick(args);
					elseif box.onClick ~= nil and type(box.onClick) == "function" then box.onClick(args);end;					
					return;
				elseif args.clickAreaTable.areaClick == "closeIcon_" then				
					box.isSetting = false;
					box.show = false;
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Box Creator Info					
					args.box = box;
					if box.onSettingClick ~= nil and type(box.onSettingClick) == "function" then box.onSettingClick(args);
					elseif box.onClick ~= nil and type(box.onClick) == "function" then box.onClick(args);end;					
					return;
				elseif args.clickAreaTable.areaClick == "saveIcon_" then					
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Box Creator Info					
					args.box = box;
					hlBoxXml:save(box, args.clickAreaTable.typPos);
					if box.onSettingClick ~= nil and type(box.onSettingClick) == "function" then box.onSettingClick(args);
					elseif box.onClick ~= nil and type(box.onClick) == "function" then box.onClick(args);end;
					box.isSave = true;					
					return;
				elseif args.clickAreaTable.areaClick == "viewExtraLine_" then								
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Box Creator Info					
					box.viewExtraLine = not box.viewExtraLine;
					return;	
				elseif args.clickAreaTable.areaClick == "autoCloseIcon_" then								
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Box Creator Info					
					box.autoClose = not box.autoClose;
					if box.show and box.autoClose and not g_currentMission.hlUtils.isMouseCursor then box.isSetting = false;end;
					box.isSave = false;	
					return;	
				elseif args.clickAreaTable.areaClick == "helpIcon_" then								
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Box Creator Info					
					box.isHelp = not box.isHelp;
					box.isSave = false;	
					return;	
				elseif args.clickAreaTable.areaClick == "menueClose_" and args.clickAreaTable.ownTable ~= nil and args.clickAreaTable.ownTable[1] ~= nil then
					if box.menue[args.clickAreaTable.ownTable[1]] ~= nil then
						g_currentMission.hlUtils.deleteTextDisplay(); --delete Box Creator Info	
						box.menue[args.clickAreaTable.ownTable[1]].show = false;
						if box.onSettingClick ~= nil and type(box.onSettingClick) == "function" then box.onSettingClick(args);
						elseif box.onClick ~= nil and type(box.onClick) == "function" then box.onClick(args);end;
						return;
					end;				
				end;
			end;
		elseif args.button == Input.MOUSE_BUTTON_MIDDLE then
			
		elseif args.button == Input.MOUSE_BUTTON_RIGHT then
			if args.clickAreaTable.areaClick == "helpIcon_" then				
				g_currentMission.hlHudSystem:setFirstInfo();
			end;
		end;		
	end;
end;