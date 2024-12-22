hlCamBoxMouseKeyEvents = {};

function hlCamBoxMouseKeyEvents:setMouse(args)
	
end;

function hlCamBoxMouseKeyEvents.onClick(args)
	if args == nil or type(args) ~= "table" or args.clickAreaTable == nil then return;end;
	if args.isDown then
		if g_currentMission.hlUtils.dragDrop.on then return;end;
		local box = args.box;
		if box ~= nil then
			local data = g_currentMission.hlHudSystem.camera.object;
			if args.clickAreaTable.whereClick == "cameraOverlay_" and data ~= nil and data.onClick ~= nil and type(data.onClick) == "function" then
				data.onClick(args);
				return;
			end;
		end;
	end;	
end;