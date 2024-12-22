hlPda = {};

local hlPda_mt = Class(hlPda);

function hlPda.generate(args)	
	
	local self = {};

	setmetatable(self, hlPda_mt);	
	local hudSystem = g_currentMission.hlHudSystem;
	self.name = Utils.getNoNil(args.name, "UnknownMod_Pda");
	
	if args.hiddenMod ~= nil then self.hiddenMod = args.hiddenMod; if g_currentMission.hlHudSystem.ownData.hiddenMods[args.hiddenMod] == nil then g_currentMission.hlHudSystem.ownData.hiddenMods[args.hiddenMod] = {isHidden=false,infoText=args.hiddenInfo};end;end;
	self.isHidden = function() if self.hiddenMod == nil or g_currentMission.hlHudSystem.ownData.hiddenMods[self.hiddenMod] == nil then return false;end;return g_currentMission.hlHudSystem.ownData.hiddenMods[self.hiddenMod].isHidden;end;
	
	self.screen = hudSystem.screen.new( {typ="pda"} );
	
	self.xml = hlPdaXml.new( {screen=self.screen, fileName=self.name} );
	
	if self.xml.file == nil then 
		if args.width == nil then 
			args.width = 35;
		else
			if hudSystem.screen.pixelW*args.width < hudSystem.screen.size.background[5] then args.width = 35;end;
		end;		
		if args.height == nil then 
			args.height = 35;
		else
			if hudSystem.screen.pixelH*args.height < hudSystem.screen.size.background[4] then args.height = 35;end;
		end;
	else
		args.width = self.screen.width/self.screen.pixelW;
		if self.screen.width < self.screen.size.background[5] then args.width = 35;end;
		args.height = self.screen.height/self.screen.pixelH;
		if self.screen.height < self.screen.size.background[4] then args.height = 35;end;
	end;
	
	self.typ = "pda";
	self.displayName = Utils.getNoNil(args.displayName, self.name);
	if self.xml.displayName ~= nil then self.displayName = Utils.getNoNil(self.xml.displayName, self.name);end;
	self.info = Utils.getNoNil(args.info, "Unknown Mod Creator Info");	
	self.moreInfo = "";
	self.searchFilter = "";
	self.autoZoomOutIn = Utils.getNoNil(args.autoZoomOutIn, ""); --HL Hud System can automatic ZoomOutIn icon or text in Pda total area (only is Pda Setting On) Default NO 
	if self.xml.autoZoomOutIn ~= nil then self.autoZoomOutIn = Utils.getNoNil(self.xml.autoZoomOutIn, "");end;
	self.show = Utils.getNoNil(args.show, true);
	if self.xml.show ~= nil then self.show = Utils.getNoNil(self.xml.show, true);end;	
	self.visibleDraw = true; --set here alone optional hidden Pda Draw
	self.drawIsIngameMapLarge = Utils.getNoNil(args.drawIsIngameMapLarge, false);
	if self.xml.drawIsIngameMapLarge ~= nil then self.drawIsIngameMapLarge = Utils.getNoNil(self.xml.drawIsIngameMapLarge, false);end;
	self.viewSettingIcons = Utils.getNoNil(args.viewSettingIcons, true);	
	if self.xml.viewSettingIcons ~= nil then self.viewSettingIcons = Utils.getNoNil(self.xml.viewSettingIcons, true);end;
	self.viewExtraLine = Utils.getNoNil(self.xml.viewExtraLine, false); --only true or false, is true set optional a line with !!!! button top left
	self.canDraw = function() return true;end;
	self.clickAreas = {};	
	self.canSave = true;
	self.canClose = true;
	self.canAutoClose = true;
	self.autoClose = Utils.getNoNil(self.xml.autoClose, false);
	self.canDragDropWidth = true;
	self.canDragDropHeight = true;
	self.canDragDrop = true;
	self.resetBoundsByDragDrop = true;
	self.resetBoundByDragDropWH = true;
	self.isHelp = Utils.getNoNil(self.xml.isHelp, false);	
	self.isSelect = false;
	self.isSetting = false;	
	self.settingTyp = 1;
	self.isSave = true;
	self.autoSave = true;
	self.needsUpdate = false;
	self.ownTable = Utils.getNoNil(args.ownTable, {});	
	self.overlays = hudSystem.overlays.new( {screen=self.screen, width=args.width, height=args.height, loadDefaultIcons=args.loadDefaultIcons, typ="pda"} );
	self.mouseInArea = hlHudSystemMouseKeyEvents.isInArea;		
	self.guiMenue = {};
	
	table.insert(hudSystem.pda, #hudSystem.pda+1, self);	
	
	return hudSystem.pda[#hudSystem.pda];		
end;

function hlPda:setMoreInfo(text)
	if text ~= nil and text:len() > 1 then self.moreInfo = "\n".. tostring(text);else self.moreInfo = "";end;
end;

function hlPda:setSearchFilter(text, resetBounds)
	local noUpdateState = text ~= nil and text == self.searchFilter;
	if text ~= nil and text:len() > 0 then self.searchFilter = tostring(text);else self.searchFilter = "";end;
	if noUpdateState == false then self:setUpdateState(resetBounds);end;
end;

function hlPda:setUpdateState(resetBounds, globalSave)
	self.needsUpdate = true;
	if globalSave == nil or globalSave == true then g_currentMission.hlHudSystem.isSave = false;end;
	if self.canSave then self.isSave = false;else self.isSave = true;end;
	if resetBounds == nil or resetBounds == true then self:resetBounds();end;
end;

function hlPda:resetBounds()
	if not self.screen.canBounds.on then return;end;
	self.screen:resetBounds();
end;

function hlPda:getPosition()
	return self.screen:getPosition();
end;

function hlPda:setPosition(posX, posY, resetBounds)
	local isUpdate = self.screen:setPosition(posX, posY, self.typ);
	if isUpdate then self:setUpdateState(resetBounds);end; 
end;

function hlPda:getWidthHeight()
	return self.screen:getWidthHeight();
end;

function hlPda:getWidth()
	return self.screen:getWidth();
end;

function hlPda:getHeight()
	return self.screen:getHeight();
end;

function hlPda:setWidthHeight(width, height, resetBounds)
	local isUpdate = self.screen:setWidthHeight(width, height);
	if isUpdate then self:setUpdateState(resetBounds);end;
end;

function hlPda:setMinHeight(height, resetBounds)
	local isUpdate = self.screen:setMinHeight(height);
	if isUpdate then self:setUpdateState(resetBounds);end;
end;

function hlPda:setMinWidth(width, resetBounds)
	local isUpdate = self.screen:setMinWidth(width);
	if isUpdate then self:setUpdateState(resetBounds);end;
end;

function hlPda:getOptiWidthHeight(args)
	return self.screen:getOptiWidthHeight(args);
end;

function hlPda:getMaxLineText(args)
	return self.screen:getMaxLineText(args);
end;

function hlPda:getMaxLineIcon(args)
	return self.screen:getMaxLineIcon(args);
end;

function hlPda:setZoomOutIn(args)
	local isUpdate = self.screen:setZoomOutIn(args);
	if isUpdate then self:setUpdateState(args.resetBounds);end;
end;

function hlPda:getScreen()
	return self.screen:getScreen();
end;

function hlPda:getSize(args)
	return self.screen:getSize(args);
end;

function hlPda:setSizeDistance(args, resetBounds)
	local isUpdate = self.screen:setSizeDistance(args);
	if isUpdate then self:setUpdateState(resetBounds);end;
end;

function hlPda:getLastShowPda()
	local lastShowPda = 0;
	if #g_currentMission.hlHudSystem.pda > 0 then	
		for pos=1, #g_currentMission.hlHudSystem.pda do
			if g_currentMission.hlHudSystem.pda[pos].show then
				lastShowPda = pos;
			end;			
		end;
	end;
	return lastShowPda;
end;

function hlPda:getFirstShowPda()
	local firstShowPda = 0;
	if #g_currentMission.hlHudSystem.pda > 0 then	
		for pos=1, #g_currentMission.hlHudSystem.pda do
			if g_currentMission.hlHudSystem.pda[pos].show then
				firstShowPda = pos;
				break;
			end;			
		end;
	end;
	return firstShowPda;
end;

function hlPda:getAllShowPdas()
	local showPdas = {};
	if #g_currentMission.hlHudSystem.pda > 0 then	
		for pos=1, #g_currentMission.hlHudSystem.pda do
			if g_currentMission.hlHudSystem.pda[pos].show then
				local values = {pda=pos};
				table.insert(showPdas, values);
			end;
		end;
	end;
	return showPdas;
end;

function hlPda:getData(pda)
	if pda == nil then return self, hlPda:getTablePos(self);end;
	if type(pda) == "number" then
		if g_currentMission.hlHudSystem.pda[pda] ~= nil then
			return g_currentMission.hlHudSystem.pda[pda], pda;
		end;
	elseif type(pda) == "string" and #g_currentMission.hlHudSystem.pda > 0 then
		for pos=1, #g_currentMission.hlHudSystem.pda do
			if g_currentMission.hlHudSystem.pda[pos].name == pda then return g_currentMission.hlHudSystem.pda[pos], pos;end;
		end;
	end;
	return nil;
end;

function hlPda:show(pda)
	if pda == nil then self.show = not self.show;self.clickAreas = {};return;end;
	local _, pdaPos = hlPda:getData(pda);
	if pdaPos == nil then return;end;
	g_currentMission.hlHudSystem.pda[pdaPos].show = not g_currentMission.hlHudSystem.pda[pdaPos].show;
	g_currentMission.hlHudSystem.pda[pdaPos].clickAreas = {};
end;

function hlPda:getTablePos(pda)
	if pda == nil then return;end;
	for pos=1, #g_currentMission.hlHudSystem.pda do
		if g_currentMission.hlHudSystem.pda[pos] == pda then return pos;end;
	end;
	return;
end;

function hlPda:delete(pda)	
	function removePdaIcons(deletePda)		
		g_currentMission.hlUtils.deleteOverlays(deletePda.overlays.settingIcons);		
		if deletePda.overlays.icons ~= nil then
			for modName,groupTable in pairs (deletePda.overlays.icons) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(deletePda.overlays.icons[modName][groupName]);						
					end;
				end;
			end;
		end;
		if deletePda.overlays.modIcons ~= nil then
			for modName,groupTable in pairs (deletePda.overlays.modIcons) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(deletePda.overlays.modIcons[modName][groupName]);						
					end;
				end;
			end;
		end;
		g_currentMission.hlUtils.deleteOverlays(deletePda.overlays);		
	end;
	if pda == nil then 
		pda = self;
		local pdaPos = hlPda:getTablePos(pda);
		if pdaPos == nil then return false;end;
		self.show = false;
		removePdaIcons(self);		
		table.remove(g_currentMission.hlHudSystem.pda, pdaPos);
		return true;
	else	
		local deletePda, pdaPos = hlPda:getData(pda);	
		if deletePda == nil or pdaPos == nil then return false;end;
		deletePda.show = false;
		removePdaIcons(deletePda);	
		table.remove(g_currentMission.hlHudSystem.pda, pdaPos);
		return true;
	end;
	return false;
end;

function hlPda:getXml()
	return self.xml:getXmlFile(), self.xml:getXmlNameTag();
end;

function hlPda:saveXml()
	self.xml:save(self);	
end;

function hlPda:setClickArea(args)		
	if args == nil or type(args) ~= "table" then return;end;
	if not g_currentMission.hlUtils.isMouseCursor then 
		self.clickAreas = {};
		return;
	end;
	local whatClick = args.whatClick or "pda_"; --optional a string
	if self.clickAreas[whatClick] == nil then self.clickAreas[whatClick] = {};end;
	self.clickAreas[whatClick][#self.clickAreas[whatClick]+1] = {
		args[1]; --posX needs
		args[2]; --posX1 needs
		args[3]; --posY needs
		args[4]; --posY1 needs		
		whatClick = whatClick;		
		whereClick = args.whereClick; --optional or use ownTable		
		areaClick = args.areaClick; --optional or use ownTable	
		overlay = args.overlay; --optional
		ownTable = args.ownTable; --optional
		onClick = args.onClick; --optional for mouse click area callback or callback self.onClick (pda.onClick)
		typ = args.typ or "pda"; 
		typPos = args.typPos or 0;
	};	
end;

function hlPda:getI18n(text)
	if text == nil then return "Missing Text";end;
	return g_i18n:getText(tostring(text), "hlHudSystem");
end;