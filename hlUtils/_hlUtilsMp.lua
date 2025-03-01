hlUtilsMp = {};

hlUtilsMp.metadata = {	
	title = "HL MP Utils",
	author = "(by HappyLooser)",
	version ="v0.3 Beta",
	systemVersion = 0.3,
	datum = "22.10.2024",
	update = "30.01.2025",	
};

hlUtilsMp.modDir = g_currentModDirectory;
source(hlUtilsMp.modDir.."hlUtils/_hlUtilsMpEvent.lua");

function hlUtilsMp:loadMap()	
	Mission00.onStartMission = Utils.prependedFunction(Mission00.onStartMission, hlUtilsMp.onStartMission);
	if g_currentMission.hlUtilsMp == nil then 
		g_currentMission.hlUtilsMp = {};
		g_currentMission.hlUtilsMp.version = hlUtilsMp.metadata.systemVersion;
		g_currentMission.hlUtilsMp.modDir = hlUtilsMp.modDir;	
		g_currentMission.hlUtilsMp.savegameTypId = 0;
		hlUtilsMp:setFunction();
	else
		if g_currentMission.hlUtilsMp.version < hlUtilsMp.metadata.systemVersion then
			g_currentMission.hlUtilsMp = {};
			g_currentMission.hlUtilsMp.version = hlUtilsMp.metadata.systemVersion;
			g_currentMission.hlUtilsMp.modDir = hlUtilsMp.modDir;
			g_currentMission.hlUtilsMp.savegameTypId = 0;
			hlUtilsMp:setFunction();
		end;			
	end;	
end;

function hlUtilsMp.onStartMission()
	if g_currentMission == nil or g_currentMission.hlUtilsMp == nil or g_currentMission.hlUtilsMp.modDir ~= hlUtilsMp.modDir then
		removeModEventListener(hlUtilsMp);
	else		
		if g_server ~= nil and g_currentMission.missionDynamicInfo.isMultiplayer then print("---loading ".. tostring(hlUtilsMp.metadata.title).. " ".. tostring(hlUtilsMp.metadata.version).. " ".. tostring(hlUtilsMp.metadata.author).. "---");end;		
		if g_dedicatedServer ~= nil or (g_server ~= nil and g_client ~= nil) or (g_currentMission.missionDynamicInfo.isMultiplayer and g_server ~= nil) then
			hlUtilsMp:loadXml();			
			--FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, hlUtilsMp.saveSavegame);
			ItemSystem.save = Utils.prependedFunction(ItemSystem.save, hlUtilsMp.saveSavegame); --patch 1.5.0.1
		end;
		FSBaseMission.onConnectionFinishedLoading = Utils.appendedFunction(FSBaseMission.onConnectionFinishedLoading, hlUtilsMp.onClientJoined)
	end;
end;

function hlUtilsMp:loadXml()	
	local file = hlUtilsMp:getXmlFile();
	if fileExists(file) then 		
		local Xml = loadXMLFile("_hlUtilsMp_XML", file, "hlUtilsMp");
		local xmlNameTag = ("hlUtilsMp"):format(0);	
		if Xml ~= nil then
			if getXMLString(Xml, xmlNameTag.. "#savegameTypId") ~= nil then
				local savegameTypId = getXMLString(Xml, xmlNameTag.. "#savegameTypId");
				g_currentMission.hlUtilsMp.savegameTypId = tonumber(savegameTypId);				
			end;
			delete(Xml);
		end;		
	else
		local savegameTypId = hlUtilsMp:generateSavegameTypId();		
		g_currentMission.hlUtilsMp.savegameTypId = tonumber(savegameTypId);
		hlUtilsMp:saveXml();
	end;
end;

function hlUtilsMp:saveXml()
	local file = hlUtilsMp:getXmlFile();
	local Xml = createXMLFile("_hlUtilsMp_XML", file, "hlUtilsMp");
	local xmlNameTag = "hlUtilsMp";
	if Xml ~= nil then		
		setXMLString(Xml, xmlNameTag.. "#savegameTypId", tostring(g_currentMission.hlUtilsMp.savegameTypId));
		saveXMLFile(Xml);
		delete(Xml);
	end;	
end;

function hlUtilsMp.saveSavegame()
	hlUtilsMp:saveXml();
end;

function hlUtilsMp:getXmlFile()	
	local file = nil;	
	local path = g_currentMission.missionInfo.savegameDirectory;	
	if path == nil then
		file = getUserProfileAppPath() .. "savegame" .. g_currentMission.missionInfo.savegameIndex.. "/".. "_hlUtils.xml";
	else
		file = path.. "/".. "_hlUtils.xml";
	end;	
	return file;
end;

function hlUtilsMp.onClientJoined(mission, connection, x, y, z, viewDistanceCoeff)	
	connection:sendEvent(hlUtilsMpEvent.new("getSavegameTypId","setSavegameTypId"));
end;
addModEventListener(hlUtilsMp);

----------------------------
function hlUtilsMp:setFunction()

if g_currentMission.hlUtilsMp.getValue==nil then g_currentMission.hlUtilsMp.getValue=
function(getFunction)
	if g_currentMission.hlUtilsMp[getFunction] ~= nil then return g_currentMission.hlUtilsMp[getFunction]();end;
end;end;

if g_currentMission.hlUtilsMp.setValue==nil then g_currentMission.hlUtilsMp.setValue=
function(setFunction, value)
	if g_currentMission.hlUtilsMp[setFunction] ~= nil then g_currentMission.hlUtilsMp[setFunction](value);end;
end;end;

if g_currentMission.hlUtilsMp.getSavegameTypId==nil then g_currentMission.hlUtilsMp.getSavegameTypId=
function()
	return tostring(g_currentMission.hlUtilsMp.savegameTypId);
end;end;

if g_currentMission.hlUtilsMp.setSavegameTypId==nil then g_currentMission.hlUtilsMp.setSavegameTypId=
function(value)
	g_currentMission.hlUtilsMp.savegameTypId = tonumber(value);
end;end;

end;

function hlUtilsMp:generateSavegameTypId()
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
end;