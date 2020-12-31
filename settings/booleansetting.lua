namespace "Zeta.Settings"

class "BooleanSetting" extends "Setting"
{
	Set = function(self, value)
		if tobool(value) ~= nil then
			return self.BaseClass.Set(self, value)
		end
	end;
}