namespace "Zeta"

class "File"
{
	__construct = function(self, name)
		self.FullName = name
		self.Name = name:GetFileFromFilename()
		self.Extension = name:GetExtensionFromFilename()
		self.Path = name:GetPathFromFilename()
	end;

	Exists = function(self)
		return file.Exists(self.FullName, "GAME")
	end;

	Read = function(self)
		return file.Read(self.FullName, "GAME") or ""
	end;

	__tostring = function(self)
		return ("[%s] %s"):format(self.ClassName, self.FullName)
	end;

	static
	{
		Current = function()
			return Zeta.File(debug.getinfo(2).source:TrimLeft("@"))
		end;
	}
}