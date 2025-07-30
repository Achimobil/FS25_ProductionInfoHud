hlCamBoxDraw = {};

function hlCamBoxDraw.canDrawBox(args) 
	if args == nil or type(args) ~= "table" or args.typPos == nil then return true;end;
	if g_currentMission.hlHudSystem.camera.object.node ~= 0 then
		return true;
	end;
	return false;
end;

function hlCamBoxDraw.setBox(args)
	if args == nil or type(args) ~= "table" or args.typPos == nil or args.inArea == nil then return;end;
	local box = g_currentMission.hlHudSystem.box[args.typPos];
	if box == nil then return;end;
	
	local x, y, w, h = box:getScreen();	
	
	local distance = box:getSize( {"distance"} ); 
	local difW = distance.iconWidth --default width
	local difH = distance.iconHeight; --default height
	
	function needsUpdate()
		if box.needsUpdate or box.ownTable.iconWidth == nil then
			box.ownTable.iconWidth, box.ownTable.iconHeight = box:getOptiWidthHeight( {typ="box", height=h-(difH*2), width=w-(difW*2)} );
		end;
		box.needsUpdate = false;
	end;
	needsUpdate();
	
	local iconWidth = box.ownTable.iconWidth;
	local iconHeight = box.ownTable.iconHeight;
	local data = g_currentMission.hlHudSystem.camera.object;	
	local cameraNode = g_currentMission.hlHudSystem.camera.node;
	local camZoom = 0;
	local camRotation = {0,0,0};
		
	if data == nil or data.node == 0 or cameraNode == nil or camerNode == 0 then box.isSetting = false;box.show = false;return;end;	
	local camObject = g_currentMission.nodeToObject[data.node];
	if camObject == nil then box.isSetting = false;box.show = false;return;end;	
	
	local inArea = args.inArea
	local setCamera = false;
	if not data.isVehicle and (g_currentMission.hlHudSystem.camera.object.x == nil or data.interAction) then
		local ox, oy, oz = getWorldTranslation(data.node);
		if ox ~= nil and oy ~= nil and oz ~= nil then
			if data.camZoom == nil then camZoom = 10;else camZoom = data.camZoom;end;
			g_currentMission.hlHudSystem.camera.object.x = ox;
			g_currentMission.hlHudSystem.camera.object.y = oy;
			g_currentMission.hlHudSystem.camera.object.z = oz;
			setTranslation(cameraNode, ox, oy+camZoom, oz);
			setCamera = true;
		end;
	elseif not data.isVehicle and g_currentMission.hlHudSystem.camera.object.x ~= nil then
		setCamera = true;
	elseif data.isVehicle then
		
		local ox, oy, oz = getWorldTranslation(data.node);		
		
			if data.camZoom == nil then camZoom = 6;else camZoom = data.camZoom;end;
			setTranslation(cameraNode, ox, oy+camZoom, oz);
			local dx, dy, dz = localDirectionToWorld(data.node, 0, 0, 1);		
			
			local rotMin = math.rad(GuiTopDownCamera.ROTATION_MIN_X_NEAR + (GuiTopDownCamera.ROTATION_MIN_X_FAR - GuiTopDownCamera.ROTATION_MIN_X_NEAR) * 0.5)
			local rotMax = math.rad(GuiTopDownCamera.ROTATION_MAX_X_NEAR + (GuiTopDownCamera.ROTATION_MAX_X_FAR - GuiTopDownCamera.ROTATION_MAX_X_NEAR) * 0.5)
			local rotationX = rotMin + (rotMax - rotMin) * 0.5
			--setRotation(cameraNode, rotationX, self.cameraRotY, 0)
			
			--renderText(0.5, 0.7, 0.010, "-direction: ".. tostring(direction));
			--renderText(0.5, 0.69, 0.010, "-dy: ".. tostring(dy));
			local rx, ry, rz = getRotation(data.node);
			if data.camRotation[1] ~= nil then camRotation[1] = data.camRotation[1];end;
			if data.camRotation[2] ~= nil then camRotation[2] = data.camRotation[2];end;
			if data.camRotation[3] ~= nil then camRotation[3] = data.camRotation[3];end;
			setRotation(cameraNode, 0-math.rad(camRotation[1]), 0-math.rad(camRotation[2]), 0-math.rad(camRotation[3])); -- -math.rad(180)		
			--setDirection(cameraNode, ox, oy+camZoom, oz, 0, 1, 0);
			setCamera = true;
		
	end;
	
	if setCamera then
		local posX = x+(w/2)-(iconWidth/2);
		local posY = y+h-(h/2)-(iconHeight/2);		
		renderOverlay(g_currentMission.hlHudSystem.camera.overlay, posX, posY, iconWidth, iconHeight);
		updateRenderOverlay(g_currentMission.hlHudSystem.camera.overlay);		
		if data.interAction and not g_currentMission.hlUtils:disableInArea() and inArea then box:setClickArea( {posX, posX+iconWidth, posY, posY+iconHeight, onClick=hlCamBoxMouseKeyEvents.onClick, whatClick="hlHudSystem_CameraBox", whereClick="cameraOverlay_", ownTable={}} );end;
	else
		box.isSetting = false;
		box.show = false;
	end;
end;