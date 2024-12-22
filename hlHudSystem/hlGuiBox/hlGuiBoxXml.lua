hlGuiBoxXml = {};

local hlGuiBoxXml_mt = Class(hlGuiBoxXml);

function hlGuiBoxXml.new(args)	
	
	local self = {};

	setmetatable(self, hlGuiBoxXml_mt);
	
	self.deleteXml = false; --default not delete XML File
	self.file = nil;
	self.xmlNameTag = nil;
	
	local path = g_currentMission.hlHudSystem.settingsDir.. "guibox/";
	if fileExists(path.. args.fileName.. ".xml") then
		self.file = loadXMLFile("HlHudSystem_XML", path.. args.fileName.. ".xml", "hlHudSystemXML");
		if self.file ~= nil then			
			self.xmlNameTag = ("hlHudSystemXML.ownValues(%d)"):format(0);
			--hlGuiBoxXml:loadDefault(self.file);
			hlGuiBoxXml:loadScreen(args.screen, self.file);
			--hlGuiBoxXml:loadOther(self.file);
		end;
	end;
	return self;
end;

function hlGuiBoxXml:delete(fileName)
	local path = g_currentMission.hlHudSystem.settingsDir.. "guibox/";
	if fileExists(path.. fileName.. ".xml") then
		if self.deleteXml then
			deleteFile(path.. fileName.. ".xml");
		end;
	end;
end;

function hlGuiBoxXml:loadDefault(Xml)
	local xmlNameTag = ("hlHudSystemXML"):format(0);	
	--if getXMLBool(Xml, xmlNameTag.."#show") ~= nil then self.show = getXMLBool(Xml, xmlNameTag.."#show");end;	
	--if getXMLString(Xml, xmlNameTag.."#displayName") ~= nil then self.displayName = getXMLString(Xml, xmlNameTag.."#displayName");end;
end;

function hlGuiBoxXml:loadScreen(screen, Xml)
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

function hlGuiBoxXml:loadOther(Xml)
	local xmlNameTag = ("hlHudSystemXML"):format(0);
	local groupNameTag = (xmlNameTag.. ".other(%d)"):format(0);
	--if getXMLBool(Xml, groupNameTag.."#drawIsIngameMapLarge") ~= nil then self.drawIsIngameMapLarge = getXMLBool(Xml, groupNameTag.."#drawIsIngameMapLarge");end;	
	--if getXMLBool(Xml, groupNameTag.."#isHelp") ~= nil then self.isHelp = getXMLBool(Xml, groupNameTag.."#isHelp");end;	
	--if getXMLBool(Xml, groupNameTag.."#viewSettingIcons") ~= nil then self.viewSettingIcons = getXMLBool(Xml, groupNameTag.."#viewSettingIcons");end;
	--if getXMLBool(Xml, groupNameTag.."#viewExtraLine") ~= nil then self.viewExtraLine = getXMLBool(Xml, groupNameTag.."#viewExtraLine");end;
	--if getXMLString(Xml, groupNameTag.."#autoZoomOutIn") ~= nil then self.autoZoomOutIn = getXMLString(Xml, groupNameTag.."#autoZoomOutIn");end;
	--if getXMLBool(Xml, groupNameTag.."#autoClose") ~= nil then self.autoClose = getXMLBool(Xml, groupNameTag.."#autoClose");end;
end;

function hlGuiBoxXml:getXmlNameTag()	
	return self.xmlNameTag;	
end;

function hlGuiBoxXml:getXmlFile()	
	return self.file;	
end;

function hlGuiBoxXml:save(guiBox, guiBoxPos)
	local file = g_currentMission.hlHudSystem.settingsDir.. "guibox/".. guiBox.name.. ".xml"
	local Xml = createXMLFile("HlHudSystem_XML", file, "hlHudSystemXML");	
	local xmlNameTag = ("hlHudSystemXML"):format(0);
	setXMLInt(Xml, xmlNameTag.."#version", g_currentMission.hlHudSystem.metadata.xmlVersion);
	setXMLString(Xml, xmlNameTag.."#name", tostring(guiBox.name));
	--setXMLString(Xml, xmlNameTag.."#displayName", tostring(guiBox.displayName));
	--setXMLBool(Xml, xmlNameTag.."#show", guiBox.show);
	
	local groupNameTag = (xmlNameTag.. ".other(%d)"):format(0);
	--setXMLBool(Xml, groupNameTag.."#drawIsIngameMapLarge", guiBox.drawIsIngameMapLarge);
	--setXMLBool(Xml, groupNameTag.."#isHelp", guiBox.isHelp);
	--setXMLBool(Xml, groupNameTag.."#viewSettingIcons", guiBox.viewSettingIcons);
	--setXMLBool(Xml, groupNameTag.."#viewExtraLine", guiBox.viewExtraLine);
	--setXMLString(Xml, groupNameTag.."#autoZoomOutIn", tostring(guiBox.autoZoomOutIn));
	--setXMLBool(Xml, groupNameTag.."#autoClose", guiBox.autoClose);
		
	groupNameTag = (xmlNameTag.. ".screen(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#posX", guiBox.screen.posX);
	setXMLFloat(Xml, groupNameTag.."#posY", guiBox.screen.posY);
	setXMLFloat(Xml, groupNameTag.."#width", guiBox.screen.width);
	setXMLFloat(Xml, groupNameTag.."#height", guiBox.screen.height);
	setXMLFloat(Xml, groupNameTag.."#difWidth", guiBox.screen.difWidth);
	setXMLFloat(Xml, groupNameTag.."#difHeight", guiBox.screen.difHeight);
	
	groupNameTag = (xmlNameTag.. ".size.bg(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#width", guiBox.screen.size.background[1]);
	setXMLFloat(Xml, groupNameTag.."#height", guiBox.screen.size.background[2]);
	setXMLFloat(Xml, groupNameTag.."#minWidth", guiBox.screen.size.background[5]);
	setXMLFloat(Xml, groupNameTag.."#maxHeight", guiBox.screen.size.background[3]);
	setXMLFloat(Xml, groupNameTag.."#minHeight", guiBox.screen.size.background[4]);
	
	groupNameTag = (xmlNameTag.. ".size.icon(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#difScaleWidth", guiBox.screen.size.icon[1]);
	setXMLFloat(Xml, groupNameTag.."#difScaleHeight", guiBox.screen.size.icon[2]);
	
	groupNameTag = (xmlNameTag.. ".size.zoomOutIn.text(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#textSize", guiBox.screen.size.zoomOutIn.text[1]);
	setXMLFloat(Xml, groupNameTag.."#textSizeLevel", guiBox.screen.size.zoomOutIn.text[2]);
	setXMLFloat(Xml, groupNameTag.."#maxTextSize", guiBox.screen.size.zoomOutIn.text[3]);
	setXMLFloat(Xml, groupNameTag.."#minTextSize", guiBox.screen.size.zoomOutIn.text[4]);
	
	groupNameTag = (xmlNameTag.. ".size.zoomOutIn.icon(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#iconSize", guiBox.screen.size.zoomOutIn.icon[1]);
	setXMLFloat(Xml, groupNameTag.."#iconSizeLevel", guiBox.screen.size.zoomOutIn.icon[2]);
	setXMLFloat(Xml, groupNameTag.."#maxIconSize", guiBox.screen.size.zoomOutIn.icon[3]);
	setXMLFloat(Xml, groupNameTag.."#minIconSize", guiBox.screen.size.zoomOutIn.icon[4]);
	
	groupNameTag = (xmlNameTag.. ".size.distance(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#width", guiBox.screen.size.distance.width);
	setXMLFloat(Xml, groupNameTag.."#height", guiBox.screen.size.distance.height);
	setXMLFloat(Xml, groupNameTag.."#iconWidth", guiBox.screen.size.distance.iconWidth);
	setXMLFloat(Xml, groupNameTag.."#iconHeight", guiBox.screen.size.distance.iconHeight);
	setXMLFloat(Xml, groupNameTag.."#textLine", guiBox.screen.size.distance.textLine);
	setXMLFloat(Xml, groupNameTag.."#textWidth", guiBox.screen.size.distance.textWidth);
	setXMLFloat(Xml, groupNameTag.."#textHeight", guiBox.screen.size.distance.textHeight);
	
	if guiBox.onSaveXml ~= nil and type(guiBox.onSaveXml) == "function" then 
		groupNameTag = (xmlNameTag.. ".ownValues(%d)"):format(0);
		guiBox.onSaveXml(guiBox, Xml, groupNameTag);
	end;
	--guiBox.isSave = true;
	saveXMLFile(Xml);
	delete(Xml);
end;