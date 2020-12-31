namespace "Zeta.Serialization"

class "Von" implements "ISerializer"
{
	static
	{
		Serialize = function(data)
			return von.serialize(data)
		end;

		Deserialize = function(data)
			return von.deserialize(data)
		end;
	};
}