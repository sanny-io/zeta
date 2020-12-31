namespace "Zeta.Serialization"

class "Json" implements "ISerializer"
{
	static
	{
		Serialize = function(data)
			return util.TableToJSON(data)
		end;

		Deserialize = function(data)
			return util.JSONToTable(data)
		end;
	};
}