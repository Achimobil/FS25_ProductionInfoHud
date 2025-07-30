hlCamBox = {};
source(hlHudSystem.modDir.."hlHudSystem/hlCamBox/hlCamBoxXml.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlCamBox/hlCamBoxDraw.lua"); 
source(hlHudSystem.modDir.."hlHudSystem/hlCamBox/hlCamBoxMouseKeyEvents.lua"); 

function hlCamBox:generateNew(box)
	if g_currentMission.hlHudSystem.camera.active and g_currentMission.hlHudSystem.camera.node == 0 then
		g_currentMission.hlHudSystem.camera.node = createCamera("hlHudSystem_CameraBox", math.rad(60), 0.15, 6000); --1.0471975511965976, 1, 10000
		
		g_currentMission.hlHudSystem.camera.baseNode = createTransformGroup("hlHudSystem_CameraBoxBaseNode");
		link(getRootNode(), g_currentMission.hlHudSystem.camera.node);
		link(g_currentMission.hlHudSystem.camera.baseNode, g_currentMission.hlHudSystem.camera.node)
		
		setRotation(g_currentMission.hlHudSystem.camera.node, 0, math.rad(180), 0)
        setTranslation(g_currentMission.hlHudSystem.camera.node, 0, 2.5, 0.06)
		
		--local camera = CameraPath.createFromI3D("data/vehicles/fendt/vario900/vario900.i3d", 0, g_currentMission.hlHudSystem.camera.node)
		
		--g_currentMission.hlHudSystem.camera.cam = camera;
		--print(DebugUtil.printTableRecursively(camera, "camera ", 0, 1))
		--link(g_currentMission.hlHudSystem.camera.baseNode, g_currentMission.hlHudSystem.camera.node);
		--g_currentMission.hlHudSystem.camera.element = {isLoading=true,isRenderDirty=true,filename=g_currentMission.hlHudSystem.modDir.. "hlHudSystem/hlCamBox/camera.i3d"};
		--g_currentMission.hlHudSystem.camera.element.loadingRequestId = g_i3DManager:loadSharedI3DFileAsync(g_currentMission.hlHudSystem.camera.element.filename, false, false, hlCamBox.setSceneFinished, g_currentMission.hlHudSystem.camera.element, box); 
		
		
		local x, y, w, h = box:getScreen();
		local iconWidth, iconHeight = g_currentMission.hlUtils.getOptiIconWidthHeight(h, box.screen.pixelW, box.screen.pixelH);		
		local resolutionX = math.ceil(g_screenWidth * iconWidth) * 2;
		local resolutionY = math.ceil(g_screenHeight * iconHeight) * 2;
		local aspectRatio = resolutionX / resolutionY;
		
		local useAlpha = true
		local renderShadows = false
		local bloomQuality = 0
		local enableDof = false
		local ssaoQuality = 0
		local asyncShaderCompilation = false  -- flag to toggle async shader compilation for drawn overlay, if true overlay might not show anything after the first updateRenderOverlay() calls(s)
		local shapesMask = 98304 -- show all objects with bits 1-8 enabled
		local lightMask = 98304 -- per default only render lights with bit 26 enabled		
		--local shapesMask = 98304; --by Mod--
		--local lightMask = 98304; --by Mod
		--local shapesMask = 4294967295; --by Test
		--local lightMask = 4294967295; --by Test
		--$data/vehicles/caseIH/a8800MR/a8800MR.i3d		
		--print(DebugUtil.printTableRecursively(g_currentMission.maps, "g_currentMission.maps ", 0, 1))	
		--log("loaded", "cambox scene: ".. tostring(g_currentMission.hlHudSystem.camera.element.scene))
		g_currentMission.hlHudSystem.camera.overlay = createRenderOverlay(g_currentMission.maps[1], g_currentMission.hlHudSystem.camera.node, aspectRatio, resolutionX, resolutionY, useAlpha, shapesMask, lightMask, renderShadows, bloomQuality, enableDof, ssaoQuality, asyncShaderCompilation);
		--log("loaded", "cambox overlay: ".. tostring(g_currentMission.hlHudSystem.camera.overlay))
		
		--g_currentMission.hlHudSystem.camera.overlay.isRenderDirty = true
		--g_currentMission.hlHudSystem.camera.overlay:raiseCallback("onRenderLoadCallback", g_currentMission.maps[1], g_currentMission.hlHudSystem.camera.overlay)
	end;
end;


function hlCamBox:generate(box)
	if g_currentMission.hlHudSystem.camera.active and g_currentMission.hlHudSystem.camera.node == 0 then
		g_currentMission.hlHudSystem.camera.node = createCamera("hlHudSystem_CameraBox", math.rad(60), 0.15, 6000); --1.0471975511965976, 1, 10000
		--g_currentMission.hlHudSystem.camera.baseNode = createTransformGroup("hlHudSystem_CameraBoxBaseNode");
		link(getRootNode(), g_currentMission.hlHudSystem.camera.node);
		--link(g_currentMission.hlHudSystem.camera.baseNode, g_currentMission.hlHudSystem.camera.node);
		--g_currentMission.hlHudSystem.camera.element = {isLoading=true,isRenderDirty=true,filename="data/vehicles/fendt/vario900/vario900.i3d"};
		--g_currentMission.hlHudSystem.camera.element.loadingRequestId = g_i3DManager:loadSharedI3DFileAsync(g_currentMission.hlHudSystem.camera.element.filename, false, false, hlCamBox.setSceneFinished, g_currentMission.hlHudSystem.camera.element, box); 
		
		
		local x, y, w, h = box:getScreen();
		local iconWidth, iconHeight = g_currentMission.hlUtils.getOptiIconWidthHeight(h, box.screen.pixelW, box.screen.pixelH);		
		local resolutionX = math.ceil(g_screenWidth * iconWidth) * 2;
		local resolutionY = math.ceil(g_screenHeight * iconHeight) * 2;
		local aspectRatio = resolutionX / resolutionY;
		
		local useAlpha = true
		local renderShadows = false
		local bloomQuality = 0
		local enableDof = false
		local ssaoQuality = 0
		local asyncShaderCompilation = false  -- flag to toggle async shader compilation for drawn overlay, if true overlay might not show anything after the first updateRenderOverlay() calls(s)
		local shapesMask = 98304 -- show all objects with bits 1-8 enabled
		local lightMask = 98304 -- per default only render lights with bit 26 enabled		
		--local shapesMask = 98304; --by Mod--
		--local lightMask = 98304; --by Mod
		--local shapesMask = 4294967295; --by Test
		--local lightMask = 4294967295; --by Test
		--$data/vehicles/caseIH/a8800MR/a8800MR.i3d		
		--print(DebugUtil.printTableRecursively(g_currentMission.maps, "g_currentMission.maps ", 0, 1))	
		--log("loaded", "cambox scene: ".. tostring(g_currentMission.hlHudSystem.camera.element.scene))
		
		--g_currentMission.hlHudSystem.camera.overlay = createRenderOverlay(g_currentMission.hlHudSystem.camera.element.scene, g_currentMission.hlHudSystem.camera.node, aspectRatio, resolutionX, resolutionY, useAlpha, shapesMask, lightMask, renderShadows, bloomQuality, enableDof, ssaoQuality, asyncShaderCompilation);
		
		g_currentMission.hlHudSystem.camera.overlay = createRenderOverlay(g_currentMission.maps[1], g_currentMission.hlHudSystem.camera.node, aspectRatio, resolutionX, resolutionY, useAlpha, shapesMask, lightMask, renderShadows, bloomQuality, enableDof, ssaoQuality, asyncShaderCompilation);
		
		--log("loaded", "cambox overlay: ".. tostring(g_currentMission.hlHudSystem.camera.overlay))
		
		--g_currentMission.hlHudSystem.camera.overlay.isRenderDirty = true
		--g_currentMission.hlHudSystem.camera.overlay:raiseCallback("onRenderLoadCallback", g_currentMission.maps[1], g_currentMission.hlHudSystem.camera.overlay)
	end;
end;

function hlCamBox:deleteObject(camBox)
	if camBox == nil then camBox = g_currentMission.hlHudSystem.hlBox:getData("hlHudSystem_CameraBox");end;
	if camBox ~= nil and camBox.show then camBox.show = false;end;
	g_currentMission.hlHudSystem.camera.object = {};	
end;

function hlCamBox:setObject(args)
	if args == nil or type(args) ~= "table" or args.node == nil then return;end;	
	g_currentMission.hlHudSystem.camera.object.node = args.node;
	g_currentMission.hlHudSystem.camera.object.isVehicle = args.isVehicle or false;
	g_currentMission.hlHudSystem.camera.object.camZoom = args.camZoom;
	g_currentMission.hlHudSystem.camera.object.camRotation = {0,0,0};
	if args.camRotation ~= nil and type(args.camRotation) == "table" then
		if args.camRotation[1] ~= nil then g_currentMission.hlHudSystem.camera.object.camRotation[1] = args.camRotation[1];end;
		if args.camRotation[2] ~= nil then g_currentMission.hlHudSystem.camera.object.camRotation[2] = args.camRotation[2];end;
		if args.camRotation[3] ~= nil then g_currentMission.hlHudSystem.camera.object.camRotation[3] = args.camRotation[3];end;
	end;
	g_currentMission.hlHudSystem.camera.object.onClick = args.onClick;
	g_currentMission.hlHudSystem.camera.object.interAction = g_currentMission.hlHudSystem.camera.object.onClick ~= nil and type(g_currentMission.hlHudSystem.camera.object.onClick) == "function";
end;

function hlCamBox:setShow(state)
	if g_currentMission.hlHudSystem.camera.object.node == 0 then return;end;
	local camBox = g_currentMission.hlHudSystem.hlBox:getData("hlHudSystem_CameraBox");
	if camBox ~= nil then
		g_currentMission.hlHudSystem.camera.state = state or false;
		camBox.show = state or false;
		if not camBox.show then hlCamBox:deleteObject(camBox);end;
	else
		g_currentMission.hlHudSystem.camera.state = false;
	end;
end;

function hlCamBox:setSceneFinished(node, failedReason, box)
	g_currentMission.hlHudSystem.camera.element.isLoading = false

	if failedReason == LoadI3DFailedReason.FILE_NOT_FOUND or failedReason == LoadI3DFailedReason.UNKNOWN then
		Logging.error("Failed to load character creation scene from '%s'", g_currentMission.hlHudSystem.camera.element.filename)
	end

	if failedReason == LoadI3DFailedReason.NONE then
		g_currentMission.hlHudSystem.camera.element.scene = node

		link(getRootNode(), node)
		--log("loaded", "cambox: ".. tostring(node))
		local x, y, w, h = box:getScreen();
		local iconWidth, iconHeight = g_currentMission.hlUtils.getOptiIconWidthHeight(h, box.screen.pixelW, box.screen.pixelH);		
		local resolutionX = math.ceil(g_screenWidth * iconWidth) * 2;
		local resolutionY = math.ceil(g_screenHeight * iconHeight) * 2;
		local aspectRatio = resolutionX / resolutionY;
		
		local useAlpha = true
		local renderShadows = false
		local bloomQuality = 0
		local enableDof = false
		local ssaoQuality = 0
		local asyncShaderCompilation = false  -- flag to toggle async shader compilation for drawn overlay, if true overlay might not show anything after the first updateRenderOverlay() calls(s)
		local shapesMask = 98304 -- show all objects with bits 1-8 enabled
		local lightMask = 98304 -- per default only render lights with bit 26 enabled		
		--local shapesMask = 98304; --by Mod--
		--local lightMask = 98304; --by Mod
		--local shapesMask = 4294967295; --by Test
		--local lightMask = 4294967295; --by Test
		--$data/vehicles/caseIH/a8800MR/a8800MR.i3d		
		--print(DebugUtil.printTableRecursively(g_currentMission.maps, "g_currentMission.maps ", 0, 1))	
		--log("loaded", "cambox scene: ".. tostring(g_currentMission.hlHudSystem.camera.element.scene))
		g_currentMission.hlHudSystem.camera.overlay = createRenderOverlay(g_currentMission.hlHudSystem.camera.element.scene, g_currentMission.hlHudSystem.camera.node, aspectRatio, resolutionX, resolutionY, useAlpha, shapesMask, lightMask, renderShadows, bloomQuality, enableDof, ssaoQuality, asyncShaderCompilation);
		--log("loaded", "cambox overlay: ".. tostring(g_currentMission.hlHudSystem.camera.overlay))
		g_currentMission.hlHudSystem.camera.active = true;
	elseif node ~= 0 then
		g_currentMission.hlHudSystem.camera.active = false;
		delete(node)
	end
end

