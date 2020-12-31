namespace "Zeta.Serialization"

class "Pon" implements "ISerializer"
{
	static
	{
		Serialize = function(data)
			return pon.encode(data)
		end;

		Deserialize = function(data)
			return pon.decode(data)
		end;
	};
}