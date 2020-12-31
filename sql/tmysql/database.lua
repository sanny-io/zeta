if not Zeta.SafeRequire("tmysql4") then return end

namespace "Zeta.Sql.Tmysql"

class "Database" extends "Zeta.Sql.Database"
{
	__construct = function(self, config)
		Zeta.Sql.Database.__construct(self, config)
	end;

	__finalize = function(self)
		if self:IsConnected() then
			self:Disconnect()
		end;
	end;

	Query = function(self, query, successCallback, errorCallback)
		self:RequiresConnection()

		Zeta.Sql.Tmysql.Query(self, query, successCallback, errorCallback)
	end;

	Escape = function(self, input)
		self:RequiresConnection()

		return self.Connection:Escape(input)
	end;

	Connect = function(self)
		if not self:IsConnected() then
			local config = self.Config
			local connectionError

			self.Connection, connectionError = tmysql.initialize(config.host or "localhost", config.username, config.password, config.database, config.port or 3306, config.socket or "")

			if self.Connection then
				if self.OnConnected then
					self:OnConnected()
				end
			elseif self.OnConnectionFailed then
				self.OnConnectionFailed(connectionError)
			end
		end
	end;

	Disconnect = function(self)
		self:RequiresConnection()

		return self.Connection:Disconnect()
	end;

	IsConnected = function(self)
		--return self.Connection ~= nil
	end;
}