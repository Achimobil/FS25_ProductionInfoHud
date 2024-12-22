hlHudSystemXml = {};
source(hlHudSystem.modDir.."hlHudSystem/hlHud/hlHudXml.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlPda/hlPdaXml.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlBox/hlBoxXml.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlHud/hlHudOwnXml.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlGuiBox/hlGuiBoxXml.lua");
source(hlHudSystem.modDir.."hlHudSystem/hlGuiBox/hlOwnGuiBoxXml.lua");

function hlHudSystemXml:load(modName)
	hlHudSystemXml:loadDefault();	
	g_currentMission.hlUtils.loadLanguage( {modTitle=tostring(g_currentMission.hlHudSystem.metadata.title), class="hlHudSystem", modDir=g_currentMission.hlHudSystem.modDir.. "hlHudSystem/", xmlDir="HudSystem", xmlVersion=g_currentMission.hlHudSystem.metadata.languageVersion} );
end;

function hlHudSystemXml:loadDefault()
	local path = g_currentMission.hlHudSystem.settingsDir;
	local file = path.. "hlHudSystem.xml";
	if fileExists(file) then
		local Xml = loadXMLFile("HlHudSystem_XML", file, "hlHudSystemXML");
		if Xml ~= nil then
			local xmlNameTag = ("hlHudSystemXML"):format(0);			
			if getXMLInt(Xml, xmlNameTag.."#version") ~= nil then
				g_currentMission.hlHudSystem.infoDisplay.firstStart = false;							
			else
				g_currentMission.hlUtils.addTimer( {delay=g_currentMission.hlHudSystem.timer.firstInfo or 80, name="hlHudSystem_firstInfo", repeatable=1, ms=false, action=g_currentMission.hlHudSystem.firstInfo} );
				return; --first config not found
			end;			
			local groupNameTag = (xmlNameTag.. ".screen(%d)"):format(0);
			if getXMLFloat(Xml, groupNameTag.."#height") ~= nil then g_currentMission.hlHudSystem.screen.height = getXMLFloat(Xml, groupNameTag.."#height");end;			
			if getXMLFloat(Xml, groupNameTag.."#posX") ~= nil then g_currentMission.hlHudSystem.screen.posX = getXMLFloat(Xml, groupNameTag.."#posX");end;
			if getXMLFloat(Xml, groupNameTag.."#posY") ~= nil then g_currentMission.hlHudSystem.screen.posY = getXMLFloat(Xml, groupNameTag.."#posY");end;
			if getXMLFloat(Xml, groupNameTag.."#maxHeight") ~= nil then g_currentMission.hlHudSystem.screen.size.background[3] = getXMLFloat(Xml, groupNameTag.."#maxHeight");end;
			if getXMLFloat(Xml, groupNameTag.."#minHeight") ~= nil then g_currentMission.hlHudSystem.screen.size.background[4] = getXMLFloat(Xml, groupNameTag.."#minHeight");end;
			if getXMLFloat(Xml, groupNameTag.."#minWidth") ~= nil then g_currentMission.hlHudSystem.screen.size.background[5] = getXMLFloat(Xml, groupNameTag.."#minWidth");end;
			delete(Xml);
		end;		
	else
		hlHudSystemXml:saveDefault();
	end;
	function searchAlreadyExistsXml(typ)		
		local files = Files.new(path.. tostring(typ).. "/");	
		for _, v in pairs(files.files) do
			local xmlName = nil
			if not v.isDirectory then
				xmlName = string.gsub(v.filename, ".xml", "");
				g_currentMission.hlHudSystem.alreadyExistsXml[typ][xmlName]	= true;	
			end;		
		end;	
	end;
	searchAlreadyExistsXml("hud");
	searchAlreadyExistsXml("pda");
	searchAlreadyExistsXml("box");
	searchAlreadyExistsXml("guibox");
	searchAlreadyExistsXml("other");	
end;

function hlHudSystemXml:save(autoSave)
	hlHudSystemXml:saveDefault();	
	hlHudSystemXml:saveHud(nil,autoSave);
	hlHudSystemXml:savePda(nil,autoSave);
	hlHudSystemXml:saveBox(nil,autoSave);
	hlHudSystemXml:saveGuiBox(nil,autoSave);
end;

function hlHudSystemXml:saveDefault()
	local path = g_currentMission.hlHudSystem.settingsDir;
	local Xml = createXMLFile("HlHudSystem_XML", path.. "hlHudSystem.xml", "hlHudSystemXML");
	local xmlNameTag = ("hlHudSystemXML"):format(0);
	setXMLInt(Xml, xmlNameTag.."#version", g_currentMission.hlHudSystem.metadata.xmlVersion);	
	local groupNameTag = (xmlNameTag.. ".screen(%d)"):format(0);
	setXMLFloat(Xml, groupNameTag.."#height", g_currentMission.hlHudSystem.screen.height);
	setXMLFloat(Xml, groupNameTag.."#posX", g_currentMission.hlHudSystem.screen.posX);
	setXMLFloat(Xml, groupNameTag.."#posY", g_currentMission.hlHudSystem.screen.posY);
	setXMLFloat(Xml, groupNameTag.."#maxHeight", g_currentMission.hlHudSystem.screen.size.background[3]);
	setXMLFloat(Xml, groupNameTag.."#minHeight", g_currentMission.hlHudSystem.screen.size.background[4]);
	setXMLFloat(Xml, groupNameTag.."#minWidth", g_currentMission.hlHudSystem.screen.size.background[5]);
	g_currentMission.hlHudSystem.isSave = true;
	saveXMLFile(Xml);
	delete(Xml);
end;

function hlHudSystemXml:saveHud(hud, autoSave)	
	if #g_currentMission.hlHudSystem.hud > 0 then
		if hud ~= nil and hud.canSave then
			local hud, pos = hud:getData();
			if hud ~= nil then
				if hud.canSave then hlHudXml:save(hud, pos);end;
				hud.isSave = true;
			end;
		else
			for pos=1, #g_currentMission.hlHudSystem.hud do
				local hud = g_currentMission.hlHudSystem.hud[pos];
				if hud ~= nil and (autoSave == nil or (autoSave and hud.autoSave and not hud.isSave)) then
					if hud.canSave then hlHudXml:save(hud, pos);end;
					hud.isSave = true;
				end;
			end;
		end;
	end;
end;

function hlHudSystemXml:savePda(pda, autoSave)
	if #g_currentMission.hlHudSystem.pda > 0 then
		if pda ~= nil and pda.canSave then
			local pda, pos = pda:getData();
			if pda ~= nil then
				if pda.canSave then hlPdaXml:save(pda, pos);end;
				pda.isSave = true;
			end;
		else
			for pos=1, #g_currentMission.hlHudSystem.pda do
				local pda = g_currentMission.hlHudSystem.pda[pos];
				if pda ~= nil and (autoSave == nil or (autoSave and pda.autoSave and not pda.isSave)) then
					if pda.canSave then hlPdaXml:save(pda, pos);end;
					pda.isSave = true;
				end;
			end;
		end;		
	end;
end;

function hlHudSystemXml:saveBox(box, autoSave)
	if #g_currentMission.hlHudSystem.box > 0 then
		if box ~= nil and box.canSave then
			local box, pos = box:getData();
			if box ~= nil then
				if box.canSave then hlBoxXml:save(box, pos);end;
				box.isSave = true;
			end;
		else
			for pos=1, #g_currentMission.hlHudSystem.box do
				local box = g_currentMission.hlHudSystem.box[pos];
				if box ~= nil and (autoSave == nil or (autoSave and box.autoSave and not box.isSave)) then
					if box.canSave then hlBoxXml:save(box, pos);end;
					box.isSave = true;
				end;
			end;
		end;		
	end;
end;

function hlHudSystemXml:saveGuiBox(guiBox, autoSave)
	if #g_currentMission.hlHudSystem.guiBox > 0 then
		if guiBox ~= nil then
			local guiBox, pos = box:getData();
			if guiBox ~= nil then
				hlGuiBoxXml:save(guiBox, pos);				
			end;
		else
			for pos=1, #g_currentMission.hlHudSystem.guiBox do
				local guiBox = g_currentMission.hlHudSystem.guiBox[pos];
				if guiBox ~= nil then
					hlGuiBoxXml:save(guiBox, pos);					
				end;
			end;
		end;		
	end;
end;

function hlHudSystemXml:loadLanguages(modName)
	local modName = tostring(modName);
	local modEnv = _G["hlHudSystem"];	
	if modEnv ~= nil then
		if modEnv.g_i18n == nil then
			modEnv.g_i18n = g_i18n:addModI18N("hlHudSystem");
		end;
		local l10nFilenamePrefix = "languages/l10n";	
		local l10nFilenameExternPrefixFull = Utils.getFilename(l10nFilenamePrefix, getUserProfileAppPath().. "modSettings/HL/HudSystem/"); --prio		
		local l10nFilenamePrefixFull = Utils.getFilename(l10nFilenamePrefix, g_currentMission.hlHudSystem.modDir.. "hlHudSystem/");
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
				if version ~= nil and version >= g_currentMission.hlHudSystem.meta.languageVersion then
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
			if not fileExists(l10nFilename) or not isCorrectVersion then
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
			print("Warning: No l10n file found for '".. l10nFilenamePrefix.. "' in mod '".. modName.. "'")
		end;
	end;
end;
