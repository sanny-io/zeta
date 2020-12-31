namespace "Zeta.Sql.Tmysql"

class "Query" extends "Zeta.Sql.Query"
{
	__construct = function(self, database, queryString, successCallback, errorCallback)
		Zeta.Sql.Query.__construct(self, database, queryString, successCallback, errorCallback)

		resultbase.Connection:Query(queryString, function(result)
			result = result[1]

			if result.status then
				self.lastId = result.lastid
				self.affectedRows = result.affected

				return successCallback(result.result)
			else
				self.lastError = result.error

				return errorCallback(result.error)
			end
		end)
	end;
}