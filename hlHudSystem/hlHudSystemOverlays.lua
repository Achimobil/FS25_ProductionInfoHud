hlHudSystemOverlays = {};

local hlHudSystemOverlays_mt = Class(hlHudSystemOverlays);

function hlHudSystemOverlays.new(args)	
	
	local self = {};

	setmetatable(self, hlHudSystemOverlays_mt);
		
	if args.screen == nil then args.screen = g_currentMission.hlHudSystem.screen;end;
	self.bg = hlHudSystemOverlays:insertOverlay( {name="background", screen=args.screen, width=args.width, height=args.height, iconPos=120} );	
	self.bgFrame = hlHudSystemOverlays:insertOverlay( {name="background", color=hlHudSystemOverlays.color.backgroundSetting, screen=args.screen, width=args.width, height=args.height, iconPos=120} );
	self.state = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, color=hlHudSystemOverlays.color.backgroundState ,iconPos=114, setStateInArea=true} );
	self.statePercent = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, color=hlHudSystemOverlays.color.backgroundState, iconPos=113, setStateInArea=true} );
	self.bgLine = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=127, setStateInArea=true} );	
	self.bgLine.visible = false; --hidden line for marker/select click areas or ....
	if args.typ == "hud" then
		self.separator = hlHudSystemOverlays:insertOverlay( {name="separator", screen=args.screen, iconPos=120} );		
		self.inArea = hlHudSystemOverlays:insertOverlay( {name="inArea", screen=args.screen, width=args.width, iconPos=120} ); 
		self.selectArea = hlHudSystemOverlays:insertOverlay( {name="selectArea", screen=args.screen, width=args.width, iconPos=120} );
	end;	
	self.settingIcons = {};
	self.settingIcons.bgBlack = hlHudSystemOverlays:insertOverlay( {name="backgroundSetting", color="black", screen=args.screen, iconPos=120, setStateInArea=true} );
	setOverlayColor(self.settingIcons.bgBlack.overlayId, 0, 0, 0, 1); --problem with default color option and black ? set here color
	self.settingIcons.bgRoundBlack = hlHudSystemOverlays:insertOverlay( {name="backgroundSetting", color="black", screen=args.screen, iconPos=119, setStateInArea=true} );
	setOverlayColor(self.settingIcons.bgRoundBlack.overlayId, 0, 0, 0, 1); --problem with default color option and black ? set here color
	self.settingIcons.dragDrop = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=55, setStateInArea=true} );	
	self.settingIcons.sizeWidthHeight = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.on, screen=args.screen, iconPos=54, setStateInArea=true} );
	self.settingIcons.setting = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.on, screen=args.screen, iconPos=20, setStateInArea=true} );	
	self.settingIcons.settingO = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.on, screen=args.screen, iconPos=58, setStateInArea=true} );
	self.settingIcons.leftRight = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.text, screen=args.screen, iconPos=56, setStateInArea=true} ); --speziale small		
	self.settingIcons.view = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.on, screen=args.screen, iconPos=35, setStateInArea=true} );
	self.settingIcons.save = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.on, screen=args.screen, iconPos=17, setStateInArea=true} );
	self.settingIcons.help = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=13, setStateInArea=true} );
	self.settingIcons.info = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=30, setStateInArea=true} );
	self.settingIcons.search = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=59, setStateInArea=true} );
	self.settingIcons.search.visible = false; --default hidden
	if args.typ == "pda" or args.typ == "box" then		
		self.settingIcons.markerWidthHeight = hlHudSystemOverlays:insertOverlay( {name="icon", screen=args.screen, iconPos=53, setStateInArea=true} );
		self.settingIcons.autoClose = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.notActive, screen=args.screen, iconPos=42, setStateInArea=true} );
		self.settingIcons.close = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.off, screen=args.screen, iconPos=50, setStateInArea=true} );
		self.settingIcons.up = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.text, screen=args.screen, iconPos=3, setStateInArea=true} );
		self.settingIcons.up.visible = false; --default hidden
		self.settingIcons.down = hlHudSystemOverlays:insertOverlay( {name="icon", color=hlHudSystemOverlays.color.text, screen=args.screen, iconPos=2, setStateInArea=true} );
		self.settingIcons.down.visible = false; --default hidden
	end;
	if args.loadDefaultIcons ~= nil and args.loadDefaultIcons then
		self.icons = {byName={}};
		g_currentMission.hlUtils.insertIcons( {xmlTagName="hlHudSystem.loadIcons", modDir=g_currentMission.hlHudSystem.modDir, iconFile="hlHudSystem/icons/icons.dds", xmlFile="hlHudSystem/icons/icons.xml", modName="defaultIcons", groupName=tostring(args.typ), fileFormat={64,512,1024}, setStateInArea=true, iconTable=self.icons} );
	end;
	self.modIcons = {byName={}}; --optional insert Mods Icons here (with g_currentMission.hlUtils.insertIcons(....) ) or set new table ( !Attention! mod delete not new table)
		
	return self;
end;

function hlHudSystemOverlays:insertOverlay(args)	
	local iconFilePath = Utils.getFilename(args.fileName or "hlHudSystem/icons/icons.dds", args.modDir or g_currentMission.hlHudSystem.modDir);
	if iconFilePath == nil then return nil;end;
	local height = 0; 
	local color = args.color or hlHudSystemOverlays.color[args.name] 
	if color == nil then color = hlHudSystemOverlays.color["background"];end;
	local width = 0;
	if args.height ~= nil and args.screen ~= nil then
		height = args.screen.pixelH*args.height;
	elseif args.screen ~= nil then
		if args.name ~= nil and args.name == "background" then
			height = args.screen.size.background[2];
		end;
	elseif args.height ~= nil then
		height = g_currentMission.hlHudSystem.screen.pixelH*args.height;
	end;
	if args.width ~= nil and args.screen ~= nil then
		width = args.screen.pixelW*args.width;
	elseif args.screen ~= nil then		
		if args.name ~= nil and args.name == "background" then
			width = args.screen.size.background[1];
		end;
	elseif args.width ~= nil then
		width = g_currentMission.hlHudSystem.screen.pixelW*args.width;
	end;
	local overlay = Overlay.new(iconFilePath, 0, 0, width, height);
	local formatO = 64;
	local sW = 512;
	local sH = 1024;
	local iconPos = 1;
	if args.iconPos ~= nil and type(args.iconPos) == "number" then
		iconPos = args.iconPos or 1;
		if args.fileFormat ~= nil then
			formatO = args.fileFormat[1] or 0;
			sW = args.fileFormat[2] or 0;
			sH = args.fileFormat[3] or 0;
		end;	
	end;
	g_currentMission.hlUtils.setOverlayUVsPx(overlay, unpack(g_currentMission.hlUtils.getNormalUVs(formatO, sW, sH, iconPos)));
	overlay.mouseInArea = false;
	if args.setStateInArea ~= nil and args.setStateInArea then g_currentMission.hlUtils.setStateInArea(overlay);end;
	
	g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor(color, true));
	
	if args.name ~= nil and args.name == "background" and args.screen ~= nil then
		args.screen.width = width;
		args.screen.height = height;
	end;
	return overlay;
end;

function hlHudSystemOverlays:setColorStyle(styleName) --for player other switch colors ?
	if styleName == nil or self[styleName.. "Color"] == nil then return;end;
	self.color = g_currentMission.hlUtils.getTableCopy(self[styleName.. "Color"]);
end;

function hlHudSystemOverlays:getColorStyle()
	return self.color.style or "unknown";
end;

function hlHudSystemOverlays:generateColorStyle(styleName,colors)
	if styleName == nil or type(colors) ~= "table" then return;end;
	self[styleName.. "Color"] = colors;
	if self[styleName.. "Color"].style == nil then self[styleName.. "Color"].style = styleName;end;
end;
	
hlHudSystemOverlays.color = {
	style = "ls25";
	background = "ls25bg";
	backgroundSetting = "black";
	backgroundState = "blackInactive";
	separator = "whiteInactive";	
	inArea = "ls25active";
	selectArea = "ls25";
	isShow = "ls25";
	icon = "darkGray";
	notActive = "darkGray";
	active = "ls25active";
	title = "ls25";
	text = "white";
	columTitle = "gold";
	columText1 = "khaki";
	columText2 = "mangenta";
	on = "green";
	off = "red";
	warning = "yellow";
	globalSettingOn = "darkGreen";
	globalSettingOff = "darkGray";
	settingOn = "darkGreen";
	settingOff = "darkGray";	
};

hlHudSystemOverlays.ls22Color = {
	style = "ls22";
	background = "blackDisabled";
	backgroundSetting = "black";
	backgroundState = "blackInactive";
	separator = "whiteInactive";	
	inArea = "ls15";
	selectArea = "ls22";
	isShow = "ls22";
	icon = "darkGray";
	notActive = "darkGray";
	active = "ls15";
	title = "ls22";
	text = "white";
	columTitle = "gold";
	columText1 = "khaki";
	columText2 = "mangenta";
	on = "green";
	off = "red";
	warning = "yellow";
	globalSettingOn = "ls22";
	globalSettingOff = "darkGray";
	settingOn = "ls22";
	settingOff = "darkGray";	
};

	
hlHudSystemOverlays.ls25Color = {
	style = "ls25";
	background = "ls25bg";
	backgroundSetting = "black";
	backgroundState = "blackInactive";
	separator = "whiteInactive";	
	inArea = "ls25active";
	selectArea = "ls25";
	isShow = "ls25";
	icon = "darkGray";
	notActive = "darkGray";
	active = "ls25active";
	title = "ls25";
	text = "white";
	columTitle = "gold";
	columText1 = "khaki";
	columText2 = "mangenta";
	on = "green";
	off = "red";
	warning = "yellow";
	globalSettingOn = "darkGreen";
	globalSettingOff = "darkGray";
	settingOn = "darkGreen";
	settingOff = "darkGray";	
};

function hlHudSystemOverlays:deleteAllOverlays()
	function deleteOverlays(typ, debugPrint, txt)		
		g_currentMission.hlUtils.deleteOverlays(typ.overlays.settingIcons, debugPrint, txt.. " settingIcons");		
		g_currentMission.hlUtils.deleteOverlays(typ.overlays, debugPrint, txt.. " default");
		if typ.overlays.icons ~= nil then
			for modName,groupTable in pairs (typ.overlays.icons) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(typ.overlays.icons[modName][groupName], debugPrint, txt.. " icons");						
					end;
				end;
			end;
		end;
		if typ.overlays.modIcons ~= nil then
			for modName,groupTable in pairs (typ.overlays.modIcons) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(typ.overlays.modIcons[modName][groupName], debugPrint, txt.. " modIcons");						
					end;
				end;
			end;
		end;		
	end;
	function deleteGuiOverlays(typ, debugPrint, txt)
		if typ.overlays ~= nil then
			for modName,groupTable in pairs (typ.overlays) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(typ.overlays[modName][groupName], debugPrint, txt.. " icons");						
					end;
				end;
			end;
		end;
	end;
	if g_currentMission.hlHudSystem.guiBox ~= nil and #g_currentMission.hlHudSystem.guiBox > 0 then
		for g=1, #g_currentMission.hlHudSystem.guiBox do
			deleteGuiOverlays(g_currentMission.hlHudSystem.guiBox[g], false, "GuiBox ".. tostring(g));
		end;
	end;
	if g_currentMission.hlHudSystem.hud ~= nil and #g_currentMission.hlHudSystem.hud > 0 then
		for h=1, #g_currentMission.hlHudSystem.hud do
			deleteOverlays(g_currentMission.hlHudSystem.hud[h], false, "Hud ".. tostring(h));
		end;		
	end;
	if g_currentMission.hlHudSystem.pda ~= nil and #g_currentMission.hlHudSystem.pda > 0 then
		for p=1, #g_currentMission.hlHudSystem.pda do
			deleteOverlays(g_currentMission.hlHudSystem.pda[p], false, "Pda ".. tostring(p));
		end;
	end;
	if g_currentMission.hlHudSystem.box ~= nil and #g_currentMission.hlHudSystem.box > 0 then
		for b=1, #g_currentMission.hlHudSystem.box do
			deleteOverlays(g_currentMission.hlHudSystem.box[b], false, "Box ".. tostring(b));
		end;
	end;
	if g_currentMission.hlHudSystem.textTicker ~= nil then g_currentMission.hlHudSystem.textTicker.deleteOverlays();end;
	deleteOverlays(g_currentMission.hlHudSystem, false, "HL Hud System");
end;

function hlHudSystemOverlays:generateGuiBoxIcons()
	local overlays = {byName={}};	
	g_currentMission.hlUtils.insertIcons( {xmlTagName="hlHudSystem.guiBoxIcons", modDir=g_currentMission.hlHudSystem.modDir, iconFile="hlHudSystem/icons/icons.dds", xmlFile="hlHudSystem/icons/icons.xml", modName="defaultIcons", groupName="guiBox", fileFormat={64,512,1024}, setStateInArea=true, iconTable=overlays} );
	return overlays;
end;

function hlHudSystemOverlays:generateInfoBox()
	local uiScale = g_gameSettings:getValue(GameSettings.SETTING.UI_SCALE)
	local infoBox = WarningDisplay.new();
	infoBox:setScale(uiScale);
	infoBox:setVisible(false);
	infoBox.setInfo = function(args)
		hlInfoBox.addInfo(unpack(args));
	end;
	hlInfoBox:storeScaledValues(infoBox);
	return infoBox
end;