local ent = FindMetaTable("Entity")

function GetSharedVar(key, default)
	return game.GetWorld():GetSharedVar(key, default)
end

function ent:GetSharedVar(key, default)
	if (IsValid(self) or self:IsWorld()) and self.SharedVars and self.SharedVars[key] ~= nil then
		return self.SharedVars[key]
	end

	return default
end

if SERVER then
	Zeta.Net.Pool("SetSharedVar")

	function ent:SetSharedVar(key, value)
		self.SharedVars = self.SharedVars or {}
		self.SharedVarListeners = self.SharedVarListeners or {}
		self.SharedVars[key] = value

		if self:IsWorld() then
			self.SharedVarListeners[key] = player.GetAll()
		else
			if not self.SharedVarListeners[key] then
				if self:IsPlayer() then
					self.SharedVarListeners[key] = {self}
				else
					self.SharedVarListeners[key] = {}
				end
			end
		end

		Zeta.Net.Send("SetSharedVar", self.SharedVarListeners[key], self, key, value, self:IsWorld())
	end

	function ent:AddSharedVarListener(key, ply)
		self.SharedVars = self.SharedVars or {}
		self.SharedVarListeners = self.SharedVarListeners or {}

		if not self.SharedVarListeners[key] then
			if self:IsPlayer() then
				self.SharedVarListeners[key] = {self}
			else
				self.SharedVarListeners[key] = {}
			end
		end

		if not table.HasValue(self.SharedVarListeners[key], ply) then
			table.insert(self.SharedVarListeners[key], ply)
			Zeta.Net.Send("SetSharedVar", ply, self, key, self.SharedVars[key], self:IsWorld())
		end
	end

	function ent:RemoveSharedVarListener(key, ply)
		self.SharedVars = self.SharedVars or {}
		self.SharedVarListeners = self.SharedVarListeners or {}

		if ply ~= self and self.SharedVarListeners[key] then
			table.RemoveByValue(self.SharedVarListeners[key], ply)
			Zeta.Net.Send("SetSharedVar", ply, self, key, nil, self:IsWorld())
		end
	end

	function SetSharedVar(key, value)
		return game.GetWorld():SetSharedVar(key, value)
	end
else
	Zeta.Net.Receive("SetSharedVar", function(ent, key, value, isWorld)
		if IsValid(ent) or isWorld then
			local oldValue = nil

			ent = isWorld and game.GetWorld() or ent
			ent.SharedVars = ent.SharedVars or {}
			oldValue = ent.SharedVars[key]
			ent.SharedVars[key] = value

			Zeta.Net:Emit("SharedVarChanged", ent, key, value, oldValue)
		end
	end)
end