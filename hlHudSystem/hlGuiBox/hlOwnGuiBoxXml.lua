hlOwnGuiBoxXml = {};

function hlOwnGuiBoxXml:defaultValues(guiBox)
	guiBox.ownTable = {				
		modHidden = {};		
		mods = {};		
		infoDisplay = {2,1,2};
		mouseAcceptsInfo = {2,1,2};
		saveInfo = {2,1,2};
		autoSave = {2,1,2};
		autoSaveTimer = {600,200,1000,100,600}; --is,min,max,level,default (~ sec)		
		adEditModusMouseOff = {1,1,2};
	};		
end;

function hlOwnGuiBoxXml:onLoadXml(guiBox, Xml, xmlNameTag)
	if guiBox.ownTable.modHidden == nil then hlOwnGuiBoxXml:defaultValues(guiBox);end;	
	if Xml ~= nil and xmlNameTag ~= nil then	
		if getXMLInt(Xml, xmlNameTag.."#version") ~= nil then 
						
		else
			return; --first config not found
		end;
		
		local groupNameTag = (xmlNameTag.. ".global(%d)"):format(0);
		if getXMLInt(Xml, groupNameTag.."#infoDisplay") ~= nil then			
			guiBox.ownTable.infoDisplay[1] = getXMLInt(Xml, groupNameTag.."#infoDisplay");
			g_currentMission.hlHudSystem.infoDisplay.on = guiBox.ownTable.infoDisplay[1] > 1;
		else
			g_currentMission.hlUtils.addTimer( {delay=g_currentMission.hlHudSystem.timer.firstInfo or 80, name="hlHudSystem_firstInfo", repeatable=1, ms=false, action=g_currentMission.hlHudSystem.firstInfo} );
		end;
		if getXMLInt(Xml, groupNameTag.."#mouseAcceptsInfo") ~= nil then 
			guiBox.ownTable.mouseAcceptsInfo[1] = getXMLInt(Xml, groupNameTag.."#mouseAcceptsInfo");
			g_currentMission.hlHudSystem.infoDisplay.mouseAccepts = guiBox.ownTable.mouseAcceptsInfo[1] > 1;
		end;
		if getXMLBool(Xml, groupNameTag.."#drawIsIngameMapLarge") ~= nil then g_currentMission.hlHudSystem.drawIsIngameMapLarge = getXMLBool(Xml, groupNameTag.."#drawIsIngameMapLarge");end;		
		if getXMLInt(Xml, groupNameTag.."#saveInfo") ~= nil then guiBox.ownTable.saveInfo[1] = getXMLInt(Xml, groupNameTag.."#saveInfo");end;
		if getXMLInt(Xml, groupNameTag.."#autoSave") ~= nil then guiBox.ownTable.autoSave[1] = getXMLInt(Xml, groupNameTag.."#autoSave");end;
		if getXMLInt(Xml, groupNameTag.."#autoSaveTimer") ~= nil then guiBox.ownTable.autoSaveTimer[1] = getXMLInt(Xml, groupNameTag.."#autoSaveTimer");end;
		if guiBox.ownTable.autoSaveTimer[1] > guiBox.ownTable.autoSaveTimer[3] then guiBox.ownTable.autoSaveTimer[1] = guiBox.ownTable.autoSaveTimer[5];end;
		if getXMLInt(Xml, groupNameTag.."#adEditModusMouseOff") ~= nil then guiBox.ownTable.adEditModusMouseOff[1] = getXMLInt(Xml, groupNameTag.."#adEditModusMouseOff");end;
		
		local textTicker = g_currentMission.hlHudSystem.textTicker;		
		if textTicker ~= nil then			
			groupNameTag = (xmlNameTag.. ".textTicker(%d)"):format(0);
			if getXMLInt(Xml, groupNameTag.."#runTimer") ~= nil then textTicker.runTimer[1] = getXMLInt(Xml, groupNameTag.."#runTimer");end;
			if getXMLInt(Xml, groupNameTag.."#info") ~= nil then textTicker.info[1] = getXMLInt(Xml, groupNameTag.."#info");end;
			if getXMLInt(Xml, groupNameTag.."#sound") ~= nil then textTicker.sound[1] = getXMLInt(Xml, groupNameTag.."#sound");end;
			if getXMLInt(Xml, groupNameTag.."#soundVolume") ~= nil then textTicker.soundVolume[1] = getXMLInt(Xml, groupNameTag.."#soundVolume");end;
			if getXMLInt(Xml, groupNameTag.."#soundSample") ~= nil then textTicker.soundSample[1] = getXMLInt(Xml, groupNameTag.."#soundSample");end;
			if getXMLInt(Xml, groupNameTag.."#viewConnectPlayTime") ~= nil then textTicker.viewConnectPlayTime[1] = getXMLInt(Xml, groupNameTag.."#viewConnectPlayTime");end;
			if getXMLInt(Xml, groupNameTag.."#dropWidth") ~= nil then 
				local dropWidth = getXMLInt(Xml, groupNameTag.."#dropWidth");
				if dropWidth < textTicker.dropWidth[2] or dropWidth > textTicker.dropWidth[3] then dropWidth = textTicker.dropWidth[5];end;
				textTicker.dropWidth[1] = dropWidth;
			end;
			if getXMLInt(Xml, groupNameTag.."#drawPosition") ~= nil then 
				local position = getXMLInt(Xml, groupNameTag.."#drawPosition");
				if textTicker.pos[position] ~= nil then	textTicker.position[1] = position;end;
			end;
			if getXMLBool(Xml, groupNameTag.."#isOn") ~= nil then 
				local state = getXMLBool(Xml, groupNameTag.."#isOn");
				--if state then textTicker:setOnOff(true);end;				
				g_currentMission.hlHudSystem.ownData.textTickerSaveState = state;				
			end;
			for a=1, #textTicker.pos do				
				local groupNameTagTemp = (xmlNameTag.. ".textTicker.position.pos(%d)"):format(a-1);
				
				if textTicker.pos[a].loadXml > 0 then
					if groupNameTagTemp ~= nil then
						local loadXml = 0;
						if getXMLFloat(Xml, groupNameTagTemp.."#x") ~= nil then textTicker.pos[a].x = getXMLFloat(Xml, groupNameTagTemp.."#x");loadXml = loadXml+1;end;
						if getXMLFloat(Xml, groupNameTagTemp.."#y") ~= nil then textTicker.pos[a].y = getXMLFloat(Xml, groupNameTagTemp.."#y");loadXml = loadXml+1;end;
						if getXMLFloat(Xml, groupNameTagTemp.."#width") ~= nil then 
							local width = getXMLFloat(Xml, groupNameTagTemp.."#width");							
							textTicker.pos[a].width = width;
							if width > 0 then loadXml = loadXml+1;end;
						end;
						if loadXml > 2 then textTicker.pos[a].loadXml = loadXml;end;
						if getXMLFloat(Xml, groupNameTagTemp.."#textSize") ~= nil then 
							local textSize = getXMLFloat(Xml, groupNameTagTemp.."#textSize");
							if textSize < textTicker.pos[a].textSize[2] then
								textSize = textTicker.pos[a].textSize[2];
							elseif textSize > textTicker.pos[a].textSize[3] then 
								textSize = textTicker.pos[a].textSize[3];
							end;
							textTicker.pos[a].textSize[1] = textSize;
						end;
						if getXMLBool(Xml, groupNameTagTemp.."#drawBg") ~= nil then textTicker.pos[a].drawBg = getXMLBool(Xml, groupNameTagTemp.."#drawBg");end;
						if getXMLFloat(Xml, groupNameTagTemp.."#bgT") ~= nil then textTicker.pos[a].bgT = getXMLFloat(Xml, groupNameTagTemp.."#bgT");end;
					end;
				end;				
			end;			
		end;
		
		local int = 0;
		while true do
			groupNameTag = (xmlNameTag.. ".modIsHidden(%d)"):format(int);
			if groupNameTag == nil or getXMLString(Xml, groupNameTag.. "#name") == nil or not getXMLString(Xml, groupNameTag.. "#name") or int > 100 then break;else
			guiBox.ownTable.modHidden[getXMLString(Xml, groupNameTag.. "#name")] = {};
			int = int+1;
			end;
		end;
	end;
	guiBox.ownTable.modHiddenLinesLoaded = false;
end;

function hlOwnGuiBoxXml.onSaveXml(guiBox, Xml, xmlNameTag)
	setXMLInt(Xml, xmlNameTag.."#version", hlHudSystem.metadata.xmlVersion);
	
	local groupNameTag = (xmlNameTag.. ".global(%d)"):format(0);
	setXMLBool(Xml, groupNameTag.."#drawIsIngameMapLarge", g_currentMission.hlHudSystem.drawIsIngameMapLarge);
	setXMLInt(Xml, groupNameTag.."#infoDisplay", guiBox.ownTable.infoDisplay[1]);
	setXMLInt(Xml, groupNameTag.."#mouseAcceptsInfo", guiBox.ownTable.mouseAcceptsInfo[1]);
	setXMLInt(Xml, groupNameTag.."#saveInfo", guiBox.ownTable.saveInfo[1]);
	setXMLInt(Xml, groupNameTag.."#autoSave", guiBox.ownTable.autoSave[1]);
	setXMLInt(Xml, groupNameTag.."#autoSaveTimer", guiBox.ownTable.autoSaveTimer[1]);
	setXMLInt(Xml, groupNameTag.."#adEditModusMouseOff", guiBox.ownTable.adEditModusMouseOff[1]);
	
	local textTicker = g_currentMission.hlHudSystem.textTicker;		
	if textTicker ~= nil then
		groupNameTag = (xmlNameTag.. ".textTicker(%d)"):format(0);		
		setXMLBool(Xml, groupNameTag.."#isOn", g_currentMission.hlHudSystem.ownData.textTickerSaveState);
		setXMLInt(Xml, groupNameTag.."#runTimer", textTicker.runTimer[1]);
		setXMLInt(Xml, groupNameTag.."#info", textTicker.info[1]);
		setXMLInt(Xml, groupNameTag.."#sound", textTicker.sound[1]);
		setXMLInt(Xml, groupNameTag.."#soundSample", textTicker.soundSample[1]);
		setXMLInt(Xml, groupNameTag.."#soundVolume", textTicker.soundVolume[1]);
		setXMLInt(Xml, groupNameTag.."#viewConnectPlayTime", textTicker.viewConnectPlayTime[1]);		
		setXMLInt(Xml, groupNameTag.."#dropWidth", textTicker.dropWidth[1]);
		setXMLInt(Xml, groupNameTag.."#drawPosition", textTicker.position[1]);
				
		for a=1, #textTicker.pos do			
			local groupNameTagTemp = (xmlNameTag.. ".textTicker.position.pos(%d)"):format(a-1);
			setXMLFloat(Xml, groupNameTagTemp.."#x", textTicker.pos[a].x);
			setXMLFloat(Xml, groupNameTagTemp.."#y", textTicker.pos[a].y);
			setXMLFloat(Xml, groupNameTagTemp.."#width", textTicker.pos[a].width);
			if textTicker.pos[a].bgT ~= nil then setXMLFloat(Xml, groupNameTagTemp.."#bgT", textTicker.pos[a].bgT);end;
			if textTicker.pos[a].textSize ~= nil then setXMLFloat(Xml, groupNameTagTemp.."#textSize", textTicker.pos[a].textSize[1]);end;
			if textTicker.pos[a].drawBg ~= nil then	setXMLBool(Xml, groupNameTagTemp.."#drawBg", textTicker.pos[a].drawBg);end;			
		end;
	end;
	
	if g_currentMission.hlHudSystem.ownData.hiddenMods ~= nil then
		local int = 0;
		for k,v in pairs(g_currentMission.hlHudSystem.ownData.hiddenMods) do
			if g_currentMission.hlHudSystem.ownData.hiddenMods[k] ~= nil and g_currentMission.hlHudSystem.ownData.hiddenMods[k].isHidden then
				groupNameTag = (xmlNameTag.. ".modIsHidden(%d)"):format(int);
				setXMLString(Xml, groupNameTag.. "#name", tostring(k));
				int = int+1;
			end;
		end;
	end;
end;

function hlOwnGuiBoxXml:loadGuiBox()	
	g_currentMission.hlHudSystem.guiMenu = g_currentMission.hlHudSystem.hlGuiBox.generate( {name="HlHudSystem_GuiBox", title="Hl Hud System Settings"} );
	g_currentMission.hlUtils.insertIcons( {xmlTagName="hlHudSystem.ownGuiBoxIcons", modDir=g_currentMission.hlHudSystem.modDir, iconFile="hlHudSystem/icons/icons.dds", xmlFile="hlHudSystem/icons/icons.xml", modName="defaultIcons", groupName="guiBox", fileFormat={64,512,1024}, iconTable=g_currentMission.hlHudSystem.guiMenu.overlays} );
	g_currentMission.hlUtils.insertIcons( {xmlTagName="hlHudSystem.ownGuiBoxOtherIcons", modDir=g_currentMission.hlHudSystem.modDir, iconFile="hlHudSystem/icons/otherIcons.dds", xmlFile="hlHudSystem/icons/icons.xml", modName="defaultIcons", groupName="guiBox", fileFormat={32,256,512}, iconTable=g_currentMission.hlHudSystem.guiMenu.overlays} );
	g_currentMission.hlUtils.insertIcons( {xmlTagName="hlHudSystem.ownGuiBoxOther1Icons", modDir=g_currentMission.hlHudSystem.modDir, iconFile="hlHudSystem/icons/other1Icons.dds", xmlFile="hlHudSystem/icons/icons.xml", modName="defaultIcons", groupName="guiBox", fileFormat={32,256,512}, iconTable=g_currentMission.hlHudSystem.guiMenu.overlays} );
	
	local linesSequence = {"globalHeadline_","drawIsIngameMapLarge_","infoDisplay_","mouseAcceptsInfo_","autoSave_","saveInfo_","autoSaveTimer_","viewConnectPlayTime_","adEditModusMouseOff_",
		"textTickerHeadline_","textTicker_","position_","drawBg_","runTimer_","dropWidth_","setInfo_","setSound_","setVolume_",	
	};
	if not g_currentMission.hlHudSystem.ownData.autoDrive then table.remove(linesSequence, 7);end;
	g_currentMission.hlHudSystem.guiMenu.screen.canBounds.on = true;
	g_currentMission.hlHudSystem.guiMenu.onClick = hlGuiBoxMouseKeyEvents.onClickOwnGuiBox;
	g_currentMission.hlHudSystem.guiMenu.onSaveXml = hlOwnGuiBoxXml.onSaveXml;
	hlOwnGuiBoxXml:onLoadXml(g_currentMission.hlHudSystem.guiMenu, g_currentMission.hlHudSystem.guiMenu:getXml()); --own guiBox load over Xml (replace Data)
	if g_currentMission.hlHudSystem.guiMenu.ownTable.autoSave[1] > 1 then
		g_currentMission.hlUtils.addTimer( {delay=g_currentMission.hlHudSystem.guiMenu.ownTable.autoSaveTimer[1], name="hlHudSystem_autoSave", repeatable=true, ms=false, action=g_currentMission.hlHudSystem.autoSave} );
	end;	
	hlOwnTextTicker:generateData();	
	g_currentMission.hlHudSystem.guiMenu.getLine = hlOwnGuiBoxXml.getLines;
	g_currentMission.hlHudSystem.guiMenu.guiLines = {};
	for k,v in pairs(linesSequence) do
		table.insert(g_currentMission.hlHudSystem.guiMenu.guiLines, v);
	end;		
	for l=1, #g_currentMission.hlHudSystem.guiMenu.guiLines do
		g_currentMission.hlHudSystem.guiMenu:addLine( {} );
	end;
	g_currentMission.hlHudSystem.guiMenu:resetDimension();
	g_currentMission.hlHudSystem.onLoadComplete = g_currentMission.hlHudSystem.onLoadComplete+1;
	g_currentMission.hlHudSystem.guiMenu.canAddModLines = true;
end;

function hlOwnGuiBoxXml:setModHiddenLines()
	if g_currentMission.hlHudSystem.guiMenu ~= nil then
		g_currentMission.hlHudSystem.guiMenu.ownTable.modHiddenLinesLoaded = true;
		local lineSequence = {};
		local foundHiddenMods = false;
		local foundHiddenMod = false;
		if g_currentMission.hlHudSystem.ownData.hiddenMods ~= nil then
			for k,v in pairs(g_currentMission.hlHudSystem.ownData.hiddenMods) do
				if k ~= nil then foundHiddenMods = true;end;
				table.insert(lineSequence, "modHidder_".. tostring(k).. "_");
				if g_currentMission.hlHudSystem.ownData.hiddenMods[k] ~= nil and not g_currentMission.hlHudSystem.ownData.hiddenMods[k].isHidden and g_currentMission.hlHudSystem.guiMenu.ownTable.modHidden[k] ~= nil then
					foundHiddenMod = true;
					g_currentMission.hlHudSystem.ownData.hiddenMods[k].isHidden = true;
				end;
			end;
			table.sort(lineSequence, function (k1, k2) return k1 < k2 end);
		end;
		if foundHiddenMods then			
			g_currentMission.hlHudSystem.guiMenu.lines[#g_currentMission.hlHudSystem.guiMenu.lines+1] = {lineCallSequence="modHidderHeadline_",getLine=hlOwnGuiBoxXml.getModHidderLines};
			g_currentMission.hlHudSystem.guiMenu.firstAddModHidderLinePos = #g_currentMission.hlHudSystem.guiMenu.lines;					
			for k,v in pairs(lineSequence) do				
				g_currentMission.hlHudSystem.guiMenu:addLine( {lineCallSequence=v,getLine=hlOwnGuiBoxXml.getModHidderLines,modHidder=true} );
			end;			
		end;
		if foundHiddenMod then
			g_currentMission.hlHudSystem.guiMenu.ownTable.modHidden = {};
			g_currentMission.hlHudSystem.hlHud:updatePosition();
		end;		
		g_currentMission.hlHudSystem.guiMenu:resetDimension();		
	end;	
end;

function hlOwnGuiBoxXml.getLines(args)
	local guiBox = args.guiBox;
	if guiBox == nil then return;end;	
	local textTicker = g_currentMission.hlHudSystem.textTicker;	
	local overlayDefaultGroup = guiBox.overlays["defaultIcons"]["guiBox"];
	local overlayDefaultByName = guiBox.overlays.byName["defaultIcons"]["guiBox"];
	local line = args.line or 1;	
	local textL = "";
	local textR = "-";
	local textColor = "white";
	local textOffColor = g_currentMission.hlHudSystem.overlays.color.notActive;
	local iconColor = g_currentMission.hlHudSystem.overlays.color.notActive;	
	local onColor = g_currentMission.hlHudSystem.overlays.color.on;
	local languageColorTxt = g_i18n:getText("configuration_valueColor");
	local helpText = "";
	local helpText2 = "";	
	local stateOn = g_i18n:getText("ui_on");
	local stateOff = g_i18n:getText("ui_off");
	local state = false;
	local stateColor = nil;	
	local moreTxt = "";
	local infoTxt = "";
	
	if guiBox.guiLines[line] == "globalHeadline_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_headline");	
		return {typ="headline", text={[1]={text=textL, color="ls25"}} };
	end;
	if guiBox.guiLines[line] == "drawIsIngameMapLarge_" then	
		textL = "View Huds (Map Large)"; --g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_infoDisplay");	
		if g_currentMission.hlHudSystem.drawIsIngameMapLarge then state = true;iconColor = onColor;else stateColor = textOffColor;end;
		helpText = "Is IngameMap Large then view Huds."; --g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_help_infoDisplay");
		return {oneClick=true, typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=state}} };
	end;
	if guiBox.guiLines[line] == "infoDisplay_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_infoDisplay");	
		if guiBox.ownTable.infoDisplay[1] > 1 then state = true;iconColor = onColor;else stateColor = textOffColor;end;
		helpText = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_help_infoDisplay");
		return {oneClick=true, typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=state}} };
	end;
	if guiBox.guiLines[line] == "mouseAcceptsInfo_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_mouseAcceptsInfo");	
		if guiBox.ownTable.mouseAcceptsInfo[1] > 1 then state = true;iconColor = onColor;else stateColor = textOffColor;end;
		--helpText = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_help_infoDisplay");
		return {oneClick=true, typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=state}} };
	end;
	if guiBox.guiLines[line] == "autoSave_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_autoSave");	
		if guiBox.ownTable.autoSave[1] > 1 then state = true;iconColor = onColor;else stateColor = textOffColor;end;
		helpText = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_help_autoSave");
		return {oneClick=true, icon=overlayDefaultGroup[overlayDefaultByName["save"]], iconColor=iconColor, typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=state}} };
	end;
	if guiBox.guiLines[line] == "saveInfo_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_saveInfo");	
		if guiBox.ownTable.autoSave[1] > 1 and guiBox.ownTable.saveInfo[1] > 1 then state = true;iconColor = onColor;else stateColor = textOffColor;end;
		helpText = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_help_saveInfo");
		return {oneClick=true, typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=state}} };
	end;
	if guiBox.guiLines[line] == "autoSaveTimer_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_autoSaveTimer");	
		if guiBox.ownTable.autoSave[1] > 1 then iconColor = onColor;else stateColor = textOffColor;end;
		helpText = string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_global_help_autoSaveTimer"), guiBox.ownTable.autoSaveTimer[1], guiBox.ownTable.autoSaveTimer[5]);
		if guiBox.ownTable.autoSave[1] == 1 then
			stateColor = textOffColor;
			iconColor = textOffColor;
			return {oneClick=true, iconColor=iconColor, helpText=helpText, typ="string", text={[1]={text=textL,color=stateColor}} };
		else
			return {typ="number", helpText=helpText, text={[1]={text=textL}, [2]={text=tostring(guiBox.ownTable.autoSaveTimer[1]).. "s"}} };
		end;
	end;	
	if guiBox.guiLines[line] == "adEditModusMouseOff_" then	
		textL = "AD ".. g_i18n:getText("ui_aiSettingsMode");	
		if g_currentMission.hlHudSystem.ownData.autoDrive and guiBox.ownTable.adEditModusMouseOff[1] > 1 then state = true;iconColor = onColor;else stateColor = textOffColor;end;
		helpText = "AutoDrive Editor ".. g_i18n:getText("ui_aiSettingsMode").. ": ".. g_i18n:getText("ui_on").. "\nHL Hud System: ".. g_i18n:getText("ui_mouse").. " (".. g_i18n:getText("ui_action").. ") ".. g_i18n:getText("ui_paused");
		if g_currentMission.hlHudSystem.ownData.autoDrive then
			return {oneClick=true, typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=state}} };
		else
			return {oneClick=true, typ="string", helpText=helpText, text={[1]={text=textL,color=textOffColor}} };
		end;
	end;	
	if guiBox.guiLines[line] == "textTickerHeadline_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_headline");	
		return {typ="headline", text={[1]={text=textL, color="ls25"}} };
	end;
	if guiBox.guiLines[line] == "textTicker_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_textTicker");	
		if textTicker.isOn then state = true;iconColor = onColor;else stateColor = textOffColor;end;
		helpText = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_help_textTicker");
		return {oneClick=true, icon=overlayDefaultGroup[overlayDefaultByName["textTicker"]], iconColor=iconColor, typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=state}} };
	end;
	if guiBox.guiLines[line] == "position_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_position");		
		if textTicker.isOn then iconColor = textColor;else stateColor = textOffColor;end;
		helpText = string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_help_position"), g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_textTicker"));		
		if not textTicker.isOn or textTicker.position[3] == 1 or #textTicker.pos == 1 then
			stateColor = textOffColor;
			iconColor = textOffColor;
			return {oneClick=true, iconColor=iconColor, helpText=helpText, typ="string", text={[1]={text=textL,color=stateColor}} };
		else			
			return {typ="number", helpText=helpText, text={[1]={text=textL}, [2]={text=tostring(textTicker.position[1])}} };
		end;
	end;
	if guiBox.guiLines[line] == "drawBg_" then
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_drawBg");
		helpText = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_help_drawBg");
		if textTicker.isOn then 
			iconColor = textColor;
			if textTicker.pos[textTicker.position[1]].drawBg == nil or textTicker.pos[textTicker.position[1]].drawBg then state = true;else stateColor = textOffColor;end;
			return {oneClick=true, iconColor=iconColor, typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=state}} };
		else 
			stateColor = textOffColor;
			iconColor = textOffColor;
			return {oneClick=true, iconColor=iconColor, helpText=helpText, typ="string", text={[1]={text=textL,color=stateColor}} };
		end;		
	end;
	if guiBox.guiLines[line] == "runTimer_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_runTimer");		
		if textTicker.isOn then iconColor = textColor;else stateColor = textOffColor;end;
		helpText = string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_help_runTimer"), textTicker.runTimer[5],textTicker.runTimer[2],textTicker.runTimer[3]);	
		if not textTicker.isOn then
			stateColor = textOffColor;			
			return {oneClick=true, iconColor=iconColor, typ="string", text={[1]={text=textL,color=stateColor}} };
		else			
			return {typ="number", helpText=helpText, text={[1]={text=textL}, [2]={text=tostring(textTicker.runTimer[1]).. " Ticks"}} };
		end;
	end;
	if guiBox.guiLines[line] == "dropWidth_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_dropWidth");	
		if textTicker.isOn then iconColor = textColor;else stateColor = textOffColor;end;
		helpText = string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_help_dropWidth"), textTicker.dropWidth[5]);		
		if not textTicker.isOn then
			stateColor = textOffColor;
			return {oneClick=true, iconColor=iconColor, typ="string", text={[1]={text=textL,color=stateColor}} };
		else			
			return {typ="number", helpText=helpText, text={[1]={text=textL}, [2]={text=tostring(textTicker.dropWidth[1])}} };
		end;
	end;
	if guiBox.guiLines[line] == "setInfo_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_setInfo");	
		helpText = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_help_setInfo");	
		if textTicker.info[1] > 1 then state = true;iconColor = onColor;else stateColor = textOffColor;end;
		if not textTicker.isOn then			
			iconColor = textOffColor;
			stateColor = textOffColor;
			return {icon=overlayDefaultGroup[overlayDefaultByName["setInfo"]], iconColor=iconColor, typ="string", text={[1]={text=textL,color=stateColor}} };
		else			
			return {oneClick=true, icon=overlayDefaultGroup[overlayDefaultByName["setInfo"]], iconColor=iconColor, typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=state}} };
		end;
	end;
	if guiBox.guiLines[line] == "setSound_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_setSound");		
		local stateText = stateOff;
		if textTicker.sound[1] > 1 then stateText = stateOn;state = true;iconColor = onColor;else stateColor = textOffColor;end;
		helpText = string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_help_setSound"), stateText);
		if not textTicker.isOn then			
			iconColor = textOffColor;
			stateColor = textOffColor;
			return {icon=overlayDefaultGroup[overlayDefaultByName["setSound"]], iconColor=iconColor, typ="string", text={[1]={text=textL,color=stateColor}} };
		else			
			if textTicker.sound[1] == 1 then				
				return {oneClick=true, icon=overlayDefaultGroup[overlayDefaultByName["setSound"]], iconColor=iconColor, typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=false}} };
			else
				helpText2 = string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_textTicker_help_sample"), textTicker.soundSample[3]);
				return {icon=overlayDefaultGroup[overlayDefaultByName["setSound"]], iconColor=iconColor, typ="number", text={[1]={text=textL,color=stateColor,helpText=helpText}, [2]={text=tostring(textTicker.soundSample[1]),helpText=helpText2}} };
			end;
		end;
	end;
	if guiBox.guiLines[line] == "setVolume_" then
		textL = g_i18n:getText("ui_volumeSound");
		local stateText = stateOff;
		if textTicker.sound[1] > 1 then stateText = stateOn;state = true;iconColor = onColor;else stateColor = textOffColor;end;
		if not textTicker.isOn or textTicker.sound[1] == 1 then			
			iconColor = textOffColor;
			stateColor = textOffColor;
			return {oneClick=true, iconColor=iconColor, typ="string", text={[1]={text=textL,color=stateColor}} };
		else
			helpText = g_i18n:getText("setting_sfxVolume");
			return {icon=overlayDefaultGroup[overlayDefaultByName["setVolume"]], iconColor=iconColor, typ="number", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={text=tostring(textTicker.soundVolume[1])}} };
		end;
	end;
	if guiBox.guiLines[line] == "viewConnectPlayTime_" then	
		textL = g_i18n:getText("ui_mpPlaytime").. " ".. g_i18n:getText("ui_inGameMenuBriefing");
		if textTicker.viewConnectPlayTime[1] > 1 then state = true;iconColor = onColor;else stateColor = textOffColor;end;
		helpText = g_i18n:getText("statistic_playTime").. "/".. g_i18n:getText("ui_realTime").. " (".. string.format(g_i18n:getText("shop_saleRemaingHoursValue"), 1).. " 1x)";
		return {oneClick=true, icon=overlayDefaultGroup[overlayDefaultByName["sayings"]], typ="boolean", helpText=helpText, text={[1]={text=textL,color=stateColor}, [2]={color=stateColor,state=state}} };
	end;	
end;

function hlOwnGuiBoxXml.getModHidderLines(args)
	local guiBox = args.guiBox;
	if guiBox == nil or args.lineCallSequence == nil then return;end;
	local textOffColor = g_currentMission.hlHudSystem.overlays.color.notActive;
	local iconColor = g_currentMission.hlHudSystem.overlays.color.notActive;
	local onColor = g_currentMission.hlHudSystem.overlays.color.on;
	local state = nil;
	local textL = "";
	local helpText = "";
	if args.lineCallSequence ~= nil and args.lineCallSequence == "modHidderHeadline_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_modHidder_headline");	
		helpText = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_modHidder_help")
		return {typ="headline", helpText=helpText, text={[1]={text=textL, bold=true, color=guiBox.colorTitle}} };
	end;
	if args.lineCallSequence ~= nil and string.find(args.lineCallSequence, "modHidder_") then
		local repTxt = string.gsub(args.lineCallSequence, "modHidder_", "");
		textL = string.gsub(repTxt, "_", "");
		state = not g_currentMission.hlHudSystem.ownData.hiddenMods[textL].isHidden;
		helpText = g_currentMission.hlHudSystem.ownData.hiddenMods[textL].infoText;
		if state then iconColor = onColor;else stateColor = textOffColor;end;		
		return {oneClick=true, typ="boolean", helpText=helpText, text={[1]={text=textL,color=iconColor}, [2]={color=stateColor,state=state}}, ownTable={textL} };
	end;
end;

function hlOwnGuiBoxXml.getOtherLineGuiBoxOn(args)
	local guiBox = args.guiBox;
	if guiBox == nil or args.lineCallSequence == nil then return;end;
	local overlayDefaultGroup = guiBox.overlays["defaultIcons"]["guiBox"];
	local overlayDefaultByName = guiBox.overlays.byName["defaultIcons"]["guiBox"];		
	local textOffColor = g_currentMission.hlHudSystem.overlays.color.notActive;
	local iconColor = g_currentMission.hlHudSystem.overlays.color.notActive;
	local onColor = g_currentMission.hlHudSystem.overlays.color.on;
	local state = nil;
	local textL = "";
	local helpText = "";
	if args.lineCallSequence ~= nil and args.lineCallSequence == "otherModsHeadline_" then	
		textL = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_otherMods_headline");		
		helpText = g_currentMission.hlHudSystem.hlHud:getI18n("hl_guiBox_otherMods_help");	
		return {typ="headline", helpText=helpText, text={[1]={text=textL, bold=true, color=guiBox.colorTitle}} };
	end;
	if string.find(args.lineCallSequence, "otherGuiBoxOn_") then
		local name = string.gsub(args.lineCallSequence, "otherGuiBoxOn_", "");		
		--local name = string.gsub(repTxt, "_", "");
		if name ~= nil and name:len() > 0 then
			local modGuiBox = g_currentMission.hlHudSystem.hlGuiBox:getData(tostring(name));
			if modGuiBox ~= nil then
				textL = modGuiBox.displayName or name;
				local state = modGuiBox.show;
				if state then iconColor = onColor;end;		
				return {oneClick=true, icon=overlayDefaultGroup[overlayDefaultByName["settingExtension"]], iconColor=iconColor, typ="string", text={[1]={text=textL, color=iconColor}}, ownTable={name} };
			end;
		end;
	end;
end;