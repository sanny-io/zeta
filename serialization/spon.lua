namespace "Zeta.Serialization"

class "Spon" implements "ISerializer"
{
	static
	{
		Serialize = function(data)
			return spon.encode(data)
		end;

		Deserialize = function(data)
			return spon.decode(data)
		end;
	};
}