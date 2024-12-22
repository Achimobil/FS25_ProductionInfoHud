hlCamBox = {};
source(hlHudSystem.modDir.."hlHudSystem/hlCamBox/hlCamBoxXml.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlCamBox/hlCamBoxDraw.lua"); 
source(hlHudSystem.modDir.."hlHudSystem/hlCamBox/hlCamBoxMouseKeyEvents.lua"); 

function hlCamBox:generate(box)
	if g_currentMission.hlHudSystem.camera.active and g_currentMission.hlHudSystem.camera.node == 0 then
		g_currentMission.hlHudSystem.camera.node = createCamera("hlHudSystem_CameraBox", math.rad(60), 0.15, 6000);
		link(getRootNode(), g_currentMission.hlHudSystem.camera.node);
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
		local syncShaderCompilation = false  -- flag to toggle async shader compilation for drawn overlay, if true overlay might not show anything after the first updateRenderOverlay() calls(s)
		local shapesMask = 255 -- show all objects with bits 1-8 enabled
		local lightMask = 67108864 -- per default only render lights with bit 26 enabled		
		--local shapesMask = 98304; --by Mod--
		--local lightMask = 98304; --by Mod
		--local shapesMask = 4294967295; --by Test
		--local lightMask = 4294967295; --by Test
		g_currentMission.hlHudSystem.camera.overlay = createRenderOverlay(nil, g_currentMission.hlHudSystem.camera.node, aspectRatio, resolutionX, resolutionY, useAlpha, shapesMask, lightMask, renderShadows, bloomQuality, enableDof, ssaoQuality, asyncShaderCompilation);
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