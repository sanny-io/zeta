namespace "Zeta.Sql"

Zeta.Sql.Databases = Zeta.Sql.Databases or {}

class "Database" extends "Zeta.Events.EventEmitter"
{
	__construct = function(self, config)
		assert(istable(config), "no configuration provided")

		self.Config = config
		self.Models = {}
		self:On("Connected", function()
			self:CreateModels()
		end)

		if config.identifier then
			Zeta.Sql.Databases[config.identifier] = self
		end
	end;

	RequiresConnection = function(self)
		assert(self:IsConnected(), "database not connected")
	end;

	Create = function(self, tableName)
		return self:Query(("CREATE TABLE IF NOT EXISTS `%s` (%%s)"):format(tableName), nil, nil, true)
	end;

	Select = function(self, tableName)
		return self:Query(("SELECT * FROM `%s`"):format(tableName), nil, nil, true)
	end;

	Insert = function(self, tableName)
		return self:Query(("INSERT INTO `%s` (%%s) VALUES (%%s)"):format(tableName), nil, nil, true)
	end;

	Update = function(self, tableName)
		return self:Query(("UPDATE `%s` SET %%s"):format(tableName), nil, nil, true)
	end;

	Upsert = function(self, tableName)
		local query = self:Insert(tableName)
			query:On("PostBuild", function()
				local updates = ""

				for k, v in ipairs(query.InsertColumns) do
					if k ~= #query.InsertColumns then
						updates = updates .. ("`%s` = %s, "):format(v, query.InsertValues[k])
					else
						updates = updates .. ("`%s` = %s"):format(v, query.InsertValues[k])
					end
				end

				query.String = ("%s ON DUPLICATE KEY UPDATE %s"):format(query.String, updates)
			end)
		return query
	end;

	CreateModels = function(self)
		local promises = {}

		for _, model in ipairs(self.Models) do
			table.insert(promises, function()
				return model:CreateTable()
			end)
		end

		Zeta.Promise.Do(unpack(promises)):Then(function()
			if self:IsConnected() then
				self:Emit("ModelsCreated")
			end
		end, print)
	end;

	Delete = function(self, tableName)
		return self:Query(("DELETE FROM `%s`"):format(tableName), nil, nil, true)
	end;

	GetConnection = function(self)
		return self.Connection
	end;

	GetConfig = function(self)
		return self.Config
	end;

	GetLastError = function(self)
		return self.LastError
	end;

	GetLastId = function(self)
		return self.LastId
	end;

	GetAffectedRows = function(self)
		return self.AffectedRows
	end;

	__tostring = function(self)
		return ("%s (connected: %s)"):format(self.FullClassName, tostring(self:IsConnected()))
	end;

	abstract
	{
		Connect = function(self) end;
		Query = function(self, queryString, successCallback, errorCallback, manualExecution) end;
		Escape = function(self, input) end;
		IsConnected = function(self) end;
	};
}