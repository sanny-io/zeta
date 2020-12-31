namespace "Zeta"

local function LaunchRequest(url, method, parameters, body, headers, contentType)
	return Zeta.Promise(function(resolve, reject)
		HTTP({url = url, method = method, parameters = parameters, headers = headers, body = body, type = contentType, failed = reject, success = function(code, body, headers)
			resolve(Zeta.Http.HttpResponse(code, body, headers))
		end})
	end)
end

class "Http"
{
	static
	{
		Get = function(url)
			return LaunchRequest(url, "get", parameters)
		end;

		Post = function(url, parameters)
			return LaunchRequest(url, "post", parameters)
		end;

		Head = function(url, parameters)
			return LaunchRequest(url, "head", parameters)
		end;

		Put = function(url, parameters)
			return LaunchRequest(url, "put", parameters)
		end;

		Delete = function(url, parameters)
			return LaunchRequest(url, "delete", parameters)
		end;
	}
}