namespace "Zeta.Sql.Sqlite"

class "Database" extends "Zeta.Sql.Database"
{
	Connect = function(self)
		if self.OnConnected then
			self:OnConnected()
		end
	end;

	Query = function(self, queryString, successCallback, errorCallback)
		local result = sql.Query(queryString)

		if result ~= false then
			self.LastId = sql.QueryValue("SELECT last_insert_rowid()")
			self.AffectedRows = sql.QueryValue("SELECT changes()")

			if (successCallback) then
				return successCallback(result)
			end
		else
			self.LastError = sql.LastError()

			if errorCallback then
				return errorCallback(query, self.lastError)
			end
		end
	end;

	IsConnected = function()
		return true
	end;

	Escape = function(self, input)
		return sql.SQLStr(input, true)
	end;

	LastError = function(self)
		return self.lastError
	end;

	LastId = function(self)
		return self.lastId
	end;

	AffectedRows = function(self)
		return self.affectedRows
	end;
}