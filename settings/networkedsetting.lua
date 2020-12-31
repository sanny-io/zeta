namespace "Zeta.Settings"

class "NetworkedSetting" extends "Setting"
{
	__construct = function(self, name, key, description, value)
		self:On("Changed", print)
	end;

	abstract
	{
		PlayerCanRead	=	function(self, ply) end;
		PlayerCanWrite	=	function(self, ply) end;
	};
}