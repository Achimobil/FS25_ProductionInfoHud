hlBox = {};

local hlBox_mt = Class(hlBox);

function hlBox.generate(args)	
		
	local self = {};

	setmetatable(self, hlBox_mt);	
	local hudSystem = g_currentMission.hlHudSystem;
	self.name = Utils.getNoNil(args.name, "UnknownMod_Box");
	
	if args.hiddenMod ~= nil then self.hiddenMod = args.hiddenMod; if g_currentMission.hlHudSystem.ownData.hiddenMods[args.hiddenMod] == nil then g_currentMission.hlHudSystem.ownData.hiddenMods[args.hiddenMod] = {isHidden=false,infoText=args.hiddenInfo};end;end;
	self.isHidden = function() if self.hiddenMod == nil or g_currentMission.hlHudSystem.ownData.hiddenMods[self.hiddenMod] == nil then return false;end;return g_currentMission.hlHudSystem.ownData.hiddenMods[self.hiddenMod].isHidden;end;
	
	typ = "box";
		
	self.screen = hudSystem.screen.new( {typ=typ} );
	
	self.xml = hlBoxXml.new( {screen=self.screen, fileName=self.name} );
	
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
	
	self.typ = typ;
	self.displayName = Utils.getNoNil(args.displayName, self.name);
	if self.xml.displayName ~= nil then self.displayName = Utils.getNoNil(self.xml.displayName, self.name);end;	
	self.info = Utils.getNoNil(args.info, "Unknown Mod Creator Info");	
	self.moreInfo = "";
	self.searchFilter = "";
	self.autoZoomOutIn = Utils.getNoNil(args.autoZoomOutIn, ""); --HL Hud System can automatic ZoomOutIn icon or text in Box total area (only is Box Setting On) Default NO 
	if self.xml.autoZoomOutIn ~= nil then self.autoZoomOutIn = Utils.getNoNil(self.xml.autoZoomOutIn, "");end;
	self.show = Utils.getNoNil(args.show, true);
	if self.xml.show ~= nil then self.show = Utils.getNoNil(self.xml.show, true);end;	
	self.visibleDraw = true; --set here alone optional hidden Box Draw
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
	self.overlays = hudSystem.overlays.new( {screen=self.screen, width=args.width, height=args.height, loadDefaultIcons=args.loadDefaultIcons, typ=typ} );
	self.mouseInArea = hlHudSystemMouseKeyEvents.isInArea;	
	self.guiMenue = {};	
	self.isGuiBox = args.guiBox ~= nil and args.guiBox;	
		
	table.insert(hudSystem.box, #hudSystem.box+1, self);	
	
	return hudSystem.box[#hudSystem.box];	
end;

function hlBox:setMoreInfo(text)
	if text ~= nil and text:len() > 1 then self.moreInfo = "\n".. tostring(text);else self.moreInfo = "";end;
end;

function hlBox:setSearchFilter(text, resetBounds)
	local noUpdateState = text ~= nil and text == self.searchFilter;
	if text ~= nil and text:len() > 0 then self.searchFilter = tostring(text);else self.searchFilter = "";end;
	if noUpdateState == false then self:setUpdateState(resetBounds);end;
end;

function hlBox:setUpdateState(resetBounds, globalSave)
	self.needsUpdate = true;
	if globalSave == nil or globalSave == true then g_currentMission.hlHudSystem.isSave = false;end;
	if self.canSave then self.isSave = false;else self.isSave=true;end;
	if resetBounds == nil or resetBounds == true then self:resetBounds();end;
end;

function hlBox:resetBounds()
	if not self.screen.canBounds.on then return;end;
	self.screen:resetBounds();
end;

function hlBox:getPosition()
	return self.screen:getPosition();
end;

function hlBox:setPosition(posX, posY, resetBounds)
	local isUpdate = self.screen:setPosition(posX, posY, self.typ);
	if isUpdate then self:setUpdateState(resetBounds);end;
end;

function hlBox:getWidthHeight()
	return self.screen:getWidthHeight();
end;

function hlBox:getWidth()
	return self.screen:getWidth();
end;

function hlBox:getHeight()
	return self.screen:getHeight();
end;

function hlBox:setWidthHeight(width, height, resetBounds)
	local isUpdate = self.screen:setWidthHeight(width, height);
	if isUpdate then self:setUpdateState(resetBounds);end;
end;

function hlBox:setMinHeight(height, resetBounds)
	local isUpdate = self.screen:setMinHeight(height);
	if isUpdate then self:setUpdateState(resetBounds);end;
end;

function hlBox:setMinWidth(width, resetBounds)
	local isUpdate = self.screen:setMinWidth(width);
	if isUpdate then self:setUpdateState(resetBounds);end;
end;

function hlBox:getOptiWidthHeight(args)
	return self.screen:getOptiWidthHeight(args);
end;

function hlBox:getMaxLineText(args)
	return self.screen:getMaxLineText(args);
end;

function hlBox:getMaxLineIcon(args)
	return self.screen:getMaxLineIcon(args);
end;

function hlBox:setZoomOutIn(args)
	local isUpdate = self.screen:setZoomOutIn(args);
	if isUpdate then self:setUpdateState(args.resetBounds);end;
end;

function hlBox:getScreen()
	return self.screen:getScreen();
end;

function hlBox:getSize(args)
	return self.screen:getSize(args);
end;

function hlBox:setSizeDistance(args, resetBounds)
	local isUpdate = self.screen:setSizeDistance(args);
	if isUpdate then self:setUpdateState(resetBounds);end;
end;

function hlBox:getLastShowBox()
	local lastShowBox = 0;
	if #g_currentMission.hlHudSystem.box > 0 then	
		for pos=1, #g_currentMission.hlHudSystem.box do
			if g_currentMission.hlHudSystem.box[pos].show then
				lastShowBox = pos;
			end;			
		end;
	end;
	return lastShowBox;
end;

function hlBox:getFirstShowBox()
	local firstShowBox = 0;
	if #g_currentMission.hlHudSystem.box > 0 then	
		for pos=1, #g_currentMission.hlHudSystem.box do
			if g_currentMission.hlHudSystem.box[pos].show then
				firstShowBox = pos;
				break;
			end;			
		end;
	end;
	return firstShowBox;
end;

function hlBox:getAllShowBoxen()
	local showBoxen = {};
	if #g_currentMission.hlHudSystem.box > 0 then	
		for pos=1, #g_currentMission.hlHudSystem.box do
			if g_currentMission.hlHudSystem.box[pos].show then
				local values = {box=pos};
				table.insert(showBoxen, values);
			end;
		end;
	end;
	return showBoxen;
end;

function hlBox:getData(box)
	if box == nil then return self, hlBox:getTablePos(self);end;
	if type(box) == "number" then
		if g_currentMission.hlHudSystem.box[box] ~= nil then
			return g_currentMission.hlHudSystem.box[box], box;
		end;
	elseif type(box) == "string" and #g_currentMission.hlHudSystem.box > 0 then
		for pos=1, #g_currentMission.hlHudSystem.box do
			if g_currentMission.hlHudSystem.box[pos].name == box then return g_currentMission.hlHudSystem.box[pos], pos;end;
		end;
	end;
	return nil;
end;

function hlBox:show(box)
	if box == nil then self.show = not self.show;self.clickAreas = {};return;end;
	local _, boxPos = hlBox:getData(box);
	if boxPos == nil then return;end;
	g_currentMission.hlHudSystem.box[boxPos].show = not g_currentMission.hlHudSystem.box[boxPos].show;
	g_currentMission.hlHudSystem.box[boxPos].clickAreas = {};
end;

function hlBox:getTablePos(box)
	if box == nil then return;end;
	for pos=1, #g_currentMission.hlHudSystem.box do
		if g_currentMission.hlHudSystem.box[pos] == box then return pos;end;
	end;
	return;
end;

function hlBox:delete(box)	
	function removeBoxIcons(deleteBox)		
		g_currentMission.hlUtils.deleteOverlays(deleteBox.overlays.settingIcons);						
		if deleteBox.overlays.icons ~= nil then
			for modName,groupTable in pairs (deleteBox.overlays.icons) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(deleteBox.overlays.icons[modName][groupName]);						
					end;
				end;
			end;
		end;
		if deleteBox.overlays.modIcons ~= nil then
			for modName,groupTable in pairs (deleteBox.overlays.modIcons) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(deleteBox.overlays.modIcons[modName][groupName]);						
					end;
				end;
			end;
		end;
		g_currentMission.hlUtils.deleteOverlays(deleteBox.overlays);			
	end;
	if box == nil then 
		box = self;
		local boxPos = hlBox:getTablePos(box);
		if boxPos == nil then return false;end;
		self.show = false;
		removeBoxIcons(self);		
		table.remove(g_currentMission.hlHudSystem.box, boxPos);
		return true;
	else	
		local deleteBox, boxPos = hlBox:getData(box);	
		if deleteBox == nil or boxPos == nil then return false;end;
		deleteBox.show = false;
		removeBoxIcons(deleteBox);	
		table.remove(g_currentMission.hlHudSystem.box, boxPos);
		return true;
	end;
	return false;
end;

function hlBox:getXml()
	return self.xml:getXmlFile(), self.xml:getXmlNameTag();
end;

function hlBox:saveXml()
	self.xml:save(self);	
end;

function hlBox:setClickArea(args)		
	if args == nil or type(args) ~= "table" then return;end;
	if not g_currentMission.hlUtils.isMouseCursor then 
		self.clickAreas = {};
		return;
	end;
	local whatClick = args.whatClick or "box_"; --optional a string
	if self.clickAreas[whatClick] == nil then self.clickAreas[whatClick] = {};end;
	self.clickAreas[whatClick][#self.clickAreas[whatClick]+1] = {
		args[1]; --posX
		args[2]; --posX1
		args[3]; --posY
		args[4]; --posY1		
		whatClick = whatClick;			
		whereClick = args.whereClick; --optional or use ownTable		
		areaClick = args.areaClick; --optional or use ownTable
		overlay = args.overlay; --optional
		ownTable = args.ownTable; --optional
		onClick = args.onClick; --optional for mouse click area callback or callback self.onClick (box.onClick)
		typ = args.typ or "box";
		typPos = args.typPos or 0;
	};	
end;

function hlBox:getI18n(text)
	if text == nil then return "Missing Text";end;
	return g_i18n:getText(tostring(text), "hlHudSystem");
end;