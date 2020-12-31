namespace "Zeta.Sql"

class "ModelInstance"
{
	__construct = function(self, model, fields, noSanitize)
		rawset(self, "Model", model)
		rawset(self, "Fields", fields or {})
		rawset(self, "__index", self.Fields)

		for k, v in pairs(model.Functions) do
			rawset(self, k, v)
		end

		if fields then
			self:Update(fields, noSanitize)
		end

		if self.Fields[self.Model.Key] then
			if self:IsCached() then
				return self.Model.Instances[self.Fields.Id]:Update(fields, noSanitize)
			else
				self.Model.Instances[self.Fields.Id] = self
			end
		end
	end;

	Update = function(self, fields, noSanitize)
		for field, value in pairs(fields) do
			if not self.Model.Fields[field] then -- It's an unknown field. Discard it.
				fields[field] = nil
			elseif self.Fields then
				self.Fields[field] = value

				if field:EndsWith("_Id") then
					local foreignModelName = field:match("(%w+)_Id")

					for k, model in ipairs(self.Model.Database.Models) do
						if model.Name == foreignModelName then
							--
						end
					end
				end
			end
		end

		self.Model:Emit("Update", self)

		return self
	end;

	Save = function(self, callback)
		self.Model:Emit("Save", self)

		local query = self.Model.Database:Upsert(self.Model.Table)

		for k, v in pairs(self.Fields) do
			query:Value(k, v)
		end

		return Zeta.Promise(function(resolve, reject)
			query:Execute(function()
				if self.Fields.Id then
					self.Model.Database:Select(self.Model.Table):Where("Id", self.Fields.Id):Execute(function(result)
						self:Update(result[1], true)

						if callback then
							callback(self)
						end

						resolve(self)

						self.Model:Emit("PostSave", self)
					end)
				else
					self.Model.Database:Select(self.Model.Table):WhereRaw("Id", ("(SELECT MAX(`Id`) FROM `%s`)"):format(self.Model.Table)):Execute(function(result)
						self:Update(result[1], true)

						if callback then
							callback(self)
						end

						resolve(self)

						self.Model:Emit("PostSave", self)
					end)
				end
			end)
		end)
	end;

	Delete = function(self, callback)
		self.Model:Emit("Delete", self)

		return Zeta.Promise(function(resolve, reject)
			self.Model.Database:Delete(self.Model.Table):Where("Id", self.Fields.Id):Execute(function()
				if self:IsCached() then
					self.Model.Instances[self.Fields.Id] = nil
				end

				if callback then
					callback(self)
				end

				resolve(self)

				self.Model:Emit("PostDelete", self)
			end)
		end)
	end;

	IsCached = function(self)
		return self.Model.Instances[self.Fields.Id] ~= nil
	end;

	__newindex = function(self, key, value)
		if self.Model.Fields[key] then
			self.Fields[key] = value
		else
			rawset(self, key, value)
		end
	end;
}