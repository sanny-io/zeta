namespace "Zeta.Http"

class "HttpResponse"
{
	__construct = function(self, code, body, headers)
		self.Code = code
		self.Body = body
		self.Headers = headers
	end;
}