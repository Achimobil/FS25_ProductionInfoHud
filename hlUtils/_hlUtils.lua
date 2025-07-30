--set in modDesc
--<l10n>		
--	<text name="input_HL_ONOFFMOUSECURSOR"><en>HL Mouse On/Off</en></text>
--</l10n>
--<actions>
--	<action name="HL_ONOFFMOUSECURSOR" ignoreComboMask="false" axisType="HALF" category="ONFOOT VEHICLE" />		
--</actions>
--<inputBinding>		
--	<actionBinding action="HL_ONOFFMOUSECURSOR">
--		<binding device="KB_MOUSE_DEFAULT" input="KEY_f9" axisComponent="+" neutralInput="0" index="1"/>
--	</actionBinding>		
--</inputBinding>

hlUtils = {}; --LUA load over modDesc, first

hlUtils.metadata = {
	interface = "FS25 ...",
	title = "HL Utils", --löst das alte _hl System ab was ich seit LS15 benutzt habe und in fast allen meinen Mods vorhanden war
	notes = "Nützliche Utils die man in Mods (meine fast alle) immer wieder mal braucht, incl. Maussteuerung (Default F9)",
	author = "(by HappyLooser)",
	version = "v1.02 Beta",
	systemVersion = 1.02,
	datum = "21.05.2023",
	update = "04.06.2025",
	web = "no",
	info = "Link Freigabe und Änderungen ist ohne meine Zustimmung nicht erlaubt (Freeware)",
	info1 = "Benutzung als HL Utils in einem Mod (ohne Code Änderung) ist ohne Zustimmung erlaubt",
	"##Orginal Link Freigabe:"
};

--print(DebugUtil.printTableRecursively(lineTable, "fillTypes ", 0, 5))	
hlUtils.modDir = g_currentModDirectory;
source(hlUtils.modDir.."hlUtils/_hlUtilsMp.lua");

function hlUtils:loadMap()	
	if hlUtils:getDetiServer() then return;end;
	Mission00.onStartMission = Utils.prependedFunction(Mission00.onStartMission, hlUtils.onStartMission);	
	Mission00.onStartMission = Utils.appendedFunction(Mission00.onStartMission, hlUtils.startMission);
	createFolder(getUserProfileAppPath().. "modSettings/");
	createFolder(getUserProfileAppPath().. "modSettings/HL/");
	if g_currentMission.hlUtils == nil then 
		g_currentMission.hlUtils = {};
		g_currentMission.hlUtils.version = hlUtils.metadata.systemVersion;
		g_currentMission.hlUtils.modDir = hlUtils.modDir;
		g_currentMission.hlUtils.playerFrozen = false;
		g_currentMission.hlUtils.binding = {isCombi=false,isKeyboard=false,isMouse=false,inputString={}};		
		g_currentMission.hlUtils.precisionFarming = false;
		hlUtils:setFunction();
		hlUtils:registerActionEvent();
	else
		if g_currentMission.hlUtils.version < hlUtils.metadata.systemVersion then
			g_currentMission.hlUtils = {};
			g_currentMission.hlUtils.version = hlUtils.metadata.systemVersion;
			g_currentMission.hlUtils.modDir = hlUtils.modDir;
			g_currentMission.hlUtils.playerFrozen = false;
			g_currentMission.hlUtils.binding = {isCombi=false,isKeyboard=false,isMouse=false,inputString={}};			
			g_currentMission.hlUtils.precisionFarming = false; --update 1.01
			hlUtils:setFunction();
			hlUtils:registerActionEvent();
		else
			--print("---Info Not loading ".. tostring(hlUtils.metadata.title).. " over Mod, found newer or identical Version")			
		end;		
	end;	
end;

function hlUtils:registerActionEvent()
	local displayText = g_i18n:getText("ui_mouse").. " ".. g_i18n:getText("ui_on").. "/".. g_i18n:getText("ui_off")
	PlayerInputComponent.registerGlobalPlayerActionEvents = Utils.appendedFunction(
		PlayerInputComponent.registerGlobalPlayerActionEvents,
		function(self, controlling)			
			--if controlling ~= "VEHICLE" then
				local inputAction = InputAction.HL_ONOFFMOUSECURSOR;
				local callbackTarget = self;
				local callbackFunc = self.hlHudSystemActionKeyMouse;
				local triggerUp = false;
				local triggerDown = true;
				local triggerAlways = false;
				local startActive = true;

				local _, eventId = g_inputBinding:registerActionEvent(inputAction, callbackTarget, callbackFunc, triggerUp, triggerDown, triggerAlways, startActive, nil, true);

				--g_inputBinding:setActionEventText(eventId, "HL MouseCursor On/Off");				
				g_inputBinding:setActionEventTextVisibility(eventId, false);
				--g_inputBinding:setActionEventActive(eventId, true);
				local action = g_inputBinding.nameActions[InputAction.HL_ONOFFMOUSECURSOR];				
				if action ~= nil then
					action.displayCategory = "HL Hud System";
					action.displayNamePositive = tostring(displayText);
					action.displayNameNegative = action.displayNamePositive;				
				end;
			--end			
	end)
	function PlayerInputComponent:hlHudSystemActionKeyMouse(actionName, inputValue, callbackState, isAnalog, isMouse, deviceCategory)
		if not g_currentMission.hlUtils.dragDrop.on then			
			if actionName == "HL_ONOFFMOUSECURSOR" then			
				if g_currentMission.hlUtils.isMouseCursor then				
					g_currentMission.hlUtils.mouseOnOff(false, false);			
				else				
					g_currentMission.hlUtils.mouseOnOff(true, g_currentMission.hlUtils.playerFrozen);				
				end;
			end;
		end;
	end;
end;

function hlUtils.onStartMission()	
	if g_currentMission == nil or g_currentMission.hlUtils == nil or g_currentMission.hlUtils.modDir ~= hlUtils.modDir then
		removeModEventListener(hlUtils);
	else
		if hlUtils:getDetiServer() then return;end;
		print("---loading ".. tostring(hlUtils.metadata.title).. " ".. tostring(hlUtils.metadata.version).. " ".. tostring(hlUtils.metadata.author).. "---")
		g_currentMission.hlUtils.addTimer( {true} );
		g_currentMission.hlUtils.addSwitchTimer( {true} );
		g_currentMission.hlUtils.helpMenuData = {};		
		hlUtils:addOverlays();
		hlUtils:loadSaveXml();
		---
		--hlUtils:playerHandTool();
		hlUtils:vehicleZoom();
		hlUtils:loadInputHelpDisplay();
		---
	end;	
end;

function hlUtils.startMission()
	if g_currentMission ~= nil and g_currentMission.hlUtils ~= nil and g_currentMission.hlUtils.modDir == hlUtils.modDir then		
		if g_modIsLoaded["FS25_precisionFarming"] and FS25_precisionFarming ~= nil and FS25_precisionFarming.g_precisionFarming ~= nil then --update 1.01
			g_currentMission.hlUtils.precisionFarming = true;
		else
			g_currentMission.hlUtils.precisionFarming = false;
		end;
	end;
end;

function hlUtils:delete()
	if g_currentMission == nil then return;end;
	if hlUtils:getDetiServer() then return;end;
	
end;

function hlUtils:deleteMap()
	if g_currentMission == nil then return;end;
	if hlUtils:getDetiServer() then return;end;
	if g_currentMission.hlUtils.overlays ~= nil then		
		for modName,groupTable in pairs (g_currentMission.hlUtils.overlays) do		
			if modName ~= "txtDisplay" then
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(g_currentMission.hlUtils.overlays[modName][groupName]);
						g_currentMission.hlUtils.overlays[modName][groupName] = nil;
					end;
				end;				
				g_currentMission.hlUtils.overlays[modName] = nil;
			end;
		end;		
		g_currentMission.hlUtils.deleteOverlays(g_currentMission.hlUtils.overlays);	
		g_currentMission.hlUtils.overlays = nil;
	end;	
end;

function hlUtils:mouseEvent(posX, posY, isDown, isUp, button)
	if g_currentMission == nil then return;end;
	if hlUtils:getDetiServer() then return;end;	
	g_currentMission.hlUtils.mouseCursor = {posX=posX, posY=posY, isDown=isDown, isUp=isUp, button=button};
end;

function hlUtils:keyEvent(unicode, sym, modifier, isDown)	
	if g_currentMission == nil then return;end;
	if hlUtils:getDetiServer() then return;end;
	g_currentMission.hlUtils.key = {unicode=unicode, sym=sym, modifier=modifier, isDown=isDown};
end;

function hlUtils:update(dt)	
	if g_currentMission == nil then return;end;
	if hlUtils:getDetiServer() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;
	g_currentMission.hlUtils.update_timers(dt);
	g_currentMission.hlUtils.update_switchTimers(dt);	
	if g_currentMission.hlUtils.isMouseCursor then g_currentMission.hlUtils.mouseOnOff(true, g_currentMission.hlUtils.playerFrozen);end;		
end;

function hlUtils:draw()	
	if g_currentMission == nil then return;end;
	if hlUtils:getDetiServer() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;
	g_currentMission.hlUtils.drawTextDisplay();
end;

function hlUtils:getDetiServer()	
	return g_dedicatedServer ~= nil;
end;
addModEventListener(hlUtils);

function hlUtils:playerHandTool()	
	oldPlayerStateCycleHandtool = PlayerStateCycleHandtool.isAvailable;
	PlayerStateCycleHandtool.isAvailable = function (self)
		local isOkay, result = pcall(oldPlayerStateCycleHandtool, self);
		if isOkay and self ~= nil then
			if g_currentMission.hlUtils.isMouseCursor then return false;end;			
			if g_currentMission.hlUtils.modLoaded["FS25_AllRoundExtension"] ~= nil and not g_currentMission.hlUtils.globalFunction["FS25_AllRoundExtension"].getHandTool() then return false;end; --update 0.4
			return result;
		end;
	end;	
end;

function hlUtils:vehicleZoom() 
	oldVehicleCamera = VehicleCamera.zoomSmoothly;
	VehicleCamera.zoomSmoothly = function(self, offset)
		local zoomTarget = self.zoomTarget;
		local isOkay, result = pcall(oldVehicleCamera, self, offset)
		if isOkay and self ~= nil then
			if not g_currentMission.hlUtils.isMouseCursor then				
				return offset;			
			else				
				self.zoomTarget = zoomTarget;				
			end;
		end;
	end;
end;

function hlUtils:loadInputHelpDisplay() --update 0.97
	
	function hlUtils.preInputHelpDisplayDraw(self, offsetX, offsetY)
		
		local pf25 = g_modIsLoaded["FS25_precisionFarming"] and FS25_precisionFarming ~= nil and FS25_precisionFarming.g_precisionFarming ~= nil and FS25_precisionFarming.g_precisionFarming.inputHelpDisplayExtension ~= nil and FS25_precisionFarming.g_precisionFarming.inputHelpDisplayExtension.isEnabled; --update 1.01				
				
		local inputBinding = g_inputBinding;
		local inputDisplayManager = g_inputDisplayManager;

		local pressedComboMaskGamepad, pressedComboMaskMouse = inputBinding:getComboCommandPressedMask();
		local useGamepadButtons = GS_IS_CONSOLE_VERSION or (inputBinding:getInputHelpMode() == GS_INPUT_HELP_MODE_GAMEPAD);
		local currentPressedMask = useGamepadButtons and pressedComboMaskGamepad or pressedComboMaskMouse;
		local isCombo = currentPressedMask ~= 0;

		local comboActionStatus = inputDisplayManager:getComboHelpElements(useGamepadButtons);
		local hasComboCommands = next(comboActionStatus) ~= nil;

		local eventHelpElements = inputDisplayManager:getEventHelpElements(currentPressedMask, useGamepadButtons);
		if (eventHelpElements == nil or #eventHelpElements == 0) and not hasComboCommands and isCombo then        
			eventHelpElements = inputDisplayManager:getEventHelpElements(0, useGamepadButtons);
		end;
		
		table.sort(self.helpExtensions, function(a, b)
			return a.priority < b.priority
		end)

		table.sort(self.infoExtensions, function(a, b)
			return a.priority < b.priority
		end)
		
		local difHeight = 0;
		local actionNames = {};
		local comboHeight = 0;
		local eventHelpElementTotalHeight = 0;
		local helpExtensionTotalHeight = 0;
		local infoExtensionTotalHeight = 0;
		local extraHelpTextTotalHeight = 0;
		local numElements = 0;
		local hasEventElement = false;
		local noVehicleControl = self.vehicle == nil or self.vehicle.schemaOverlay == nil;
		function setEventsHelpElementsTotalHeight()
			if eventHelpElements ~= nil then
				for k, helpElement in ipairs(eventHelpElements) do
					if self.skipActions[helpElement.actionName] == nil then
						if helpElement.actionName == InputAction.SWITCH_IMPLEMENT and not noVehicleControl then
							eventHelpElementTotalHeight = eventHelpElementTotalHeight + self.lineBg.height + self.lineOffsetY;											
						else
							eventHelpElementTotalHeight = eventHelpElementTotalHeight + self.lineBg.height + self.lineOffsetY;
						end;
						if actionNames[helpElement.actionName] == nil then 
							actionNames[helpElement.actionName] = true;
							--eventHelpElementTotalHeight = eventHelpElementTotalHeight + self.lineBg.height + self.lineOffsetY;
						end;
						numElements = numElements + 1;
						local maxNumElements = helpElement.priority <= GS_PRIO_HIGH and InputHelpDisplay.MAX_NUM_ELEMENTS_HIGH_PRIORITY or InputHelpDisplay.MAX_NUM_ELEMENTS;
						if numElements > maxNumElements then							
							break;
						end;
					end;
				end;
			end;
		end;	
		function setHelpExtensionTotalHeight()		
			if self.helpExtensions ~= nil and #self.helpExtensions > 0 then 
				for i=#self.helpExtensions, 1, -1 do
					local hasEvent = false;
					local helpExtension = self.helpExtensions[i];				
					if helpExtension.setEventHelpElements ~= nil then
						hasEventElement = true;
					end;
					local maxNumElements = helpExtension.priority <= GS_PRIO_HIGH and InputHelpDisplay.MAX_NUM_ELEMENTS_HIGH_PRIORITY or InputHelpDisplay.MAX_NUM_ELEMENTS;
					if numElements < maxNumElements then				
						local height = helpExtension:getHeight();
						if height > 0 then
							helpExtensionTotalHeight = helpExtensionTotalHeight + height + self.lineOffsetY;
							
						end;
					end;
				end;
			end;		
		end;
		function setInfoExtensionTotalHeight()		
			if self.infoExtensions ~= nil and #self.infoExtensions > 0 then
				for i=#self.infoExtensions, 1, -1 do
					local infoExtension = self.infoExtensions[i];
					if infoExtension.setEventHelpElements ~= nil then
						hasEventElement = true;
					end;
					local height = infoExtension:getHeight();
					if height > 0 then
						infoExtensionTotalHeight = infoExtensionTotalHeight + height + self.lineOffsetY;			
					end;				
				end;
			end;		
		end;
		function setExtraHelpTextTotalHeight()
			for k, text in pairs(self.extraHelpTexts) do
				if k ~= nil and text ~= nil and text:len() > 0 then
					extraHelpTextTotalHeight = extraHelpTextTotalHeight + self.lineBg.height + self.lineOffsetY;
				end;
			end
		end;
		if hasComboCommands then
			comboHeight = comboHeight + self.comboBg.height + self.lineOffsetY;
		end;
		setEventsHelpElementsTotalHeight();
		setHelpExtensionTotalHeight();
		setInfoExtensionTotalHeight();
		setExtraHelpTextTotalHeight();
		if difHeight > 0 then
			helpExtensionTotalHeight = helpExtensionTotalHeight - difHeight;
		end;
		g_currentMission.hlUtils.helpMenuData.eventHelpElementHeight = eventHelpElementTotalHeight;
		g_currentMission.hlUtils.helpMenuData.helpExtensionHeight = helpExtensionTotalHeight;
		g_currentMission.hlUtils.helpMenuData.infoExtensionHeight = infoExtensionTotalHeight;
		g_currentMission.hlUtils.helpMenuData.extraHelpTextHeight = extraHelpTextTotalHeight;
		g_currentMission.hlUtils.helpMenuData.comboHeight = comboHeight;
		g_currentMission.hlUtils.helpMenuData.totalHeight = eventHelpElementTotalHeight + helpExtensionTotalHeight + infoExtensionTotalHeight + comboHeight + extraHelpTextTotalHeight;
		g_currentMission.hlUtils.helpMenuData.hasEventElement = hasEventElement;
		g_currentMission.hlUtils.helpMenuData.hasVehicle = self.vehicle ~= nil;
		g_currentMission.hlUtils.helpMenuData.hasVehicleSchema = self.vehicle ~= nil and self.vehicle.schemaOverlay ~= nil;
		
		local posX, posY = self:getPosition();
		g_currentMission.hlUtils.helpMenuData.posX = posX;
		g_currentMission.hlUtils.helpMenuData.posY = posY;
		g_currentMission.hlUtils.helpMenuData.offsetX = offsetX or 0;
		g_currentMission.hlUtils.helpMenuData.offsetY = offsetY or 0;
		g_currentMission.hlUtils.helpMenuData.textOffsetX = self.textOffsetX;
		g_currentMission.hlUtils.helpMenuData.textOffsetY = self.textOffsetY;
		g_currentMission.hlUtils.helpMenuData.lineHeight = self.lineBg.height;
		g_currentMission.hlUtils.helpMenuData.lineWidth = self.lineBg.width;
		g_currentMission.hlUtils.helpMenuData.lineComboHeight = self.comboBg.height;
		g_currentMission.hlUtils.helpMenuData.lineOffsetY = self.lineOffsetY;
		g_currentMission.hlUtils.helpMenuData.isVisible = self:getVisible();
		g_currentMission.hlUtils.helpMenuData.isPF = not g_currentMission.hlUtils.helpMenuData.isVisible and pf25; --update 1.01
	end;
	
	InputHelpDisplay.draw = Utils.prependedFunction(InputHelpDisplay.draw, hlUtils.preInputHelpDisplayDraw);
	
end;

function hlUtils:addOverlays() --default hlUtils Overlays
	if g_currentMission.hlUtils.textDisplay==nil then g_currentMission.hlUtils.textDisplay={};if g_currentMission.hlUtils.overlays == nil then g_currentMission.hlUtils.overlays={};end;g_currentMission.hlUtils.getDefaultBackground(g_currentMission.hlUtils.overlays, "txtDisplay", true);g_currentMission.hlUtils.setBackgroundColor(g_currentMission.hlUtils.overlays["txtDisplay"],g_currentMission.hlUtils.getColor("blackDisabled", true));end;
end;

function hlUtils:addFillTypesOverlays() --load global for all Mods.. (optional here)
	function loadIconFillTypes() 
		if g_fillTypeManager.fillTypes ~= nil then
			function isFillAnimals(index)		
				if g_fillTypeManager.categoryNameToFillTypes["ANIMAL"][index] ~= nil or g_fillTypeManager.categoryNameToFillTypes["HORSE"][index] ~= nil then return true;end;
				return false;
			end;			
			function getSubTypeAnimalName(index)
				local subTypeIndex = g_currentMission.animalSystem:getSubTypeIndexByFillTypeIndex(index)
				local subType = g_currentMission.animalSystem:getSubTypeByIndex(subTypeIndex)
				if subType ~= nil then					
					local subTypeName = "";
					local overlayTable = 0;
					if subType.visuals ~= nil and subType.visuals[1] ~= nil and subType.visuals[1].store ~= nil and subType.visuals[1].store.name ~= nil then subTypeName = "/".. subType.visuals[1].store.name;end;
					if subTypeName:len() > 0 then
						if subType.visuals[1].store.imageFilename ~= nil then
							overlayTable = g_currentMission.hlUtils.insertIcon( {modName="LS_FillTypes", groupName="subFillTypes", iconFile=subType.visuals[1].store.imageFilename, iconName=subType.visuals[1].store.name, setStateInArea=true} );
							g_currentMission.hlUtils.overlays["LS_FillTypes"]["subFillTypes"][overlayTable].index = subTypeIndex;
							g_currentMission.hlUtils.overlays["LS_FillTypes"]["subFillTypes"][overlayTable].masterIndex = index;
							g_currentMission.hlUtils.overlays["LS_FillTypes"]["subFillTypes"][overlayTable].isAnimal = true;
							g_currentMission.hlUtils.overlays["LS_FillTypes"]["subFillTypes"][overlayTable].isSubType = true;
							g_currentMission.hlUtils.overlays["LS_FillTypes"]["subFillTypes"][overlayTable].name = subType.name;
							g_currentMission.hlUtils.overlays["LS_FillTypes"]["subFillTypes"][overlayTable].title = subType.visuals[1].store.name;	
						end;
					end;
					return overlayTable, subTypeIndex, subTypeName;
				end;
				return 0, 0, "";
			end;
			for index, desc in pairs(g_fillTypeManager.fillTypes) do		
				if desc ~= nil and desc.name ~= nil and desc.hudOverlayFilename ~= nil and desc.hudOverlayFilename ~= "" then
					local overlayTable = g_currentMission.hlUtils.insertIcon( {modName="LS_FillTypes", groupName="fillTypes", iconFile=desc.hudOverlayFilename, iconName=desc.name, setStateInArea=true} );
					g_currentMission.hlUtils.overlays["LS_FillTypes"]["fillTypes"][overlayTable].index = desc.index;
					g_currentMission.hlUtils.overlays["LS_FillTypes"]["fillTypes"][overlayTable].isAnimal = isFillAnimals(desc.index);
					local subTypeName = "";					
					if g_currentMission.hlUtils.overlays["LS_FillTypes"]["fillTypes"][overlayTable].isAnimal then
						local subTypeIndex = 0;
						local overlayPos = 0;
						g_currentMission.hlUtils.overlays["LS_FillTypes"]["fillTypes"][overlayTable].isSubType = false;						
						overlayPos, subTypeIndex, subTypeName = getSubTypeAnimalName(desc.index);
						if subTypeIndex > 0 then g_currentMission.hlUtils.overlays["LS_FillTypes"]["fillTypes"][overlayTable].subTypeIndex = subTypeIndex;end;
						if overlayPos > 0 then g_currentMission.hlUtils.overlays["LS_FillTypes"]["fillTypes"][overlayTable].subTypeOverlay = overlayPos;end;
					end;					
					g_currentMission.hlUtils.overlays["LS_FillTypes"]["fillTypes"][overlayTable].name = desc.name;
					g_currentMission.hlUtils.overlays["LS_FillTypes"]["fillTypes"][overlayTable].title = desc.title.. subTypeName;					
				end;
			end;
		end;
	end;
	if g_currentMission.hlUtils.overlays == nil then g_currentMission.hlUtils.overlays = {};end;
	if g_currentMission.hlUtils.overlays["LS_FillTypes"] == nil or g_currentMission.hlUtils.overlays["LS_FillTypes"]["fillTypes"] == nil then loadIconFillTypes();end;
end;

function hlUtils:loadSaveXml()
	local file = getUserProfileAppPath().. "modSettings/HL/hlUtils.xml";
	if fileExists(file) then 		
		local Xml = loadXMLFile("_hlUtils_XML", file, "hlUtils");
		local xmlNameTag = ("hlUtils"):format(0);	
		if Xml ~= nil then
			if getXMLBool(Xml, xmlNameTag.. "#playerFrozenIsMouseOn") ~= nil then
				g_currentMission.hlUtils.playerFrozen = getXMLBool(Xml, xmlNameTag.. "#playerFrozenIsMouseOn");	
			end;			
			delete(Xml);
		end;		
	else
		if not hlUtils:getDetiServer() then			
			local file = getUserProfileAppPath().. "modSettings/HL/hlUtils.xml";
			local Xml = createXMLFile("_hlUtils_XML", file, "hlUtils");
			local xmlNameTag = ("hlUtils"):format(0);
			if Xml ~= nil then		
				setXMLBool(Xml, xmlNameTag.. "#playerFrozenIsMouseOn", g_currentMission.hlUtils.playerFrozen);				
				saveXMLFile(Xml);
				delete(Xml);
			end;
		end;
	end;
end;

function hlUtils:setFunction()

g_currentMission.hlUtils.globalFunction = {};
g_currentMission.hlUtils.modLoaded = {};
if g_currentMission.hlUtils.modLoad==nil then g_currentMission.hlUtils.modLoad=
function(modName)
	if modName == nil or g_currentMission.hlUtils.modLoaded[modName] ~= nil then return;end;
	g_currentMission.hlUtils.modLoaded[modName] = true;
end;end;

if g_currentMission.hlUtils.modUnLoad==nil then g_currentMission.hlUtils.modUnLoad=
function(modName)
	if modName == nil or g_currentMission.hlUtils.modLoaded[modName] == nil then return;end;
	g_currentMission.hlUtils.modLoaded[modName] = nil;
end;end;

if g_currentMission.hlUtils.loadVehicleOverlay==nil then g_currentMission.hlUtils.loadVehicleOverlay= --update 0.7
function(vehicle, storeItem)
	if vehicle == nil and storeItem == nil then return;end;
	local imageFilename = nil;
	if vehicle ~= nil and vehicle.getImageFilename ~= nil then imageFilename = vehicle:getImageFilename();elseif storeItem ~= nil then imageFilename = storeItem.imageFilename;end;
	if imageFilename ~= nil then		
		local overlayVehiclesGroup = nil;
		if g_currentMission.hlUtils.overlays ~= nil and g_currentMission.hlUtils.overlays["LS_Vehicles"] ~= nil and g_currentMission.hlUtils.overlays["LS_Vehicles"]["vehicles"] ~= nil then overlayVehiclesGroup = g_currentMission.hlUtils.overlays["LS_Vehicles"]["vehicles"];end;
		local overlayVehiclesByName = nil;
		if g_currentMission.hlUtils.overlays ~= nil and g_currentMission.hlUtils.overlays.byName["LS_Vehicles"] ~= nil and g_currentMission.hlUtils.overlays.byName["LS_Vehicles"]["vehicles"] ~= nil then overlayVehiclesByName = g_currentMission.hlUtils.overlays.byName["LS_Vehicles"]["vehicles"];end;		
		local vehicleTypeName = nil;
		if vehicle ~= nil then vehicleTypeName = vehicle.typeName;elseif storeItem ~= nil then vehicleTypeName = g_storeManager.speciesToSchema[storeItem.species].name;end;
		--if vehicle ~= nil then vehicleTypeName = vehicle.typeName;elseif storeItem ~= nil then vehicleTypeName = storeItem.species;end;
		local notLoad = vehicleTypeName == nil or string.find(vehicleTypeName:lower(), "train") or string.find(vehicleTypeName:lower(), "locomotive") or string.find(vehicleTypeName:lower(), "pallet");
		local vehicleName = nil;
		if vehicle ~= nil then vehicleName = tostring(vehicle.getName(vehicle));elseif storeItem ~= nil then vehicleName = tostring(storeItem.name);end;
		if vehicleName == nil or notLoad then return;end;
		if overlayVehiclesGroup == nil or overlayVehiclesByName == nil then
			g_currentMission.hlUtils.insertIcon( {modName="LS_Vehicles", groupName="vehicles", iconFile=imageFilename, iconName=vehicleName, setStateInArea=true} );
			return true;
		else
			local x = g_currentMission.hlUtils.getOverlay(overlayVehiclesGroup[overlayVehiclesByName[vehicleName]]);
			if x == nil then
				g_currentMission.hlUtils.insertIcon( {modName="LS_Vehicles", groupName="vehicles", iconFile=imageFilename, iconName=vehicleName, setStateInArea=true} );
				return true;
			end;
			return false;
		end;
	end;
end;end;

if g_currentMission.hlUtils.loadFillTypesOverlays==nil then g_currentMission.hlUtils.loadFillTypesOverlays=
function()
	hlUtils:addFillTypesOverlays();
end;end;

if g_currentMission.hlUtils.debugPrint==nil then g_currentMission.hlUtils.debugPrint=
function(modName)
	if modName == nil or type(modName) ~= "string" then return;end;
	if g_currentMission.hlUtils.debug ~= nil and g_currentMission.hlUtils.debug[modName] ~= nil then 
		local a=1;		
		for key,value in pairs(g_currentMission.hlUtils.debug) do
			for key1,value1 in pairs(value) do			
				print(tostring(a).. ".hl_Debug Error at ".. tostring(key).. " = ".. tostring(value1))			
				a=a+1;
			end;
		end;
	else		
		print("1.hl_Debug NOT Found Error at ".. tostring(modName))
	end;
end;end;

if g_currentMission.hlUtils.setDebug==nil then g_currentMission.hlUtils.setDebug=
function (argsMod, args1, errorTxt, args2, args3)	
	local limit = 50;
	if argsMod == nil or type(argsMod) ~= "string" then return;end;
	if g_currentMission.hlUtils.debug == nil then g_currentMission.hlUtils.debug = {};end;
	if g_currentMission.hlUtils.debug[argsMod] == nil then g_currentMission.hlUtils.debug[argsMod] = {};end;
	local errorString = "Trigger: ".. tostring(args1).. " -errorTxtCall: ".. tostring(errorTxt).. " -argsError: ".. tostring(args2).. " -resultError: ".. tostring(args3);
	local alreadyExists = false;
	if #g_currentMission.hlUtils.debug[argsMod] == 0 then 
		table.insert(g_currentMission.hlUtils.debug[argsMod], tostring(errorString));
	else
		if #g_currentMission.hlUtils.debug[argsMod] > limit then return;end;
		for key,value in pairs(g_currentMission.hlUtils.debug[argsMod]) do			
			if tostring(value) == errorString and string.len(value) == string.len(errorString) then alreadyExists=true;break;end;			
		end;		
		if not alreadyExists then table.insert(g_currentMission.hlUtils.debug[argsMod], tostring(errorString));end;
	end;	
end;end;

--ist args1 table vorhanden und args2 true dann return rootNode
if g_currentMission.hlUtils.isAvailable==nil then g_currentMission.hlUtils.isAvailable=function(table,rootNode)if table==nil or type(table)~="table" then return false,nil;end;for _, value in pairs(table) do if not rootNode or nil then return true,nil;end;return true,value.rootNode or nil;end;return false,nil;end;end;	

if g_currentMission.hlUtils.isNotGhostObject == nil then g_currentMission.hlUtils.isNotGhostObject=
function(objectId)
	if objectId == nil or objectId == 0 then return false;end;
	if g_currentMission.nodeToObject[objectId] ~= nil then
		return true;
	end;
	local id = getNumOfChildren(Utils.getNoNil(objectId, 0));
	if id ~= nil and id ~= 0 then 
		return true;
	end;
	return false;
end;end;

if g_currentMission.hlUtils.isObjectFound == nil then g_currentMission.hlUtils.isObjectFound=
function(object, item)		
	if object ~= nil and item then --g_currentMission:getNodeObject(object) --for items,later
		local objectId = object.rootNode or object.nodeId;
		if objectId ~= nil and g_currentMission.nodeToObject[objectId] ~= nil then
			if object.isa ~= nil and object:isa(Vehicle) then return true;end;
		end;		
	end;
	if object ~= nil and item == nil then
		local objectId = object.rootNode or object.nodeId;
		if objectId ~= nil and objectId ~= 0 then			
			local id = getNumOfChildren(Utils.getNoNil(objectId, 0));
			if id == nil or id == 0 then return false;end;return true;
		end;		
	end;
	return false;
end;end;

if g_currentMission.hlUtils.stringSplit==nil then g_currentMission.hlUtils.stringSplit=
function(txtString,delimiter,formatting)
	local result={};
	local from=1;
	if txtString==nil or delimiter==nil or type(txtString) ~= "string" or string.len(txtString) <= 1 then return result;end; --ab 0.71
	local delim_from,delim_to=string.find(txtString,delimiter,from,formatting);
	while delim_from do
		table.insert(result,string.sub(txtString,from,delim_from-1));
		from=delim_to+1;
		delim_from,delim_to=string.find(txtString,delimiter,from,formatting);
	end;
	table.insert(result,string.sub(txtString,from));
	return result;
end;end;

if g_currentMission.hlUtils.getProzentFillLevel==nil then g_currentMission.hlUtils.getProzentFillLevel=
function(fillLevel, capacity, getString)	
	if (getString == nil or getString) and (type(capacity) ~= "number" or type(fillLevel) ~= "number" or capacity <= 0) then return "0";end;
	if (getString == nil or getString) then return string.format("%1.0f", "".. tonumber(fillLevel)/tonumber(capacity)*100);else return fillLevel/capacity*100;end;
	return 0;
end;end;

if g_currentMission.hlUtils.getIngameMap==nil then g_currentMission.hlUtils.getIngameMap=
function()
	return Utils.getNoNil(g_gameSettings:getValue("ingameMapState"), 0) == 4;
end;end;

if g_currentMission.hlUtils.getIngameMapState==nil then g_currentMission.hlUtils.getIngameMapState=
function()
	return Utils.getNoNil(g_gameSettings:getValue("ingameMapState"), 1);
end;end;

if g_currentMission.hlUtils.getFullSize==nil then g_currentMission.hlUtils.getFullSize=
function(isPaused ,isOpen)	
	if (g_currentMission.paused and isPaused) or
		(g_gui:getIsGuiVisible() and isOpen) or 
		(g_currentMission.hud.ingameMessage.isGamePaused and isPaused) or 
		--(g_currentMission.inGameMenu.isOpen and isOpen) or		
		(g_currentMission.physicsPaused and isPaused) or
		(not g_currentMission.hud.isVisible) or 
		(g_currentMission.noHudApp ~= nil and g_currentMission.noHudApp) then 
		if g_currentMission.missionDynamicInfo.isMultiplayer and g_currentMission.manualPaused and isPaused and g_gameStateManager.gameState ~= 5 then return false;end;
		return true;
	end;
	return false;
end;end;

--args1 zahl, args2 invert (100 > oder kleiner als 100,95 etc.) return (1-7, 1 gut 7 schlecht)
if g_currentMission.hlUtils.getProzentColor==nil then g_currentMission.hlUtils.getProzentColor=function(prozent,invert)local color=1;if prozent==nil then return color;end;if (tonumber(prozent)<=100 and invert) then color=2;end;if (tonumber(prozent)>=25 and not invert) or (tonumber(prozent)<=75 and invert) then color=3;end;if (tonumber(prozent)>=50 and not invert) or (tonumber(prozent)<=50 and invert) then color=4;end;if (tonumber(prozent)>=75 and not invert) or (tonumber(prozent)<=25 and invert) then color=5;end;if (tonumber(prozent)>=95 and not invert) or (tonumber(prozent)<=5 and invert) then color=6;end;if (tonumber(prozent)>=100 and not invert) or (tonumber(prozent)<=0 and invert) then color=7;end;return color;end;end;
	
if g_currentMission.hlUtils.setBackgroundColor==nil then g_currentMission.hlUtils.setBackgroundColor=
function(overlay, color)
	if overlay ~= nil and overlay.overlayId ~= nil and overlay.overlayId > 0 and type(color) == "table" then 
		setOverlayColor(overlay.overlayId, unpack(color));		
	end;	
end;end;

if g_currentMission.hlUtils.setOverlay==nil then g_currentMission.hlUtils.setOverlay=
function(overlay, posX, posY, width, height)
	if overlay ~= nil and overlay.overlayId ~= nil then
		if width ~= nil then overlay.width = width;end;
		if height ~= nil then overlay.height = height;end;
		if posX ~= nil then overlay.x = posX;end;
		if posY ~= nil then overlay.y = posY;end;		
	end;	
end;end;
if g_currentMission.hlUtils.deleteOverlays==nil then g_currentMission.hlUtils.deleteOverlays=
function(overlaysTable, debugPrint, debugTxt)
	if overlaysTable ~= nil then		
		for _index,v in pairs (overlaysTable) do
			local overlay = overlaysTable[_index];
			if overlay ~= nil and overlay.overlayId ~= nil then				
				if debugPrint then
					local infoTxt = "";
					if debugTxt ~= nil then infoTxt = " (".. tostring(debugTxt).. ")";end;
					print("Delete Overlay: ".. tostring(overlay.iconName or _index).. tostring(infoTxt));
				end;
				overlay:delete();
				overlay = nil;
			end;
		end;		
	end;	
end;end;
if g_currentMission.hlUtils.getDefaultBackground==nil then g_currentMission.hlUtils.getDefaultBackground=
function(overlaysTable, overlayName, newOther) 
	if overlaysTable~=nil and overlayName~=nil then	
		if newOther ~= nil and newOther then 
			overlaysTable[overlayName] = Overlay.new(g_baseUIFilename, 0, 0, 0, 0);
			overlaysTable[overlayName]:setUVs(g_colorBgUVs);
			overlaysTable[overlayName]:setColor(0, 0, 0, 0.65);			
		else
			overlaysTable[overlayName] = Overlay.new(HUD.MENU_BACKGROUND_PATH, 0, 0, 0, 0);
		end;
	end;
end;end;
if g_currentMission.hlUtils.getDefaultNewBackground==nil then g_currentMission.hlUtils.getDefaultNewBackground=
function(overlaysTable, overlayName, newOther) 
	if overlaysTable~=nil and overlayName~=nil then	
		if newOther ~= nil and newOther then 
			overlaysTable[overlayName] = Overlay.new("dataS/menu/gui.png", 0, 0, 0, 0);
			overlaysTable[overlayName]:setUVs( {0.0673828125, 0.42236328125, 0.0673828125, 0.4541015625, 0.068603515625, 0.42236328125, 0.068603515625, 0.4541015625} );
			overlaysTable[overlayName]:setColor(0, 0, 0, 0.65);			
		else
			overlaysTable[overlayName] = Overlay.new(HUD.MENU_BACKGROUND_PATH, 0, 0, 0, 0);
		end;
	end;
end;end;
if g_currentMission.hlUtils.getOverlay==nil then g_currentMission.hlUtils.getOverlay=
function(overlay)	
	if overlay ~= nil and overlay.overlayId then
		return overlay.x, overlay.y, overlay.width, overlay.height;			
	end;
	return nil;
end;end;

if g_currentMission.hlUtils.setOverlayUVsPx==nil then g_currentMission.hlUtils.setOverlayUVsPx=
function(overlay, UVs, textureSizeX, textureSizeY)	
	if overlay.overlayId and overlay.currentUVs == nil or overlay.currentUVs ~= UVs then
		local leftX, bottomY, rightX, topY = unpack(UVs);
		local fromTop = false;
		if topY < bottomY then
			fromTop = true;
		end;
		local leftXNormal = leftX / textureSizeX;
		local rightXNormal = rightX / textureSizeX;
		local bottomYNormal = bottomY / textureSizeY;
		local topYNormal = topY / textureSizeY;
		if fromTop then
			bottomYNormal = 1 - bottomYNormal;
			topYNormal = 1 - topYNormal;
		end;
		setOverlayUVs(overlay.overlayId, leftXNormal,bottomYNormal, leftXNormal,topYNormal, rightXNormal,bottomYNormal, rightXNormal,topYNormal);		
		overlay.currentUVs = UVs;
	end;
end;end;

if g_currentMission.hlUtils.overlayOverlap==nil then g_currentMission.hlUtils.overlayOverlap=
function(overlay1, overlay2, txt, optiSize)	
	local difWidth = 1 / g_screenWidth;
	local difHeight = 1 / g_screenHeight;
	local box1x = overlay1.x;	
	local box1y = overlay1.y;
	local box1w = overlay1.width-difWidth;
	local box1h = overlay1.height-difHeight;
	local box2x = overlay2.x;	
	local box2y = overlay2.y;
	local box2w = overlay2.width;
	local box2h = overlay2.height;
	if txt then
		box2w = getTextWidth(optiSize, utf8Substr(txt, 0))-difWidth;
		box2h = getTextHeight(optiSize, utf8Substr(txt, 0))-difHeight;
	else
		box2w = box2w-difWidth;
		box2h = box2h-difHeight;
	end;	
	if box1x >= box2x + box2w or -- Is box1 on the right side of box2?
	   box1y >= box2y + box2h or -- Is box1 under box2?
	   box2x >= box1x + box1w or -- Is box2 on the right side of box1?
	   box2y >= box1y + box1h    -- Is b2 under b1?
	then
		return false; 
	else
		return true;
	end;	
end;end;

if g_currentMission.hlUtils.cloneOverlay == nil then g_currentMission.hlUtils.cloneOverlay=
function(overlay, cloneOverlay)
	local overlayId = overlay.overlayId;
	local cloneOverlayTable = g_currentMission.hlUtils.getTableCopy(cloneOverlay);	
	overlay = cloneOverlayTable;
	overlay.overlayId = overlayId;
	--overlay.currentUVs = cloneOverlay.uvs;
	setOverlayUVs(overlayId, unpack(cloneOverlay.uvs));
	overlay.isCloneOverlay = true;
end;end;

if g_currentMission.hlUtils.getMaxIconWidth==nil then g_currentMission.hlUtils.getMaxIconWidth=
function(maxWidth, iconWidth, roundUp) 
	if roundUp == nil or not roundUp then
		return math.floor(maxWidth/iconWidth, -0.5);
	else
		return math.ceil(maxWidth/iconWidth);
	end;
end;end;

if g_currentMission.hlUtils.getMaxIconHeight==nil then g_currentMission.hlUtils.getMaxIconHeight=
function(maxHeight, iconHeight, roundDown)
	if roundDown == nil or roundDown then
		return math.floor(maxHeight/iconHeight, -0.5);
	else
		return math.ceil(maxHeight/iconHeight);
	end;
end;end;

if g_currentMission.hlUtils.setStateInArea == nil then g_currentMission.hlUtils.setStateInArea=
function (overlay, delete)
	if overlay == nil then return;end;
	if delete == nil or delete == false then
		overlay.mouseInArea = function() return not g_currentMission.hlUtils.dragDrop.on and g_currentMission.hlUtils.isMouseCursor and g_currentMission.hlUtils.mouseIsInArea(nil, nil, unpack( {overlay.x, overlay.x+overlay.width, overlay.y, overlay.y+overlay.height} ));end;
	else
		overlay.mouseInArea = function() return false;end;
	end;
end;end;

if g_currentMission.hlUtils.getNormalUVs==nil then g_currentMission.hlUtils.getNormalUVs=
function (formatO, sW, sH, pos1, pos2, dif) --default 64x64 area Overlay and default dds 512x512
	local setDefaultS = false;
	if sW == 0 or sH == 0 then sW=512;sH=512;end;
	if formatO == 0 then formatO = 64;end;
	if pos2 == nil or pos2 == 0 then pos2 = pos1;end;
	if dif == nil then dif = 0.8;end;
	local line = 1;
	local linePos = pos1;
	local startPos = pos1*formatO-formatO;		
	local endPos = pos2*formatO;
	if startPos >= sW then 
		for l=2, sH/formatO do
			if startPos < sW*l then line = l;break;end;
		end;
		local tempLinePos = (sW/formatO)-((sW/formatO*line)-pos1);		
		for lp=1, sW/formatO do
			if lp == tempLinePos then linePos = lp;break;end;			
		end;
		startPos = linePos*formatO-formatO;
		if pos1 ~= pos2 then
			endPos = linePos*(formatO*(pos2-pos1+1));
		else
			endPos = linePos*formatO;
		end;
	end;	
	return { {startPos+(dif), formatO*line-(dif), endPos-(dif), formatO*line-formatO+(dif)}, sW, sH };	
end;end;

if g_currentMission.hlUtils.insertIcons == nil then g_currentMission.hlUtils.insertIcons=
function(args)
	if args == nil or type(args) ~= "table" or args.xmlTagName == nil or args.modName == nil or args.groupName == nil or args.iconFile == nil or args.xmlFile == nil then return nil;end;
	local icons = nil;	
	if type(args.loadIcons) == "table" then icons = args.loadIcons;end; 
	local iconFilePath, xmlFilePath = g_currentMission.hlUtils.checkFilePath(args.iconFile, args.xmlFile, args.modDir);	
	if iconFilePath == nil or xmlFilePath == nil then return nil;end;
	local iconOverlayTable = nil;
	local formatO = 0; --default 64X64 area
	local sW = 0; --default 512 dds file width
	local sH = 0; --default 512 dds file height
	if args.fileFormat ~= nil and type(args.fileFormat) == "table" then
		formatO = args.fileFormat[1] or 0;
		sW = args.fileFormat[2] or 0;
		sH = args.fileFormat[3] or 0;
	end;
	if type(formatO) ~= "number" or formatO == nil then formatO = 0;end;if type(sW) ~= "number" or sW == nil then sW = 0;end;if type(sH) ~= "number" or sH == nil then sH = 0;end;
	-----------
	
	------------	
	if args.iconTable == nil then		
		if g_currentMission.hlUtils.overlays == nil then g_currentMission.hlUtils.overlays = {};end;
		if g_currentMission.hlUtils.overlays[args.modName] == nil then g_currentMission.hlUtils.overlays[args.modName] = {};end;
		if g_currentMission.hlUtils.overlays[args.modName][args.groupName] == nil then g_currentMission.hlUtils.overlays[args.modName][args.groupName] = {};end;
		if g_currentMission.hlUtils.overlays.byName == nil then g_currentMission.hlUtils.overlays.byName = {};end;
		if g_currentMission.hlUtils.overlays.byName[args.modName] == nil then g_currentMission.hlUtils.overlays.byName[args.modName] = {};end;
		if g_currentMission.hlUtils.overlays.byName[args.modName][args.groupName] == nil then g_currentMission.hlUtils.overlays.byName[args.modName][args.groupName] = {};end;
		iconOverlayTable = g_currentMission.hlUtils.overlays[args.modName][args.groupName];	
	else
		if args.iconTable[args.modName] == nil then args.iconTable[args.modName] = {};end;
		if args.iconTable[args.modName][args.groupName] == nil then args.iconTable[args.modName][args.groupName] = {};end;
		if args.iconTable.byName == nil then args.iconTable.byName = {};end;
		if args.iconTable.byName[args.modName] == nil then args.iconTable.byName[args.modName] = {};end;
		if args.iconTable.byName[args.modName][args.groupName] == nil then args.iconTable.byName[args.modName][args.groupName] = {};end;
		iconOverlayTable = args.iconTable[args.modName][args.groupName];
	end;
	local Xml = loadXMLFile("LoadOverlays_XML", xmlFilePath);
	local xmlNameTag = tostring(args.xmlTagName);
	local loadIcons = 0;		
	local firstIcon = #iconOverlayTable+1;
	local endIcon = nil;	
	-----------------------------
	function generateOverlay(int)
		iconOverlayTable[#iconOverlayTable+1] = Overlay.new(iconFilePath, 0, 0, 0, 0);
		local overlay = iconOverlayTable[#iconOverlayTable];		
		local iconPlaceB = int;
		local iconPlaceE = nil;
		local iconDifWH = nil;
		local iconFormatO = nil;
		local iconPlace = getXMLInt(Xml, xmlNameTag.."#placeB");
		if iconPlace ~= nil then iconPlaceB = iconPlace;end;
		local iconPlaceEnd = getXMLInt(Xml, xmlNameTag.."#placeE");
		if iconPlaceEnd ~= nil then iconPlaceE = iconPlaceEnd;end;
		local iconPlaceDifWH = getXMLFloat(Xml, xmlNameTag.."#placeDifWH"); --update 1.00
		if iconPlaceDifWH ~= nil then iconDifWH = iconPlaceDifWH;end;
		iconPlaceFormatO = getXMLInt(Xml, xmlNameTag.."#placeFormatO");
		if iconPlaceFormatO ~= nil then  iconFormatO = iconPlaceFormatO;else iconFormatO = formatO;end;		
		g_currentMission.hlUtils.setOverlayUVsPx(overlay, unpack(g_currentMission.hlUtils.getNormalUVs(iconFormatO, sW, sH, iconPlaceB, iconPlaceE, iconDifWH))); --update 1.00
		local iconName = getXMLString(Xml, xmlNameTag.."#name");
		if args.iconTable == nil then
			g_currentMission.hlUtils.overlays.byName[args.modName][args.groupName][iconName] = #iconOverlayTable;
		else
			args.iconTable.byName[args.modName][args.groupName][iconName] = #iconOverlayTable;
		end;
		overlay.iconPlaceB = iconPlaceB;
		overlay.iconPlaceE = iconPlaceE;
		--overlay.saveArgs = args;
		overlay.iconName = tostring(iconName);
		overlay.modDir = tostring(args.modDir);
		overlay.xmlTagName = tostring(args.xmlTagName);
		overlay.modName = tostring(args.modName);
		overlay.groupName = tostring(args.groupName);
		overlay.infoTxt = Utils.getNoNil(getXMLString(Xml, xmlNameTag.."#infoTxt"), nil);
		overlay.isBlinking = false;
		overlay.mouseInArea = function()return false;end;		
		local iconType = getXMLInt(Xml, xmlNameTag.."#type");		
		if iconType == nil then iconType = 1;end;		
		overlay.iconType = iconType;
		--old ls22--
		overlay.ownValue = "";
		if getXMLString(Xml, xmlNameTag.."#ownValue") then
			overlay.ownValue = getXMLString(Xml, xmlNameTag.."#ownValue");
		end;
		--old ls22--
		--new--
		overlay.ownTable = {};
		if getXMLBool(Xml, xmlNameTag.."#setOwnTable") ~= nil and getXMLBool(Xml, xmlNameTag.."#setOwnTable") then
			local intT = 0;
			while true do
				local groupNameTag = (xmlNameTag.. ".ownTable(%d)"):format(intT);
				if groupNameTag == nil or getXMLString(Xml, groupNameTag.. "#name") == nil or not getXMLString(Xml, groupNameTag.. "#name") or intT > 10 then break;else
					overlay.ownTable[getXMLString(Xml, groupNameTag.."#name")] = {};
					local ownTable = overlay.ownTable[getXMLString(Xml, groupNameTag.."#name")];
					--values--
					local intV = 0;
					while true do
						local typGroupNameTag = (groupNameTag.. ".values(%d)"):format(intV);
						if typGroupNameTag == nil or getXMLString(Xml, typGroupNameTag.. "#typ") == nil or not getXMLString(Xml, typGroupNameTag.. "#typ") or getXMLString(Xml, typGroupNameTag.. "#name") == nil or not getXMLString(Xml, typGroupNameTag.. "#name") or getXMLString(Xml, typGroupNameTag.. "#value") == nil or not getXMLString(Xml, typGroupNameTag.. "#value") or intV > 10 then break;else
							local typ = getXMLString(Xml, typGroupNameTag.. "#typ");
							local name = getXMLString(Xml, typGroupNameTag.. "#name");
							local isFloat = typ == "float";local isString = typ == "string";local isInt = typ == "int";local isBool = typ == "bool";local isFunc = typ == "func";
							if isFloat then ownTable[name] = getXMLFloat(Xml, typGroupNameTag.. "#value");
							elseif isString then ownTable[name] = getXMLString(Xml, typGroupNameTag.. "#value");
							elseif isInt then ownTable[name] = getXMLInt(Xml, typGroupNameTag.. "#value");
							elseif isBool then ownTable[name] = getXMLBool(Xml, typGroupNameTag.. "#value");
							elseif isFunc then local func = g_currentMission.hlUtils.getFunction(getXMLString(Xml, typGroupNameTag.."#value"));if func ~= nil then ownTable[name] = func;end;end;
							intV = intV+1;
						end;
					end;
					--values
					intT = intT+1;
				end;
			end;			
		end;
		--new--
		if (getXMLBool(Xml, xmlNameTag.."#setStateInArea") ~= nil and getXMLBool(Xml, xmlNameTag.."#setStateInArea")) or (args.setStateInArea ~= nil and args.setStateInArea) then
			g_currentMission.hlUtils.setStateInArea(overlay);
		end;
		if getXMLString(Xml, xmlNameTag.."#onDraw") then
			local func = g_currentMission.hlUtils.getFunction(getXMLString(Xml, xmlNameTag.."#onDraw"))
			if func ~= nil then overlay.onDraw = func;end;
		end;		
		if getXMLString(Xml, xmlNameTag.."#action") then
			local func = g_currentMission.hlUtils.getFunction(getXMLString(Xml, xmlNameTag.."#action"))
			if func ~= nil then overlay.action = func;end;
		end;		
		local iconRotation = getXMLFloat(Xml, xmlNameTag.."#rotation");
		if iconRotation ~= nil then 
			setOverlayRotation(overlay.overlayId, iconRotation, 0+overlay.width/2, 0+overlay.height/2);	
		end;		
		local iconColorState = false;
		
		
		if iconType == 2 or iconType == 3 then
			local iconColor = getXMLString(Xml, xmlNameTag.."#color");			
			if iconColor ~= nil then
				local color = g_currentMission.hlUtils.getColor(tostring(iconColor), true);				
				local iconTransparent = getXMLFloat(Xml, xmlNameTag.."#transparent"); 
				if iconTransparent then
					color[4] = iconTransparent;
				end;
				iconColorState = true;
				overlay.colorState = color;
				g_currentMission.hlUtils.setBackgroundColor(overlay, color);				
			end;		
			if iconColor == nil then
				local iconColorDefault = getXMLString(Xml, xmlNameTag.."#defaultColor");
				if iconColorDefault ~= nil then
					local color = g_currentMission.hlUtils.getColor(tostring(iconColorDefault), true);					
					overlay.defaultColor = tostring(iconColorDefault);
					if not iconColorState then overlay.colorState = color;iconColorState = true;end;					
				end;
			end;			
		end;
		if not iconColorState then overlay.colorState = {1,1,1,1};end;
		endIcon = #iconOverlayTable;
	end;
	-----------------------------	
	if icons == nil and getXMLInt(Xml, xmlNameTag.."#load") ~= nil then
		loadIcons = getXMLInt(Xml, xmlNameTag.."#load");			
		for a=1, loadIcons do
			xmlNameTag = (tostring(args.xmlTagName).. ".icon(%d)"):format(a-1);
			if xmlNameTag == nil then break;end;
			if getXMLString(Xml, xmlNameTag.."#name") and a <= loadIcons then				
				generateOverlay(a);								
			else
				break;
			end;
		end;		
	elseif icons ~= nil then		
		for a=1, #icons do
			local iconNumber = icons[a];
			if iconNumber ~= nil and iconNumber <= 64 then
				xmlNameTag = (tostring(args.xmlTagName).. ".icon(%d)"):format(iconNumber-1);
				if xmlNameTag == nil then break;end;
				if getXMLString(Xml, xmlNameTag.."#name") then				
					generateOverlay(iconNumber);								
				else
					break;
				end;
			end;
		end;		
	end;
	return firstIcon, endIcon;
end;end;
if g_currentMission.hlUtils.insertIcon == nil then g_currentMission.hlUtils.insertIcon= --simple function ! VI and MOH ! FillType Icons, Vehicle Icons or... (not scale ...UVsPx)
function(args)
	if args == nil or type(args) ~= "table" or args.modName == nil or args.groupName == nil or args.iconFile == nil or args.iconName == nil then return nil;end;
	-----------
	local iconOverlayTable = nil;
	if args.iconTable == nil then
		if g_currentMission.hlUtils.overlays == nil then g_currentMission.hlUtils.overlays = {};end;
		if g_currentMission.hlUtils.overlays[args.modName] == nil then g_currentMission.hlUtils.overlays[args.modName] = {};end;
		if g_currentMission.hlUtils.overlays[args.modName][args.groupName] == nil then g_currentMission.hlUtils.overlays[args.modName][args.groupName] = {};end;
		if g_currentMission.hlUtils.overlays.byName == nil then g_currentMission.hlUtils.overlays.byName = {};end;
		if g_currentMission.hlUtils.overlays.byName[args.modName] == nil then g_currentMission.hlUtils.overlays.byName[args.modName] = {};end;
		if g_currentMission.hlUtils.overlays.byName[args.modName][args.groupName] == nil then g_currentMission.hlUtils.overlays.byName[args.modName][args.groupName] = {};end;
		iconOverlayTable = g_currentMission.hlUtils.overlays[args.modName][args.groupName];
	end;
	------------	
	iconOverlayTable[#iconOverlayTable+1] = Overlay.new(args.iconFile, 0, 0, 0, 0);
	if args.iconTable == nil then
		g_currentMission.hlUtils.overlays.byName[args.modName][args.groupName][args.iconName] = #iconOverlayTable;
	else
		args.iconTable.byName[args.modName][args.groupName][args.iconName] = #iconOverlayTable;
	end;
	if args.setStateInArea ~= nil and setStateInArea then g_currentMission.hlUtils.setStateInArea(iconOverlayTable[#iconOverlayTable]);else iconOverlayTable[#iconOverlayTable].mouseInArea = function()return false;end;end;
	return #iconOverlayTable;
end;end;
	
g_currentMission.hlUtils.colorIntern = {   --RGB		
	ownDemand =     	{   4/255,  98/255, 180/255, 1.00 };
	transparent =   	{  33/255,  48/255,  24/255, 0.50 };	
	darkYellow =   		{ 255/255, 161/255,  17/255, 1.00 };
	darkYellowOff =  	{ 255/255, 161/255,  17/255, 0.75 };
	white =         	{ 255/255, 255/255, 255/255, 1.00 };	
	whiteMatt = 	    { 255/255, 255/255, 255/255, 0.90 };
	whiteDisabled = 	{ 255/255, 255/255, 255/255, 0.75 };
	whiteInactive = 	{ 255/255, 255/255, 255/255, 0.50 };
	whiteOff = 			{ 255/255, 255/255, 255/255, 0.20 };
	whiteOff1 = 		{ 255/255, 255/255, 255/255, 0.10 };
	pulldownWhite =     { 255/255, 255/255, 220/255, 1.00 };
	hover =         	{   4/255,  98/255, 180/255, 1.00 };
	hoverBestPrice =	{   4/255,  98/255, 180/255, 0.75 };
	darkBlue =	 		{ 	0/255,   0/255, 139/255, 1.00 };
	blue =	 			{ 	0/255,   0/255, 255/255, 1.00 };
	midnightBlue =		{  25/255,  25/255, 112/255, 1.00 };
	royalBlue =			{  65/255, 105/255, 225/255, 1.00 };
	activeGreen =   	{  43/255, 205/255,  10/255, 1.00 }; 
	activeRed =    	 	{ 153/255,  22/255,  19/255, 1.00 }; 
	closeRed =      	{ 116/255,   0/255,   0/255, 1.00 }; 
	warningRed =    	{ 222/255,   2/255,   3/255, 1.00 };
	red =      			{ 255/255,   0/255,   0/255, 1.00 };
	redDisabled =   	{ 255/255,   0/255,   0/255, 0.75 };
	darkRed = 			{ 205/255,   0/255,   0/255, 1.00 };
	shadow =        	{   4/255,   4/255,   4/255, 1.00 }; 
	textDark =      	{   1/255,   1/255,   1/255, 1.00 };
	yellow =        	{ 255/255, 255/255,   0/255, 1.00 };
	yellowDisabled =	{ 255/255, 255/255,   0/255, 0.75 };
	yellowGreen =		{ 154/255, 205/255,  50/255, 1.00 };
	yellow1 =			{ 238/255, 221/255, 130/255, 1.00 };
	yellow2 =			{ 238/255, 238/255,   0/255, 1.00 };
	gold =				{ 255/255, 215/255,   0/255, 1.00 };
	green =        		{ 	0/255, 255/255,   0/255, 1.00 };
	darkOliveGreen =    {  85/255, 107/255,  47/255, 1.00 };
	greenDisabled = 	{ 	0/255, 255/255,   0/255, 0.75 };
	darkGreen = 		{ 	0/255, 100/255,   0/255, 1.00 };
	lightGreen =   		{ 144/255, 238/255, 144/255, 1.00 };
	chartreuse4 =		{  69/255,  139/255,  0/255, 1.00 };
	happylooser =   	{ 143/255, 188/255, 143/255, 1.00 };---
	happylooserOff= 	{ 143/255, 188/255, 143/255, 0.75 };---
	gray = 				{ 190/255, 190/255, 190/255, 1.00 };
	darkGray = 			{  87/255,  87/255,  87/255, 1.00 };
	darkGrayInactive = 	{  87/255,  87/255,  87/255, 0.50 };
	darkGrayOff = 		{  87/255,  87/255,  87/255, 0.20 };
	darkGrayOff1 = 		{  87/255,  87/255,  87/255, 0.10 };
	pulldownGray = 		{  34/255,  34/255,  34/255, 1.00 };
	black =        		{ 	0/255,   0/255,   0/255, 1.00 };
	blackDisabled = 	{ 	0/255,   0/255,   0/255, 0.75 };
	blackInactive = 	{ 	0/255,   0/255,   0/255, 0.50 };
	blackOff = 			{ 	0/255,   0/255,   0/255, 0.20 };
	orange =        	{ 255/255, 165/255,   0/255, 1.00 };
	orangeRed =        	{ 255/255,  55/255,   0/255, 1.00 };
	khaki =         	{ 240/255, 230/255, 140/255, 1.00 };
	khakiDisabled =     { 240/255, 230/255, 140/255, 0.75 };
	khakiInactive =     { 240/255, 230/255, 140/255, 0.50 };
	ls15 =          	{   0/255, 255/255, 255/255, 1.00 };
	ls15Disabled =  	{   0/255, 255/255, 255/255, 0.75 };
	ls15Inactive =  	{   0/255, 255/255, 255/255, 0.50 };
	mangenta =  		{ 255/255, 	 0/255, 255/255, 1.00 };
	deepPink =  		{ 255/255, 020/255, 147/255, 1.00 };
	purple =  			{ 160/255, 032/255, 240/255, 1.00 };
	ls22 =  			{  0.0003,  0.5647,  0.9822, 1.00 };
	ls22Disabled =  	{  0.0003,  0.5647,  0.9822, 0.75 };
	ls22Inactive =  	{  0.0003,  0.5647,  0.9822, 0.50 };
	ls25 =  			{  0.2384,	0.4621,  0.0015, 1.00 }; 
	ls25Disabled =  	{  0.2384,	0.4621,  0.0015, 0.75 };
	ls25Inactive =  	{  0.2384,	0.4621,  0.0015, 0.50 };
	ls25active 	 =  	{ 118/255, 185/255,   0/255, 1.00 };
	ls25bg 	 	 =  	{ 	0/255, 	 0/255,   0/255, 0.65 };
	ad	 	 	 =  	{  16/255, 190/255, 107/255, 1.00 };
	cp	 	 	 =  	{ 205/255, 206/255,   0/255, 1.00 };
};

g_currentMission.hlUtils.colorDefault = {	--RGB	
	darkYellow =   		{ 255/255, 161/255,  17/255, 1.00 };
	darkYellowOff =  	{ 255/255, 161/255,  17/255, 0.75 };
	white =         	{ 255/255, 255/255, 255/255, 1.00 };	
	whiteInactive = 	{ 255/255, 255/255, 255/255, 0.75 };
	whiteDisabled = 	{ 255/255, 255/255, 255/255, 0.15 };
	whiteOff = 			{ 255/255, 255/255, 255/255, 0.20 };
	whiteOff1 = 		{ 255/255, 255/255, 255/255, 0.10 };
	hover =         	{   4/255,  98/255, 180/255, 1.00 };
	hoverBestPrice =	{   4/255,  98/255, 180/255, 0.70 };
	darkBlue =	 		{ 	0/255,   0/255, 139/255, 1.00 };
	blue =	 			{ 	0/255,   0/255, 255/255, 1.00 };
	activeGreen =   	{  43/255, 205/255,  10/255, 1.00 }; 
	activeRed =    	 	{ 153/255,  22/255,  19/255, 1.00 }; 
	closeRed =      	{ 116/255,   0/255,   0/255, 1.00 }; 
	warningRed =    	{ 222/255,   2/255,   3/255, 1.00 };
	red =      			{ 255/255,   0/255,   0/255, 1.00 };
	redDisabled =   	{ 255/255,   0/255,   0/255, 0.75 };
	darkRed = 			{ 205/255,   0/255,   0/255, 1.00 };
	shadow =        	{   4/255,   4/255,   4/255, 1.00 }; 
	textDark =      	{   1/255,   1/255,   1/255, 1.00 };
	yellow =        	{ 255/255, 255/255,   0/255, 1.00 };
	yellowDisabled =	{ 255/255, 255/255,   0/255, 0.75 };
	yellowGreen =		{ 154/255, 205/255,  50/255, 1.00 };
	yellow1 =			{ 238/255, 221/255, 130/255, 1.00 };
	gold =				{ 255/255, 215/255,   0/255, 1.00 };
	green =        		{ 	0/255, 255/255,   0/255, 1.00 };
	darkOliveGreen =    {  85/255, 107/255,  47/255, 1.00 };
	greenDisabled = 	{ 	0/255, 255/255,   0/255, 0.75 };
	darkGreen = 		{ 	0/255, 100/255,   0/255, 1.00 };
	lightGreen =   		{ 144/255, 238/255, 144/255, 1.00 };
	chartreuse4 =		{  69/255,  139/255,  0/255, 1.00 };
	happylooser =   	{ 143/255, 188/255, 143/255, 1.00 };---
	happylooserOff= 	{ 143/255, 188/255, 143/255, 0.75 };---
	gray = 				{ 190/255, 190/255, 190/255, 1.00 };
	darkGray = 			{  87/255,  87/255,  87/255, 1.00 };
	darkGrayInactive = 	{  87/255,  87/255,  87/255, 0.50 };
	darkGrayOff = 		{  87/255,  87/255,  87/255, 0.20 };
	darkGrayOff1 = 		{  87/255,  87/255,  87/255, 0.10 };
	black =        		{ 	0/255,   0/255,   0/255, 1.00 };
	blackDisabled = 	{ 	0/255,   0/255,   0/255, 0.75 };
	blackInactive = 	{ 	0/255,   0/255,   0/255, 0.50 };
	blackOff = 			{ 	0/255,   0/255,   0/255, 0.20 };
	orange =        	{ 255/255, 165/255,   0/255, 1.00 };
	orangeRed =        	{ 255/255,  55/255,   0/255, 1.00 };
	khaki =         	{ 240/255, 230/255, 140/255, 1.00 };
	khakiDisabled =     { 240/255, 230/255, 140/255, 0.75 };
	khakiInactive =     { 240/255, 230/255, 140/255, 0.50 };
	ls15 =          	{   0/255, 255/255, 255/255, 1.00 };
	ls15Disabled =  	{   0/255, 255/255, 255/255, 0.75 };
	mangenta =  		{ 255/255, 	 0/255, 255/255, 1.00 }; 
	deepPink =  		{ 255/255, 020/255, 147/255, 1.00 };
	purple =  			{ 160/255, 032/255, 240/255, 1.00 };
	ls22 =  			{  0.0003,  0.5647,  0.9822, 1.00 };
	ls22Disabled =  	{  0.0003,  0.5647,  0.9822, 0.75 };
	ls22Inactive =  	{  0.0003,  0.5647,  0.9822, 0.50 };
	ls25 =  			{  0.2384,	0.4621,  0.0015, 1.00 };
	ls25Disabled =  	{  0.2384,	0.4621,  0.0015, 0.75 };
	ls25Inactive =  	{  0.2384,	0.4621,  0.0015, 0.50 };
	ls25active 	 =  	{ 118/255, 185/255,   0/255, 1.00 };
	ls25bg 	 	 =  	{ 	0/255, 	0/255,    0/255, 0.65 };
	ad	 	 	 =  	{  16/255, 190/255, 107/255, 1.00 };
	cp	 	 	 =  	{ 205/255, 206/255,   0/255, 1.00 };
};

g_currentMission.hlUtils.colorProzent = {[1]="white", [2]="green", [3]="yellowGreen", [4]="yellow", [5]="orange", [6]="orangeRed", [7]="red"}; --1 default return hl_ 
g_currentMission.hlUtils.colorExtern = {};

if g_currentMission.hlUtils.getColorProzentName==nil then g_currentMission.hlUtils.getColorProzentName=
function(prozentColor)
	return g_currentMission.hlUtils.colorProzent[prozentColor];
end;end;

if g_currentMission.hlUtils.getColorProzent==nil then g_currentMission.hlUtils.getColorProzent= --update 0.7 new (t)
function(prozentColor, intern, otherColor, t)	
	return g_currentMission.hlUtils.getColor(g_currentMission.hlUtils.colorProzent[prozentColor], intern or false, otherColor, t);
end;end;

if g_currentMission.hlUtils.getColor==nil then g_currentMission.hlUtils.getColor= --update 0.7 new (t)
function(name, intern, otherColor, t)
	local color = nil;
	local defaultColor = { 255/255, 255/255, 255/255, 1.00 }; --white
	if otherColor ~= nil then defaultColor = otherColor;else if t ~= nil and type(t) == "number" then defaultColor[4] = t;end;end;	
	if intern then
		if g_currentMission.hlUtils.colorIntern[name] ~= nil then 
			color = { unpack(g_currentMission.hlUtils.colorIntern[name]) };
			if t ~= nil and type(t) == "number" then color[4] = t;end;
			return color;
		end;
		if g_currentMission.hlUtils.colorIntern[name] == nil then return defaultColor;end;
	else
		if g_currentMission.hlUtils.colorExtern[name] ~= nil then 
			color = { unpack(g_currentMission.hlUtils.colorExtern[name]) };
			if t ~= nil and type(t) == "number" then color[4] = t;end;
			return color;
		end;
		if g_currentMission.hlUtils.colorExtern[name] == nil then return defaultColor;end;
	end;
	return defaultColor;
end;end;

if g_currentMission.hlUtils.getMilliSecondsToHours==nil then g_currentMission.hlUtils.getMilliSecondsToHours=
function(sMilliSeconds, getHoursMinSec, getHoursMin, getMinSec, getHours, getMin, getSec)
	if sMilliSeconds == nil then return nil;end;
	local nMilliSeconds = tonumber(sMilliSeconds);
	if nMilliSeconds == 0 then	
		return nil;
	else
		local nHours = string.format("%02.f", math.floor(nMilliSeconds/3600000));
		local nMins = string.format("%02.f", math.floor(nMilliSeconds/60000 - (tonumber(nHours)*60)));	
		local nSecs = string.format("%02.f", math.floor(nMilliSeconds/1000 - (tonumber(nHours)*3600) - (tonumber(nMins)*60)));
		if getHoursMinSec then return nHours.. ":".. nMins.. ":".. nSecs;end;
		if getHoursMin then return nHours.. ":".. nMins;end;
		if getMinSec then return nMins.. ":".. nSecs;end;
		if getHours and not getMin and not getSec then return nHours;end;
		if not getHours and getMin and not getSec then return nMins;end;
		if not getHours and not getMin and getSec then return nSecs;end;
		if getHours and getMin and not getSec then return nHours, nMins;end;
		if getHours and not getMin and getSec then return nHours, nSecs;end;
		if not getHours and getMin and getSec then return nMins, nSecs;end;
		if getHours and getMin and getSec then return nHours, nMins, nSecs;end;		
	end;
	return nil;
end;end;

if g_currentMission.hlUtils.getRealTime==nil then g_currentMission.hlUtils.getRealTime=
function(getHours, getMin, getSec, timeFormat12)
	if timeFormat12 == nil or timeFormat12 == false then	
	if getHours and not getMin and not getSec then return tostring(getDate("%H"));end;
	if not getHours and getMin and not getSec then return tostring(getDate("%M"));end;
	if not getHours and not getMin and getSec then return tostring(getDate("%S"));end;
	if getHours and getMin and not getSec then return tostring(getDate("%H:%M"));end;
	if getHours and getMin and getSec then return tostring(getDate("%H:%M:%S"));end;
	else
	if getHours and not getMin and not getSec then return tostring(getDate("%I")).. string.lower(getDate("%p"));end;
	if not getHours and getMin and not getSec then return tostring(getDate("%M")).. string.lower(getDate("%p"));end;
	if not getHours and not getMin and getSec then return tostring(getDate("%S")).. string.lower(getDate("%p"));end;
	if getHours and getMin and not getSec then return tostring(getDate("%I:%M")).. string.lower(getDate("%p"));end;
	if getHours and getMin and getSec then return tostring(getDate("%I:%M:%S")).. string.lower(getDate("%p"));end;
	end;
	return "0";
end;end;

if g_currentMission.hlUtils.getRealDay==nil then g_currentMission.hlUtils.getRealDay=
function(day, weekday, month, year)
	if day and not weekday and not month and not year then return getDate("%d");end;
	if weekday and not day and not month and not year then return getDate("%w");end; --math.mod(getDate("%w"), 7);end;
	if month and not day and not weekday and not year then return getDate("%m");end;
	if year and not day and not weekday and not month then return getDate("%Y");end;	
	if weekday and day and month and not year then return getDate("%d"), getDate("%w"), getDate("%m");end;
	if weekday and day and month and year then return getDate("%d"), getDate("%w"), getDate("%m"), getDate("%Y");end;
	return 1, 1, 1, 1;
end;end;

if g_currentMission.hlUtils.getPlayerPos==nil then g_currentMission.hlUtils.getPlayerPos= --update 0.95
function(noVehicle)
	if g_currentMission.playerUserId == nil or g_currentMission.playerSystem.playersByUserId[g_currentMission.playerUserId] == nil then return nil;end;
	local player = g_currentMission.playerSystem.playersByUserId[g_currentMission.playerUserId];
	if player:getIsInVehicle() then
		if noVehicle then return nil;end;
		local vehicle = player:getCurrentVehicle()
		if vehicle ~= nil and vehicle.steeringAxleNode ~= nil then
			return getWorldTranslation(vehicle.steeringAxleNode);
		end;
	else
		return player:getPosition();
	end;
	return nil;
end;end;

if g_currentMission.hlUtils.nearObject==nil then g_currentMission.hlUtils.nearObject=
function(object1, object2, distance)
	local defaultDistance = distance or 5;			
	if object2 == nil or object1 == nil or object2.x == nil or object2.y == nil or object2.z == nil then return false;end;	
	local mathDistance = MathUtil.vector3Length(object2.x-object1.x, object2.y-object1.y, object2.z-object1.z);	
	if mathDistance < defaultDistance then return true;else return false;end;	
	return false;
end;end;

if g_currentMission.hlUtils.optiHeightSize==nil then g_currentMission.hlUtils.optiHeightSize= --update 0.91 txtBold
function(height, txt, size, txtBold)
	setTextBold(txtBold or false);
	local txtHeight = getTextHeight(size, utf8Substr(txt, 0));
	local returnSize = size;
	if txtHeight > height then
		local i = 0;
		while txtHeight > height do
			i = i + 0.0005;			
			txtHeight = getTextHeight(size-i, utf8Substr(txt, 0));
		end;
		setTextBold(false);
		return size-i;	
	end;
	setTextBold(false);
	return returnSize;
end;end;

if g_currentMission.hlUtils.optiWidthSize==nil then g_currentMission.hlUtils.optiWidthSize= --update 0.91 txtBold
function(width, txt, size, txtBold)
	setTextBold(txtBold or false);
	local length = getTextWidth(size, utf8Substr(txt, 0));
	local returnSize = size;
	if length > width then
		local i = 0;
		while length > width do
			i = i + 0.0005;
			if size-i <= 0 then setTextBold(false);return 0;end;
			length = getTextWidth(size-i, utf8Substr(txt, 0));
		end
		setTextBold(false);
		return size-i;
	end;
	setTextBold(false);
	return returnSize;
end;end;

if g_currentMission.hlUtils.getTxtToWidth==nil then g_currentMission.hlUtils.getTxtToWidth= --update 0.91 txtBold
function(txt, size, width, trimFront, trimReplaceText, txtBold)
		setTextBold(txtBold or false);
		local replaceTextWidth = getTextWidth(size, trimReplaceText);
		local firstCharacter = 1;
		local lastCharacter = utf8Strlen(txt);
		if txt:len() <=1 then
			if trimReplaceText:len() > 0 then setTextBold(false);return tostring(trimReplaceText), 0 ,0;end;
			return txt, 0, 0;
		end;
		if width >= 0 then
			local totalWidth = getTextWidth(size, txt);
			if width < totalWidth then
				if trimFront then					
					firstCharacter = getTextLineLength(size, txt, totalWidth - width + replaceTextWidth);
					if utf8Substr(txt, firstCharacter) == nil then 
						setTextBold(false);
						return tostring(trimReplaceText), 0, 0;
					end;
					if firstCharacter > 1 then
						txt = trimReplaceText.. utf8Substr(txt, firstCharacter);
					else
						txt = utf8Substr(txt, firstCharacter);
					end;
				else
					lastCharacter = getTextLineLength(size, txt, width - replaceTextWidth);
					txt = utf8Substr(txt, 0, lastCharacter).. trimReplaceText;
				end;
			end;
		else
			setTextBold(false);
			return tostring(trimReplaceText), 0, 0;
		end;
		setTextBold(false);
		return txt, firstCharacter, lastCharacter;
end;end;

if g_currentMission.hlUtils.getLimitTxtToWidth==nil then g_currentMission.hlUtils.getLimitTxtToWidth=
function (size, width, txtBold, letter)
	setTextBold(txtBold or false);
	local textWidth = getTextWidth(size, utf8Substr(letter or "M", 0));	
	local firstCharacter = 1;
	local lastCharacter = 1;
	local totalTextWidth = textWidth;
	if width > textWidth then
		while totalTextWidth <= width do
			totalTextWidth = totalTextWidth+textWidth;
			lastCharacter = lastCharacter+1;
		end;
		lastCharacter = lastCharacter-1;totalTextWidth = totalTextWidth-textWidth;		
	else
		firstCharacter = 0;lastCharacter = 0;totalTextWidth = 0;
	end;	
	setTextBold(false);
	return firstCharacter, lastCharacter, totalTextWidth;	
end;end;

if g_currentMission.hlUtils.getTxtToWidthFix==nil then g_currentMission.hlUtils.getTxtToWidthFix= --update 0.91 txtBold
function(txt, size, width, trimReplaceText, difLength, txtBold)
		setTextBold(txtBold or false);
		local txtLengthOld = utf8Strlen(utf8Substr(txt, 0));
		local txtLengthNew = getTextLineLength(size, utf8Substr(txt, 0), width);
		--local txtLengthNew = g_currentMission.hlUtils.maxWidthText(width, txt, size);
		if txtLengthNew < txtLengthOld then
			txtLengthNew = txtLengthNew+(difLength);
			if txtLengthNew <= 1 then txtLengthNew = 2;end;
			txt = utf8Substr(txt,0,txtLengthNew-2).. tostring(trimReplaceText);										
		end;
		setTextBold(false);
		return txt;		
end;end;

if g_currentMission.hlUtils.getTableCopy==nil then g_currentMission.hlUtils.getTableCopy=
function(oldTable)
	function tableCopy(oldTable)
		local newTable = {};
		for key,value in pairs(oldTable) do
			if type(value) == "table" then
				newTable[key] = tableCopy(value);
			else
				newTable[key] = value;
			end;
		end;
		return newTable;
	end;
	return tableCopy(oldTable);
end;end;

if g_currentMission.hlUtils.getTableCopyFunc==nil then g_currentMission.hlUtils.getTableCopyFunc=
function(oldTable)
    function tableCopy(oldTable)
		local newTable = {}
        for key,value in pairs(oldTable) do
            local value_type = type(value);
            local new_value;
            if value_type == "function" then
                new_value = loadstring(string.dump(value));                
            elseif value_type == "table" then
                new_value = tableCopy(value);
            else
                new_value = value;
            end
            newTable[key] = new_value;
        end
        return newTable;
    end;
    return tableCopy(oldTable);
end;end;

if g_currentMission.hlUtils.maxWidthText==nil then g_currentMission.hlUtils.maxWidthText= --update 0.91 txtBold
function(maxWidth, txt, size, height, txtBold)	
	setTextBold(txtBold or false);
	local size = size;
	if height ~= nil then size = g_currentMission.hlUtils.optiHeightSize(height, txt, size, txtBold);end;	
	local txtLength = utf8Strlen(utf8Substr(txt, 0));	
	local txtWidth = getTextWidth(size, utf8Substr(txt, 0));	
	if txtWidth > maxWidth then		
		local i = 0;
		while txtWidth > maxWidth do
			i = i + 1;
			txtLength = txtLength-i;			
			txtWidth = getTextWidth(size, utf8Substr(txt, 0, txtLength));
			if txtWidth <= 0 or txtLength <= 0 then setTextBold(false);return 0;end;
		end;		
	end;
	setTextBold(false);
	return txtLength;
end;end;

if g_currentMission.hlUtils.maxLineBounds==nil then g_currentMission.hlUtils.maxLineBounds=
function(maxHeight, txtHeight, size)	
	local size = size;	
	local lineBounds = 0;
	local txtHeightTemp = txtHeight;
	while txtHeight < maxHeight do
		lineBounds = lineBounds + 1;					
		txtHeight = txtHeightTemp*lineBounds;		
	end;		
	return lineBounds-1;	
end;end;

if g_currentMission.hlUtils.mouseIsInArea==nil then g_currentMission.hlUtils.mouseIsInArea=
function(mouseX, mouseY, areaX1, areaX2, areaY1, areaY2)
	if mouseX == nil and g_currentMission.hlUtils.mouseCursor ~= nil then mouseX=g_currentMission.hlUtils.mouseCursor.posX;mouseY=g_currentMission.hlUtils.mouseCursor.posY;end; --update 0.2 g_currentMission.hlUtils.mouseCursor ~= nil
	if mouseX == nil or mouseY == nil or areaX1 == nil or areaX2 == nil or areaY1 == nil or areaY2 == nil then return false;end;
	return mouseX >= areaX1 and mouseX <= areaX2 and mouseY >= areaY1 and mouseY <= areaY2;
end;end;

if g_currentMission.hlUtils.timers == nil then g_currentMission.hlUtils.timers = {};end;
if g_currentMission.hlUtils.addTimer==nil then g_currentMission.hlUtils.addTimer=
function(args) ---> table with optional values	
	if args ~= nil and type(args) == "table" then						
		local delayNs = 1*10; -->1 nSec
		local delayMs = 1*100; -->1 mSec		
		local delay = 1*1000; -->default is 1 sec
		local action = nil;
		local ownTable = nil;
		local repeatable = true; -->default endless (optional false=1x or integer for max runs)
		local timerReady = false;		
		for arg, value in pairs(args) do
			if arg == "ns" and type(args.ns) == "boolean" and args.ns then delay = delayNs;end; --update 0.9
			if arg == "ms" and type(args.ms) == "boolean" and args.ms then delay = delayMs;end;
			if arg == "delay" and type(args.delay) == "number" and args.delay > 1 then delay = args.delay*delay;end;
			if arg == "action" and type(args.action) == "function" then action = args.action;end;
			if arg == "ownTable" and type(args.ownTable) == "table" then ownTable = args.ownTable;end;
			if arg == "repeatable" and (type(args.repeatable) == "number" or type(args.repeatable) == "boolean") then repeatable = args.repeatable;end;
			if arg == "name" and type(args.name) == "string" and g_currentMission.hlUtils.timers[args.name] == nil then				
				timerReady = true;
			end;	
			if g_currentMission.hlUtils.timers["1sec"] == nil then --default Timers 1-60 sec. Add over Mod
				for a=1, 60 do
					g_currentMission.hlUtils.timers[tostring(a).. "sec"] = {current_time = 0, delay = a*1000, onOff= true, action = nil, repeatable = true, runs = true};
				end;				
			end;
			if g_currentMission.hlUtils.timers["1mSec"] == nil then --default Timers 1-60 Milli-sec. Add over Mod
				for a=1, 60 do
					g_currentMission.hlUtils.timers[tostring(a).. "mSec"] = {current_time = 0, delay = a*100, onOff= true, action = nil, repeatable = true, runs = true};
				end;				
			end;
		end;
		if timerReady then 
			g_currentMission.hlUtils.timers[args.name] = {current_time = 0, delay = delay, action = action, ownTable = ownTable, onOff = true, repeatable = repeatable, runs = true}; --with Timer Name (runs = true/false,set auto over Timers)
			return true;
		else 
			return false, "addTimer... Table name=.... not found/incorrect(needs string) or name already exists";
		end;
	end;
	return false, "addTimer... Table not Found or not a Table";
end;end;

if g_currentMission.hlUtils.runsTimer==nil then g_currentMission.hlUtils.runsTimer=
function(name,onOff)
	if name == nil or type(name) ~= "string" then return nil;end;	
	if g_currentMission.hlUtils.timers ~= nil and g_currentMission.hlUtils.timers[name] ~= nil then		
		if onOff ~= nil and onOff then
			return g_currentMission.hlUtils.timers[name].onOff, g_currentMission.hlUtils.timers[name].repeatable;
		else
			return g_currentMission.hlUtils.timers[name].runs, g_currentMission.hlUtils.timers[name].repeatable;
		end;
	end;
	return nil;
end;end;

if g_currentMission.hlUtils.removeTimer==nil then g_currentMission.hlUtils.removeTimer=
function(name)
	if name == nil or type(name) ~= "string" then return nil;end;
	if g_currentMission.hlUtils.timers ~= nil and g_currentMission.hlUtils.timers[name] ~= nil then
		g_currentMission.hlUtils.timers[name] = nil;
		return true;
	end;
	return nil;
end;end;

if g_currentMission.hlUtils.update_timers==nil then g_currentMission.hlUtils.update_timers=
function(dt)
	for name, timer in pairs(g_currentMission.hlUtils.timers) do
		if g_currentMission.hlUtils.timers[name] ~= nil then --for delete -timer check
			timer.current_time = timer.current_time + dt;
			if timer.current_time > timer.delay then
				if timer.onOff then timer.onOff = false;else timer.onOff = true;end; --onOff 1xon 1xoff all ..sec
				timer.runs = false; --1x all ..sec, blink effect oder auslöser						 
				if timer.action then timer.action(timer);end;            
				if timer.repeatable then 
					if type(timer.repeatable) == "number" then
						timer.repeatable = timer.repeatable - 1
						if timer.repeatable >= 0 then 
							timer.current_time = 0;							
						else 
							g_currentMission.hlUtils.timers[name] = nil; 
						end;
					else 
						timer.current_time = 0;						
					end;
				else
					g_currentMission.hlUtils.timers[name] = nil;
				end;
			else
				timer.runs = true;
			end;
		end;
	end;		
end;end;

if g_currentMission.hlUtils.switchTimers == nil then g_currentMission.hlUtils.switchTimers = {};end; --update 0.8
if g_currentMission.hlUtils.addSwitchTimer==nil then g_currentMission.hlUtils.addSwitchTimer= --update 0.8
function(args) ---> table with optional values	
	if args ~= nil and type(args) == "table" then		
		local delay = 1*1000; -->default is 1 sec		
		local formatDelay = 1*1000;
		local ownTable = nil;
		local repeatable = true; -->default endless (optional false=1x or integer for max runs)
		local isSwitch = 1;
		local switch = {};		
		local formatSwitch = {};		
		local timerReady = false;		
		for arg, value in pairs(args) do			
			if arg == "delay" and type(args.delay) == "number" and args.delay > 1 then delay = args.delay*delay;end;
			if arg == "action" and type(args.action) == "function" then action = args.action;end;
			if arg == "ownTable" and type(args.ownTable) == "table" then ownTable = args.ownTable;end;
			if arg == "repeatable" and (type(args.repeatable) == "number" or type(args.repeatable) == "boolean") then repeatable = args.repeatable;end;			
			if arg == "switch" and type(args.switch) == "table" and #args.switch > 1 then switch = args.switch;end;			
			if arg == "isSwitch" and type(args.isSwitch) == "number" and args.isSwitch > 0 and args.isSwitch <= #switch then isSwitch = args.isSwitch;end;
			function formatSwitchDelay()
				formatSwitch = {};
				for s=1, #switch do
					if type(switch[s]) == "number" then formatSwitch[s] = switch[s]*formatDelay;else formatSwitch[s] = delay;end;
				end;
			end;
			if arg == "switch" then formatSwitchDelay();end;
			if arg == "name" and type(args.name) == "string" and g_currentMission.hlUtils.switchTimers[args.name] == nil then				
				timerReady = true;
			end;
			if g_currentMission.hlUtils.switchTimers["2x5"] == nil then --default switchTimers ..x5	= 5 sec. takt			
				for a=2, 10 do
					for s=1, a do
						formatSwitch[s] = 5*delay;
					end;
					g_currentMission.hlUtils.switchTimers[tostring(a).. "x5"] = {current_time=0, delay=5*delay, isSwitch=isSwitch, switch=formatSwitch, repeatable=true};
					formatSwitch = {};
				end;				
			end;
			if g_currentMission.hlUtils.switchTimers["2x10"] == nil then --default switchTimers ..x10 = 10 sec. takt				
				for a=2, 10 do
					for s=1, a do
						formatSwitch[s] = 10*delay;
					end;
					g_currentMission.hlUtils.switchTimers[tostring(a).. "x10"] = {current_time=0, delay=10*delay, isSwitch=isSwitch, switch=formatSwitch, repeatable=true};
					formatSwitch = {};
				end;				
			end;
		end;
		if timerReady and #formatSwitch > 0 then 
			g_currentMission.hlUtils.switchTimers[args.name] = {current_time=0, delay=delay, ownTable=ownTable, isSwitch=isSwitch, switch=formatSwitch, action=action, repeatable=repeatable};
			return true;
		else 
			return false, "addSwitchTimer... Table name=.... not found/incorrect(needs string) or name already exists or table switch missing";
		end;
	end;
	return false, "addSwitchTimer... Table not Found or not a Table";
end;end;

if g_currentMission.hlUtils.getIsSwitchTimer==nil then g_currentMission.hlUtils.getIsSwitchTimer=
function(name)
	if name == nil or type(name) ~= "string" then return nil;end;	
	if g_currentMission.hlUtils.switchTimers ~= nil and g_currentMission.hlUtils.switchTimers[name] ~= nil then		
		return g_currentMission.hlUtils.switchTimers[name].isSwitch;		
	end;
	return nil;
end;end;

if g_currentMission.hlUtils.removeSwitchTimer==nil then g_currentMission.hlUtils.removeSwitchTimer= --update 0.8
function(name)
	if name == nil or type(name) ~= "string" then return nil;end;
	if g_currentMission.hlUtils.switchTimers ~= nil and g_currentMission.hlUtils.switchTimers[name] ~= nil then
		g_currentMission.hlUtils.switchTimers[name] = nil;
		return true;
	end;
	return nil;
end;end;

if g_currentMission.hlUtils.update_switchTimers==nil then g_currentMission.hlUtils.update_switchTimers= --update 0.8
function(dt)
	for name, timer in pairs(g_currentMission.hlUtils.switchTimers) do
		if g_currentMission.hlUtils.switchTimers[name] ~= nil then --for delete -timer check
			timer.current_time = timer.current_time + dt;
			if timer.current_time > timer.delay then				
				local lastSwitch = timer.isSwitch;
				if timer.isSwitch+1 > #timer.switch then timer.isSwitch = 1;else timer.isSwitch = timer.isSwitch+1;end;
				timer.delay = timer.switch[timer.isSwitch];
				if timer.action then timer.action(timer, timer.isSwitch);end;								
				if timer.repeatable or lastSwitch < #timer.switch then 
					if type(timer.repeatable) == "number" then
						timer.repeatable = timer.repeatable - 1
						if timer.repeatable >= 0 then 
							timer.current_time = 0;							
						else 
							g_currentMission.hlUtils.switchTimers[name] = nil; 
						end;
					else 
						timer.current_time = 0;						
					end;
				else
					g_currentMission.hlUtils.switchTimers[name] = nil;
				end;			
			end;
		end;
	end;		
end;end;

if g_currentMission.hlUtils.dragDrop==nil then g_currentMission.hlUtils.dragDrop={on=false};end;
if g_currentMission.hlUtils.setDragDrop==nil then g_currentMission.hlUtils.setDragDrop=
function(on,args)
	if on then
		g_currentMission.hlUtils.dragDrop={on=true,system=args.system,what=args.what,where=args.where,warning=args.warning,area=args.area,overlay=args.overlay,typ=args.typ,typPos=args.typPos};
	else
		g_currentMission.hlUtils.dragDrop={on=false};
	end;
	return true;
end;end;

if g_currentMission.hlUtils.isMouseCursor==nil then g_currentMission.hlUtils.isMouseCursor=false;end; 
if g_currentMission.hlUtils.mouseOnOff==nil then g_currentMission.hlUtils.mouseOnOff= --update 1.02/save last pos
function(on,frozen,saveLastPos)	
	if on == nil or frozen == nil then return nil;end;	
	if on then g_inputBinding:setShowMouseCursor(true,saveLastPos);g_currentMission.hlUtils.isMouseCursor=true;else g_inputBinding:setShowMouseCursor(false,saveLastPos);g_currentMission.hlUtils.isMouseCursor=false;g_currentMission.hlUtils.setDragDrop(false);end;
	if frozen and not g_currentMission.isPlayerFrozen then
		g_currentMission.isFrozen = true;			
		g_currentMission.isPlayerFrozen = true;
	elseif not frozen then 
		g_currentMission.isFrozen = false;			
		g_currentMission.isPlayerFrozen = false;
	end;	
	return true;	
end;end;


if g_currentMission.hlUtils.addTextDisplay==nil then g_currentMission.hlUtils.addTextDisplay= --update 0.91 set setTextBold before getTextWidth etc..
function(args) --txt, txtSize, txtBold, txtColor, maxLine, duration, add, bg, bgColor, posX, posY
	if args == nil or type(args) ~= "table" then return;end;
	if args.add == nil or not args.add then
		g_currentMission.hlUtils.removeTimer("_hlUtilsDrawTextDisplay");
		g_currentMission.hlUtils.textDisplay = {};
	end;
	g_currentMission.hlUtils.textDisplay[#g_currentMission.hlUtils.textDisplay+1] = {		
		txt = tostring(args.txt);			
		size = args.txtSize or 0.015;			
		bold = args.txtBold or false;
		line = args.maxLine or 1; --args.maxLine = 0 --> unknown MaxLines
		color = args.txtColor or "ls25active";
		duration = args.duration or 1; --sec		
		bgColor = args.bgColor or "blackDisabled";
		bg = args.bg or true;
		posX = args.posX or nil;
		posY = args.posY or nil;
		warning = args.warning or nil;
	};
	local txtDisplay = g_currentMission.hlUtils.textDisplay[#g_currentMission.hlUtils.textDisplay];
	txtDisplay.txtHeight = 0;
	txtDisplay.txtWidth = 0;	
	setTextBold(args.txtBold or false);
	if (txtDisplay.line > 1 or txtDisplay.line == 0) and txtDisplay.bg then 
		--local txtSplit = g_currentMission.hlUtils.stringSplit(txtDisplay.txt,"\n","");
		local txtSplit = string.split(txtDisplay.txt, "\n");	
		if txtSplit ~= nil and #txtSplit > 1 then			
			for t=1, #txtSplit do
				local splitWidth = getTextWidth(txtDisplay.size, utf8Substr(txtSplit[t].. "  ", 0));
				if splitWidth > txtDisplay.txtWidth then txtDisplay.txtWidth = splitWidth;end;
				txtDisplay.txtHeight = txtDisplay.txtHeight+getTextHeight(txtDisplay.size, utf8Substr(txtSplit[t], 0));
			end;
			if txtDisplay.line == 0 then txtDisplay.line = #txtSplit;end;
		else
			txtDisplay.line = 1;
			txtDisplay.txtHeight = txtDisplay.txtHeight+getTextHeight(txtDisplay.size, utf8Substr(txtDisplay.txt, 0));
			txtDisplay.txtWidth = getTextWidth(txtDisplay.size, utf8Substr(txtDisplay.txt.. "  ", 0));
		end;
	else
		txtDisplay.txtHeight = getTextHeight(txtDisplay.size, utf8Substr(txtDisplay.txt, 0));
		txtDisplay.txtWidth = getTextWidth(txtDisplay.size, utf8Substr(txtDisplay.txt.. "  ", 0));
	end;
	setTextBold(false);
	if txtDisplay.warning ~= nil and txtDisplay.warning then txtDisplay.bgColor = "whiteInactive";txtDisplay.color = "darkRed";end;	
end;end;
if g_currentMission.hlUtils.deleteTextDisplay==nil then g_currentMission.hlUtils.deleteTextDisplay=
function()		
	if #g_currentMission.hlUtils.textDisplay > 0 then
		table.remove(g_currentMission.hlUtils.textDisplay, 1);
	end;		
end;end;
if g_currentMission.hlUtils.drawTextDisplay==nil then g_currentMission.hlUtils.drawTextDisplay=
function()
	if #g_currentMission.hlUtils.textDisplay > 0 then			
		local txtDisplay = g_currentMission.hlUtils.textDisplay[1];
		if g_currentMission.hlUtils.timers["_hlUtilsDrawTextDisplay"] == nil then g_currentMission.hlUtils.addTimer( {delay=txtDisplay.duration, name="_hlUtilsDrawTextDisplay", repeatable=1, action=g_currentMission.hlUtils.deleteTextDisplay} );end; 
		if g_currentMission.hlUtils.timers["_hlUtilsDrawTextDisplay"] ~= nil then
			local overlay = g_currentMission.hlUtils.overlays["txtDisplay"];
			g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(txtDisplay.bgColor, true, "blackInactive"));
			local width =  txtDisplay.txtWidth*1.1; 
			local height = txtDisplay.txtHeight*1.2;
			local posX = 0.5-(width/2);
			local posY = 0.485-height;
			if txtDisplay.posX ~= nil then posX = txtDisplay.posX;end;
			if txtDisplay.posY ~= nil then posY = txtDisplay.posY;end;
			g_currentMission.hlUtils.setOverlay(overlay, posX, posY, width, height);
			if txtDisplay.bg then overlay:render();end;
			setTextAlignment(0);
			setTextLineBounds(0, 0);
			setTextWrapWidth(0.9);			
			setTextColor(unpack(g_currentMission.hlUtils.getColor(txtDisplay.color, true, "ls22")));
			setTextBold(txtDisplay.bold);								
			if (txtDisplay.warning ~= nil and txtDisplay.warning and g_currentMission.hlUtils.runsTimer("5mSec", true)) or txtDisplay.warning == nil or not txtDisplay.warning then 
				renderText(overlay.x+(width/2)-(txtDisplay.txtWidth/2), overlay.y+(overlay.height)-(txtDisplay.txtHeight/txtDisplay.line), txtDisplay.size, txtDisplay.txt);
			end;
			--respect settings for other mods (not every mod) that's why
			setTextAlignment(0);
			setTextLineBounds(0, 0);
			setTextWrapWidth(0);
			setTextColor(1, 1, 1, 1);
			setTextBold(false);
			--respect settings for other mods			
		end;
	end;
end;end;

if g_currentMission.hlUtils.disableInArea==nil then g_currentMission.hlUtils.disableInArea=
function()
	return g_currentMission.hlUtils.dragDrop.on or not g_currentMission.hlUtils.isMouseCursor;
end;end;

if g_currentMission.hlUtils.getFunction==nil then g_currentMission.hlUtils.getFunction=
function(funcName)
	--local parts = StringUtil.splitString(".", funcName); old LS19
	local parts = g_currentMission.hlUtils.stringSplit(funcName, ".", true);	
	local numParts = table.getn(parts);
	local currentTable = _G[parts[1]];
	if numParts > 1 then
		if type(currentTable) ~= "table" then
			return nil;
		end;
		for i = 2, numParts do
			currentTable = currentTable[parts[i]];
			if i ~= numParts and type(currentTable) ~= "table" then
				return nil;
			end;
		end;
	end;
	if type(currentTable) ~= "function" then
		return nil;
	end;
	return currentTable;
end;end;

if g_currentMission.hlUtils.generateObjectMapHotspot == nil then g_currentMission.hlUtils.generateObjectMapHotspot=
function(args)
	if args == nil or type(args) ~= "table" then return;end;
	if args.objects == nil or type(args.objects) ~= "table" or args.file == nil then return;end;
	if g_currentMission.hlUtils.timers["hlUtils_objectsMapHotSpot"] ~= nil and (args.insert == nil or not args.insert) then
		g_currentMission.hlUtils.removeTimer("hlUtils_objectsMapHotSpot");
		g_currentMission.hlUtils.deleteObjectMapHotspot();
	end;
	local objects = args.objects;
	local width, height = getNormalizedScreenValues(args.width or 25, args.height or 25);	
	local file = args.file;
	if not fileExists(file) then return;end;
	local formatO = 0;local sW=0;local sH=0;local iconPos=nil;
	if args.fileFormat ~= nil and type(args.fileFormat) == "table" then
		formatO = args.fileFormat[1] or 0;
		sW = args.fileFormat[2] or 0;
		sH = args.fileFormat[3] or 0;
		iconPos = args.fileFormat[4] or nil;
	end;
	if args.insert == nil or not args.insert or g_currentMission.hlUtils.objectsMapHotspot == nil then g_currentMission.hlUtils.objectsMapHotspot = {};end;
	local color = g_currentMission.hlUtils.getColor(Utils.getNoNil(args.color, "red"), true);
	local int = 1;
	if args.insert ~= nil and args.insert and g_currentMission.hlUtils.objectsMapHotspot ~= nil then int = int+Utils.getNoNil(#g_currentMission.hlUtils.objectsMapHotspot, 0);end;
	function insertMapHotspot(x, z, setColor)
		g_currentMission.hlUtils.objectsMapHotspot[int] = MapHotspot.new();
		g_currentMission.hlUtils.objectsMapHotspot[int].icon = Overlay.new(file, 0, 0, width, height);				
		g_currentMission.hlUtils.setOverlayUVsPx(g_currentMission.hlUtils.objectsMapHotspot[int].icon, unpack(g_currentMission.hlUtils.getNormalUVs(formatO, sW, sH, iconPos)));								
		g_currentMission.hlUtils.objectsMapHotspot[int].worldX = x or 0;
		g_currentMission.hlUtils.objectsMapHotspot[int].worldZ = z or 0;
		g_currentMission.hlUtils.objectsMapHotspot[int]:setColor(unpack(setColor));
		g_currentMission.hlUtils.objectsMapHotspot[int].isBlinking = Utils.getNoNil(args.isBlinking, true);
		g_currentMission.hlUtils.objectsMapHotspot[int].isPersistent = true;
		g_currentMission.hlUtils.objectsMapHotspot[int].isVisible = true;
		g_currentMission:addMapHotspot(g_currentMission.hlUtils.objectsMapHotspot[int]);	
	end;
	if objects.positionen ~= nil and type(objects.positionen) == "table" then
		for p=1, #objects.positionen do
			if objects.positionen[p] ~= nil and objects.positionen[p].x ~= nil and objects.positionen[p].z ~= nil then
				local positionColor = g_currentMission.hlUtils.getColor(Utils.getNoNil(objects.positionen[p].color, "red"), true);				
				insertMapHotspot(objects.positionen[p].x, objects.positionen[p].z, positionColor);
				int = int+1;
			end;
		end;
	else
		for key, value in pairs(objects) do	
			local objectId = value.nodeId or key.nodeId;
			if objectId ~= nil and entityExists(objectId) then			
				local x, y, z = getWorldTranslation(objectId);
				if x ~= nil then
					insertMapHotspot(x, z, color);
					int = int+1;
				end;			
			end;
		end;
	end;
	g_currentMission.hlUtils.addTimer({name="hlUtils_objectsMapHotSpot", delay=10, repeatable=1, action=g_currentMission.hlUtils.deleteObjectMapHotspot});
end;end;

if g_currentMission.hlUtils.deleteObjectMapHotspot == nil then g_currentMission.hlUtils.deleteObjectMapHotspot=
function()
	if g_currentMission.hlUtils.objectsMapHotspot ~= nil then
		for a=1, #g_currentMission.hlUtils.objectsMapHotspot do
			if g_currentMission.hlUtils.objectsMapHotspot[a] ~= nil and g_currentMission.hlUtils.objectsMapHotspot[a].icon ~= nil then
				g_currentMission.hlUtils.objectsMapHotspot[a].icon:delete();
				g_currentMission.hlUtils.objectsMapHotspot[a].icon = nil;
				g_currentMission:removeMapHotspot(g_currentMission.hlUtils.objectsMapHotspot[a]);
			end;
		end;
	end;
end;end;

if g_currentMission.hlUtils.loadLanguage == nil then g_currentMission.hlUtils.loadLanguage=
function(args)
	if args == nil or type(args) ~= "table" or args.class == nil then return;end;
	local xmlPath = Utils.getNoNil(args.xmlPath, "modSettings/HL/");
	local xmlDir = Utils.getNoNil(args.xmlDir, "Unknown");
	local modTitle = Utils.getNoNil(tostring(args.modTitle), "Unknown Mod");
	local modEnv = _G[args.class];	
	if modEnv ~= nil then
		if modEnv.g_i18n == nil then
			modEnv.g_i18n = g_i18n:addModI18N(args.class);
		end;
		local l10nFilenamePrefix = "languages/l10n";	
		local l10nFilenameExternPrefixFull = Utils.getFilename(l10nFilenamePrefix, getUserProfileAppPath().. xmlPath.. xmlDir.. "/"); --prio		
		local l10nFilenamePrefixFull = Utils.getFilename(l10nFilenamePrefix, args.modDir);
		if args.debug ~= nil and args.debug then
			print("Info: Languages XML files Intern in mod '".. modTitle.. "'".. tostring(l10nFilenamePrefixFull));
			print("Info: Languages XML files Extern in mod '".. modTitle.. "'".. tostring(l10nFilenameExternPrefixFull));
		end;
		if args.externPrio ~= nil and not args.externPrio then l10nFilenameExternPrefixFull = l10nFilenamePrefixFull;end;
		local l10nXmlFile, l10nFilename = nil;
		local langs = {
			g_languageShort,
			"en",
			"de"
		};
		
		function getVersion(l10nFilename)
			l10nXmlFile = loadXMLFile("modL10n", l10nFilename);
			if l10nXmlFile ~= nil then
				local xmlNameTag = ("l10n"):format(0);
				local version = getXMLInt(l10nXmlFile, xmlNameTag.. "#version");				
				if version ~= nil and version >= Utils.getNoNil(args.xmlVersion, 1) then
					delete(l10nXmlFile);
					return true;
				else
					delete(l10nXmlFile);
				end;
			end;
			return false;
		end;

		for _, lang in ipairs(langs) do
			l10nFilename = l10nFilenameExternPrefixFull.. "_".. lang.. ".xml"; --prio
			local isCorrectVersion = false;
			if fileExists(l10nFilename) then isCorrectVersion = getVersion(l10nFilename);end;
			if not fileExists(l10nFilename) then
				l10nFilename = l10nFilenamePrefixFull.. "_".. lang.. ".xml";
				if fileExists(l10nFilename) then
					l10nXmlFile = loadXMLFile("modL10n", l10nFilename);
					break;
				end;
			else
				l10nXmlFile = loadXMLFile("modL10n", l10nFilename);
				break;
			end;
		end;

		if l10nXmlFile ~= nil then
			local textI = 0;
			while true do
				local key = string.format("l10n.texts.text(%d)", textI);

				if not hasXMLProperty(l10nXmlFile, key) then
					break;
				end;

				local name = getXMLString(l10nXmlFile, key.. "#name");
				local text = getXMLString(l10nXmlFile, key.. "#text");

				if name ~= nil and text ~= nil then
					if modEnv.g_i18n:hasModText(name) then
						print("Warning: Duplicate l10n entry '".. name.. "' in '" .. l10nFilename.. "'. Ignoring this definition.")
					else
						modEnv.g_i18n:setText(name, text:gsub("/n/", "\n"));
					end;
				end;
				textI = textI + 1;
			end;
			textI = 0;
			delete(l10nXmlFile);
		else
			if args.debug ~= nil and args.debug then print("Warning: No l10n file found for '".. l10nFilenamePrefix.. "' in mod '".. modTitle.. "'");end;
		end;
	else
		if args.debug ~= nil and args.debug then print("Warning: No Class file found for in mod '".. modTitle.. "'");end;
	end;
end;end;

if g_currentMission.hlUtils.checkFilePath==nil then g_currentMission.hlUtils.checkFilePath= --update 1.02/textureFileExists,audioFileExists
function(file, xmlFile, modDir)	
	local filePath = Utils.getFilename(tostring(file), modDir);
	local xmlFilePath = Utils.getFilename(tostring(xmlFile), modDir);
	if string.endsWith(file, ".dds") or string.endsWith(file, ".png") then
		if not textureFileExists(filePath) or not fileExists(xmlFilePath) then return nil;end;
	elseif string.endsWith(filePath, ".ogg") or (string.endsWith(filePath, ".wav") or string.endsWith(filePath, ".gls")) then
		if not audioFileExists(filePath) or not fileExists(xmlFilePath) then return nil;end;
	else
		if not fileExists(filePath) or not fileExists(xmlFilePath) then	return nil;end;
	end;
	return filePath, xmlFilePath;
end;end;

if g_currentMission.hlUtils.checkFile==nil then g_currentMission.hlUtils.checkFile= --update 1.02/textureFileExists,audioFileExists
function(file, modDir)	
	local filePath = Utils.getFilename(tostring(file), modDir);	
	if string.endsWith(file, ".dds") or string.endsWith(file, ".png") then
		if not textureFileExists(filePath) then return nil;end;
	elseif string.endsWith(filePath, ".ogg") or (string.endsWith(filePath, ".wav") or string.endsWith(filePath, ".gls")) then
		if not audioFileExists(filePath) then return nil;end;
	else
		if not fileExists(filePath) then return nil;end;
	end;
	return filePath;
end;end;

--update 0.4
if g_currentMission.hlUtils.getRealDayString==nil then g_currentMission.hlUtils.getRealDayString=
function(large)
	local realDay = math.fmod(g_currentMission.hlUtils.getRealDay(false,true,false,false), 7);
	if realDay == 0 then realDay = 7;end;
	local day = g_i18n:getText("ui_dayShort".. tostring(realDay));	
	if large ~= nil and large then day = g_i18n:getText("ui_financesDay".. tostring(realDay));end;
	return tostring(day);
end;end;

if g_currentMission.hlUtils.getIngameDayString==nil then g_currentMission.hlUtils.getIngameDayString=
function(large)	
	local ingameDay = math.fmod(g_currentMission.environment.currentDay, 7);
	if ingameDay == 0 then ingameDay = 7;end;
	local day = g_i18n:getText("ui_dayShort".. tostring(ingameDay));	
	if large ~= nil and large then day = g_i18n:getText("ui_financesDay".. tostring(ingameDay));end;
	return tostring(day);
end;end;

if g_currentMission.hlUtils.getIngameTimeString==nil then g_currentMission.hlUtils.getIngameTimeString=
function()
	local currentTime = g_currentMission.environment.dayTime / 3600000;
	local timeHours = math.floor(currentTime);
	local timeMinutes = math.floor((currentTime - timeHours) * 60);
	return string.format("%02d:%02d", timeHours, timeMinutes);	
end;end;
--update 0.4
--update 0.6
if g_currentMission.hlUtils.getTypId==nil then g_currentMission.hlUtils.getTypId=
function(r1, r2)	
	local randomNr = math.random (r1 or 1, r2 or 9);			
	local typIdDate_D = string.format("%0.2i", Utils.getNoNil(getDate("%d"), tostring(randomNr)));		
	local typIdDate_M = string.format("%0.2i", Utils.getNoNil(getDate("%m"), tostring(randomNr))); 
	local typIdDate_Y = string.format("%0.2i", Utils.getNoNil(getDate("%y"), tostring(randomNr))); 
	local typIdTimeH = string.format("%0.2i", Utils.getNoNil(getDate("%I"), tostring(randomNr)));		
	local typIdTimeM = Utils.getNoNil(getDate("%M"), tostring(randomNr));
	if tonumber(typIdTimeM) <= 0 then typIdTimeM = "60";else typIdTimeM = string.format("%0.2i", typIdTimeM);end;
	local typIdTimeS = Utils.getNoNil(getDate("%S"), tostring(randomNr));
	if tonumber(typIdTimeS) <= 0 then typIdTimeS = "60";else typIdTimeS = string.format("%0.2i", typIdTimeS);end;
	local typIdString = typIdDate_D.. typIdDate_M.. typIdDate_Y.. typIdTimeH.. typIdTimeM.. typIdTimeS.. tostring(randomNr);		
	return tonumber(typIdString);	
end;end;
--update 0.6
--update 0.7
--update 0.7
--update 0.8
if g_currentMission.hlUtils.getOptiIconWidthHeight==nil then g_currentMission.hlUtils.getOptiIconWidthHeight=
function(height, pixelW, pixelH)
	local iconWidth, iconHeight = 0,0;
	local zoomLV = 0.5;
	local int = zoomLV;
	while iconHeight < height do
		iconHeight = pixelH*int;		
		int = int+zoomLV;
	end;
	iconWidth = pixelW*(iconHeight/pixelH);
	return iconWidth, iconHeight;
end;end;
--update 0.8
--update 0.91
if g_currentMission.hlUtils.getTextWidth==nil then g_currentMission.hlUtils.getTextWidth=
function(txt, size, txtBold, firstCharacter, lastCharacter)
	setTextBold(txtBold or false);
	local txtWidth = 0;
	if lastCharacter == nil or type(lastCharacter) ~= "number" then
		txtWidth = getTextWidth(size, utf8Substr(txt, firstCharacter or 0));
	else
		txtWidth = getTextWidth(size, utf8Substr(txt, firstCharacter or 0, lastCharacter));
	end;
	setTextBold(false);
	return txtWidth;	
end;end;

if g_currentMission.hlUtils.getTextHeight==nil then g_currentMission.hlUtils.getTextHeight=
function(txt, size, txtBold, firstCharacter, lastCharacter)
	setTextBold(txtBold or false);
	local txtHeight = 0;
	if lastCharacter == nil or type(lastCharacter) ~= "number" then
		txtHeight = getTextHeight(size, utf8Substr(txt, firstCharacter or 0));
	else
		txtHeight = getTextHeight(size, utf8Substr(txt, firstCharacter or 0, lastCharacter));
	end;
	setTextBold(false);
	return txtHeight;	
end;end;

if g_currentMission.hlUtils.getTextLineLength==nil then g_currentMission.hlUtils.getTextLineLength=
function(txt, size, txtBold, firstCharacter, lastCharacter, width)
	setTextBold(txtBold or false);
	local txtLineLength = 0;
	if lastCharacter == nil or type(lastCharacter) ~= "number" then
		txtLineLength = getTextLineLength(size, utf8Substr(txt, firstCharacter or 0), width);
	else
		txtLineLength = getTextLineLength(size, utf8Substr(txt, firstCharacter or 0, lastCharacter), width);
	end;
	setTextBold(false);
	return txtLineLength;	
end;end;
--update 0.91
--update 0.93 convert LS22 to LS25
--update 0.96
if g_currentMission.hlUtils.hasPlayerFarmId==nil then g_currentMission.hlUtils.hasPlayerFarmId=
function()
	return g_localPlayer ~= nil and g_localPlayer.farmId ~= nil and g_localPlayer.farmId > 0;
end;end;

if g_currentMission.hlUtils.getPlayerFarmId==nil then g_currentMission.hlUtils.getPlayerFarmId=
function()
	local farmId = 0;
	if g_localPlayer ~= nil and g_localPlayer.farmId ~= nil then farmId = g_localPlayer.farmId;end;
	return farmId;
end;end;

if g_currentMission.hlUtils.teleportPlayerToObject==nil then g_currentMission.hlUtils.teleportPlayerToObject= --update 0.97 + 0.98
function(object, forceMouse)
	local isTeleport = false;
	if object == nil then return isTeleport;end;
	if object.mapHotspot ~= nil then
		for hotspots=1, #object.mapHotspot.mapHotspots do
			local hotspot = object.mapHotspot.mapHotspots[hotspots];
			if hotspot ~= nil and hotspot.teleportWorldX ~= nil and hotspot.teleportWorldY ~= nil and hotspot.teleportWorldZ ~= nil then
				if g_localPlayer ~= nil then
					if g_localPlayer:getIsInVehicle() then
						g_localPlayer:leaveVehicle();						
						g_localPlayer:teleportTo(hotspot.teleportWorldX, hotspot.teleportWorldY, hotspot.teleportWorldZ, false, false);	
					else
						g_localPlayer:teleportTo(hotspot.teleportWorldX, hotspot.teleportWorldY, hotspot.teleportWorldZ, false, false);							
					end;				
					isTeleport = true;
				end;
				break;										
			end;
		end;	
	end;
	--! or over nodeId !--
	if not isTeleport then
		local objectId = object.rootNode or object.nodeId;
		if objectId ~= nil and entityExists(objectId) then			
			local x, y, z = getWorldTranslation(objectId);
			if x ~= nil and y ~= nil and z ~= nil then
				local terrainHeight = getTerrainHeightAtWorldPos(g_currentMission.foliageSystem.terrainRootNode, x, y, z);
				y = terrainHeight + y;
				if g_localPlayer ~= nil then
					if g_localPlayer:getIsInVehicle() then
						g_localPlayer:leaveVehicle();						
						g_localPlayer:teleportTo(x, y, z, false, false);
					else		
						g_localPlayer:teleportTo(x, y, z, false, false);					
					end;
					isTeleport = true;
				end;
			end;
		end;
	end;
	if isTeleport then			
		if forceMouse == nil or forceMouse then g_currentMission.hlUtils.mouseOnOff(false, false);end; --force mouseOff			
	end;
	return isTeleport;
end;end;
--update 0.96
--update 0.97
if g_currentMission.hlUtils.getHelpMenuData==nil then g_currentMission.hlUtils.getHelpMenuData=
function()	
	if g_currentMission.hlUtils.helpMenuData.posY == nil then hlUtils.preInputHelpDisplayDraw(g_currentMission.hud.inputHelp, offsetX, offsetY);end; --is savegame f1menu off, first temp load 
	return g_currentMission.hlUtils.helpMenuData;	
end;end;

if g_currentMission.hlUtils.getVehicleSchemaData==nil then g_currentMission.hlUtils.getVehicleSchemaData=
function()
	if g_currentMission.hlUtils.vehicleSchemaData == nil then g_currentMission.hlUtils.vehicleSchemaData = {};end;
	local vehicleSchema = g_currentMission.hud.inputHelp
	if vehicleSchema ~= nil and vehicleSchema.vehicle ~= nil then
		--local offsetX, offsetY = getNormalizedScreenValues(unpack(SwitchVehicleDisplay.POSITION.GAMEPAD_OFFSET));
		local posX, posY = vehicleSchema:getPosition();
		local height = vehicleSchema.lineBg.height;
		local comboHeight = vehicleSchema.comboBg.height;
		local width = vehicleSchema.lineBg.width;
		local maxWidth = vehicleSchema.maxSchemaWidth;
		local w = vehicleSchema.lineBgScale.width;
		local pX = vehicleSchema.lineBgScale.x;
		local pY = vehicleSchema.lineBgScale.y + vehicleSchema.comboTextOffsetY;		
		local endPosX = vehicleSchema.lineBgRight.x + vehicleSchema.lineBgRight.width;
		local leftWidth = vehicleSchema.lineBgLeft.width;
		-- + (offsetY or 0);-- + (offsetX or 0);		
		if vehicleSchema:getVisible() then posY = posY-comboHeight;else posY = posY - height;end;		
		g_currentMission.hlUtils.vehicleSchemaData = {posX=posX, posY=posY, width=width, height=height, endPosX=endPosX, scaleX=pX, scaleTextY=pY, scaleWidth=w, leftWidth=leftWidth, maxWidth=maxWidth, isVisible=vehicleSchema:getVisible()};
		return g_currentMission.hlUtils.vehicleSchemaData;
	end;
	return nil;	
end;end;

if g_currentMission.hlUtils.isControlledVehicle==nil then g_currentMission.hlUtils.isControlledVehicle=
function()
	return g_localPlayer ~= nil and g_localPlayer.getCurrentVehicle ~= nil and g_localPlayer:getIsInVehicle();	
end;end;

if g_currentMission.hlUtils.getControlledVehicle==nil then g_currentMission.hlUtils.getControlledVehicle=
function(isControlled)
	if isControlled ~= nil and isControlled then
		if g_currentMission.hlUtils.isControlledVehicle() then return g_localPlayer:getCurrentVehicle();end;
	else
		return g_localPlayer:getCurrentVehicle();
	end;
	return nil;
end;end;
--update 0.97
--update 0.98
if g_currentMission.hlUtils.getObjectDistance==nil then g_currentMission.hlUtils.getObjectDistance=
function(object1, object2)
	if object2 == nil or object1 == nil or object2.x == nil or object2.y == nil or object2.z == nil or object1.x == nil or object1.y == nil or object1.z == nil then return -1;end;
	return MathUtil.vector3Length(object2.x-object1.x, object2.y-object1.y, object2.z-object1.z);
end;end;

if g_currentMission.hlUtils.getDistance==nil then g_currentMission.hlUtils.getDistance=
function(currentPosition, targetPosition, searchCurrentPosition)
	local cPos, tPos = currentPosition, targetPosition;
	local distance = -1;
	if tPos == nil then return distance;end;
	if currentPosition == nil and searchCurrentPosition ~= nil and searchCurrentPosition:lower() == "vehicle" or searchCurrentPosition:lower() == "player" then	
		local currentTyp = searchCurrentPosition:lower();
		local cX, cY, cZ = 0,0,0;
		if currentTyp == "vehicle" then 
			if not g_currentMission.hlUtils.isControlledVehicle() then return distance;end;
			local vehicle = g_currentMission.hlUtils.getControlledVehicle();
			if vehicle == nil or vehicle.steeringAxleNode == nil then return distance;end;
			cX, cY, cZ = getWorldTranslation(vehicle.steeringAxleNode);			
		else
			cX, cY, cZ = g_localPlayer:getPosition();
		end;
		if cX ~= nil and cY ~= nil and cZ ~= nil then cPos = {x=cX,y=cY,z=cZ};end;
	else
		return distance;
	end;
	return g_currentMission.hlUtils.getObjectDistance(cPos, tPos);
end;end;
--update 0.98
--update 0.99
if g_currentMission.hlUtils.getUiScale==nil then g_currentMission.hlUtils.getUiScale=
function()
	return g_gameSettings:getValue("uiScale");
end;end;
if g_currentMission.hlUtils.isNewUiScale==nil then g_currentMission.hlUtils.isNewUiScale=
function(uiScale)	
	if uiScale == nil then return false;end;
	return g_currentMission.hlUtils.getUiScale() ~= uiScale;
end;end;	
--update 0.99
--update 1.00
if g_currentMission.hlUtils.getRandomByKey==nil then g_currentMission.hlUtils.getRandomByKey=
function(tab)
	if tab == nil or type(tab) ~= "table" then return "";end;
	local sum = 0;
	for _, chance in pairs(tab) do
		sum = sum + chance;
	end;
	local select = math.random() * sum;
	for key, chance in pairs(tab) do
		select = select - chance;
		if select < 0 then return key end;
	end;
end;end;
--update 1.00
end;
