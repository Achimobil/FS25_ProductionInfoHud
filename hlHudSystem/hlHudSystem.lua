hlHudSystem = {};

hlHudSystem.metadata = {
	interface = "FS25 ...",
	title = "HL Hud System",
	notes = "Erstellt Hud/PDA und Box Anzeigen für Mods etc. zum selbst befüllen von Daten/Icons etc. um diese im Spiel anzuzeigen",
	author = "(by HappyLooser)",
	version = "v1.36 Beta",
	systemVersion = 1.34,
	xmlVersion = 1,
	languageVersion = 1;
	datum = "21.05.2023",
	update = "15.12.2024",
	web = "no",
	info = "Link Freigabe und Änderungen ist ohne meine Zustimmung nicht erlaubt",
	info1 = "Benutzung als HUD System in einem Mod (ohne Code Änderung) ist ohne Zustimmung erlaubt",
	"##Orginal Link Freigabe:"
};

hlHudSystem.modDir = g_currentModDirectory;
function hlHudSystem:loadMap()
	if hlHudSystem:getDetiServer() then return;end;
	Mission00.onStartMission = Utils.prependedFunction(Mission00.onStartMission, hlHudSystem.onStartMission);
	if g_currentMission.hlHudSystem == nil then
		g_currentMission.hlHudSystem = {};
		g_currentMission.hlHudSystem.version = hlHudSystem.metadata.systemVersion;
		g_currentMission.hlHudSystem.xmlVersion = hlHudSystem.metadata.xmlVersion;
		g_currentMission.hlHudSystem.modDir = hlHudSystem.modDir;
		g_currentMission.hlHudSystem.meta = hlHudSystem.metadata;
	else
		if g_currentMission.hlHudSystem.version < hlHudSystem.metadata.systemVersion then
			g_currentMission.hlHudSystem = {};
			g_currentMission.hlHudSystem.version = hlHudSystem.metadata.systemVersion;
			g_currentMission.hlHudSystem.xmlVersion = hlHudSystem.metadata.xmlVersion;
			g_currentMission.hlHudSystem.modDir = hlHudSystem.modDir;
			g_currentMission.hlHudSystem.meta = hlHudSystem.metadata;
		else
			if g_currentMission.hlHudSystem.version > hlHudSystem.metadata.systemVersion then
				print("---Info: Not loading ".. tostring(hlHudSystem.metadata.title).. " over Mod, found newer Version (".. tostring(g_currentMission.hlHudSystem.meta.version).. ")")
			end;
		end;		
	end;	
end;

function hlHudSystem.onStartMission()	
	if g_currentMission == nil or g_currentMission.hlHudSystem == nil or g_currentMission.hlHudSystem.modDir ~= hlHudSystem.modDir or g_currentMission.hlUtils == nil then
		if g_currentMission.hlUtils == nil then
			print("---WARNING ".. tostring(hlHudSystem.metadata.title).. " needs HL Utils Script by HappLooser, deinstalled HL Hud System")
		end;
		removeModEventListener(hlHudSystem);
	else
		if hlHudSystem:getDetiServer() then return;end;
		print("---loading ".. tostring(hlHudSystem.metadata.title).. " ".. tostring(hlHudSystem.metadata.version).. " ".. tostring(hlHudSystem.metadata.author).. "---")
		createFolder(getUserProfileAppPath().. "modSettings/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/languages/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/hud/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/pda/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/box/");
		createFolder(getUserProfileAppPath().. "modSettings/HL/HudSystem/guibox/");
		loadScripts();		
		g_currentMission.hlHudSystem = hlHudSystem.new();		
		g_currentMission.hlHudSystem.hlHud = hlHud;
		g_currentMission.hlHudSystem.hlPda = hlPda;
		g_currentMission.hlHudSystem.hlBox = hlBox;
		g_currentMission.hlHudSystem.hlGuiBox = hlGuiBox; --simple Gui Box
		hlHudSystemXml:load(hlHudSystem.metadata.title);		
		hlCamBoxXml:loadBox("hlHudSystem_CameraBox");
		hlOwnGuiBoxXml:loadGuiBox();		
		---enable this hud bsp. only for testing, then deactivate it again---
		--local hud = hlHud.generate( {name="hlHudSystem_OwnHud", info="HL Hud System Own Bsp. Hud\nReal Time Day by HappyLooser"} );
		--hud.onDraw = hlHudOwnDraw.setHud; --own hud
		--hud.onClick = hlHudOwnMouseKeyEvents.onClick; --own hud			
		--hud.onSaveXml = hlHudOwnXml.onSaveXml; --own hud
		--hlHudOwnXml:onLoadXml(hud, hud:getXml()); --own hud load over Xml		
		---enable this hud bsp. only for testing, then deactivate it again---
		g_currentMission.hlHudSystem.onLoadComplete = g_currentMission.hlHudSystem.onLoadComplete+1;
	end;
end;

function hlHudSystem:delete()
	
end;

function hlHudSystem:deleteMap()
	if g_currentMission == nil then return;end;
	if hlHudSystem:getDetiServer() then return;end;
	hlHudSystemXml:save(); --save all Hud/Pda/Box
	hlHudSystemOverlays:deleteAllOverlays();	
end;

function hlHudSystem:mouseEvent(posX, posY, isDown, isUp, button)
	if g_currentMission == nil then return;end;
	if hlHudSystem:getDetiServer() or not hlHudSystem:getHudIsVisible() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;	
	hlHudSystemMouseKeyEvents:setKeyMouse(nil, nil, nil, nil, posX, posY, isDown, isUp, button);
end;

function hlHudSystem:keyEvent(unicode, sym, modifier, isDown)	
	if g_currentMission == nil then return;end;
	if hlHudSystem:getDetiServer() or not hlHudSystem:getHudIsVisible() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;
	hlHudSystemMouseKeyEvents:setKeyMouse(unicode, sym, modifier, isDown, nil, nil, nil, nil, nil);
end;

function hlHudSystem:update(dt)	
	if g_currentMission == nil then return;end;
	if hlHudSystem:getDetiServer() or not hlHudSystem:getHudIsVisible() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;
	if not g_currentMission.hlUtils.isMouseCursor then g_currentMission.hlHudSystem.clickAreas = {};end;
	if g_currentMission.hlHudSystem.infoDisplay.firstStart and g_currentMission.hlUtils.isMouseCursor then hlHudSystem.firstInfo();end;
	if g_currentMission.hlHudSystem.guiMenu.ownTable ~= nil and g_currentMission.hlHudSystem.guiMenu.ownTable.modHiddenLinesLoaded ~= nil and not g_currentMission.hlHudSystem.guiMenu.ownTable.modHiddenLinesLoaded then hlOwnGuiBoxXml:setModHiddenLines();end;
	if g_currentMission.hlHudSystem.infoBox ~= nil then hlInfoBox:update(dt);end;
end;

function hlHudSystem:draw()	
	if g_currentMission == nil then return;end;
	if hlHudSystem:getDetiServer() or not hlHudSystem:getHudIsVisible() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;
	--respect settings for other mods (not every mod) that's why
	setTextAlignment(0);
	setTextLineBounds(0, 0);
	setTextWrapWidth(0);
	setTextColor(1, 1, 1, 1);
	setTextBold(false);
	--respect settings for other mods	
		
	hlHudSystemDraw.showHuds();	
	if g_currentMission.hlHudSystem.infoBox ~= nil then hlInfoBox:draw();end;
	
	if #g_currentMission.hlHudSystem.testString > 0 then
		setTextBold(true);		
		for a=1, #g_currentMission.hlHudSystem.testString do
			local posY = 0.25-(a/100);
			renderText(0.5, posY, 0.010, "-S ".. tostring(a).. "- ".. tostring(g_currentMission.hlHudSystem.testString[a]));
		end;
	end;
	--respect settings for other mods
	setTextAlignment(0);
	setTextLineBounds(0, 0);
	setTextWrapWidth(0);
	setTextColor(1, 1, 1, 1);
	setTextBold(false);
	--respect settings for other mods	
end;

function hlHudSystem.new()	
	local hlHudSystem_mt = Class(hlHudSystem);
	local self = {};

	setmetatable(self, hlHudSystem_mt);
	
	self.hud = {};
	self.pda = {};
	self.box = {};
	self.guiBox = {}; --simple Gui Box	
	self.other = {};	
	
	self.camera = {active=false,node=0,overlay=0,object={interAction=false,isVehicle=false,node=0,data={}}};
	self.settingsDir = getUserProfileAppPath().. "modSettings/HL/HudSystem/";	
	self.modDir = hlHudSystem.modDir;	
	self.metadata = hlHudSystem.metadata;
	self.screen = hlHudSystemScreen.new( {typ="hud", master=true} );
	self.overlays = hlHudSystemOverlays.new( {loadDefaultIcons=false, screen=self.screen, typ="hud", master=true} );	
	self.isSetting = {hud=false,pda=false,box=false,other=false,viewFrame=false};
	self.infoDisplay = {on=true, firstStart=true};	
	self.ownData = {textTickerSaveState=false, mpOff=false, isHidden=false, hiddenMods={}};	
	self.autoAlign = hlHudSystemAutoAlign:getTables();
	self.drawIsIngameMapLarge = true;
	self.language = "_".. string.lower(g_languageShort);
	self.isSave = true;
	self.timer = {firstInfo=80};	
	self.callbacks = {};
	self.testString = {};
	self.clickAreas = {};
	self.areas = {}; --own for Setting Icons etc.
	self.alreadyExistsXml = {hud={}, pda={}, box={}, guibox={}, other={} };
	self.isAlreadyExistsXml = function(typ, name) return self.alreadyExistsXml[typ][name];end;	
	self.setMapHotspot = function(objects, color, blinking, insert)	g_currentMission.hlUtils.generateObjectMapHotspot( {objects=objects, color=color, file=g_currentMission.hlHudSystem.modDir.. "hlHudSystem/icons/icons.dds", fileFormat={64, 512, 1024, 15}, blinking=blinking, insert=insert} );end;
	----
	self.setAllGuiBoxOff = function() g_currentMission.hlHudSystem.hlGuiBox:setShow();end;	
	--self.camBox = {setObject=function(args) hlCamBox:setObject(args);end;
	--			deleteObject=function(camBox) hlCamBox:deleteObject(camBox);end;
	--			setShow=function(state) hlCamBox:setShow(state);end;
	--};	
	----
	self.guiMenu = {};
	self.textTicker = hlTextTicker.new( {update=true,draw=true,delete=false,mouseInteraction=true} );	
	self.infoBox = hlHudSystemOverlays:generateInfoBox();
	self.showInfoBox = function(args) hlInfoBox:addInfo(unpack(args));end;
	self.onLoadComplete = 0;
	
	return self;
end;

function hlHudSystem:addTextDisplay(args)
	if args == nil or type(args) ~= "table" then return;end;
	if args.txtSize == nil then args.txtSize = 0.013;end; --default
	if args.posY == nil then args.posY = 0.12;end; --default
	g_currentMission.hlUtils.addTextDisplay(args);
end;

function loadScripts()		
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemAutoAlign.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemXml.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemScreen.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemOverlays.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlHud/hlHud.lua");		
	source(hlHudSystem.modDir.."hlHudSystem/hlPda/hlPda.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlBox/hlBox.lua");	
	source(hlHudSystem.modDir.."hlHudSystem/hlGuiBox/hlGuiBox.lua"); --simple Gui Box	
	source(hlHudSystem.modDir.."hlHudSystem/hlCamBox/hlCamBox.lua"); --simple Camera Box
	source(hlHudSystem.modDir.."hlHudSystem/hlOthers/hlInfoBox.lua"); --simple Info Box
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemMouseKeyEvents.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlHudSystemDraw.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlTextTicker/hlTextTicker.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlTextTicker/hlOwnTextTicker.lua");
	source(hlHudSystem.modDir.."hlHudSystem/hlTextTicker/hlTextTickerMouseKeyEvents.lua");
end;

function hlHudSystem:getDetiServer()	
	return g_dedicatedServer ~= nil;
end;

function hlHudSystem:getHudIsVisible() --by Giants
	return g_currentMission.hud.isVisible and not g_noHudModeEnabled;
end;

function hlHudSystem.autoSave()
	if hlHudSystem:getDetiServer() then return;end;
	if g_currentMission.missionDynamicInfo.isMultiplayer and g_currentMission.hlHudSystem.ownData.mpOff then return;end;
	hlHudSystemXml:save(true);
	if g_currentMission.hlHudSystem.guiMenu.ownTable.saveInfo[1] > 1 then		
		g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, "HL Hud System INFO: ".. g_i18n:getText("ui_autosave", "Auto Save"), 2500);
	end;
end;

function hlHudSystem.firstInfo()
	if not g_currentMission.hlHudSystem.infoDisplay.firstStart then return;end;
	g_currentMission.hlHudSystem.infoDisplay.firstStart = false;
	hlHudSystem:setFirstInfo();
end;

function hlHudSystem:setFirstInfo()
	g_currentMission.hlUtils.deleteTextDisplay(); --delete Info
	g_currentMission.hud:showInGameMessage("HL Hud System Info",  g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_firstStart"), -1);
	g_currentMission.hlUtils.deleteTextDisplay(); --delete Info
end;

function hlHudSystem:setClickArea(args) --free onClick areas somewhere on screen	
	if args == nil or type(args) ~= "table" or args.whatClick == nil or type(args.whatClick) ~= "string" or args.onClick == nil or type(args.onClick) ~= "function" then return;end;
	if not g_currentMission.hlUtils.isMouseCursor then
		self.clickAreas = {};
		return;
	end;
	if self.clickAreas[args.whatClick] == nil then self.clickAreas[args.whatClick] = {};end;
	self.clickAreas[args.whatClick][#self.clickAreas[args.whatClick]+1] = {
		args[1]; --posX needs
		args[2]; --posX1 needs
		args[3]; --posY needs
		args[4]; --posY1 needs		
		whatClick = args.whatClick; --needs	a string		
		whereClick = args.whereClick; --optional or use ownTable		
		areaClick = args.areaClick; --optional
		overlay = args.overlay; --optional
		ownTable = args.ownTable; --optional
		onClick = args.onClick; --needs for mouse click area callback
	};	
end;

function hlHudSystem:searchFilter(typ, resetBounds, dialogTxt)
	local text = g_i18n:getText("button_apply");
	local confirmText = g_i18n:getText("helpLine_FarmingBasics_MapFilters_filters_title").. "/".. g_i18n:getText("button_apply");
	local backText = g_i18n:getText("button_close").. "/".. g_i18n:getText("button_delete")
	local dialogText = dialogTxt or "Search (min. 1 Letter)\n* first + min. 1 Letter\nBsp: *hor -> w -> ha -> *ors ...";
	
	if ls25Convert then
		g_gui:showTextInputDialog({
			text = text,
			defaultText = typ.searchFilter,
			callback = function (result, yes)
				if yes then
					if result:len() < 1 or (result:len() == 1 and string.find(result, "*")) then
						typ:setSearchFilter("", false);					
					else
						typ:setSearchFilter(tostring(result), resetBounds);														
					end;				
				else
					typ:setSearchFilter("", resetBounds);
				end;			
			end,
			dialogPrompt = dialogText,
			imePrompt = g_i18n:getText("modHub_search"),
			confirmText = confirmText,
			backText = backText;
			maxCharacters = 30,
			disableFilter = true		
		})
	else
		local text = g_i18n:getText("button_apply");
		local okayText = g_i18n:getText("button_apply"); --g_i18n:getText("helpLine_FarmingBasics_MapFilters_filters_title").. "/".. g_i18n:getText("button_apply"); --to long ?
		local backText = g_i18n:getText("button_close").. "/".. g_i18n:getText("button_delete")
		local dialogPrompt = dialogTxt or "Search (min. 1 Letter)\n* first + min. 1 Letter\nBsp: *hor -> w -> ha -> *ors ...";
		local title = g_i18n:getText("modHub_search"); --?
		local callback = function (result, yes)
			if yes then
				if result:len() < 1 or (result:len() == 1 and string.find(result, "*")) then
					typ:setSearchFilter("", false);					
				else
					typ:setSearchFilter(tostring(result), resetBounds);					
				end;				
			else
				typ:setSearchFilter("", resetBounds);				
			end;			
		end;
		local dialog = g_gui:showDialog("TextInputDialog");
		dialog.target:setTitle(title); --not active
		dialog.target:setText(dialogPrompt);
		--dialog.target:setMaxCharacter(30); --default is 30
		dialog.target:setDialogType(DialogElement.TYPE_QUESTION);
		dialog.target:setButtonTexts(okayText, backText);
		dialog.target:setCallback(callback, nil, typ.searchFilter);		
	end;
end;

function hlHudSystem:yesNoDialog(args)	
	if ls25Convert then
		g_gui:showYesNoDialog({				
			text = args.text or "";
			title = args.title or "Mod Info"; 				
			callback = function(yes)
				if yes then
					args.callback(true, args.ownTable);
				else
					args.callback(false, args.ownTable);
				end
			end,				
		})
	else
		local callback = function(yes)
			if yes then
				args.callback(true, args.ownTable);
			else
				args.callback(false, args.ownTable);
			end;
		end;
		local dialog = g_gui:showDialog("YesNoDialog");
		dialog.target:setTitle(args.title or "Mod Info");
		dialog.target:setText(args.text or "");	
		dialog.target:setCallback(callback);	
	end;
end;														
addModEventListener(hlHudSystem);