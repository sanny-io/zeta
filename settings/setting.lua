namespace "Zeta.Settings"

class "Setting" extends "Zeta.Events.EventEmitter"
{
	__construct = function(self, name, key, description, value)
		self.Name = name
		self.Key = key
		self.Description = description
		self:Set(value)
	end;

	Set = function(self, value)
		if self.Value ~= value then
			self:Emit("Changed", value, self.Value)
			self.Value = value
		end
	end;

	Get = function(self)
		return self.Value
	end;

	__tostring = function(self)
		return ("[%s] %s = %s"):format(self.ClassName, self.Key, self.Value)
	end;
}