namespace "Zeta.Mvvm"

class "ViewModel"
{
	__construct = function(self, model)
		self.Model = model
		self.Model:On("PropertyChanged", function(propertyName, propertyValue)
			if IsValid(self.Panel) then
				local panel = self.Panel:Find(propertyName)

				if IsValid(panel) then
					panel:SetText(propertyValue)
				end
			end
		end)
	end;

	SetProperty = function(self, propertyName, propertyValue)
		return self.Model:SetProperty(propertyName, propertyValue)
	end;

	GetProperty = function(self, propertyName)
		return self.Model:GetProperty(propertyName)
	end;
}