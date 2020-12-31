if not Zeta.SafeRequire("mysqloo") then return end

namespace "Zeta.Sql.Mysqloo"

class "Database" extends "Zeta.Sql.Database"
{
	__construct = function(self, config)
		self.Connection = mysqloo.connect(config.host or "localhost", config.username, config.password, config.database, config.port or 3306, config.socket or "")

		self.Connection.onConnected = function()
			self:Emit("Connected")
		end;

		self.Connection.onConnectionFailed = function(_, err)
			self:Emit("ConnectionFailed", err)
		end;
	end;

	__finalize = function(self)
		if self:IsConnected() then
			self.Connection:abortAllQueries()
		end
	end;

	Query = function(self, query, successCallback, errorCallback, manualExecution)
		self:RequiresConnection()

		if isstring(query) then
			query = Zeta.Sql.Mysqloo.Query(self, query, successCallback, errorCallback, manualExecution)
		end

		return query
	end;

	Escape = function(self, input)
		self:RequiresConnection()

		return self.Connection:escape(tostring(input))
	end;

	Connect = function(self)
		return self.Connection:connect()
	end;

	IsConnected = function(self)
		return self.Connection:status() == mysqloo.DATABASE_CONNECTED
	end;
}