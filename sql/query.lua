namespace "Zeta.Sql"

class "Query" extends "Zeta.Events.EventEmitter"
{
	__construct = function(self, database, queryString, successCallback, errorCallback, manualExecution)
		assert(istable(database), "no database provided")
		assert(isstring(queryString), "no query string provided")

		self.Database = database
		self.String = queryString
		self.Wheres = {}
		self.Updates = {}
		self.InsertColumns = {}
		self.InsertValues = {}
		self.CreateColumns = {}
		self.Constraints = {}
	end;

	Where = function(self, column, value)
		self.Wheres[#self.Wheres + 1] = ("`%s` = '%s'"):format(column, self.Database:Escape(value))

		return self
	end;

	WhereRaw = function(self, column, value)
		self.Wheres[#self.Wheres + 1] = ("`%s` = %s"):format(column, value)

		return self
	end;

	WhereGreaterThan = function(self, column, value)
		self.Wheres[#self.Wheres + 1] = ("`%s` > '%s'"):format(column, self.Database:Escape(value))

		return self
	end;

	WhereLessThan = function(self, column, value)
		self.Wheres[#self.Wheres + 1] = ("`%s` < '%s'"):format(column, self.Database:Escape(value))

		return self
	end;

	WhereGreaterThanOrEqual = function(self, column, value)
		self.Wheres[#self.Wheres + 1] = ("`%s` >= '%s'"):format(column, self.Database:Escape(value))

		return self
	end;

	WhereLessThanOrEqual = function(self, column, value)
		self.Wheres[#self.Wheres + 1] = ("`%s` <= '%s'"):format(column, self.Database:Escape(value))

		return self
	end;

	WhereLike = function(self, column, value)
		self.Wheres[#self.Wheres + 1] = ("`%s` LIKE '%s'"):format(column, self.Database:Escape(value))

		return self
	end;

	WhereNotLike = function(self, column, value)
		self.Wheres[#self.Wheres + 1] = ("`%s` NOT LIKE '%s'"):format(column, self.Database:Escape(value))

		return self
	end;

	Value = function(self, column, value)
		self.InsertColumns[#self.InsertColumns + 1] = column
		self.InsertValues[#self.InsertValues + 1] = "'" .. self.Database:Escape(value) .. "'"

		return self
	end;

	Column = function(self, column, info)
		self.CreateColumns[#self.CreateColumns + 1] = ("`%s` %s"):format(column, info)

		return self
	end;

	Set = function(self, column, value)
		self.Updates[#self.Updates + 1] = ("`%s` = '%s'"):format(column, self.Database:Escape(value))

		return self
	end;

	Constraint = function(self, constraint)
		self.Constraints[#self.Constraints + 1] = constraint

		return self
	end;

	Build = function(self)
		if #self.InsertColumns > 0 then
			self.String = self.String:format(table.concat(self.InsertColumns, ", "):Trim(", "), table.concat(self.InsertValues, ", "):Trim(", "))
		end

		if #self.Updates > 0 then
			self.String = self.String:format(table.concat(self.Updates, ", "):Trim(", "))
		end

		if #self.CreateColumns > 0 then
			self.String = self.String:format(table.concat(self.CreateColumns, ", "):Trim(", "))
		end

		if #self.Wheres > 0 then
			self.String = ("%s WHERE %s"):format(self.String, table.concat(self.Wheres, " AND "))
		end

		if #self.Constraints > 0 then
			self.String = ("%s), %s"):format(self.String:Trim(")"), table.concat(self.Constraints, " ")):Trim() .. ")"
		end

		self:Emit("PostBuild")

		--print(self.String)

		return self.String:Trim()
	end;

	GetString = function(self)
		return self.String
	end;

	GetObject = function(self)
		return self.QueryObject
	end;

	__tostring = function(self)
		return ("%s: %s"):format(self.FullClassName, self.String)
	end;

	abstract
	{
		--__construct = function(self, database, queryString, successCallback, errorCallback, manualExecution) end;
		Execute = function(self, successCallback) end;
	};
}