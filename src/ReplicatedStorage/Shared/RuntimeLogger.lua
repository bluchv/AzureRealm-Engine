local RuntimeLogger = {}
RuntimeLogger.__index = RuntimeLogger

-- Constructor
function RuntimeLogger.new()
	local self = setmetatable({
		start = tick(),
	}, RuntimeLogger)
	return self
end

-- Deconstructor
function RuntimeLogger:destroy()
	table.clear(self)
	setmetatable(self, nil)
	table.freeze(self)
end

-- Easy print and auto cleanup
function RuntimeLogger:PrintTime(msg: string)
	print((msg):format(("%0.2f"):format(self:getTime())))
	self:destroy()
end

-- Gets the logger delta time
function RuntimeLogger:getTime()
	local elapsed = tick() - self.start
	return tostring(elapsed)
end

return RuntimeLogger
