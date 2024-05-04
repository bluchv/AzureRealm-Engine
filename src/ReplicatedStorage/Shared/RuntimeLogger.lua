local RuntimeLogger = {}
RuntimeLogger.__index = RuntimeLogger

function RuntimeLogger.new()
	local self = setmetatable({
		start = tick(),
	}, RuntimeLogger)
	return self
end

function RuntimeLogger:PrintTime(msg: string)
	print((msg):format(("%0.2f"):format(self:getTime())))
	self:destroy()
end

function RuntimeLogger:getTime()
	local elapsed = tick() - self.start
	return tostring(elapsed)
end

function RuntimeLogger:destroy()
	table.clear(self)
	setmetatable(self, nil)
	table.freeze(self)
end

return RuntimeLogger
