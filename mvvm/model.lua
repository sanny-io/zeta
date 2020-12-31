namespace "Zeta.Mvvm"

class "Model" extends "Zeta.Events.EventEmitter"
{
	SetProperty = function(self, propertyName, propertyValue)
		if self[propertyName] ~= propertyValue then
			self[propertyName] = propertyValue
			self:Emit("PropertyChanged", propertyName, propertyValue)
		end
	end;

	GetProperty = function(self, propertyName)
		return self[propertyName]
	end;
}