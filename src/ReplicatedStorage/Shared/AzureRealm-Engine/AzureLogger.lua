local AzureLogger = {}

function AzureLogger:Log(msg: string)
	print(`[AzureRealm-Engine] {msg}`)
end

function AzureLogger:Warn(msg: string)
	warn(`[AzureRealm-Engine] {msg}`)
end

function AzureLogger:Fatal(msg: string)
	error(`[AzureRealm-Engine] {msg}`)
end

return AzureLogger
