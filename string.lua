namespace "Zeta"

class "String"
{
	__construct = function(self, str)
		self.Array = tostring(str):Split("")
	end;

	Append = function(self, str)
		str = tostring(str)
		local length = #str

		if length > 0 then
			for i = 1, length do
				self.Array[#self.Array + 1] = str[i]
			end
		end

		return self
	end;

	Prepend = function(self, str)
		str = tostring(str)
		local length = #str

		if length > 0 then
			-- Counting backwards lets us freely adjust the keys to a higher number.
			for i = self:Length(), 1, -1 do
				self.Array[i + length] = self.Array[i]
			end

			-- Now we just add the prepended string at the beginning.
			for i = 1, length do
				self.Array[i] = str[i]
			end
		end

		return self
	end;

	Contains = function(self, str)
		return tostring(self):find(str, 1, true)
	end;

	Copy = function(self)
		return Zeta.String(self)
	end;

	Empty = function(self)
		for k in ipairs(self.Array) do
			self.Array[k] = nil
		end

		return self
	end;

	Length = function(self)
		return #self.Array
	end;

	__index = function(self, key)
		return self.Array[key]
	end;

	__newindex = function(self, key, value)
		if key ~= "Array" then
			assert(isnumber(key), "index is not a number")
			assert(isstring(value), "value must be a string")
			assert(key > 0 and key <= self:Length(), "index is out of bounds")

			self.Array[key] = tostring(value)
		else
			rawset(self, key, value)
		end
	end;

	__len = function(self)
		return self:Length()
	end;

	__concat = function(self, other)
		return tostring(self) .. tostring(other)
	end;

	__add = function(self, other)
		return self:__concat(other)
	end;

	__eq = function(self, other)
		return tostring(self) == tostring(other)
	end;

	__lt = function(self, other)
		return tostring(self) < tostring(other)
	end;

	__le = function(self, other)
		return tostring(self) <= tostring(other)
	end;

	__tostring = function(self)
		return table.concat(self.Array, "")
	end;
}