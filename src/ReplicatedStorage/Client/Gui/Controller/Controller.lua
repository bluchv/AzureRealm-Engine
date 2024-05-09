local _model = require(script.Parent.Parent.Model.Model)
local View = require(script.Parent.Parent.View.View)

local Controller = {}

function Controller:UpdateSprinting(...)
	View:UpdateSprintingLabel(...)
end

return Controller
