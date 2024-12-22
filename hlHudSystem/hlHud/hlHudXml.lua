hlHudXml = {};

local hlHudXml_mt = Class(hlHudXml);

function hlHudXml.new(args)	
	
	local self = {};

	setmetatable(self, hlHudXml_mt);
	
	self.deleteXml = false; --default not delete XML File
	self.file = nil;
	self.xmlNameTag = nil;
	
	local path = g_currentMission.hlHudSystem.settingsDir.. "hud/";
	if fileExists(path.. args.fileName.. ".xml") then
		self.file = loadXMLFile("HlHudSystem_XML", path.. args.fileName.. ".xml", "hlHudSystemXML");
		if self.file ~= nil then
			self.xmlNameTag = ("hlHudSystemXML.ownValues(%d)"):format(0);
			hlHudXml:loadDefault(self.file);
			hlHudXml:loadScreen(args.screen, self.file);
			hlHudXml:loadOther(self.file);
		end;
	end;
	return self;
end;

function hlHudXml:delete(fileName)
	local path = g_currentMission.hlHudSystem.settingsDir.. "hud/";
	if fileExists(path.. fileName.. ".xml") then
		if self.deleteXml then
			deleteFile(path.. fileName.. ".xml");
		end;
	end;
end;

function hlHudXml:loadDefault(Xml)
	local xmlNameTag = ("hlHudSystemXML"):format(0);	
	if getXMLInt(Xml, xmlNameTag.."#hudPosition") ~= nil then self.hudPos = getXMLInt(Xml, xmlNameTag.."#hudPosition");end;
	if getXMLBool(Xml, xmlNameTag.."#show") ~= nil then self.show = getXMLBool(Xml, xmlNameTag.."#show");end;
	if getXMLString(Xml, xmlNameTag.."#displayName") ~= nil then self.displayName = getXMLString(Xml, xmlNameTag.."#displayName");end;
end;

function hlHudXml:loadScreen(screen, Xml)
	local xmlNameTag = ("hlHudSystemXML"):format(0);
	local groupNameTag = (xmlNameTag.. ".screen(%d)"):format(0);	
	if getXMLFloat(Xml, groupNameTag.."#posX") ~= nil then screen.posX = getXMLFloat(Xml, groupNameTag.."#posX");end;
	if getXMLFloat(Xml, groupNameTag.."#posY") ~= nil then screen.posY = getXMLFloat(Xml, groupNameTag.."#posY");end;
	if getXMLFloat(Xml, groupNameTag.."#width") ~= nil then screen.width = getXMLFloat(Xml, groupNameTag.."#width");end;
	if getXMLFloat(Xml, groupNameTag.."#height") ~= nil then screen.height = getXMLFloat(Xml, groupNameTag.."#height");end;
	if getXMLFloat(Xml, groupNameTag.."#difWidth") ~= nil then screen.difWidth = getXMLFloat(Xml, groupNameTag.."#difWidth");end;
	if getXMLFloat(Xml, groupNameTag.."#difHeight") ~= nil then screen.difHeight = getXMLFloat(Xml, groupNameTag.."#difHeight");end;
	
	--size bg--
	groupNameTag = (xmlNameTag.. ".size.bg(%d)"):format(0);
	if getXMLFloat(Xml, groupNameTag.."#width") ~= nil then screen.size.background[1] = getXMLFloat(Xml, groupNameTag.."#width");end;
	if getXMLFloat(Xml, groupNameTag.."#height") ~= nil then screen.size.background[2] = getXMLFloat(Xml, groupNameTag.."#height");end;
	if getXMLFloat(Xml, groupNameTag.."#maxHeight") ~= nil then screen.size.background[3] = getXMLFloat(Xml, groupNameTag.."#maxHeight");end;
	if getXMLFloat(Xml, groupNameTag.."#minHeight") ~= nil then screen.size.background[4] = getXMLFloat(Xml, groupNameTag.."#minHeight");end;
	if getXMLFloat(Xml, groupNameTag.."#minWidth") ~= nil then screen.size.background[5] = getXMLFloat(Xml, groupNameTag.."#minWidth");end;	
	--size bg--
	--size icon--
	groupNameTag = (xmlNameTag.. ".size.icon(%d)"):format(0);
	if getXMLFloat(Xml, groupNameTag.."#difScaleWidth") ~= nil then screen.size.icon[1] = getXMLFloat(Xml, groupNameTag.."#difScaleWidth");end;
	if getXMLFloat(Xml, groupNameTag.."#difScaleHeight") ~= nil then screen.size.icon[2] = getXMLFloat(Xml, groupNameTag.."#difScaleHeight");end;
	--size icon--
	--size zoomOutIn text--
	groupNameTag = (xmlNameTag.. ".size.zoomOutIn.text(%d)"):format(0);
	if getXMLFloat(Xml, groupNameTag.."#textSize") ~= nil then screen.size.zoomOutIn.text[1] = getXMLFloat(Xml, groupNameTag.."#textSize");end;
	if getXMLFloat(Xml, groupNameTag.."#textSizeLevel") ~= nil then screen.size.zoomOutIn.text[2] = getXMLFloat(Xml, groupNameTag.."#textSizeLevel");end;
	if getXMLFloat(Xml, groupNameTag.."#maxTextSize") ~= nil then screen.size.zoomOutIn.text[3] = getXMLFloat(Xml, groupNameTag.."#maxTextSize");end;
	if getXMLFloat(Xml, groupNameTag.."#minTextSize") ~= nil then screen.size.zoomOutIn.text[4] = getXMLFloat(Xml, groupNameTag.."#minTextSize");end;
	--size zoomOutIn text--
	--size zoomOutIn icon--
	groupNameTag = (xmlNameTag.. ".size.zoomOutIn.icon(%d)"):format(0);
	if getXMLFloat(Xml, groupNameTag.."#iconSize") ~= nil then screen.size.zoomOutIn.icon[1] = getXMLFloat(Xml, groupNameTag.."#iconSize");end;
	if getXMLFloat(Xml, groupNameTag.."#iconSizeLevel") ~= nil then screen.size.zoomOutIn.icon[2] = getXMLFloat(Xml, groupNameTag.."#iconSizeLevel");end;
	if getXMLFloat(Xml, groupNameTag.."#maxIconSize") ~= nil then screen.size.zoomOutIn.icon[3] = getXMLFloat(Xml, groupNameTag.."#maxIconSize");end;
	if getXMLFloat(Xml, groupNameTag.."#minIconSize") ~= nil then screen.size.zoomOutIn.icon[4] = getXMLFloat(Xml, groupNameTag.."#minIconSize");end;
	--size zoomOutIn icon--
	--size distance--
	groupNameTag = (xmlNameTag.. ".size.distance(%d)"):format(0);
	if getXMLFloat(Xml, groupNameTag.."#width") ~= nil then screen.size.distance.width = getXMLFloat(Xml, groupNameTag.."#width");end;
	if getXMLFloat(Xml, groupNameTag.."#height") ~= nil then screen.size.distance.height = getXMLFloat(Xml, groupNameTag.."#height");end;
	if getXMLFloat(Xml, groupNameTag.."#iconWidth") ~= nil then screen.size.distance.iconWidth = getXMLFloat(Xml, groupNameTag.."#iconWidth");end;
	if getXMLFloat(Xml, groupNameTag.."#iconHeight") ~= nil then screen.size.distance.iconHeight = getXMLFloat(Xml, groupNameTag.."#iconHeight");end;
	if getXMLFloat(Xml, groupNameTag.."#textLine") ~= nil then screen.size.distance.textLine = getXMLFloat(Xml, groupNameTag.."#textLine");end;
	if getXMLFloat(Xml, groupNameTag.."#textWidth") ~= nil then screen.size.distance.textWidth = getXMLFloat(Xml, groupNameTag.."#textWidth");end;
	if getXMLFloat(Xml, groupNameTag.."#textHeight") ~= nil then screen.size.distance.textHeight = getXMLFloat(Xml, groupNameTag.."#textHeight");end;
	--size distance--
end;

function hlHudXml:loadOther(Xml)
	local xmlNameTag = ("hlHudSystemXML"):format(0);
	local groupNameTag = (xmlNameTag.. ".other(%d)"):format(0);
	if getXMLBool(Xml, groupNameTag.."#isHelp") ~= nil then self.isHelp = getXMLBool(Xml, groupNameTag.."#isHelp");end;
	if getXMLBool(Xml, groupNameTag.."#viewSeparator") ~= nil then self.viewSeparator = getXMLBool(Xml, groupNameTag.."#viewSeparator");end;
	if getXMLBool(Xml, groupNameTag.."#viewSettingIcons") ~= nil then self.viewSettingIcons = getXMLBool(Xml, groupNameTag.."#viewSettingIcons");end;
	if getXMLString(Xml, groupNameTag.."#autoZoomOutIn") ~= nil then self.autoZoomOutIn = getXMLString(Xml, groupNameTag.."#autoZoomOutIn");end;
end;

function hlHudXml:getXmlNameTag()	
	return self.xmlNameTag;	
end;

function hlHudXml:getXmlFile()	
	return self.file;	
end;

function hlHudXml:save(hud, hudNumber)
	local file = g_currentMission.hlHudSystem.settingsDir.. "hud/".. hud.name.. ".xml"
	local Xml = createXMLFile("HlHudSystem_XML", file, "hlHudSystemXML");	
	local xmlNameTag = ("hlHudSystemXML"):format(0);
	setXMLInt(Xml, xmlNameTag.."#version", g_currentMission.hlHudSystem.metadata.xmlVersion);
	setXMLString(Xml, xmlNameTag.."#name", tostring(hud.name));
	setXMLString(Xml, xmlNameTag.."#displayName", tostring(hud.displayName));
	setXMLInt(Xml, xmlNameTag.."#hudPosition", hudNumber);
	setXMLBool(Xml, xmlNameTag.."#show", hud.show);
	
	local groupNameTag = (xmlNameTag.. ".other(%d)"):format(0);
	setXMLBool(Xml, groupNameTag.."#isHelp", hud.isHelp);
	setXMLBool(Xml, groupNameTag.."#viewSettingIcons", hud.viewSettingIcons);
	setXMLBool(Xml, groupNameTag.."#viewSeparator", hud.viewSeparator);
	setXMLString(Xml, groupNameTag.."#autoZoomOutIn", tostring(hud.autoZoomOutIn));
	
	groupNameTag = (xmlNameTag.. ".screen(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#posX", hud.screen.posX);
	setXMLFloat(Xml, groupNameTag.."#posY", hud.screen.posY);
	setXMLFloat(Xml, groupNameTag.."#width", hud.screen.width);
	setXMLFloat(Xml, groupNameTag.."#height", hud.screen.height);
	setXMLFloat(Xml, groupNameTag.."#difWidth", hud.screen.difWidth);
	setXMLFloat(Xml, groupNameTag.."#difHeight", hud.screen.difHeight);
	
	groupNameTag = (xmlNameTag.. ".size.bg(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#width", hud.screen.size.background[1]);
	setXMLFloat(Xml, groupNameTag.."#height", hud.screen.size.background[2]);
	setXMLFloat(Xml, groupNameTag.."#minWidth", hud.screen.size.background[5]);
	setXMLFloat(Xml, groupNameTag.."#maxHeight", hud.screen.size.background[3]);
	setXMLFloat(Xml, groupNameTag.."#minHeight", hud.screen.size.background[4]);
	
	groupNameTag = (xmlNameTag.. ".size.icon(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#difScaleWidth", hud.screen.size.icon[1]);
	setXMLFloat(Xml, groupNameTag.."#difScaleHeight", hud.screen.size.icon[2]);
	
	groupNameTag = (xmlNameTag.. ".size.zoomOutIn.text(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#textSize", hud.screen.size.zoomOutIn.text[1]);
	setXMLFloat(Xml, groupNameTag.."#textSizeLevel", hud.screen.size.zoomOutIn.text[2]);
	setXMLFloat(Xml, groupNameTag.."#maxTextSize", hud.screen.size.zoomOutIn.text[3]);
	setXMLFloat(Xml, groupNameTag.."#minTextSize", hud.screen.size.zoomOutIn.text[4]);
	
	groupNameTag = (xmlNameTag.. ".size.zoomOutIn.icon(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#iconSize", hud.screen.size.zoomOutIn.icon[1]);
	setXMLFloat(Xml, groupNameTag.."#iconSizeLevel", hud.screen.size.zoomOutIn.icon[2]);
	setXMLFloat(Xml, groupNameTag.."#maxIconSize", hud.screen.size.zoomOutIn.icon[3]);
	setXMLFloat(Xml, groupNameTag.."#minIconSize", hud.screen.size.zoomOutIn.icon[4]);
	
	groupNameTag = (xmlNameTag.. ".size.distance(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#width", hud.screen.size.distance.width);
	setXMLFloat(Xml, groupNameTag.."#height", hud.screen.size.distance.height);
	setXMLFloat(Xml, groupNameTag.."#iconWidth", hud.screen.size.distance.iconWidth);
	setXMLFloat(Xml, groupNameTag.."#iconHeight", hud.screen.size.distance.iconHeight);
	setXMLFloat(Xml, groupNameTag.."#textLine", hud.screen.size.distance.textLine);
	setXMLFloat(Xml, groupNameTag.."#textWidth", hud.screen.size.distance.textWidth);
	setXMLFloat(Xml, groupNameTag.."#textHeight", hud.screen.size.distance.textHeight);
	
	if hud.onSaveXml ~= nil and type(hud.onSaveXml) == "function" then 
		groupNameTag = (xmlNameTag.. ".ownValues(%d)"):format(0);
		hud.onSaveXml(hud, Xml, groupNameTag);
	end;
	hud.isSave = true;
	saveXMLFile(Xml);
	delete(Xml);
end;