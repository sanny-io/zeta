namespace "Zeta.Sql.Mysql"

class "Query" extends "Zeta.Sql.Query"
{
	__construct = function(self, database, queryString, successCallback, errorCallback)
		self.Query = database.Connection:Query(queryString)
	end;
}