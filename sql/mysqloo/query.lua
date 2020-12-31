namespace "Zeta.Sql.Mysqloo"

class "Query" extends "Zeta.Sql.Query"
{
	__construct = function(self, database, queryString, successCallback, errorCallback, manualExecution)
		if not manualExecution then
			self.QueryObject = database.Connection:query(queryString)
			self.QueryObject.onSuccess = function(_, result)
				self.Database.LastId = self.QueryObject:lastInsert()
				self.Database.AffectedRows = self.QueryObject:affectedRows()

				if successCallback then
					return successCallback(result)
				end
			end

			self.QueryObject.onError = function(_, err)
				self.Database.LastError = err

				if errorCallback then
					return errorCallback(err)
				end
			end

			self.QueryObject:start()
		end
	end;

	Execute = function(self, successCallback)
		self.QueryObject = self.Database.Connection:query(self:Build())

		return Zeta.Promise(function(resolve, reject)
			self.QueryObject.onSuccess = function(_, result)
				self.Database.LastId = self.QueryObject:lastInsert()
				self.Database.AffectedRows = self.QueryObject:affectedRows()

				if successCallback then
					successCallback(result)
				end

				self:Emit("Executed", result)

				resolve(result)
			end

			self.QueryObject.onError = function(_, err)
				reject(err)
			end

			self.QueryObject:start()
		end)
	end;
}