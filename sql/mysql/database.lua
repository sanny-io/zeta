if not Zeta.SafeRequire("mysql") then return end

namespace "Zeta.Sql.Mysql"

class "Database" extends "Zeta.Sql.Database"
{
	__construct = function(self, config)
		self.Connection = mysql.Connect(config.host or "localhost", config.username, config.password, config.database, config.port or 3306, config.socket or "")

		self.Connection.OnConnected = function()
			self:Emit("Connected")
		end;

		self.Connection.OnConnectionFailed = function(_, err)
			self:Emit("ConnectionFailed", err)
		end;
	end;

	Query = function(self, query, successCallback, errorCallback)
		self:RequiresConnection()

		if isstring(query) then
			query = Zeta.Sql.Mysql.Query(self, query)
		end

		query = query.Query

		query.OnCompleted = function(_, result)
			result = result[1]

			if result.Success then
				self.LastId = result.LastID
				self.AffectedRows = result.Affected

				if successCallback then
					return successCallback(result.Data)
				end
			else
				self.LastError = result.Error

				if errorCallback then
					return errorCallback(result.Error)
				end
			end
		end

		query:Start()
	end;

	Escape = function(self, input)
		self:RequiresConnection()

		return self.Connection:Escape(input)
	end;

	Connect = function(self)
		return self.Connection:Connect()
	end;

	Disconnect = function(self)
		self:RequiresConnection()

		return self.Connection:Disconnect()
	end;

	IsConnected = function(self)
		return self.Connection:Status() == DATABASE_CONNECTED
	end;
}