hlGuiBox = {};
local hlGuiBox_mt = Class(hlGuiBox)

function hlGuiBox.generate(args)
	
	local self = {};

	setmetatable(self, hlGuiBox_mt);
	local hudSystem = g_currentMission.hlHudSystem;
	self.name = Utils.getNoNil(args.name, "UnknownMod_GuiBox");
	
	self.screen = hudSystem.screen.new( {typ="guiBox"} );	
	
	self.xml = hlGuiBoxXml.new( {screen=self.screen, fileName=self.name} );
	
	self.title = args.title or "Unknown Title";
	self.displayName = args.displayName or self.title;
	self.colorTitle = args.colorTitle or hlHudSystemOverlays.color.columText1;
	self.viewMaxLines = args.viewMaxLines or 10; --first start height,
	self.lines = {};	
	self.canAddModLines = false;
	self.firstAddModLinePos = 0;
	self.firstAddModHidderLinePos = 0;
	self.overlays = hlHudSystemOverlays:generateGuiBoxIcons();
	self.color = {title=args.colorTitle or hlHudSystemOverlays.color.columText1,text="white"};
	self.canDragDrop = true;
	self.resetBoundsByDragDrop = false;
	self.canDragDropWidth = true;	
	self.canDragDropHeight = true;	
	self.resetBoundsByDragDropWH = true;	
	self:setDimension(args.size);	
	self.clickAreas = {};
	self.typ = "guiBox";
	self.show = false;
	self.needsUpdate = false;
	self.ownTable = Utils.getNoNil(args.ownTable, {});
	self.mouseInArea = hlHudSystemMouseKeyEvents.isInArea;	
	
	if args.onOverGuiBoxHudSystem ~= nil and args.onOverGuiBoxHudSystem then 
		if g_currentMission.hlHudSystem.guiMenu ~= nil then 			
			g_currentMission.hlHudSystem.guiMenu:addModLine( {modGuiBoxOn=true,getLine=hlOwnGuiBoxXml.getOtherLineGuiBoxOn,lineCallSequence="otherGuiBoxOn_".. self.name} ); 
		end;
	end;
	
	table.insert(hudSystem.guiBox, #hudSystem.guiBox+1, self);	
	return hudSystem.guiBox[#hudSystem.guiBox];
end;

function hlGuiBox:setUpdateState(resetBounds, globalSave)
	self.needsUpdate = true;
	if globalSave == nil or globalSave == true then g_currentMission.hlHudSystem.isSave = false;end;
	if resetBounds == nil or resetBounds == true then self:resetBounds();end;
end;

function hlGuiBox:resetBounds()
	if not self.screen.canBounds.on then return;end;
	self.screen:resetBounds();
end;

function hlGuiBox:resetDimension()
	local distance = self:getSize( {"distance"} );
	local size = self.screen.size.zoomOutIn.text[1];	
	self.textHeight = getTextHeight(size, utf8Substr("Äg", 0));
	self.lineHeight = self.textHeight+(distance.textHeight*2);
	self.titleHeight = getTextHeight(size+0.002, utf8Substr("Äg", 0));	
	self.iconWidth, self.iconHeight = self:getOptiIconWidthHeight();
	
	if not g_currentMission.hlHudSystem.isAlreadyExistsXml("guibox", self.name) then
		local viewMaxLines = self.viewMaxLines;	
		if #self.lines > 0 and #self.lines <= viewMaxLines then viewMaxLines = #self.lines;elseif #self.lines == 0 then viewMaxLines = 2;end;
		local height = (self.lineHeight*viewMaxLines)+self.titleHeight;
		self.screen.height = height;
	end;
end;

function hlGuiBox:setDimension(size)
	self.screen.canBounds.on = true;
	local maxSize = self.screen.size.zoomOutIn.text[3];
	local minSize = self.screen.size.zoomOutIn.text[4];
	if size == nil or size < minSize or size > maxSize then size = self.screen.size.zoomOutIn.text[1];end;
	local width = self.screen.pixelW*350;
	self.screen.width = width;	
	self:setMinWidth(self.screen.pixelW*300);	
	self.screen:setSizeDistance( {"textHeight", self.screen.pixelH*6} );
	self.screen:setSizeDistance( {"textWidth", self.screen.pixelW*3} );
	self.screen:setSizeDistance( {"textLine", self.screen.pixelH*8} ); --manipulate bounds
	self.screen.size.zoomOutIn.text[1] = size
	self.screen.size.zoomOutIn.text[4] = 0.015;
	local distance = self:getSize( {"distance"} );	
	local viewMaxLines = self.viewMaxLines;	
	if #self.lines > 0 and #self.lines <= viewMaxLines then viewMaxLines = #self.lines;elseif #self.lines == 0 then viewMaxLines = 2;end;
	self.textHeight = getTextHeight(size, utf8Substr("Äg", 0));
	self.lineHeight = self.textHeight+(distance.textHeight*2);
	self.titleHeight = getTextHeight(size+0.002, utf8Substr("Äg", 0));
	self:setMinHeight(self.titleHeight+self.textHeight);
	if not g_currentMission.hlHudSystem.isAlreadyExistsXml("guibox", self.name) then 
		local height = (self.lineHeight*viewMaxLines)+self.titleHeight;
		self.screen.height = height;
	end;
	self.iconWidth, self.iconHeight = g_currentMission.hlUtils.getOptiIconWidthHeight(self.textHeight, self.screen.pixelW, self.screen.pixelH);	
end;

function hlGuiBox:getOptiIconWidthHeight()
	return g_currentMission.hlUtils.getOptiIconWidthHeight(self.textHeight, self.screen.pixelW, self.screen.pixelH);
end;

function hlGuiBox:getScreen()
	return self.screen:getScreen();
end;

function hlGuiBox:isNewUiScale()
	return self.screen:isNewUiScale();
end;

function hlGuiBox:getUiScale()
	return self.screen:getUiScale();
end;

function hlGuiBox:resetUiScale()
	self.screen:resetUiScale();
end;

function hlGuiBox:getSize(args)
	return self.screen:getSize(args);
end;

function hlGuiBox:getData(guiBox)
	if guiBox == nil then return self, hlGuiBox:getTablePos(self);end;
	if type(guiBox) == "number" then
		if g_currentMission.hlHudSystem.guiBox[guiBox] ~= nil then
			return g_currentMission.hlHudSystem.guiBox[guiBox], guiBox;
		end;	
	elseif type(guiBox) == "string" and #g_currentMission.hlHudSystem.guiBox > 0 then
		for pos=1, #g_currentMission.hlHudSystem.guiBox do
			if g_currentMission.hlHudSystem.guiBox[pos].name == guiBox then return g_currentMission.hlHudSystem.guiBox[pos], pos;end;
		end;
	end;
	return nil;
end;

function hlGuiBox:getTablePos(guiBox)
	if guiBox == nil then return;end;
	for pos=1, #g_currentMission.hlHudSystem.guiBox do
		if g_currentMission.hlHudSystem.guiBox[pos] == guiBox then return pos;end;
	end;
	return;
end;

function hlGuiBox:setMinHeight(height)
	self.screen:setMinHeight(height);	
end;

function hlGuiBox:setMinWidth(width)
	self.screen:setMinWidth(width);	
end;

function hlGuiBox:deleteLines(args)
	local resetDimension = false;
	if args == nil then
		self.lines = {};		
		resetDimension = true;
	else
		if args.line ~= nil and self.lines[args.line] ~= nil then
			table.remove(self.lines, args.line);			
			resetDimension = true;
		end;			
	end;
	if resetDimension then self:resetDimension();end;
end;

function hlGuiBox:setSize(args)
	local size = self.screen.size.zoomOutIn.text[1];
	local maxSize = self.screen.size.zoomOutIn.text[3];
	local minSize = self.screen.size.zoomOutIn.text[4];
	if args.size ~= nil and args.size ~= size and args.size >= minSize and args.size <= maxSize then
		self.screen.size.zoomOutIn.text[1] = args.size;
		if #self.lines > 0 then
			for l=1, #self.lines do
				if self.lines[l][1].size > size then self.lines[l][1].size = size;end;
				if self.lines[l][2] ~= nil and self.lines[l][2].size > size then self.lines[l][2].size = size;end;
			end;
		end;		
		self:resetDimension();
	end;
end;

function hlGuiBox:setTitle(args)
	if args.title ~= nil then
		self.title = args.title;
	end;
end;

function hlGuiBox:setColorTitle(args)
	if args.color ~= nil then
		self.color.title = args.color;
	end;
end;

function hlGuiBox:addModLine(args)
	if not self.canAddModLines then return;end;
	if type(args) ~= "table" or args.getLine == nil or type(args.getLine) ~= "function" or args.lineCallSequence == nil or type(args.lineCallSequence) ~= "string" then return;end;	
	if self.name == "HlHudSystem_GuiBox" and args.modGuiBoxOn ~= nil and args.modGuiBoxOn then 
		if self.firstAddModLinePos == 0 then			
			self.lines[#self.lines+1] = {lineCallSequence="otherModsHeadline_",getLine=hlOwnGuiBoxXml.getOtherLineGuiBoxOn};
			self.firstAddModLinePos = #self.lines;					
		end;
		args.pos = self.firstAddModLinePos+1;
		args.modLine = true;
		if #self.lines < self.firstAddModLinePos or args.pos > #self.lines then args.pos = nil;end;		
		self:addLine(args);
		self:resetDimension();
	else	
		args.modLine = true;
		if args.pos ~= nil and self.firstAddModLinePos > 0 and args.pos <= self.firstAddModLinePos then args.pos = nil;end;		
		self:addLine(args);
		self:resetDimension();
	end;
end;

function hlGuiBox:addLine(args)
	if type(args) ~= "table" then return;end;
	local line = {getLine=args.getLine,modLine=args.modLine,lineCallSequence=args.lineCallSequence,modHidder=args.modHidder};		
	if args.pos ~= nil and args.pos <= #self.lines then		
		if self.firstAddModLinePos > 0 and args.pos <= self.firstAddModLinePos then self.firstAddModLinePos = self.firstAddModLinePos+1;end;
		if self.firstAddModHidderLinePos > 0 and args.pos <= self.firstAddModHidderLinePos then self.firstAddModHidderLinePos = self.firstAddModHidderLinePos+1;end;
		table.insert(self.lines, args.pos, line);		
	else
		self.lines[#self.lines+1] = line;		
	end;
	if args.modGuiBoxOn ~= nil then self.firstAddModLinePos = self.firstAddModLinePos+1;end;
	if args.modHidder ~= nil then self.firstAddModHidderLinePos = self.firstAddModHidderLinePos+1;end;
end;

function hlGuiBox:getErrorLine(line, modError)	
	local modErrorText = "Mod ";
	if not modError then modErrorText = "";end;
	return { typ="string", text={[1]={text=modErrorText.. "Error Line ".. tostring(line), color="red"}} };
end;

function hlGuiBox:formatLine(guiBox, line)	
	local maxSize = guiBox.screen.size.zoomOutIn.text[3];
	local minSize = guiBox.screen.size.zoomOutIn.text[4];
	if line.typ == nil then line.typ = "string";end;
	if line.text == nil then line.text = {[1]={}, [2]={}};end;
	if line.text[1].text == nil then line.text[1].text = "Unknown";end;
	if line.text[1].bold == nil then line.text[1].bold = false;end;
	if line.text[1].blinking == nil then line.text[1].blinking = false;end;
	if line.text[1].size == nil or line.text[1].size < minSize or line.text[1].size > maxSize then line.text[1].size = guiBox.screen.size.zoomOutIn.text[1];end;	
	if line.text[1].color == nil then line.text[1].color = guiBox.color.text;end;
	if line.typ ~= "headline" and line.text[2] ~= nil then	
		if line.text[2].text == nil then line.text[2].text = "";end;
		if line.text[2].bold == nil then line.text[2].bold = false;end;
		if line.text[2].blinking == nil then line.text[2].blinking = false;end;
		if line.text[2].size == nil or line.text[2].size < minSize or line.text[2].size > maxSize then line.text[2].size = guiBox.screen.size.zoomOutIn.text[1];end;	
		if line.text[2].color == nil then line.text[2].color = guiBox.color.text;end;	
	end;	
	return line;
end;

function hlGuiBox:setShow(state)
	if #g_currentMission.hlHudSystem.guiBox > 0 then
		if state == nil then			
			for pos=1, #g_currentMission.hlHudSystem.guiBox do
				g_currentMission.hlHudSystem.guiBox[pos].show = false;
			end;			
		elseif not state then
			self.show = false;
		elseif state then			
			for pos=1, #g_currentMission.hlHudSystem.guiBox do
				local guiBox = g_currentMission.hlHudSystem.guiBox[pos];				
				if guiBox == self then 
					guiBox.show = true;
				else
					guiBox.show = false;
				end;				
			end;			
		end;
	end;
end;

function hlGuiBox:delete(guiBox)	
	function removeGuiBoxIcons(deleteGuiBox)		
		if deleteGuiBox.overlays ~= nil then
			for modName,groupTable in pairs (deleteGuiBox.overlays) do		
				for groupName,iconTable in pairs (groupTable) do						
					if groupName ~= "byName" then
						g_currentMission.hlUtils.deleteOverlays(deleteGuiBox.overlays[modName][groupName]);						
					end;
				end;
			end;
		end;					
	end;
	if guiBox == nil then 
		guiBox = self;
		local guiBoxPos = hlGuiBox:getTablePos(guiBox);
		if guiBoxPos == nil then return false;end;
		self.show = false;
		removeGuiBoxIcons(self);		
		table.remove(g_currentMission.hlHudSystem.guiBox, guiBoxPos);
		return true;
	else	
		local deleteGuiBox, guiBoxPos = hlGuiBox:getData(guiBox);	
		if deleteGuiBox == nil or guiBoxPos == nil then return false;end;
		deleteGuiBox.show = false;
		removeGuiBoxIcons(deleteGuiBox);	
		table.remove(g_currentMission.hlHudSystem.guiBox, guiBoxPos);
		return true;
	end;
	return false;
end;

function hlGuiBox:getXml()
	return self.xml:getXmlFile(), self.xml:getXmlNameTag();
end;

function hlGuiBox:saveXml()
	self.xml:save(self);	
end;

function hlGuiBox:setClickArea(args)		
	if args == nil or type(args) ~= "table" then return;end;
	if not g_currentMission.hlUtils.isMouseCursor then 
		self.clickAreas = {};
		return;
	end;
	local whatClick = args.whatClick or "guiBox_"; --optional a string
	if self.clickAreas[whatClick] == nil then self.clickAreas[whatClick] = {};end;
	self.clickAreas[whatClick][#self.clickAreas[whatClick]+1] = {
		args[1]; --posX
		args[2]; --posX1
		args[3]; --posY
		args[4]; --posY1		
		whatClick = whatClick;			
		whereClick = args.whereClick; --optional or use ownTable		
		areaClick = args.areaClick; --optional or use ownTable
		ownTable = args.ownTable; --optional
		onClick = args.onClick; --optional for mouse click area callback or callback self.onClick (guiBox.onClick)
		line = args.line or 0;
		lineCallSequence = args.lineCallSequence;
		typPos = args.typPos or 0;
	};	
end;

function hlGuiBox:getI18n(text)
	if text == nil then return "Missing Text";end;
	return g_i18n:getText(tostring(text), "hlHudSystem");
end;