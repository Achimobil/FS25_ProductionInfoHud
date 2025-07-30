hlHud = {};

local hlHud_mt = Class(hlHud);

function hlHud.generate(args)	
		
	local self = {};

	setmetatable(self, hlHud_mt);	
	local hudSystem = g_currentMission.hlHudSystem;
	self.name = Utils.getNoNil(args.name, "UnknownMod_Hud");
	
	if args.hiddenMod ~= nil then self.hiddenMod = args.hiddenMod; if g_currentMission.hlHudSystem.ownData.hiddenMods[args.hiddenMod] == nil then g_currentMission.hlHudSystem.ownData.hiddenMods[args.hiddenMod] = {isHidden=false,infoText=args.hiddenInfo};end;end;
	self.isHidden = function() if self.hiddenMod == nil or g_currentMission.hlHudSystem.ownData.hiddenMods[self.hiddenMod] == nil then return false;end;return g_currentMission.hlHudSystem.ownData.hiddenMods[self.hiddenMod].isHidden;end;
	
	self.screen = hudSystem.screen.new( {typ="hud", master=args.master} );
	
	self.xml = hlHudXml.new( {screen=self.screen, fileName=self.name} );
		
	if self.xml.file == nil then 
		if args.width == nil then 
			args.width = 35; 
		else
			if hudSystem.screen.pixelW*args.width < hudSystem.screen.size.background[5] then args.width = 35;end;
		end;
	else
		args.width = self.screen.width/self.screen.pixelW;
		if self.screen.width < self.screen.size.background[5] then args.width = 35;end;
	end;
	
	self.typ = "hud";
	self.displayName = Utils.getNoNil(args.displayName, self.name);
	if self.xml.displayName ~= nil then self.displayName = Utils.getNoNil(self.xml.displayName, self.name);end;	
	self.info = Utils.getNoNil(args.info, "Unknown Mod Creator Info");	
	self.moreInfo = "";
	self.searchFilter = "";
	self.autoZoomOutIn = Utils.getNoNil(args.autoZoomOutIn, ""); --HL Hud System can automatic ZoomOutIn icon or text in Hud this total area (only is Hud Setting On !NOT Global Setting!) Default NO 
	if self.xml.autoZoomOutIn ~= nil then self.autoZoomOutIn = Utils.getNoNil(self.xml.autoZoomOutIn, "");end;
	self.show = Utils.getNoNil(args.show, true);
	if self.xml.show ~= nil then self.show = Utils.getNoNil(self.xml.show, true);end;
	self.visibleDraw = true; --set here alone optional hidden Hud Draw
	self.drawIsIngameMapLarge = true;	
	self.viewSettingIcons = Utils.getNoNil(args.viewSettingIcons, true);	
	if self.xml.viewSettingIcons ~= nil then self.viewSettingIcons = Utils.getNoNil(self.xml.viewSettingIcons, true);end;
	self.viewSeparator = Utils.getNoNil(self.xml.viewSeparator, true);	
	self.clickAreas = {};
	self.canSave = true;	
	self.isHelp = Utils.getNoNil(self.xml.isHelp, false);	
	self.isSelect = false;
	self.isSetting = false;	
	self.settingTyp = 1;
	self.isSave = true;
	self.autoSave = true;
	self.canDragDropWidth = true; --not active at Hud
	self.canDragDropHeight = true; --not active at Hud
	self.canDragDrop = true; --not active at Hud
	self.needsUpdate = false;
	self.ownTable = Utils.getNoNil(args.ownTable, {});	
	self.overlays = hudSystem.overlays.new( {screen=self.screen, width=args.width, loadDefaultIcons=args.loadDefaultIcons, typ="hud"} );	
	self.mouseInArea = hlHudSystemMouseKeyEvents.isInArea;	
	self.guiMenue = {};
	
	local hudPos = Utils.getNoNil(args.hudPos, #hudSystem.hud+1);
	if self.xml.hudPos ~= nil then hudPos = Utils.getNoNil(self.xml.hudPos, #hudSystem.hud+1);end;
	if hudSystem.hud[hudPos+1] == nil then hudPos = #hudSystem.hud+1;end;
	table.insert(hudSystem.hud, hudPos, self);
	hlHud:updatePosition();
	
	return hudSystem.hud[hudPos];		
end;

function hlHud:setMoreInfo(text)
	if text ~= nil and text:len() > 1 then self.moreInfo = "\n".. tostring(text);else self.moreInfo = "";end;
end;

function hlHud:setSearchFilter(text, resetBounds)
	local noUpdateState = text ~= nil and text == self.searchFilter;
	if text ~= nil and text:len() > 0 then self.searchFilter = tostring(text);else self.searchFilter = "";end;
	if noUpdateState == false then self:setUpdateState(resetBounds);end;
end;

function hlHud:setUpdateState(resetBounds, globalSave)
	self.needsUpdate = true;
	if globalSave == nil or globalSave == true then g_currentMission.hlHudSystem.isSave = false;end;
	if self.canSave then self.isSave = false;else self.isSave = true;end;
	if resetBounds == nil or resetBounds == true then self:resetBounds();end;
end;

function hlHud:resetBounds()
	if not self.screen.canBounds.on then return;end;
	self.screen:resetBounds();
end;

function hlHud:updatePosition()
	if #g_currentMission.hlHudSystem.hud > 0 then		
		local posX = g_currentMission.hlHudSystem.screen.posX;
		local posY = g_currentMission.hlHudSystem.screen.posY;
		for pos=1, #g_currentMission.hlHudSystem.hud do
			local hud = g_currentMission.hlHudSystem.hud[pos];			
			local isHidden = hud.isHidden ~= nil and hud.isHidden();
			if hud.show and not isHidden then							
				hud.screen.posX = posX;
				hud.screen.posY = posY;
				posX = posX + hud.screen.width;
			end;
			hud:setUpdateState();			
		end;
		g_currentMission.hlHudSystem.isSave = false;
	end;
end;

function hlHud:updateWidthOverMouseClick(hud, scale) --one hud, funktioniert mit scale over mouseClick and scale = 1,2... oder -1,-2..., ein Pixel wird dann nur gesetzt
	if hud == nil then hud = self;end;
	if hud == nil or scale == nil or type(scale) ~= "number" then return;end;
	if type(hud) == "number" then
		if g_currentMission.hlHudSystem.hud[hud] ~= nil then
			hud = g_currentMission.hlHudSystem.hud[hud];
		end;
	elseif type(hud) == "string" and #g_currentMission.hlHudSystem.hud > 0 then
		for pos=1, #g_currentMission.hlHudSystem.hud do
			if g_currentMission.hlHudSystem.hud[pos].name == hud then hud = g_currentMission.hlHudSystem.hud[pos];break;end;
		end;
	end;
	if hud ~= nil then		
		if scale > 0 then
			hud.screen.width = hud.screen.width+(hud.screen.pixelW*scale);
			hud.screen.size.background[1] = hud.screen.width;			
		elseif scale < 0 then
			if hud.screen.width <= hud.screen.size.background[5] then return false;end;
			local negScale = scale-(scale*2);
			hud.screen.width = hud.screen.width-(hud.screen.pixelW*negScale);
			hud.screen.size.background[1] = hud.screen.width;			
		end;
		if scale ~= 0 then			
			hlHud:updatePosition();
			return true;
		end;
		return false;
	end;
end;

function hlHud:updateWidthHeight(width, height, posX, posY, activeShowHud) --over dragDropWH
	if #g_currentMission.hlHudSystem.hud > 0 then
		local setHeight = false;
		local setWidth = false;			
		local activeShowHud = activeShowHud or 1;		
		for pos=1, #g_currentMission.hlHudSystem.hud do			
			local hud = g_currentMission.hlHudSystem.hud[pos];
			if height >= hud.screen.size.background[4] and height <= hud.screen.size.background[3] then
				hud.screen.height = height;
				hud.screen.size.background[2] = hud.screen.height;
				setHeight = true;
			end;			
			if width > 0 and pos == activeShowHud and width >= hud.screen.size.background[5] then
				hud.screen.width = width;
				hud.screen.size.background[1] = hud.screen.width;
				setWidth = true;
				g_currentMission.hlUtils.deleteTextDisplay();
			end;
			if width < hud.screen.size.background[5] and g_currentMission.hlHudSystem.infoDisplay.on then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_dragDropWarningMinW"), "HUD"), txtBold=true, warning=true} );end;
			if height < hud.screen.size.background[4] and g_currentMission.hlHudSystem.infoDisplay.on then 
				g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_dragDropWarningMinH"), "HUD"), txtBold=true, warning=true} );
			elseif height > hud.screen.size.background[3] and g_currentMission.hlHudSystem.infoDisplay.on then
				g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(g_currentMission.hlHudSystem.hlHud:getI18n("hl_infoDisplay_dragDropWarningMaxH"), "HUD"), txtBold=true, warning=true} );
			end;
		end;		
		if setHeight or setWidth then
			if setHeight then g_currentMission.hlHudSystem.screen.height = height;g_currentMission.hlHudSystem.screen.posY = posY;end;
			hlHud:updatePosition();			
		end;
	end;
end;

function hlHud:updateWidthHeightOverMouseClick(scale) --all huds, funktioniert mit scale over mouseClick and scale = 1,2... oder -1,-2..., ein Pixel wird dann nur gesetzt
	if #g_currentMission.hlHudSystem.hud > 0 then
		local setWidthHeight = 0;
		for pos=1, #g_currentMission.hlHudSystem.hud do			
			local hud = g_currentMission.hlHudSystem.hud[pos];			
			if scale > 0 then				
				if hud.screen.height < hud.screen.size.background[3] then
					hud.screen.height = hud.screen.height+(hud.screen.pixelH*scale);				
					hud.screen.size.background[2] = hud.screen.height;
					
					g_currentMission.hlHudSystem.screen.height = hud.screen.height;
					g_currentMission.hlHudSystem.screen.size.background[2] = hud.screen.height;
					
					hud.screen.width = hud.screen.width+(hud.screen.pixelW*scale);
					hud.screen.size.background[1] = hud.screen.width;
					setWidthHeight = setWidthHeight+1;					
				end;				
			else				
				local negScale = scale-(scale*2);				
				if hud.screen.height > hud.screen.size.background[4] then
					hud.screen.height = hud.screen.height-(hud.screen.pixelH*negScale);				
					hud.screen.size.background[2] = hud.screen.height;
					
					g_currentMission.hlHudSystem.screen.height = hud.screen.height;
					g_currentMission.hlHudSystem.screen.size.background[2] = hud.screen.height;
					
					if hud.screen.width > hud.screen.size.background[5] then
						hud.screen.width = hud.screen.width-(hud.screen.pixelW*negScale);
						hud.screen.size.background[1] = hud.screen.width;
					end;
					setWidthHeight = setWidthHeight+1;					
				end;				
			end;			
		end;
		if setWidthHeight > 0 then hlHud:updatePosition();end;		
	end;
end;

function hlHud:getTotalWidth()
	local width = 0;
	if #g_currentMission.hlHudSystem.hud > 0 then	
		for pos=1, #g_currentMission.hlHudSystem.hud do
			if g_currentMission.hlHudSystem.hud[pos].show then
				width = width + g_currentMission.hlHudSystem.hud[pos].screen.width;
			end;			
		end;
	end;
	return width;
end;

function hlHud:getWidthFromPosition() --by hud position
	local width = 0;
	if #g_currentMission.hlHudSystem.hud > 0 then	
		local foundFirstHud = false;
		for pos=1, #g_currentMission.hlHudSystem.hud do
			if g_currentMission.hlHudSystem.hud[pos].show then
				if g_currentMission.hlHudSystem.hud[pos] == self or foundFirstHud then
					foundFirstHud = true;
					width = width + g_currentMission.hlHudSystem.hud[pos].screen.width;
				end;
			end;
		end;
	end;
	
	return width;
end;

function hlHud:getPosition()
	return self.screen:getPosition();
end;

function hlHud:setPosition(posX, posY)
	return;
end;

function hlHud:getWidthHeight()
	return self.screen:getWidthHeight();
end;

function hlHud:getWidth()
	return self.screen:getWidth();
end;

function hlHud:getHeight()
	return self.screen:getHeight();
end;

function hlHud:setWidthHeight()
	return;
end;

function hlHud:setMinHeight()
	return;
end;

function hlHud:setMinWidth()
	return;
end;

function hlHud:getLastShowHud()
	local lastShowHud = 0;
	if #g_currentMission.hlHudSystem.hud > 0 then	
		for pos=1, #g_currentMission.hlHudSystem.hud do
			if g_currentMission.hlHudSystem.hud[pos].show then
				lastShowHud = pos;
			end;			
		end;
	end;
	return lastShowHud;
end;

function hlHud:getFirstShowHud()
	local firstShowHud = 0;
	if #g_currentMission.hlHudSystem.hud > 0 then	
		for pos=1, #g_currentMission.hlHudSystem.hud do
			if g_currentMission.hlHudSystem.hud[pos].show then
				firstShowHud = pos;
				break;
			end;			
		end;
	end;
	return firstShowHud;
end;

function hlHud:getAllShowHuds()
	local showHuds = {};
	if #g_currentMission.hlHudSystem.hud > 0 then	
		for pos=1, #g_currentMission.hlHudSystem.hud do
			if g_currentMission.hlHudSystem.hud[pos].show and not g_currentMission.hlHudSystem.hud[pos].isHidden()then
				local values = {hud=pos};
				table.insert(showHuds, values);
			end;
		end;
	end;
	return showHuds;
end;

function hlHud:getOptiSizeText(args)
	return self.screen:getOptiSizeText(args);
end;

function hlHud:getOptiWidthHeight(args)
	return self.screen:getOptiWidthHeight(args);
end;

function hlHud:getMaxLineText(args)
	return self.screen:getMaxLineText(args);
end;

function hlHud:getMaxLineIcon(args)
	return self.screen:getMaxLineIcon(args);
end;

function hlHud:setZoomOutIn(args)
	local isUpdate = self.screen:setZoomOutIn(args);
	if isUpdate then self:setUpdateState();end;
end;

function hlHud:getScreen()
	return self.screen:getScreen();
end;

function hlHud:isNewUiScale()
	return self.screen:isNewUiScale();
end;

function hlHud:getUiScale()
	return self.screen:getUiScale();
end;

function hlHud:resetUiScale()
	self.screen:resetUiScale();
end;

function hlHud:getSize(args)
	return self.screen:getSize(args);
end;

function hlHud:setSizeDistance(args, resetBounds)
	local isUpdate = self.screen:setSizeDistance(args);
	if isUpdate then self:setUpdateState(resetBounds);end;
end;

function hlHud:getData(hud)
	if hud == nil then return self, hlHud:getTablePos(self);end;
	if type(hud) == "number" then
		if g_currentMission.hlHudSystem.hud[hud] ~= nil then
			return g_currentMission.hlHudSystem.hud[hud], hud;
		end;
	elseif type(hud) == "string" and #g_currentMission.hlHudSystem.hud > 0 then
		for pos=1, #g_currentMission.hlHudSystem.hud do
			if g_currentMission.hlHudSystem.hud[pos].name == hud then return g_currentMission.hlHudSystem.hud[pos], pos;end;
		end;
	end;
	return nil;
end;

function hlHud:show(hud)
	if hud == nil then self.show = not self.show;self.clickAreas = {};hlHud:updatePosition();return;end;
	local _, hudPos = hlHud:getData(hud);
	if hudPos == nil then return;end;
	g_currentMission.hlHudSystem.hud[hudPos].show = not g_currentMission.hlHudSystem.hud[hudPos].show;	
	g_currentMission.hlHudSystem.hud[hudPos].clickAreas = {}
	hlHud:updatePosition();	
end;

function hlHud:getTablePos(hud)
	if hud == nil then return;end;
	for pos=1, #g_currentMission.hlHudSystem.hud do
		if g_currentMission.hlHudSystem.hud[pos] == hud then return pos;end;
	end;
	return;
end;

function hlHud:delete(hud)	
	function removeHudIcons(deleteHud)		
		g_currentMission.hlUtils.deleteOverlays(deleteHud.overlays.settingIcons);		
		if deleteHud.overlays.icons ~= nil then
			for modName,groupTable in pairs (deleteHud.overlays.icons) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(deleteHud.overlays.icons[modName][groupName]);						
					end;
				end;
			end;
		end;
		if deleteHud.overlays.modIcons ~= nil then
			for modName,groupTable in pairs (deleteHud.overlays.modIcons) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(deleteHud.overlays.modIcons[modName][groupName]);						
					end;
				end;
			end;
		end;
		g_currentMission.hlUtils.deleteOverlays(deleteHud.overlays);		
	end;
	if hud == nil then 
		hud = self;
		local hudPos = hlHud:getTablePos(hud);
		if hudPos == nil then return false;end;
		self.show = false;
		hlHud:updatePosition();
		removeHudIcons(self);		
		table.remove(g_currentMission.hlHudSystem.hud, hudPos);
		return true;
	else
		local deleteHud, hudPos = hlHud:getData(hud);
		if deleteHud.name == "hlHudSystem_SettingHud" then return false;end;
		if deleteHud == nil or hudPos == nil then return false;end;
		deleteHud.show = false;
		hlHud:updatePosition();
		removeHudIcons(deleteHud);	
		table.remove(g_currentMission.hlHudSystem.hud, hudPos);
		return true;
	end;
	return false;
end;

function hlHud:setNewOrderPosition(oldPos, newPos)
	if #g_currentMission.hlHudSystem.hud > 1 and oldPos ~= newPos and newPos <= #g_currentMission.hlHudSystem.hud then
		if g_currentMission.hlHudSystem.hud[oldPos] ~= nil then
			local oldHud = g_currentMission.hlHudSystem.hud[oldPos];
			oldHud.clickAreas = {};
			table.remove(g_currentMission.hlHudSystem.hud, oldPos);
			table.insert(g_currentMission.hlHudSystem.hud, newPos, oldHud);
			hlHud:updatePosition()
		end;
	end;
end;

function hlHud:getXml()
	return self.xml:getXmlFile(), self.xml:getXmlNameTag();
end;

function hlHud:saveXml()
	self.xml:save(self);	
end;

function hlHud:setSelect(hud) --not active (for key control or...)
	if hud == nil then 
		hud = self;
	end;
	local hud, hudPos = hlHud:getData(hud);
	if hud == nil then return;end;
	hud.isSelect = not hud.isSelect;
	for pos=1, #g_currentMission.hlHudSystem.hud do
		if hud ~= g_currentMission.hlHudSystem.hud[pos] and pos ~= hudPos then g_currentMission.hlHudSystem.hud[pos].isSelect = false;end;
	end;
end;

function hlHud:setClickArea(args)		
	if args == nil or type(args) ~= "table" then return;end;
	if not g_currentMission.hlUtils.isMouseCursor then 
		self.clickAreas = {};
		return;
	end;
	local whatClick = args.whatClick or "hud_"; --optional a string
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
		onClick = args.onClick; --optional for mouse click area callback or callback self.onClick (hud.onClick)
		typ = args.typ or "hud";
		typPos = args.typPos or 0;
	};	
end;

function hlHud:getI18n(text)
	if text == nil then return "Missing Text";end;
	return g_i18n:getText(tostring(text), "hlHudSystem");
end;