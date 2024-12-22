hlUtilsMpEvent = {};
local hlUtilsMpEvent_mt = Class(hlUtilsMpEvent, Event);

InitEventClass(hlUtilsMpEvent, "hlUtilsMpEvent");

function hlUtilsMpEvent.emptyNew()
	local self = Event.new(hlUtilsMpEvent_mt);
	self.className = "hlUtilsMpEvent";
	
	return self;
end

function hlUtilsMpEvent.new(gFunction, sFunction)
	local value = g_currentMission.hlUtilsMp.getValue(gFunction);
	if value == nil then return;end;
	local self = hlUtilsMpEvent.emptyNew();
	self.value = g_currentMission.hlUtilsMp.getValue(gFunction);	--tostring
	self.sFunction = sFunction;		
	return self;
end

function hlUtilsMpEvent:readStream(streamId, connection)
	--if connection:getIsServer() then
		local value = streamReadString(streamId);
		local sFunction = streamReadString(streamId);		
		self.value = value;
		self.sFunction = sFunction;
		
		g_currentMission.hlUtilsMp.setValue(self.sFunction, self.value);	--tostring
		
	--end;

	--self:run(connection)
end;

function hlUtilsMpEvent:writeStream(streamId, connection)
	--if not connection:getIsServer() then
		local value = self.value;
		local sFunction = self.sFunction;
		streamWriteString(streamId, value);
		streamWriteString(streamId, sFunction);
	--end;
end;
