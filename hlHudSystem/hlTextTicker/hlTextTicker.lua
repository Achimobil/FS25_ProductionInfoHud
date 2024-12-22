hlTextTicker = {};
local hlTextTicker_mt = Class(hlTextTicker)

function hlTextTicker.new(args)
	
	local self = {};

	setmetatable(self, hlTextTicker_mt);
	
	self.id = g_currentMission.hlUtils.getTypId(1,50);
	self.isOn = false;
	self.run = false;
	self.runTimer = {25,1,50,1,25}; --is,min,max,level,default tick, optional set own timer or .....	
	self.tick = 2;
	self.difDistance = 3;
	self.blinkingTimer = {5,1,5}; --fixed value is handover value *blinking=true*
	self.separatorText = " +++ ";
	self.positionUpdateText = "-Text Ticker Position-";
	self.info = {2,1,2,false,"*Text Ticker Info*"};
	self.sound = {2,1,2,false};
	self.soundSample = {2,1,4};
	self.sample = {
		[1]=function() return GuiSoundPlayer.SOUND_SAMPLES.FAIL;end;
		[2]=function() return GuiSoundPlayer.SOUND_SAMPLES.SUCCESS;end;
		[3]=function() return GuiSoundPlayer.SOUND_SAMPLES.COLLECTIBLE;end;
		[4]=function() return GuiSoundPlayer.SOUND_SAMPLES.NOTIFICATION;end;
	};
	self.dropWidth = {25000,20000,35000,1000,25000}; --is,min,max,level,default
	self.dt = 0;		
	self.position = {1,1,1};
	self.pos = { 
		[1] = {x=0,y=0,width=0,height=0,size=0.025,boldSize=0.025,textHeight=0,boldTextHeight=0,drawBg=false,ownTable={}}; 
	};
	self.overlays = {};
	self.mergeOrgData = {};
	self.msg = {};
	self.repeatableMsg = {};
	self.clickAreas = {};
	self.isReset = false;
	self.updateIsIngameMapLarge = false;
	self.updateIsFullSize = false;
	self.mouseInteraction = args.mouseInteraction or false;	
	g_currentMission.hlUtils.getDefaultBackground(self.overlays, "bgTextTicker", true);	
	
	self.addAcceptsValues = {
		addMsg = {id,text,color,isVisible,firstWait,repeatable,repeatableWait,separator,background,blinking,onDraw,onAction,ownTable,onClick};
		copyMsg = {id,text,color,isVisible,repeatable,repeatableWait,background,blinking,onDraw,ownTable,onAction,onClick};
		repeatableMsg = {id,text,color,isVisible,repeatable,repeatableWait,reloadWait,background,blinking,onDraw,ownTable,onAction,onClick};
	};
	
	self.addCallbacks = {firstStart=false,update=args.update or false,draw=args.draw or false,delete=args.delete or false};
		
	return self;
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

end;

function hlTextTicker:addMsg(args)
	if args == nil or type(args) ~= "table" or args.text == nil or type(args.text) ~= "string" or args.text:len() < 2 then return false;end;
	local firstWait = args.firstWait or 0; -- ~ticks(mSec)	
	if #self.msg == 0 and firstWait == 0 and not self.isReset then
		if self.info[1] > 1 then self.info[4] = true;end;
		if self.sound[1] > 1 then self.sound[4] = true;end;
	end;
	local separatorText = self.separatorText;
	if args.separator ~= nil then
		if type(args.separator) == "boolean" then
			if not args.separator then separatorText = "";end;
		elseif type(args.separator) == "string" then
			separatorText = args.separator;
		end;
	end;
	local msgTable = self.msg;	
	local tablePos = #msgTable;	
	if firstWait == 0 then
		table.insert(msgTable, {text=separatorText.. args.text,splitText={},runText="",isRun=false,isDelRun=false,isLastCharacter=false,insertText={},tick={0,0,self.tick}});
		tablePos = #msgTable;
	else
		msgTable = self.repeatableMsg;		
		table.insert(msgTable, {text=separatorText.. args.text, reloadWait=firstWait});
		tablePos = #msgTable;
	end;
	if args.color ~= nil and type(args.color) == "table" then msgTable[tablePos].color = args.color;else msgTable[tablePos].color = g_currentMission.hlUtils.getColor(args.color, true, "ls25active");end;	
	msgTable[tablePos].id = args.id or g_currentMission.hlUtils.getTypId(1,50);
	msgTable[tablePos].isVisible = args.isVisible or true;
	msgTable[tablePos].length = {1, msgTable[tablePos].text:len()+self.difDistance,0};	--dif msg to msg and last character language dif
	msgTable[tablePos].repeatable = args.repeatable or 0;
	msgTable[tablePos].repeatableWait = args.repeatableWait or 0; -- ~ticks(mSec)	
	msgTable[tablePos].background = args.background or false;
	msgTable[tablePos].blinking = 0;
	msgTable[tablePos].ownTable = args.ownTable or {};
	if args.onAction ~= nil and type(args.onAction) == "function" then msgTable[tablePos].onAction = args.onAction;end;
	if args.onDraw ~= nil and type(args.onDraw) == "function" then msgTable[tablePos].onDraw = args.onDraw;end;
	if self.mouseInteraction and args.onClick ~= nil and type(args.onClick) == "function" then msgTable[tablePos].onClick = args.onClick;end;
	if args.blinking ~= nil then
		if type(args.blinking) == "boolean" then msgTable[tablePos].blinking = self.blinkingTimer[1];end;
		if type(args.blinking) == "number" and args.blinking > 0 and args.blinking < 11 and g_currentMission.hlUtils.timers[tostring(args.blinking).. "mSec"] ~= nil then msgTable[tablePos].blinking = args.blinking;end;
	end;
	if firstWait == 0 then
		msgTable[tablePos].overlay = {};
		g_currentMission.hlUtils.getDefaultBackground(msgTable[tablePos].overlay, "textTicker", true);
		local posData = self:getPositionData();	
		g_currentMission.hlUtils.setOverlay(msgTable[tablePos].overlay["textTicker"], posData.x+posData.width, posData.y, 0, posData.textHeight);
		----		
		msgTable[tablePos].tempText = msgTable[tablePos].text;
		local txtSplit = g_currentMission.hlUtils.stringSplit(msgTable[tablePos].text," ", "");
		if txtSplit ~= nil and #txtSplit > 0 then
			for t=1, #txtSplit do				
				table.insert(msgTable[tablePos].splitText, txtSplit[t])				
			end;
		else
			msgTable[tablePos].splitText[1] = msgTable[tablePos].text;
		end;
		----
	end;
	if args.id == nil then return msgTable[tablePos].id;end;
end;

function hlTextTicker.deleteOverlays() --optional yourself start own over ...
	
end;

function hlTextTicker:delete() --yourself start over hlTextTicker.new( {update=xxx,draw=xxx,delete=true} )
	self:setOnOff(false);
	if #self.msg > 0 then self:removeMsg(nil, true);end;
	if self.overlays ~= nil then g_currentMission.hlUtils.deleteOverlays(self.overlays, false, "Text Ticker icons over delete()");end;	
end;

function hlTextTicker:update(dt) --yourself start over hlTextTicker.new( {update=true,draw=xxx,delete=xxx} )
	if g_currentMission.hlHudSystem:getDetiServer() or not g_currentMission.hlHudSystem:getHudIsVisible() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;
	self.checkPositionData();
	if self.msg ~= nil then
		self.dt = dt; --needs		
		if #self.repeatableMsg > 0 and self.isOn and not self.isReset then self:updateRepeatableMsg(dt);end;
		if #self.msg > 0 and self.isOn and not self.isReset then self.run = true;else self.run = false;end;	
	end;
end;

function hlTextTicker:updateRepeatableMsg(dt)
	for i=1, #self.repeatableMsg do
		local msg = self.repeatableMsg[i];
		if msg ~= nil then
			msg.reloadWait = msg.reloadWait-1;
			if msg.reloadWait <= 0 then
				self:addMsg( {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, id=msg.id, isVisible=msg.isVisible, background=msg.background, onDraw=msg.onDraw, separator=false, onClick=msg.onClick, ownTable=msg.ownTable} );
				table.remove(self.repeatableMsg, i);
			end;
		end;
	end;
end;

function hlTextTicker:draw() --yourself start over hlTextTicker.new( {update=xxx,draw=true,delete=xxx} )
	if g_currentMission.hlHudSystem:getDetiServer() or not g_currentMission.hlHudSystem:getHudIsVisible() or g_currentMission.hlUtils:getFullSize(true, true) then return;end;
	if not self.run or not self.isOn or self.isReset then return;end;
	if #self.msg > 0 then
		self.clickAreas = {};
		local posData = self:getPositionData();
		local mouseInteraction = self.mouseInteraction and g_currentMission.hlUtils.isMouseCursor and not g_currentMission.hlUtils.dragDrop.on;
		if mouseInteraction then
			self:masterClickAreas( {posData.x, posData.x+posData.width, posData.y, posData.y+posData.height, whatClick="_hlTextTicker_", whereClick="textTicker_", ownTable=self} ); --master area
		end;
		if posData.drawBg ~= nil and posData.drawBg then self.overlays["bgTextTicker"]:render();end;
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and (msg.isRun or msg.isDelRun) and msg.remove == nil then
				local mX,mY,mW,_ = g_currentMission.hlUtils.getOverlay(msg.overlay["textTicker"]);	
				if mouseInteraction and msg.onClick ~= nil and type(msg.onClick) == "function" then
					self:setClickArea( {mX, mX+mW, posData.y, posData.y+posData.height, whatClick="hlTextTicker_", whereClick="textTickerMsg_", onClick=msg.onClick, ownTable=msg, id=msg.id} ) --msg area
				end;
				if (self.sound[1] > 1 and self.sound[4]) or (self.info[1] > 1 and self.info[4]) then 
					if self.sound[4] and self.info[4] then g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, self.info[5], 3500, self.sample[self.soundSample[1]]());
					elseif not self.sound[4] and self.info[4] then g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, self.info[5], 3500);
					elseif self.sound[4] and not self.info[4] then g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, "", 100, self.sample[self.soundSample[1]]());end;
					self.sound[4] = false;
					self.info[4] = false;
				end;							
				if msg.isVisible == nil or msg.isVisible then					
					if msg.background ~= nil and msg.background then msg.overlay["textTicker"]:render();end;					
					if (msg.blinking > 0 and g_currentMission.hlUtils.runsTimer(tostring(msg.blinking).. "mSec", true)) or msg.blinking == 0 or msg.length[1] > 2 then						
						setTextColor(unpack(msg.color));						
						renderText(mX, mY+0.001, posData.size, msg.runText);
						renderText(mX, mY+0.001, posData.size, msg.runText);
						if msg.onDraw ~= nil and type(msg.onDraw) == "function" then msg.onDraw(posData, msg);end;
						setTextColor(1, 1, 1, 1);
					end;
				else
					if msg.onDraw ~= nil and type(msg.onDraw) == "function" then msg.onDraw(posData, msg);end;
				end;				
			else
				break;
			end;			
		end;			
	end;
end;

function hlTextTicker:setMsgOverlays3()
	if #self.msg > 0 then
		local setNextMsg = false;
		local posData = self:getPositionData();
		local lastEndPosX = 0;
		for i=1, #self.msg do			
			local beginPosX = posData.x+posData.width;			
			local msg = self.msg[i];
			if msg ~= nil and (setNextMsg or i == 1) then				
				local x,_,w,_ = g_currentMission.hlUtils.getOverlay(msg.overlay["textTicker"]);
				local newWidth = self.dt / self.dropWidth[1];
				local newPosX = x - newWidth;				
				if newPosX <= lastEndPosX then setNextMsg = false;break;end; --check before, performenc difference
				if newPosX <= posData.x and not msg.isDelRun then 					
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], posData.x);
					msg.isDelRun = true;					
				end;
				if msg.runText:len() == msg.tempText:len() and not msg.isDelRun then
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], newPosX);					
					setNextMsg = true;
					lastEndPosX = newPosX+w+(newWidth*3);
				elseif msg.runText:len() < msg.tempText:len() and not msg.isLastCharacter and not msg.isDelRun then
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], newPosX, nil, w+newWidth);
					setNextMsg = false;
				elseif msg.isDelRun then					
					if msg.isLastCharacter then
						g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], nil, nil, w-(newWidth));					
						setNextMsg = true;
						lastEndPosX = newPosX+w+(newWidth*3);
					else
						setNextMsg = false;
					end;
				end;
				if not msg.isRun and msg.onAction ~= nil and type(msg.onAction) == "function" then msg.isRun = true;msg.onAction(posData, msg);end; --1x start callback
				msg.isRun = true;				
				--if setNextMsg and w+(newWidth*3) > posData.width then setNextMsg = false;end; --dif width msg to msg				
			else
				break;
			end;
		end;
	end;
end;

function hlTextTicker.setMsgUpdate3(self) --yourself start over self:generateRunTimer or .....	
	if g_currentMission.hlHudSystem:getDetiServer() or self == nil or not g_currentMission.hlHudSystem:getHudIsVisible() then return;end;
	if not self.updateIsIngameMapLarge and g_currentMission.hlUtils:getIngameMap() then return;end;
	if not self.updateIsFullSize and g_currentMission.hlUtils:getFullSize(true,true) then return;end;	
	if not self.run or not self.isOn or self.isReset then return;end;
	if #self.msg > 0 then
		self:setMsgOverlays3();
		local posData = self:getPositionData();
		local isMsgRemove = false;
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and msg.isRun then				
				if msg.isDelRun then --front dif					
					local tempText = string.sub(msg.tempText, msg.length[1]);
					if tempText ~= nil and type(tempText) == "string" and tempText:len() > 0 then
						if msg.length[1] <= msg.length[2] then
							local textWidth = g_currentMission.hlUtils.getTextWidth(tempText, posData.size, false, msg.length[1], msg.length[2]);
							local _,_,w,_ = g_currentMission.hlUtils.getOverlay(msg.overlay["textTicker"]);
							if msg.splitText[1] ~= nil and textWidth ~= nil and textWidth >= w then
								local delText = msg.splitText[1];
								local drawText = string.gsub(tempText, delText, " ", 1);
								msg.tempText = drawText;						
								table.remove(msg.splitText, 1);
								msg.length[1] = msg.length[1]+delText:len();
							end;
						end;
					end;
					if msg.tick[1] >= msg.tick[3] then
						--msg.length[1] = msg.length[1]+1;
						msg.tick[1] = msg.tick[2];
					else
						msg.tick[1] = msg.tick[1]+1;
					end;
				end;
				if msg.length[1] >= msg.length[2] then
					if msg.repeatable >= 1 then 
						msg.repeatable = msg.repeatable-1;
						if msg.repeatableWait ~= nil and msg.repeatableWait > 0 then							
							table.insert(self.repeatableMsg, {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, reloadWait=msg.repeatableWait, isVisible=msg.isVisible, id=msg.id, onDraw=msg.onDraw, onAction=msg.onAction, background=msg.background, onClick=msg.onClick, ownTable=msg.ownTable});
						else
							self:addMsg( {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, id=msg.id, isVisible=msg.isVisible, background=msg.background, onDraw=msg.onDraw, onAction=msg.onAction, separator=false, onClick=msg.onClick, ownTable=msg.ownTable} );
						end;
					end;
					isMsgRemove = true;
					msg.remove = true;	
				else --all or back dif					
					local runText = string.sub(msg.tempText, msg.length[1]);					
					msg.runText, _, lastCharacter = g_currentMission.hlUtils.getTxtToWidth(runText, posData.size, msg.overlay["textTicker"].width, false, "");
					local isText = string.gsub(runText, msg.runText, "", 1);					
					if lastCharacter >= msg.length[2] or (msg.length[1] >= 2 and isText:len() <= 0) then msg.isLastCharacter = true;end;					
				end;
			end;
		end;
		if isMsgRemove then self:removeMsg();end;
	end;
end;

function hlTextTicker:setMsgOverlays2()
	if #self.msg > 0 then
		local setNextMsg = false;
		local posData = self:getPositionData();
		local lastEndPosX = 0;
		for i=1, #self.msg do			
			local beginPosX = posData.x+posData.width;			
			local msg = self.msg[i];
			if msg ~= nil and (setNextMsg or i == 1) then				
				local x,_,w,_ = g_currentMission.hlUtils.getOverlay(msg.overlay["textTicker"]);
				local newWidth = self.dt / self.dropWidth[1];
				local newPosX = x - newWidth;				
				if newPosX <= lastEndPosX then setNextMsg = false;break;end; --check before, performenc difference
				if newPosX <= posData.x and not msg.isDelRun then 					
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], posData.x);
					msg.isDelRun = true;					
				end;
				if msg.runText:len() == msg.text:len() and not msg.isDelRun then
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], newPosX);					
					setNextMsg = true;
					lastEndPosX = newPosX+w+(newWidth*3);
				elseif msg.runText:len() < msg.text:len() and not msg.isLastCharacter and not msg.isDelRun then
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], newPosX, nil, w+newWidth);
					setNextMsg = false;
				elseif msg.isDelRun then					
					if msg.isLastCharacter then
						g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], nil, nil, w-(newWidth));					
						setNextMsg = true;
						lastEndPosX = newPosX+w+(newWidth*3);
					else
						setNextMsg = false;
					end;
				end;
				if not msg.isRun and msg.onAction ~= nil and type(msg.onAction) == "function" then msg.isRun = true;msg.onAction(posData, msg);end; --1x start callback
				msg.isRun = true;				
				--if setNextMsg and w+(newWidth*3) > posData.width then setNextMsg = false;end; --dif width msg to msg				
			else
				break;
			end;
		end;
	end;
end;

function hlTextTicker.setMsgUpdate2(self) --yourself start over self:generateRunTimer or .....	
	if g_currentMission.hlHudSystem:getDetiServer() or self == nil or not g_currentMission.hlHudSystem:getHudIsVisible() then return;end;
	if not self.updateIsIngameMapLarge and g_currentMission.hlUtils:getIngameMap() then return;end;
	if not self.updateIsFullSize and g_currentMission.hlUtils:getFullSize(true,true) then return;end;	
	if not self.run or not self.isOn or self.isReset then return;end;
	if #self.msg > 0 then
		self:setMsgOverlays2();
		local posData = self:getPositionData();
		local isMsgRemove = false;
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and msg.isRun then
				local runText = string.sub(msg.text, msg.length[1]);
				if msg.isDelRun then --front dif or front and back					
					msg.runText, _, lastCharacter = g_currentMission.hlUtils.getTxtToWidth(runText, posData.size, msg.overlay["textTicker"].width, true, "");
					if not msg.isLastCharacter and lastCharacter >= msg.length[2] then msg.isLastCharacter = true;end;
					if not msg.isLastCharacter then msg.runText = g_currentMission.hlUtils.getTxtToWidth(msg.runText, posData.size, msg.overlay["textTicker"].width, false, "");end;
				else --all or back dif									
					msg.runText, _, lastCharacter = g_currentMission.hlUtils.getTxtToWidth(runText, posData.size, msg.overlay["textTicker"].width, false, "");
					if not msg.isLastCharacter and lastCharacter >= msg.length[2] then msg.isLastCharacter = true;end;
				end;
				if msg.runText:len() <= 1 and msg.isDelRun then
					if msg.repeatable >= 1 then
						msg.repeatable = msg.repeatable-1;
						if msg.repeatableWait ~= nil and msg.repeatableWait > 0 then							
							table.insert(self.repeatableMsg, {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, reloadWait=msg.repeatableWait, isVisible=msg.isVisible, id=msg.id, onDraw=msg.onDraw, onAction=msg.onAction, background=msg.background, onClick=msg.onClick, ownTable=msg.ownTable});
						else
							self:addMsg( {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, id=msg.id, isVisible=msg.isVisible, background=msg.background, onDraw=msg.onDraw, onAction=msg.onAction, separator=false, onClick=msg.onClick, ownTable=msg.ownTable} );
						end;
					end;
					isMsgRemove = true;		
					msg.remove = true;
				elseif not msg.isLastCharacter then
					--local isText = string.gsub(runText, msg.runText, "", 1);
				end;				
			end;
		end;
		if isMsgRemove then self:removeMsg();end;
	end;
end;

function hlTextTicker:setMsgOverlays1()
	if #self.msg > 0 then
		local setNextMsg = false;
		local posData = self:getPositionData();
		local lastEndPosX = 0;
		for i=1, #self.msg do			
			local beginPosX = posData.x+posData.width;			
			local msg = self.msg[i];
			if msg ~= nil and (setNextMsg or i == 1) then				
				local x,_,w,_ = g_currentMission.hlUtils.getOverlay(msg.overlay["textTicker"]);
				local newWidth = self.dt / self.dropWidth[1];
				local newPosX = x - newWidth;				
				if newPosX <= lastEndPosX then setNextMsg = false;break;end; --check before, performenc difference
				if newPosX <= posData.x and not msg.isDelRun then 					
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], posData.x);
					msg.isDelRun = true;					
				end;
				if msg.runText:len() == msg.text:len() then
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], newPosX);					
					setNextMsg = true;
					lastEndPosX = newPosX+w+(newWidth*3);
				elseif msg.length[1] <=1 and msg.runText:len() < msg.text:len() then
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], newPosX, nil, w+newWidth);
					setNextMsg = false;
				elseif msg.length[1] >= 2 or msg.isDelRun then					
					if msg.isLastCharacter then						
						g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], nil, nil, w-(newWidth));					
						setNextMsg = true;
						lastEndPosX = newPosX+w+(newWidth*3);
						--x,_,w,_ = g_currentMission.hlUtils.getOverlay(msg.overlay["textTicker"]);
						--local runTextWidth = getTextWidth(posData.size, msg.runText)+(newWidth*3);
						--if runTextWidth < w then g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], nil, nil, w-(newWidth*3));end;
					else
						setNextMsg = false;
					end;
				end;
				if not msg.isRun and msg.onAction ~= nil and type(msg.onAction) == "function" then msg.isRun = true;msg.onAction(posData, msg);end; --1x start callback
				msg.isRun = true;
			else
				break;
			end;
		end;
	end;
end;

function hlTextTicker.setMsgUpdate1(self) --yourself start over self:generateRunTimer or .....	
	if g_currentMission.hlHudSystem:getDetiServer() or self == nil or not g_currentMission.hlHudSystem:getHudIsVisible() then return;end;
	if not self.updateIsIngameMapLarge and g_currentMission.hlUtils:getIngameMap() then return;end;
	if not self.updateIsFullSize and g_currentMission.hlUtils:getFullSize(true,true) then return;end;	
	if not self.run or not self.isOn or self.isReset then return;end;
	if #self.msg > 0 then
		self:setMsgOverlays1();
		local posData = self:getPositionData();
		local isMsgRemove = false;
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and msg.isRun then				
				if msg.isDelRun then --front dif					
					if #msg.insertText > 0 then
						local delCharacter = msg.insertText[1];
						if delCharacter > 0 then msg.length[1] = delCharacter+1;end;
						table.remove(msg.insertText, 1);
					else
						msg.length[1] = msg.length[1]+1;
					end;					
				end;
				if msg.length[1] >= msg.length[2] then
					if msg.repeatable >= 1 then 
						msg.repeatable = msg.repeatable-1;
						if msg.repeatableWait ~= nil and msg.repeatableWait > 0 then							
							table.insert(self.repeatableMsg, {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, reloadWait=msg.repeatableWait, isVisible=msg.isVisible, id=msg.id, onDraw=msg.onDraw, onAction=msg.onAction, background=msg.background, onClick=msg.onClick, ownTable=msg.ownTable});
						else
							self:addMsg( {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, id=msg.id, isVisible=msg.isVisible, background=msg.background, onDraw=msg.onDraw, onAction=msg.onAction, separator=false, onClick=msg.onClick, ownTable=msg.ownTable} );
						end;
					end;
					isMsgRemove = true;
					msg.remove = true;	
				else --all or back dif
					local runText = string.sub(msg.text, msg.length[1]);					
					msg.runText, _, lastCharacter = g_currentMission.hlUtils.getTxtToWidth(runText, posData.size, msg.overlay["textTicker"].width, false, "");
					local isText = string.gsub(runText, msg.runText, "", 1);
					--if not msg.isLastCharacter then table.insert(msg.insertText, msg.runText:len());end;
					if lastCharacter >= msg.length[2] or (msg.length[1] >= 2 and isText:len() <= 0) then msg.isLastCharacter = true;end;					
				end;
			end;
		end;
		if isMsgRemove then self:removeMsg();end;
	end;
end;

function hlTextTicker:setMsgOverlays()
	if #self.msg > 0 then
		local setNextMsg = false;
		local posData = self:getPositionData();
		local lastEndPosX = 0;		
		for i=1, #self.msg do			
			local beginPosX = posData.x+posData.width;			
			local msg = self.msg[i];
			if msg ~= nil and (setNextMsg or i == 1) then				
				local x,_,w,_ = g_currentMission.hlUtils.getOverlay(msg.overlay["textTicker"]);
				local newWidth = self.dt / self.dropWidth[1];
				local newPosX = x - newWidth;				
				if newPosX <= lastEndPosX then setNextMsg = false;break;end; --check before, performenc difference
				if newPosX <= posData.x and not msg.isDelRun then 					
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], posData.x);
					msg.isDelRun = true;
					msg.tick[1] = msg.tick[3];
				end;
				if msg.runText:len() == msg.text:len() then
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], newPosX);					
					lastEndPosX = newPosX+w+(newWidth*3);
					setNextMsg = true;
				elseif msg.length[1] <=1 and msg.runText:len() < msg.text:len() then
					g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], newPosX, nil, w+newWidth);
					setNextMsg = false;
				elseif msg.length[1] >= 2 or msg.isDelRun then					
					if msg.isLastCharacter then
						g_currentMission.hlUtils.setOverlay(msg.overlay["textTicker"], nil, nil, w-(newWidth));					
						lastEndPosX = x+w+(newWidth*3);
						setNextMsg = true;
					else
						setNextMsg = false;
					end;
				end;
				if not msg.isRun and msg.onAction ~= nil and type(msg.onAction) == "function" then msg.isRun = true;msg.onAction(posData, msg);end; --1x start callback
				msg.isRun = true;				
			else
				break;
			end;
		end;
	end;
end;

function hlTextTicker.setMsgUpdate(self) --yourself start over self:generateRunTimer or .....	
	if g_currentMission.hlHudSystem:getDetiServer() or self == nil or not g_currentMission.hlHudSystem:getHudIsVisible() then return;end;	
	if not self.updateIsIngameMapLarge and g_currentMission.hlUtils:getIngameMap() then return;end;
	if not self.updateIsFullSize and g_currentMission.hlUtils:getFullSize(true,true) then return;end;	
	if not self.run or not self.isOn or self.isReset then return;end;	
	if #self.msg > 0 then		
		self:setMsgOverlays();
		local posData = self:getPositionData();
		local isMsgRemove = false;		
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and msg.isRun then				
				if msg.isDelRun then --front dif					
					if msg.tick[1] >= msg.tick[3] then
						msg.length[1] = msg.length[1]+1;
						msg.tick[1] = msg.tick[2];
					else
						msg.tick[1] = msg.tick[1]+1;
					end;
				end;
				if msg.length[1] >= msg.length[2] then
					if msg.repeatable >= 1 then 
						msg.repeatable = msg.repeatable-1;
						if msg.repeatableWait ~= nil and msg.repeatableWait > 0 then							
							table.insert(self.repeatableMsg, {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, reloadWait=msg.repeatableWait, id=msg.id, isVisible=msg.isVisible, onDraw=msg.onDraw, onAction=msg.onAction, background=msg.background, onClick=msg.onClick, ownTable=msg.ownTable});
						else
							self:addMsg( {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, id=msg.id, isVisible=msg.isVisible, background=msg.background, onDraw=msg.onDraw, onAction=msg.onAction, separator=false, onClick=msg.onClick, ownTable=msg.ownTable} );
						end;
					end;
					isMsgRemove = true;	
					msg.remove = true;	
				else --all or back dif
					local runText = string.sub(msg.text, msg.length[1]);					
					msg.runText, _, lastCharacter = g_currentMission.hlUtils.getTxtToWidth(runText, posData.size, msg.overlay["textTicker"].width, false, "");
					local isText = string.gsub(runText, msg.runText, "", 1);
					if lastCharacter >= msg.length[2] or (msg.length[1] >= 2 and isText:len() <= 0) then msg.isLastCharacter = true;end;
				end;
			end;
		end;
		if isMsgRemove then self:removeMsg();end;
	end;
end;

function hlTextTicker:generateRunTimer(addFinishCallback, other) --optional replace function  or ...
	self.timer = Timer.new(self.runTimer[1]);
	
	if addFinishCallback then --optional set here or ...
		self.timer:setFinishCallback(
			function(timerInstance)
				if other ~= nil then
					if other == 1 then
						self.setMsgUpdate1(self)
					elseif other == 2 then
						self.setMsgUpdate2(self)
					elseif other == 3 then
						self.setMsgUpdate3(self)
					end;
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
		if g_currentMission:getHasUpdateable(self) then g_currentMission:removeUpdateable(self);end;
		if g_currentMission:getHasDrawable(self) then g_currentMission:removeDrawable(self);end;		
		self:removeMsg(nil, true);
	elseif (state == nil and not self.isOn) or (state ~= nil and state == true) then
		if self.addCallbacks.update then g_currentMission:addUpdateable(self);end;
		if self.addCallbacks.draw then g_currentMission:addDrawable(self);end;		
		if self.addCallbacks.delete and not self.addCallbacks.firstStart then self.addCallbacks.firstStart = true;g_currentMission:addNonUpdateable(self);end;
		self:setBackgroundData();		
		self:startRunTimer();
		self.isOn = true;
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
	if #self.msg > 0 then
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and msg.id == id then
				self:removeMsg(i);
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
end;

function hlTextTicker:removeMsg(pos, removeAll)
	if #self.msg > 0 then
		if (removeAll == nil or not removeAll) and pos ~= nil then
			if self.msg[pos] == nil then return;end;
			g_currentMission.hlUtils.deleteOverlays(self.msg[pos].overlay);
			table.remove(self.msg, pos);	
		else
			for i=1, #self.msg do
				local msg = self.msg[i];
				if msg ~= nil and ((msg.remove ~= nil and msg.remove) or (removeAll ~= nil and removeAll)) then
					g_currentMission.hlUtils.deleteOverlays(msg.overlay);
					table.remove(self.msg, i);				
				end;
			end;			
		end;
	end;
	if removeAll ~= nil and removeAll then self.repeatableMsg = {};end;
end;

function hlTextTicker:resetAllMsg(updateByPlayer)
	self.isReset = true;
	local copyMsg = {};
	if #self.msg > 0 then		
		for i=1, #self.msg do
			local msg = self.msg[i];
			if msg ~= nil and msg.remove == nil then				
				table.insert(copyMsg, {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, id=msg.id, isVisible=msg.isVisible, onDraw=msg.onDraw, background=msg.background, onAction=msg.onAction, onClick=msg.onClick, ownTable=msg.ownTable});
			end;
		end;
		self:removeMsg(nil, true);		
	end;
	self:setBackgroundData();
	if #copyMsg > 0 then
		for i=1, #copyMsg do
			local msg = copyMsg[i];
			if msg ~= nil then
				self:addMsg( {text=msg.text, color=msg.color, blinking=msg.blinking, repeatable=msg.repeatable, repeatableWait=msg.repeatableWait, id=msg.id, isVisible=msg.isVisible; background=msg.background, onDraw=msg.onDraw, onAction=msg.onAction, separator=false, onClick=msg.onClick, ownTable=msg.ownTable} );
			end;
		end;
	elseif updateByPlayer ~= nil and updateByPlayer and self.positionUpdateText:len() > 0 then		
		self:addMsg( {text=self.positionUpdateText, color="green", blinking=true, separator=false} );
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

function hlTextTicker:setClickArea(args) --msg overlays		
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