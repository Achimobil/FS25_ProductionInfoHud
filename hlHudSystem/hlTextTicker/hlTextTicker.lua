hlTextTicker = {};
local hlTextTicker_mt = Class(hlTextTicker)

function hlTextTicker.new(args)
	
	local self = {};

	setmetatable(self, hlTextTicker_mt);
	
	self.isOn = false;
	self.run = false;
	self.runTimer = {25,1,40,1,20}; --is,min,max,level,default tick, optional set own timer or .....	
	self.blinkingTimer = {3,1,5}; --fixed value is handover value *blinking=true*
	self.textColor = {1,1,1,1};
	self.separatorColor = {1,1,1,1};
	self.separatorText = " +++ ";
	self.positionUpdateText = "*Text Ticker Position*";
	self.info = {2,1,2,false,"*Text Ticker Info*"};
	self.sound = {2,1,2,false};
	self.soundVolume = {6,2,10,1,6}; --is,min,max,level,default /10
	self.soundSample = {2,1,6};	
	self.samplePath = {		
		[1]="data/sounds/ui/uiFail.ogg";
		[2]="data/sounds/ui/uiSuccess.ogg";
		[3]="data/sounds/ui/uiCollectable.ogg";
		[4]="data/sounds/ui/uiNotification.ogg";
		[5]="data/sounds/ui/uiStats.ogg";
		[6]="data/sounds/ui/uiContracts.ogg";
	};	
	self.dropWidth = {25000,20000,35000,1000,25000}; --is,min,max,level,default
	self.dt = 0;		
	self.position = {1,1,3};
	self.pos = { 
		[1] = {x=0,y=0,width=0,height=0,iconWidth=0,iconHeight=0,textSize={0.020,0.020,0.020,0.001,0.020},optiTextSize=0,textHeight=0,drawBg=false,bgT=0.65,loadXml=0,ownTable={}};
		[2] = {x=0.3,y=0,width=0,height=0,iconWidth=0,iconHeight=0,textSize={0.018,0.010,0.020,0.001,0.018},optiTextSize=0,textHeight=0,drawBg=true,bgT=0.8,loadXml=1,ownTable={}};
		[3] = {x=0.3,y=0,width=0,height=0,iconWidth=0,iconHeight=0,textSize={0.018,0.010,0.020,0.001,0.018},optiTextSize=0,textHeight=0,drawBg=true,bgT=0.8,loadXml=1,ownTable={}};
	};
	self.viewConnectPlayTime = {2,1,2};	
	self.uiScale = g_gameSettings:getValue("uiScale");
	self.overlays = {};
	
	self.msg = {};
	self.copyMsg = {};
	self.repeatableMsg = {};
	self.clickAreas = {};
	self.maxTimeScale = 10;
	self.isReset = false;
	self.updateIsIngameMapLarge = false;
	self.updateIsFullSize = false;
	self.mouseInteraction = args.mouseInteraction or false;	
	g_currentMission.hlUtils.getDefaultBackground(self.overlays, "bgTextTicker", true);	
		
	self.addCallbacks = {firstStart=false,update=args.update or false,draw=args.draw or false,delete=args.delete or false};
	self.cleanEmotionalText = "()";
	
	--self.overlay = createImageOverlay("dataS/menu/base/graph_pixel.png");
		
	return self;
end;

function hlTextTicker:loadPlaySample(playSample, reset)
	if self.sample == nil or reset then 
		if reset and self.sample ~= nil then delete(self.sample);end;
		self.sample = createSample("TextTickerSound");
		local fileName = Utils.getFilename(self.samplePath[self.soundSample[1]]);	
		loadSample(self.sample, fileName, false);	
	end;	
	if playSample then self:playSample();end;
end;

function hlTextTicker:isNewUiScale()
	return g_gameSettings:getValue("uiScale") ~= self.uiScale;	
end;

function hlTextTicker:resetUiScale()
	self.uiScale = g_gameSettings:getValue("uiScale");
end;

function hlTextTicker:setBackgroundData()
	if self.overlays["bgTextTicker"] ~= nil then
		local posData = self:getPositionData();
		g_currentMission.hlUtils.setOverlay(self.overlays["bgTextTicker"], posData.x, posData.y, posData.width, posData.height);
	end;
end;

function hlTextTicker:getPositionData()
	return self.pos[self.position[1]];
end;

function hlTextTicker.checkPositionData() --start over self:update or ... replace or set here check x,y,w,h ?
	--if self:isNewUiScale() then self:resetUiScale();end;
end;

function hlTextTicker:cleanEmotionalMsg(text)	
	return string.gsub(text, "["..self.cleanEmotionalText.."]", "-");
end;

function hlTextTicker:isCorrectTimeScale()
	return true;
	--if self.maxTimeScale == nil or self.maxTimeScale < 0 then return true;end;
	--return g_currentMission.missionInfo.timeScale <= self.maxTimeScale;
end;

function hlTextTicker:playSample()
	if self.sample == nil then self:loadPlaySample();end;
	if self.sample ~= nil then
		playSample(self.sample, 1, self.soundVolume[1]/10, 0, 0, 0);
		return true;
	end;
	return false;
end;

function hlTextTicker:setInfo()
	if self.info[5] ~= nil and self.info[5]:len() > 2 then
		g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, self.info[5], 3500);
		return true;
	end;
	return false;
end;

function hlTextTicker.updateSayings() --optional yourself start own over ...
	
end;

function hlTextTicker.deleteOverlays() --optional yourself start own over ...
	
end;

function hlTextTicker:delete() --yourself start over hlTextTicker.new( {update=xxx,draw=xxx,delete=true} )
	self:setOnOff(false);
	if #self.msg > 0 then self:removeMsg(nil, true);end;
	if self.overlays ~= nil then g_currentMission.hlUtils.deleteOverlays(self.overlays, false, "Text Ticker icons over delete()");end;	
end;

function hlTextTicker:update(dt) --yourself start over hlTextTicker.new( {update=true,draw=xxx,delete=xxx} )
	if g_currentMission.hlHudSystem:getDetiServer() or not g_currentMission.hlHudSystem:getHudIsVisible() then return;end;
	self.updateSayings();
	self.checkPositionData();
	if self.msg ~= nil and self:isCorrectTimeScale() then
		self.dt = dt; --needs		
		if #self.msg > 0 and self.isOn and not self.isReset then self.run = true;else self.run = false;end;
		--if self.run then self:updateMsg(dt);end;
		if #self.repeatableMsg > 0 and self.isOn and not self.isReset then self:updateRepeatableMsg(dt);end;
	end;
end;

function hlTextTicker:updateRepeatableMsg(dt)
	if not self.updateIsIngameMapLarge and g_currentMission.hlUtils:getIngameMap() then return;end;
	if not self.updateIsFullSize and g_currentMission.hlUtils:getFullSize(true,true) then return;end;
	for i=1, #self.repeatableMsg do
		local msg = self.repeatableMsg[i];
		if msg ~= nil then
			msg.firstWait = msg.firstWait-1;
			if msg.firstWait <= 0 then				
				if not msg.remove then self:addMsg(msg);end;
				table.remove(self.repeatableMsg, i);
			end;
		end;
	end;
end;

function hlTextTicker.setMsgUpdate(self)
	if g_currentMission.hlHudSystem:getDetiServer() or not g_currentMission.hlHudSystem:getHudIsVisible() or #self.msg <= 0 then return;end;	
	if not self.updateIsIngameMapLarge and g_currentMission.hlUtils:getIngameMap() then return;end;
	if not self.updateIsFullSize and g_currentMission.hlUtils:getFullSize(true,true) then return;end;	
	if not self.run or not self.isOn or self.isReset then return;end;   		
	if self:isCorrectTimeScale() then
		local posData = self:getPositionData();
		local startPosX = posData.x+posData.width;
		local endPosX = posData.x;	
		for k,v in pairs(self.msg) do		
			if not self.isOn or not self.run or self.isReset then break;end;
			if v.pos <= endPosX or v.remove then            
				local msg = v;
				if not msg.isSeparator and not msg.remove then
					if msg.repeatable >= 1 then						
						msg.repeatable = msg.repeatable-1;
						function addMsg()
							msg.orgArgs.repeatable = msg.orgArgs.repeatable-1;
							msg.orgArgs.firstWait = msg.repeatableWait;
							self:addMsg(msg.orgArgs);												
						end;														
						if msg.lastMsg then addMsg();end;
					end;			
				end;			
				table.remove(self.msg,k);
			end;
		end;
		local setNextMsg = false;
		for i=1, #self.msg do		
			if not self.isOn or not self.run or self.isReset then break;end;
			if setNextMsg or i == 1 then
				self.msg[i].pos = self.msg[i].pos - (self.dt / self.dropWidth[1]);
				setNextMsg = self.msg[i].pos + self.msg[i].width <= startPosX;
				self.msg[i].run = self.msg[i].pos <= startPosX;			
			else
				break;
			end;
		end;
	end;    
end;

function hlTextTicker:draw()
    if g_currentMission.hlHudSystem:getDetiServer() or not g_currentMission.hlHudSystem:getHudIsVisible() then return;end;
	if not self.run or not self.isOn or self.isReset then 
		if not self.isReset and not self.run and self.isOn then self.sound[4] = false;self.info[4] = false;end;
		return;
	end;
	if not self.updateIsIngameMapLarge and g_currentMission.hlUtils:getIngameMap() then return;end;
	if not self.updateIsFullSize and g_currentMission.hlUtils:getFullSize(true,true) then return;end;
	if #self.msg > 0 and self:isCorrectTimeScale() then
        self.clickAreas = {};
		local posData = self:getPositionData();
		local startPosX = posData.x+posData.width;		
        
		local mouseInteraction = self.mouseInteraction and g_currentMission.hlUtils.isMouseCursor and not g_currentMission.hlUtils.dragDrop.on;
		if mouseInteraction and not g_currentMission.hlUtils:disableInArea() then
			self:masterClickAreas( {posData.x, posData.x+posData.width, posData.y, posData.y+posData.height, whatClick="_hlTextTicker_", whereClick="textTicker_", ownTable=self} ); --master area
		end;		
		
		if (posData.drawBg ~= nil and posData.drawBg) then self.overlays["bgTextTicker"]:render();end;		
		
		if self.sound[1] > 1 and not self.sound[4] then	self.sound[4] = self:playSample();end;
		
		if self.info[1] > 1 and not self.info[4] then self.info[4] = self:setInfo();end;
		
		setTextColor(1, 1, 1, 1);
        for i=1, #self.msg do
            if not self.isOn or not self.run or self.isReset then break;end;
			local msg = self.msg[i];			
			if msg ~= nil and msg.run then				
				if mouseInteraction and not msg.isSeparator and msg.onClick ~= nil and type(msg.onClick) == "function" then
					local inArea = g_currentMission.hlUtils.mouseIsInArea(nil, nil, posData.x, posData.y+posData.width, posData.y, posData.y+posData.height);
					if inArea then self:setClickArea( {msg.pos, msg.pos+msg.width, posData.y, posData.y+posData.height, whatClick="hlTextTicker_", whereClick="textTickerMsg_", onClick=msg.onClick, ownTable=msg, id=msg.id} );end; --msg area
				end;				
				if msg.isVisible then
					if (msg.blinking > 0 and g_currentMission.hlUtils.runsTimer(tostring(msg.blinking).. "mSec", true)) or msg.blinking == 0 then
						if msg.textColor ~= nil then setTextColor(unpack(msg.textColor));end;
						local text = g_currentMission.hlUtils.getTxtToWidth(msg.text, posData.optiTextSize, startPosX-msg.pos, false, "");
						--local text = msg.text;
						--if msg.pos >= startPosX-msg.width then text = g_currentMission.hlUtils.getTxtToWidth(msg.text, posData.optiTextSize, startPosX-msg.pos, false, "");end;
						renderText(msg.pos, posData.y+0.001, posData.optiTextSize, text);
						if msg.onDraw ~= nil and type(msg.onDraw) == "function" then msg.onDraw(posData, msg);end;
						setTextColor(1, 1, 1, 1);
					end;					
				else
					if msg.onDraw ~= nil and type(msg.onDraw) == "function" then msg.onDraw(posData, msg);end;
				end;
			end;
        end;
		setTextColor(1, 1, 1, 1);        
    else
        self.sound[4] = false;
		self.info[4] = false;
    end;
end;

function hlTextTicker:addMsg(args)
	if args == nil or type(args) ~= "table" or args.text == nil or type(args.text) ~= "string" or args.text:len() < 2 then return nil;end;
	--local text = self:cleanEmotionalMsg(args.text);
	local id = args.id or g_currentMission.hlUtils.getTypId(1,50);
	args.id = id;
	local firstWait = args.firstWait or 0; -- ~ticks(mSec)
	if firstWait <= 0 then
		local blinking = 0;
		local onAction = nil;
		local onDraw = nil;
		local onClick = nil;
		local textColor = self.textColor;
		if args.onAction ~= nil and type(args.onAction) == "function" then onAction = args.onAction;end;
		if args.onDraw ~= nil and type(args.onDraw) == "function" then onDraw = args.onDraw;end;
		if self.mouseInteraction and args.onClick ~= nil and type(args.onClick) == "function" then onClick = args.onClick;end;
		if args.color ~= nil then --old
			if type(args.color) == "table" then textColor = args.color;elseif type(args.color) == "string" then textColor = g_currentMission.hlUtils.getColor(args.color, true, "ls25active");end;
		end;
		if args.textColor ~= nil then --new
			if type(args.textColor) == "table" then textColor = args.textColor;elseif type(args.textColor) == "string" then textColor = g_currentMission.hlUtils.getColor(args.textColor, true, "ls25active");end;
		end;
		if args.blinking ~= nil then
			if type(args.blinking) == "boolean" then blinking = self.blinkingTimer[1];end;
			if type(args.blinking) == "number" and args.blinking > 0 and args.blinking < 11 and g_currentMission.hlUtils.timers[tostring(args.blinking).. "mSec"] ~= nil then blinking = args.blinking;end;
		end;
		local repeatable = args.repeatable or 0;
		local repeatableWait = args.repeatableWait or 0; -- ~ticks(mSec)	
		local isVisible = args.isVisible;
		if isVisible == nil then isVisible = true;end;
		if args.noSound ~= nil and args.noSound and #self.msg == 0 then self.sound[4] = true;end;
		if string.find(args.text, " ") then
			local textSplit = g_currentMission.hlUtils.stringSplit(args.text," ", "");
			if textSplit ~= nil and #textSplit > 0 then
				for t=1, #textSplit do				
					local blank = "";
					if t > 1 then blank = " ";end;
					if t == 1 then 
						self:addMsgFormat( {noSound=args.noSound, id=id, isVisible=true, blinking=blinking, isSeparator=true, text=self.separatorText, textColor=self.separatorColor, repeatable=0, repeatableWait=0, ownTable=args.ownTable or {}} );
					end;					
					self:addMsgFormat( {noSound=args.noSound, id=id, isVisible=isVisible, blinking=blinking, isSeparator=false, text=blank.. textSplit[t], textColor=textColor, repeatable=repeatable, repeatableWait=repeatableWait, ownTable=args.ownTable or {}, lastMsg=t==#textSplit, onDraw=onDraw, onClick=onClick, orgArgs=args} );				
				end;
			end;
		else
			self:addMsgFormat( {noSound=args.noSound, id=id, isVisible=true, blinking=blinking, isSeparator=true, text=self.separatorText, textColor=self.separatorColor, repeatable=0, repeatableWait=0, ownTable=args.ownTable or {}} );			
			self:addMsgFormat( {noSound=args.noSound, id=id, isVisible=isVisible, blinking=blinking, isSeparator=false, text=args.text, textColor=textColor, repeatable=repeatable, repeatableWait=repeatableWait, ownTable=args.ownTable or {}, lastMsg=true, onDraw=onDraw, onClick=onClick, orgArgs=args} );
		end;
	else
		args.firstWait = firstWait;		
		self.repeatableMsg[#self.repeatableMsg+1] = args;
	end;
	return id;
end;

function hlTextTicker:addMsgFormat(args)
    
    local posData = self:getPositionData();
    local startPosX = posData.x+posData.width;
	
	local msg = {};	
	msg.isVisible = args.isVisible
	msg.isSeparator = args.isSeparator or false;
	msg.text = args.text
	msg.textColor = args.textColor or self.textColor;
	msg.id = args.id;
	msg.blinking = args.blinking;
	msg.repeatable = args.repeatable;
	msg.repeatableWait = args.repeatableWait;
	msg.ownTable = args.ownTable;
	msg.pos = startPosX;
	msg.width = getTextWidth(posData.optiTextSize ,tostring(args.text));
	msg.run = false;
	msg.remove = false;
	msg.orgArgs = args.orgArgs;
	msg.lastMsg = args.lastMsg;
	msg.onDraw = args.onDraw;
	msg.onAction = args.onAction;
	msg.onClick = args.onClick;
	table.insert(self.msg, msg);	
    
end;

function hlTextTicker:generateRunTimer(addFinishCallback, otherFunc) --optional replace function  or ...
	self.timer = Timer.new(self.runTimer[1]);
	
	if addFinishCallback then --optional set here or ...
		self.timer:setFinishCallback(
			function(timerInstance)
				if otherFunc ~= nil and type(otherFunc) == "function" and self[otherFunc] ~= nil then					
					self[otherFunc](self)					
				else			
					self.setMsgUpdate(self)
				end
				timerInstance:start()
			end
		)
	end;
end;

function hlTextTicker:setRunTimerDuration()
	if self.timer ~= nil then
		self.timer:setDuration(self.runTimer[1]);
		self.timer:setTimeLeft(self.runTimer[1])
	end;
end;

function hlTextTicker:startRunTimer() --optional replace function  or ...
	if self.timer ~= nil then self.timer:start();end;
end;

function hlTextTicker:stopRunTimer() --optional replace function  or ...
	if self.timer ~= nil then self.timer:stop();end;
end;

function hlTextTicker:removeRunTimer() --optional replace function  or ...
	if self.timer ~= nil then self.timer:remove();end;
end;

function hlTextTicker:setOnOff(state)
	if (state == nil and self.isOn) or (state ~= nil and state == false) then
		self.isOn = false;		
		self:stopRunTimer();		
		self:deleteAllMsg();	
		self.sound[4] = false;
		self.info[4] = false;
		if g_currentMission:getHasUpdateable(self) then g_currentMission:removeUpdateable(self);end;
		if g_currentMission:getHasDrawable(self) then g_currentMission:removeDrawable(self);end;		
	elseif (state == nil and not self.isOn) or (state ~= nil and state == true) then
		if self.addCallbacks.update then g_currentMission:addUpdateable(self);end;
		if self.addCallbacks.draw then g_currentMission:addDrawable(self);end;		
		if self.addCallbacks.delete and not self.addCallbacks.firstStart then self.addCallbacks.firstStart = true;g_currentMission:addNonUpdateable(self);end;
		self:setBackgroundData();		
		self:startRunTimer();
		self.isOn = true;
	end;
end;

function hlTextTicker:deleteAllMsg()
	self.isReset = true;
	self.msg = {};
	self.repeatableMsg = {};
	self.isReset = false;
end;

function hlTextTicker:setRemoveMsgById(id)
	if #self.msg > 0 then
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and msg.id == id then
				msg.remove = true;
			end;
		end;		
	end;
	if #self.repeatableMsg > 0 then
		for i=1, #self.repeatableMsg do
			local msg = self.repeatableMsg[i];
			if msg ~= nil and msg.id == id then
				msg.remove = true;
			end;
		end;		
	end;
end;

function hlTextTicker:getMsgById(id)
	if #self.msg > 0 then
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and msg.id == id then
				return msg;
			end;
		end;		
	end;
	if #self.repeatableMsg > 0 then
		for i=1, #self.repeatableMsg do
			local msg = self.repeatableMsg[i];
			if msg ~= nil and msg.id == id then
				return msg;
			end;
		end;		
	end;
end;

function hlTextTicker:removeMsgById(id)
	self.isReset = true;
	if #self.msg > 0 then
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and msg.id == id then
				table.remove(self.msg, i);				
			end;
		end;		
	end;
	if #self.repeatableMsg > 0 then
		for i=1, #self.repeatableMsg do
			local msg = self.repeatableMsg[i];
			if msg ~= nil and msg.id == id then
				table.remove(self.repeatableMsg, i);
			end;
		end;		
	end;
	self.isReset = false;
end;

function hlTextTicker:removeMsg(pos, removeAll)
	self.isReset = true;
	if #self.msg > 0 then
		if (removeAll == nil or not removeAll) and pos ~= nil then
			if self.msg[pos] == nil then return;end;
			--g_currentMission.hlUtils.deleteOverlays(self.msg[pos].overlay);
			table.remove(self.msg, pos);	
		else
			for i=1, #self.msg do
				local msg = self.msg[i];
				if msg ~= nil and removeAll ~= nil and removeAll then
					--g_currentMission.hlUtils.deleteOverlays(msg.overlay);
					table.remove(self.msg, i);				
				end;
			end;			
		end;
	end;
	self.isReset = false;
	if removeAll ~= nil and removeAll then self.repeatableMsg = {};end;
end;

function hlTextTicker:copyAllMsgByPosition()
	self.isReset = true;
	self.copyMsg = {};
	if #self.msg > 0 then		
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil then				
				function addCopyMsg()
					table.insert(self.copyMsg, msg.orgArgs);																
				end;														
				if msg.lastMsg then addCopyMsg();end;
				table.remove(self.msg, i);
			end;
		end;			
	end;
	self.msg = {};
	self.isReset = false;
end;

function hlTextTicker:pasteAllMsgByPosition()
	self.isReset = true;		
	if #self.copyMsg > 0 then
		for i=1, #self.copyMsg do
			local msg = self.copyMsg[i];
			if msg ~= nil then
				self:addMsg(msg);
			end;
		end;
	end;
	self.copyMsg = {};
	self.isReset = false;
end;

function hlTextTicker:addMsgByUpdatePosition()
	if self.positionUpdateText:len() > 0 and #self.msg == 0 then		
		self:addMsg( {text=self.positionUpdateText, textColor="ls25active", blinking=true} );
	end;
end;

function hlTextTicker:addMsgByOtherReplaceValues()
	if #self.msg == 0 then		
		self:addMsg( {text="<<<<<Test>>>>>", color="ls25active", separator=false} );
	end;
end;

function hlTextTicker:resetAllMsg(updateByPlayer)
	self.isReset = true;
	local copyMsg = {};
	if #self.msg > 0 then		
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and not msg.run then				
				function addCopyMsg()
					table.insert(copyMsg, msg.orgArgs);																
				end;														
				if msg.lastMsg then addCopyMsg();end;				
			end;
		end;
		self:removeMsg(nil, true);		
	end;
	self:setBackgroundData();
	if #copyMsg > 0 then
		for i=1, #copyMsg do
			local msg = copyMsg[i];
			if msg ~= nil then
				self:addMsg(msg);
			end;
		end;
	elseif updateByPlayer ~= nil and updateByPlayer and self.positionUpdateText:len() > 0 then		
		self:addMsg( {text=self.positionUpdateText, textColor="ls25active", blinking=true} );
	end;
	self.isReset = false;
end;

function hlTextTicker:masterClickAreas(args) --master overlay		
	if g_currentMission.hlHudSystem.areas[args.whatClick] == nil then g_currentMission.hlHudSystem.areas[args.whatClick] = {};end;
	g_currentMission.hlHudSystem.areas[args.whatClick][#g_currentMission.hlHudSystem.areas[args.whatClick]+1] = {
		args[1]; --posX
		args[2]; --posX1
		args[3]; --posY
		args[4]; --posY1		
		whatClick = args.whatClick;			
		whereClick = args.whereClick or "";			
		ownTable = args.ownTable;
	};	
end;

function hlTextTicker:setClickArea(args) --msg	
	if args == nil or type(args) ~= "table" then return;end;
	if not g_currentMission.hlUtils.isMouseCursor then 
		self.clickAreas = {};
		return;
	end;
	local whatClick = args.whatClick or "textTicker_"; --optional a string
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
		onClick = args.onClick; --click area callback
		id = args.id or 0;
	};	
end;