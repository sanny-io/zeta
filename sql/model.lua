namespace "Zeta.Sql"

class "Model" extends "Zeta.Events.EventEmitter"
{
	__construct = function(self, name, database)
		self.Name = name
		self.Database = database
		self.Key = "Id"
		self.OrderNumber = 1
		self.Functions = {}
		self.Instances = Zeta.WeakTable()

		if self.Database then
			self.Database.Models[#self.Database.Models + 1] = self
		end
	end;

	SetupDatabase = function(self)
		if isstring(self.Database) then
			assert(Zeta.Sql.Databases[self.Database] ~= nil, "no database with identifier '" .. self.Database .. "'' found")

			self.Database = Zeta.Sql.Databases[self.Database]
			self.Database.Models[#self.Database.Models + 1] = self
		end
	end;

	CreateTable = function(self, callback)
		self:SetupDatabase()

		if istable(self.Database) and self.Database:IsConnected() then
			return Zeta.Promise(function(resolve)
				if not self.CreatedTable then
					local query = self.Database:Create(self.Table)

					for k, v in SortedPairsByMemberValue(self.Fields, "OrderNumber") do
						if v.IsConstraint then
							query:Constraint(tostring(v))
						else
							query:Column(v.Column, tostring(v))
						end

						self.Fields[k] = nil
						self.Fields[v.Column] = tostring(v)
					end

					query:Execute(function()
						self.CreatedTable = true

						if callback then
							callback()
						end

						resolve()
					end)
				else
					if callback then
						callback()
					end

					resolve()
				end
			end)
		end
	end;

	All = function(self, callback)
		self:SetupDatabase()

		return Zeta.Promise(function(resolve)
			self.Database:Select(self.Table):Execute(function(results)
				for k, v in ipairs(results) do
					results[k] = Zeta.Sql.ModelInstance(self, v, true)
				end

				if callback then
					callback(results)
				end

				resolve(results)
			end)
		end)
	end;

	--[[Where = function(self, column, value, multipleResults)
		self:SetupDatabase()

		local query = self.Database:Select(self.Table)
			query:Where(column, value)
			query.__call = function(query, callback)
				query:Execute(function(results)
					if #results > 0 then
						if multipleResults then
							for k, v in pairs(results) do
								results[k] = Zeta.Sql.ModelInstance(self, v, true)
							end

							callback(results)
						else
							callback(Zeta.Sql.ModelInstance(self, results[1], true))
						end
					else
						if multipleResults then
							callback({})
						else
							callback()
						end
					end
				end)
			end
		return query
	end;]]

	Where = function(self, column, value, multipleResults)
		self:SetupDatabase()

		local query = self.Database:Select(self.Table):Where(column, value)
			query.OldExecute = query.OldExecute or query.Execute
		query.Execute = function(...)
			query.OldExecute(...)

			return Zeta.Promise(function(resolve, reject)
				query:On("Executed", function(results)
					if #results > 0 then
						if multipleResults then
							for k, v in pairs(results) do
								results[k] = Zeta.Sql.ModelInstance(self, v, true)
							end

							resolve(results)
						else
							resolve(Zeta.Sql.ModelInstance(self, results[1], true))
						end
					else
						if multipleResults then
							resolve({})
						else
							resolve()
						end
					end
				end)
			end)
		end

		return query
	end;

	AllWhere = function(self, column, value)
		return self:Where(column, value, true)
	end;

	Find = function(self, value, callback)
		self:SetupDatabase()

		return Zeta.Promise(function(resolve)
			self.Database:Select(self.Table)
				:Where("Id", value)
			:Execute(function(result)
				if #result > 0 then
					local instance = Zeta.Sql.ModelInstance(self, result[1], true)

					if callback then
						callback(instance)
					end

					resolve(instance)
				else
					if callback then
						callback()
					end

					resolve()
				end
			end)
		end)
	end;

	FindOrCreate = function(self, value, callback)
		self:SetupDatabase()

		return Zeta.Promise(function(resolve)
			self.Database:Select(self.Table)
				:Where("Id", value)
			:Execute(function(result)
				local alreadyExisted = false

				if #result > 0 then
					alreadyExisted = true
				end

				self.Database:Upsert(self.Table):Value("Id", value):Execute(function()
					self.Database:Select(self.Table)
						:Where("Id", value)
					:Execute(function(result)
						local instance = Zeta.Sql.ModelInstance(self, result[1] or {Id = value}, true)

						rawset(instance, "AlreadyExisted", alreadyExisted)

						if callback then
							callback(instance)
						end

						resolve(instance)

						if not alreadyExisted then
							self:Emit("OnCreate", instance)
						end
					end)
				end)
			end)
		end)
	end;

	Flush = function(self)
		table.Empty(self.Instances)
	end;

	Increment = function(self, column)
		self.OrderNumber = self.OrderNumber + 1

		return Zeta.Sql.Field(self, column, "INTEGER UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY", self.OrderNumber)
	end;

	Integer = function(self, column, size)
		self.OrderNumber = self.OrderNumber + 1

		return Zeta.Sql.Field(self, column, ("INTEGER(%s)"):format(size or "10"), self.OrderNumber)
	end;

	BigInteger = function(self, column, size)
		self.OrderNumber = self.OrderNumber + 1

		return Zeta.Sql.Field(self, column, ("BIGINT(%s)"):format(size or "20"), self.OrderNumber)
	end;

	String = function(self, column, size)
		self.OrderNumber = self.OrderNumber + 1

		return Zeta.Sql.Field(self, column, ("VARCHAR(%s)"):format(size or "MAX"), self.OrderNumber)
	end;

	Boolean = function(self, column)
		self.OrderNumber = self.OrderNumber + 1

		return Zeta.Sql.Field(self, column, "BOOLEAN", self.OrderNumber)
	end;

	Enum = function(self, column, enumTypes)
		enumTypes = table.Copy(enumTypes)

		self.OrderNumber = self.OrderNumber + 1

		for k, enumType in ipairs(enumTypes) do
			enumTypes[k] = "'" .. enumType .. "'"
		end

		return Zeta.Sql.Field(self, column, ("ENUM(%s)"):format(table.concat(enumTypes, ", ")), self.OrderNumber)
	end;

	Foreign = function(self, model)
		local column = ("%s_Id"):format(model.Name)
		local field

		self.OrderNumber = self.OrderNumber + 1

		field = Zeta.Sql.Field(self, column, ("FOREIGN KEY (%s) REFERENCES %s(Id)"):format(column, model.Table), self.OrderNumber)
		field.IsConstraint = true

		return field
	end;

	__call = function(self, fields)
		self:SetupDatabase()

		return Zeta.Sql.ModelInstance(self, fields)
	end;
}