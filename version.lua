namespace "Zeta"

class "Version"
{
	__construct = function(self, major, minor, patch, release, build)
		if isstring(major) then
			self.Major, self.Minor, self.Patch, self.Release, self.Build = major:match("^(%d)%.(%d)%.(%d)%-?([%w-]+)%+?([%w-]+)$")
		else
			self.Major, self.Minor, self.Patch, self.Release, self.Build = major or 1, minor or 0, patch or 0, release, build
		end
	end;

	__eq = function(self, other)
		return self.Major == other.Major and self.Minor == other.Minor and self.Patch == other.Patch
	end;

	__tostring = function(self)
		local str = ("%d.%d.%d"):format(self.Major, self.Minor, self.Patch)

		if self.Release then
			str = str .. "-" .. self.Release
		end

		if self.Build then
			str = str .. "+" .. self.Build
		end

		return str
	end;
}