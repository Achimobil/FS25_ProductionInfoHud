hlHudSystemScreen = {};

local hlHudSystemScreen_mt = Class(hlHudSystemScreen);

function hlHudSystemScreen.new(args)	
	
	local self = {};

	setmetatable(self, hlHudSystemScreen_mt);
	
	local uiScale = g_gameSettings:getValue("uiScale");
	self.uiScale = uiScale;
	self.pixelX = 1 / g_screenWidth;
	self.pixelY = 1 / g_screenHeight;
	self.refPixelX = 1 / g_referenceScreenWidth;
	self.refPixelY = 1 / g_referenceScreenHeight;
	self.pixelW = math.max(self.refPixelX, self.pixelX);
	self.pixelH = math.max(self.refPixelY, self.pixelY);
	self.uiScaleW, self.uiScaleH = getNormalizedScreenValues(1 * uiScale, 1 * uiScale);
	self.pixelW = self.pixelW*g_aspectScaleX;
	self.pixelH = self.pixelH*g_aspectScaleY;
	self.difWidth = self.pixelW*1; 
	self.difHeight = self.pixelH*1;	
	if args.typ == "hud" then
		self.posX = args.posX or 0.4;
		self.posY = args.posY or 0.8;
	elseif args.typ == "pda" then
		self.posX = args.posX or 0.4;
		self.posY = args.posY or 0.6;
	elseif args.typ == "box" then
		self.posX = args.posX or 0.4;
		self.posY = args.posY or 0.4;
	elseif args.typ == "guiBox" then
		self.posX = args.posX or 0.6;
		self.posY = args.posY or 0.5;
	else
		self.posX = args.posX or 0;
		self.posY = args.posY or 0;
	end;
	self.width = 0;
	self.height = 0;
	
	self.size = hlHudSystemScreen:generateDefaultSize(self, args.typ);	
	if args.master == nil then
		self.height = g_currentMission.hlHudSystem.screen.height;
		self.size.background[2] = self.height;
	end;
	
	self.bounds = {-1,0,0,0};
	self.typ = args.typ;
	if args.typ == "pda" then
		self.canBounds = {on=false, typ="icon", setInfo=false};
	else
		self.canBounds = {on=false, typ="text", setInfo=true};
	end;
	return self;
end;

function hlHudSystemScreen:resetUiScale()
	local uiScale = g_gameSettings:getValue("uiScale");
	self.uiScale = uiScale;
	self.uiScaleW, self.uiScaleH = getNormalizedScreenValues(1 * uiScale, 1 * uiScale);
end;

function hlHudSystemScreen:getUiScale()
	return self.uiScale, self.uiScaleW, self.uiScaleH;
end;

function hlHudSystemScreen:isNewUiScale()
	return g_gameSettings:getValue("uiScale") ~= self.uiScale;	
end;

function hlHudSystemScreen:getScreen()
	return self.posX, self.posY, self.width, self.height;
end;

function hlHudSystemScreen:generateDefaultSize(screen, typ)	
	local minWidth = 25;
	if typ == "pda" or typ == "box" then minWidth = 30;end;
	if typ == "guiBox" then minWidth = 300;end;
	local size = { --default values
		background = {
			screen.pixelW*35; --width
			screen.pixelH*35; --height
			screen.pixelH*60; --max height
			screen.pixelH*25; --min height
			screen.pixelW*minWidth; --min width
		};
		separator = {
			screen.pixelW*1.2; --width
			2; --dif height scale
		};
		inArea = {
			screen.pixelH*2; --height
		};
		selectArea = {
			screen.pixelH*2; --height
		};
		icon = { --default values
			2.3; --dif scale width
			2.3; --dif scale height
		};
		settingIcon = {
			(screen.pixelW*26)/2.3; --! NOT EDIT PLS !
			(screen.pixelH*26)/2.3; --! NOT EDIT PLS !
		};		
		zoomOutIn = { --default values
			text = {
				0.015; --zoomOutIn default
				0.0005; --zoomOutIn Level
				0.020; --max zoomOutIn
				0.010; --min zoomOutIn
			};
			icon = { 
				23; --zoomOutIn default = self.screen.pixelH*self.screen.size.zoomOutIn.icon[1],self.screen.pixelW*self.screen.size.zoomOutIn.icon[1] (optional or own function)
				0.5; --zoomOutIn Level = self.screen.zoomOutIn.icon[1]+self.screen.zoomOutIn.icon[2] ... (optional or own function)
				60; --max zoomOutIn
				15; --min zoomOutIn
			};
		};
		distance = { --default difference values (optional or own function values)
			width = screen.pixelW*2;
			height = screen.pixelH*2;
			textLine = screen.pixelH*4; --
			textWidth = screen.pixelW*2; --
			textHeight = screen.pixelH*2;
			iconWidth = screen.pixelW*2;
			iconHeight = screen.pixelH*2;
		};
	};
	return size;
end;

function hlHudSystemScreen:generateBounds(args)
	if not self.canBounds.on then return;end;
	local maxLine = 0;
	if self.canBounds.typ == "text" then maxLine = self:getMaxLineText( {distanceTextLine=true} );elseif self.canBounds.typ == "icon" then maxLine = self:getMaxLineIcon( {distanceIconHeight=true,roundUp=false} );end;
	if maxLine > 0 then self.bounds[1] = 1;else self.bounds[1] = 0;end;
	self.bounds[2] = maxLine;self.bounds[3] = maxLine; --self.bounds[4] = text/icon lines Total, Mod Creator set this value or bounds is disabled
end;

function hlHudSystemScreen:setBounds(args)	
	if self.bounds[4] <= 0 or self.bounds[3] >= self.bounds[4] or self.bounds[1] == 0 then return;end;
	if args.up ~= nil and args.up then
		if self.bounds[1]-1 <= 0 then return;end;
		self.bounds[1] = self.bounds[1]-1;
		self.bounds[2] = self.bounds[2]-1;
	elseif args.down ~= nil and args.down then		
		if self.bounds[2]+1 > self.bounds[4] then return;end;
		self.bounds[1] = self.bounds[1]+1;
		self.bounds[2] = self.bounds[2]+1;
	end;
end;

function hlHudSystemScreen:checkCorrectBounds()
	if self.bounds[1] == 0 or self.bounds[4] <= 0 then return;end;
	if self.bounds[2] > self.bounds[4] then 
		local tempBounds2 = self.bounds[4]+1;
		self.bounds[2] = self.bounds[4]+1;
		if tempBounds2-self.bounds[3] <= 0 then
			self.bounds[1] = 1;
			self.bounds[2] = self.bounds[3];
		else
			self.bounds[1] = tempBounds2-self.bounds[3];
			self.bounds[2] = self.bounds[1]+self.bounds[3]-1;
		end;			
	end;
end;

function hlHudSystemScreen:resetBounds()
	self.bounds = {-1,0,0,0};
	self:generateBounds();
end;

function hlHudSystemScreen:getScreen()
	return self.posX, self.posY, self.width, self.height;
end;

function hlHudSystemScreen:getWidthHeight()
	return self.width, self.height;
end;

function hlHudSystemScreen:getWidth()
	return self.width;
end;

function hlHudSystemScreen:getHeight()
	return self.height;
end;

function hlHudSystemScreen:setWidthHeight(width, height)
	if self.typ == "hud" then return false;end;
	self.width = width or self.width; self.height = height or self.height;
	return true;
end;

function hlHudSystemScreen:setMinWidth(width)
	if self.typ == "hud" then return false;end;
	self.size.background[5] = width;
	if width > self.width then
		self.width = width;
		return true;
	end;
	return false;
end;

function hlHudSystemScreen:setMinHeight(height)
	if self.typ == "hud" then return false;end;
	self.size.background[4] = height;
	if height > self.height then 
		self.height = height;
		return true;
	end;
	return false;
end;

function hlHudSystemScreen:getPosition()
	return self.posX, self.posY;
end;

function hlHudSystemScreen:setPosition(posX, posY, typ) --not for Hud
	if typ == nil or typ == "hud" then return false;end;
	self.posX = posX; self.posY = posY;
	return true;
end;

function hlHudSystemScreen:getSize(args) --1 = sizeName
	if args == nil or type(args) ~= "table" or args[1] == nil then return;end;
	if self == nil or self.size == nil or self.size[args[1]] == nil then return;end;
	if args[2] == nil or self.size[args[1]][args[2]] == nil then 
		return self.size[args[1]];
	end;
	if args[3] == nil or self.size[args[1]][args[2]][args[3]] == nil then	
		return self.size[args[1]][args[2]];
	end;
	return self.size[args[1]][args[2]][args[3]];
end;

function hlHudSystemScreen:setSizeDistance(args)
	if args == nil or type(args) ~= "table" or args[1] == nil or args[2] == nil then return false;end;
	if self == nil or self.size == nil or self.size.distance == nil then return false;end;
	if self.size.distance[args[1]] ~= nil and args[2] ~= nil and type(args[2]) == "number" then
		self.size.distance[args[1]] = args[2];
		return true;
	end;
	return false;
end;

function hlHudSystemScreen:setZoomOutIn(args)
	if args == nil or type(args) ~= "table" or args.typ == nil or type(args.typ) ~= "string" then return false;end;
	if self == nil or self.size == nil or self.size.zoomOutIn[args.typ] == nil then return false;end;	
	local zoom = args.zoom;
	if zoom == nil then zoom = self.size.zoomOutIn[args.typ][2];end; --default zoom	
	if args.up ~= nil and args.up then
		if args.force == nil or not args.force then		
			if self.size.zoomOutIn[args.typ][1]-zoom < self.size.zoomOutIn[args.typ][4] then 
				if zoom > 1 then self.size.zoomOutIn[args.typ][1] = self.size.zoomOutIn[args.typ][4];return true;end;
				return false;
			end;
		end;
		if self.size.zoomOutIn[args.typ][1]-zoom < 0 then self.size.zoomOutIn[args.typ][1] = 0;return false;end;
		self.size.zoomOutIn[args.typ][1] = self.size.zoomOutIn[args.typ][1]-zoom;
		return true;
	elseif args.down ~= nil and args.down then
		if args.force == nil or not args.force then
			if self.size.zoomOutIn[args.typ][1]+zoom > self.size.zoomOutIn[args.typ][3] then 
				if zoom > 1 then self.size.zoomOutIn[args.typ][1] = self.size.zoomOutIn[args.typ][3];return true;end;
				return false;				
			end;
		end;
		self.size.zoomOutIn[args.typ][1] = self.size.zoomOutIn[args.typ][1]+zoom;
		return true;
	end;
end;

function hlHudSystemScreen:getMaxLineText(args)
	if self == nil or self.size == nil then return 0;end;
	local _, _, _, h = self:getScreen();
	if args.height ~= nil then h = args.height;end;
	local size = args.size or self.size.zoomOutIn.text[1];
	local txt = args.text or "Äg";
	setTextBold(args.textBold or false);
	local txtHeight = getTextHeight(size, utf8Substr(txt, 0));
	setTextBold(false);
	if args.distanceTextLine ~= nil and args.distanceTextLine then txtHeight = txtHeight+self.size.distance.textLine;end;
	if args.distanceTextHeight ~= nil and args.distanceTextHeight then txtHeight = txtHeight+self.size.distance.textHeight;end;
	return g_currentMission.hlUtils.maxLineBounds(h, txtHeight, size);
end;

function hlHudSystemScreen:getMaxLineIcon(args)
	if self == nil or self.size == nil then return 0;end;
	local _, _, _, h = self:getScreen();
	if args.height ~= nil then h = args.height;end;	
	local iconHeight = self.pixelH*self.size.zoomOutIn.icon[1];
	if args.distanceIconHeight ~= nil and args.distanceIconHeight then iconHeight = iconHeight+self.size.distance.iconHeight;end;
	return g_currentMission.hlUtils.getMaxIconHeight(h, iconHeight, args.roundDown);	
end;

function hlHudSystemScreen:getOptiSizeText(args)
	if args == nil or type(args) ~= "table" or (args.typ ~= nil and type(args.typ) ~= "string") then return 0;end;
	if self == nil or self.size == nil then return 0;end;	
	local zoom = args.zoom;
	if args.typ ~= nil and args.typ == "text" then
		if zoom == nil then zoom = self.size.zoomOutIn.text[1];end; --default zoom
		local line = args.line or 1;
		local _, _, w, h = self:getScreen();		
		if args.height ~= nil and args.height <= h then h = args.height;end;
		h = h/line;
		if args.width ~= nil and args.width <= w then w = args.width;end;
		local txt = args.text or "Äg";
		local size = g_currentMission.hlUtils.optiHeightSize(h, txt, args.size or zoom, args.textBold);
		if args.text == nil or args.width == nil then return size;end;
		if args.width ~= nil and (args.cut == nil or not args.cut) then return g_currentMission.hlUtils.optiWidthSize(w, txt, size, args.textBold);end;
		if args.width ~= nil and args.cut ~= nil and args.cut and args.text ~= nil then
			local txtCut = g_currentMission.hlUtils.getTxtToWidthFix(txt, size, w, ".", args.difLenght or 0, args.textBold);
			return size, txtCut;
		end;
		return 0;
	end;
end;

function hlHudSystemScreen:getOptiWidthHeight(args)	
	if args == nil or type(args) ~= "table" or (args.typ ~= nil and type(args.typ) ~= "string") then return 0,0;end;
	if self == nil or self.size == nil then return 0,0;end;	
	local zoom = args.zoom;
	if args.typ ~= nil and args.typ == "icon" and self.size.zoomOutIn[args.typ] ~= nil then
		if args.height ~= nil and args.width ~= nil then	
			if zoom == nil then zoom = self.size.zoomOutIn[args.typ][1];end; --default zoom		
			local iconHeight = self.pixelH*zoom;
			local iconWidth = self.pixelW*zoom;
			if iconHeight <= args.height and iconWidth <= args.width then return iconWidth, iconHeight;end;
			local zoomLV = self.size.zoomOutIn[args.typ][2];
			local int = zoomLV;
			while args.height < iconHeight or args.width < iconWidth do
				iconHeight = self.pixelH*(zoom-int);
				iconWidth = self.pixelW*(zoom-int);
				int = int+zoomLV;
			end;
			return iconWidth, iconHeight;		
		end;
	elseif (args.typ == nil or args.typ == "hud" or args.typ == "pda" or args.typ == "box") and args.height ~= nil then --total icon height/width by hud/pda/box width/height
		local iconHeight = args.height/(self.size.icon[2]/2);
		local iconWidth = self.pixelW*(iconHeight/self.pixelH);			
		if iconHeight <= args.height and args.width ~= nil and iconWidth <= args.width then return iconWidth, iconHeight;end;	
		local int = 0.1;		
		while (args.width ~= nil and args.width < iconWidth) or iconWidth > args.height do --change by width and height
			iconHeight = args.height/((self.size.icon[2]+int)/2);
			iconWidth = self.pixelW*(iconHeight/self.pixelH);
			int = int+0.1;
		end;				
		return iconWidth, iconHeight;	
	end;
	return 0,0;
end;

function hlHudSystemScreen:setDragDropPosition(args)
	if args == nil or type(args) ~= "table" then return;end;
	local refresh = false;
	local posX = g_currentMission.hlUtils.mouseCursor.posX;
	local posY = g_currentMission.hlUtils.mouseCursor.posY;
	local overlay = g_currentMission.hlUtils.dragDrop.overlay;	
	local what = g_currentMission.hlUtils.dragDrop.what;
	if args.difWidth ~= nil then posX = posX+(args.difWidth);end;
	if args.difHeight ~= nil then posY = posY+(args.difHeight);end;
	if overlay ~= nil then 
		--g_currentMission.hlUtils.setBackgroundColor(overlay, g_currentMission.hlUtils.getColor("yellow", true));
	end;
	if what == "_hlHud_" then
		if g_currentMission.hlHudSystem.screen.posX ~= posX then
			g_currentMission.hlHudSystem.screen.posX = posX;
			refresh = true;
		end;
		if g_currentMission.hlHudSystem.screen.posY ~= posY then
			g_currentMission.hlHudSystem.screen.posY = posY;
			refresh = true;
		end;
		if refresh then g_currentMission.hlHudSystem.hlHud:updatePosition();end;
	elseif what == "_hlPda_" or what == "_hlBox_" or what == "_hlGuiBox_" then
		local typ = g_currentMission.hlHudSystem[string.gsub(what, "_", "")]:getData(g_currentMission.hlUtils.dragDrop.typPos)		
		if typ ~= nil and typ.canDragDrop then
			if typ.screen.posX ~= posX then
				typ.screen.posX = posX;
				refresh = true;
			end;
			if typ.screen.posY ~= posY then
				typ.screen.posY = posY;
				refresh = true;
			end;
			if refresh then typ:setUpdateState(typ.resetBoundsByDragDrop);end;
		end;
	end;
end;

function hlHudSystemScreen:setDragDropWidthHeight(args)
	if args == nil or type(args) ~= "table" then return;end;
	local refresh = false;
	local posX = g_currentMission.hlUtils.mouseCursor.posX;
	local posY = g_currentMission.hlUtils.mouseCursor.posY;
	local what = g_currentMission.hlUtils.dragDrop.what;
	if args.difWidth ~= nil then posX = posX+(args.difWidth);end;
	if args.difHeight ~= nil then posY = posY+(args.difHeight);end;
	if g_currentMission.hlUtils.dragDrop.overlay ~= nil then 
		--g_currentMission.hlUtils.setBackgroundColor(g_currentMission.hlUtils.dragDrop.overlay, g_currentMission.hlUtils.getColor("yellow", true));
	end;
	if what == "_hlHud_" then 	
		local hud = g_currentMission.hlHudSystem[string.gsub(what, "_", "")]:getData(g_currentMission.hlUtils.dragDrop.typPos);
		local width = 0;
		if hud ~= nil then width = (posX-hud.screen.posX);end;		
		local height = (g_currentMission.hlHudSystem.screen.posY+g_currentMission.hlHudSystem.screen.height)-(posY);
		g_currentMission.hlHudSystem.hlHud:updateWidthHeight(width, height, posX, posY, g_currentMission.hlUtils.dragDrop.typPos);		
	elseif what == "_hlPda_" or what == "_hlBox_" or what == "_hlGuiBox_" then 
		local helpTyp = g_currentMission.hlUtils.dragDrop.typ;						
		local warningTxt = 0;
		local typ = g_currentMission.hlHudSystem[string.gsub(what, "_", "")]:getData(g_currentMission.hlUtils.dragDrop.typPos);		
		if typ ~= nil and (typ.canDragDropWidth or typ.canDragDropHeight) then					
			if typ.canDragDropWidth then 
				local width = posX-typ.screen.posX;				
				if width >= typ.screen.size.background[5] then
					typ.screen.width = width;
					refresh = true;
				else
					warningTxt = 1;				
				end;
			end;
			if typ.canDragDropHeight then
				local height = (typ.screen.posY+typ.screen.height)-posY;
				if height >= typ.screen.size.background[4] then 
					typ.screen.height = height;
					typ.screen.posY = posY;
					refresh = true;
				else	
					if warningTxt == 1 then warningTxt = 3;else warningTxt = 2;end;				
				end;
			end;
			if warningTxt > 0 and g_currentMission.hlHudSystem.infoDisplay.on then
				if warningTxt == 1 then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_dragDropWarningMinW"), helpTyp:upper()), txtBold=true, warning=true} );
				elseif warningTxt == 2 then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_dragDropWarningMinH"), helpTyp:upper()), txtBold=true, warning=true} );
				elseif warningTxt == 3 then g_currentMission.hlHudSystem:addTextDisplay( {txt=string.format(typ:getI18n("hl_infoDisplay_dragDropWarningMinWH"), helpTyp:upper()), txtBold=true, warning=true} );end;
			end;
			if refresh then typ:setUpdateState(typ.resetBoundsByDragDropWH);end;
		end;
	end;	
end;




