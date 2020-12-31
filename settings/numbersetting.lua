namespace "Zeta.Settings"

class "NumberSetting" extends "Setting"
{
	Set = function(self, value)
		if tonumber(value) ~= nil then
			return self.BaseClass.Set(self, value)
		end
	end;
}