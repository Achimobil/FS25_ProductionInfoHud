hlPdaMouseKeyEvents = {};

function hlPdaMouseKeyEvents:setMouse(args)
	local inClickArea = false;
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return inClickArea;end;
	if args.clickAreaTable.whereClick == "settingInPda_" then --prio
		hlPdaMouseKeyEvents:settingInPda(args);
		inClickArea = true;
	elseif args.clickAreaTable.whereClick == "pda_" then
		if g_currentMission.hlUtils.timers["hlHudSystem_ignorePdaAreaClick"] ~= nil or g_currentMission.hlUtils.dragDrop.on then return true;end;
		local pda = g_currentMission.hlHudSystem.pda[args.clickAreaTable.typPos]; 
		if pda ~= nil and pda.show then
			args.pda = pda;	
			---optional automatic setZoomOutIn icon or text by HL Hud System---
			local autoSetZoomOutIn = pda.isSetting and pda.settingTyp == 1 and pda.autoZoomOutIn:len() >= 4 and (pda.autoZoomOutIn == "icon" or pda.autoZoomOutIn == "text");
			if args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_UP and autoSetZoomOutIn then
				pda:setZoomOutIn( {typ=pda.autoZoomOutIn, up=true} );
				inClickArea = true;
			elseif args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_DOWN and autoSetZoomOutIn then
				pda:setZoomOutIn( {typ=pda.autoZoomOutIn, down=true} );
				inClickArea = true;
			end;
			---optional automatic setZoomOutIn icon or text by HL Hud System---
			---optional automatic line bounds icon or text by HL Hud System---
			local autoSetBounds = (not pda.isSetting or (pda.isSetting and pda.settingTyp > 1))  and pda.screen.canBounds.on and pda.screen.bounds[1] >= 0 and pda.screen.bounds[4] > 1;
			if args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_UP and autoSetBounds then
				pda.screen:setBounds( {up=true} );
				inClickArea = true;
			elseif args.isDown and args.button == Input.MOUSE_BUTTON_WHEEL_DOWN and autoSetBounds then
				pda.screen:setBounds( {down=true} );
				inClickArea = true;
			end;
			---optional automatic line bounds icon or text by HL Hud System---
			if not inClickArea and pda.clickAreas ~= nil then
				for k,v in pairs (pda.clickAreas) do	
					if inClickArea then break;end;					
					for clickArea=1, #v do
						if inClickArea then break;end;
						if v[clickArea] ~= nil and v[clickArea][1] ~= nil then 
							if g_currentMission.hlUtils.mouseIsInArea(posX, posY, unpack(v[clickArea]))then
								if v[clickArea].onClick ~= nil and type(v[clickArea].onClick) == "function" then --optional this Pda clickAreas --> pda:setClickArea(.......)
									inClickArea = true;
									args.clickAreaTable=v[clickArea];
									args.trigged = "pda click by found areaClick";
									v[clickArea].onClick(args);								
								elseif pda.onClick ~= nil and type(pda.onClick) == "function" then --optional this Pda --> pda.onClick --> if clickArea onClick not found
									inClickArea = true;
									args.clickAreaTable=v[clickArea];
									args.trigged = "pda click by NOT found areaClick (set pda total area click with clickAreaTable)";
									pda.onClick(args);
								end;								
							end;
						end;
					end;					
				end;				
			end;
			if not inClickArea and pda.onClick ~= nil and type(pda.onClick) == "function" then 
				inClickArea = true;				
				pda.onClick(args);
			end;			
		end;
	end;
	return inClickArea;
end;

function hlPdaMouseKeyEvents:settingInPda(args) --Pda default Setting	
	if args.isDown then	
		if g_currentMission.hlUtils.dragDrop.on then return;end;
		if args.button == Input.MOUSE_BUTTON_LEFT then
			local pda = g_currentMission.hlHudSystem.pda[args.clickAreaTable.typPos];
			if pda ~= nil then
				if args.clickAreaTable.areaClick == "settingIcon_" then					
					pda.isSetting = not pda.isSetting;
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Pda Creator Info					
					args.pda = pda;
					if pda.onSettingClick ~= nil and type(pda.onSettingClick) == "function" then pda.onSettingClick(args);
					elseif pda.onClick ~= nil and type(pda.onClick) == "function" then pda.onClick(args);end;					
					return;
				elseif args.clickAreaTable.areaClick == "closeIcon_" then					
					pda.isSetting = false;
					pda.show = false;					
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Pda Creator Info					
					args.pda = pda;
					if pda.onSettingClick ~= nil and type(pda.onSettingClick) == "function" then pda.onSettingClick(args);
					elseif pda.onClick ~= nil and type(pda.onClick) == "function" then pda.onClick(args);end;									
					return;					
				elseif args.clickAreaTable.areaClick == "saveIcon_" then								
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Pda Creator Info					
					args.pda = pda;
					hlPdaXml:save(pda, args.clickAreaTable.typPos);
					if pda.onSettingClick ~= nil and type(pda.onSettingClick) == "function" then pda.onSettingClick(args);
					elseif pda.onClick ~= nil and type(pda.onClick) == "function" then pda.onClick(args);end;
					pda.isSave = true;
					return;	
				elseif args.clickAreaTable.areaClick == "viewExtraLine_" then								
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Pda Creator Info					
					pda.viewExtraLine = not pda.viewExtraLine;
					return;	
				elseif args.clickAreaTable.areaClick == "autoCloseIcon_" then								
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Pda Creator Info					
					pda.autoClose = not pda.autoClose;
					if pda.show and pda.autoClose and not g_currentMission.hlUtils.isMouseCursor then pda.isSetting = false;end;
					pda.isSave = false;
					return;	
				elseif args.clickAreaTable.areaClick == "helpIcon_" then								
					g_currentMission.hlUtils.deleteTextDisplay(); --delete Pda Creator Info					
					pda.isHelp = not pda.isHelp;
					pda.isSave = false;
					return;
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