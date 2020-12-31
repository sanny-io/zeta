namespace "Zeta"

class "Table"
{
	__construct = function(self, tbl)
		assert(tbl == nil or istable(tbl), "table is not valid")

		rawset(self, "Table", tbl)
		self.__index = self.Table
	end;

	__tostring = function(self)
		return table.ToString(self.Table, nil, true)
	end;

	__len = function(self)
		return #self.Table
	end;

	__newindex = function(self, key, value)
		self.Table[key] = value
	end;
}