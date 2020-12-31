namespace "Zeta.Sql"

class "Field"
{
	__construct = function(self, model, column, str, orderNumber)
		self.Model = model
		self.String = str or ""
		self.String:Trim()
		self.Column = column
		self.OrderNumber = orderNumber or 1
	end;

	Primary = function(self)
		self.String = self.String .. " PRIMARY KEY"
		self.String:Trim()
		self.Model.Key = self.Column

		return self
	end;

	Unique = function(self)
		self.String = self.String .. " UNIQUE"
		self.String:Trim()

		return self
	end;

	NotNull = function(self)
		self.String = self.String .. " NOT NULL"
		self.String:Trim()

		return self
	end;

	Unsigned = function(self)
		self.String = self.String .. " UNSIGNED"
		self.String:Trim()

		return self
	end;

	Default = function(self, value)
		self.String = self.String .. (" DEFAULT '%s'"):format(value)
		self.String:Trim()

		return self
	end;

	OnUpdate = function(self, action)
		self.String = self.String .. (" ON UPDATE %s"):format(action)
		self.String:Trim()

		return self
	end;

	OnDelete = function(self, action)
		self.String = self.String .. (" ON DELETE %s"):format(action)
		self.String:Trim()

		return self
	end;

	__tostring = function(self)
		return self.String
	end;
}