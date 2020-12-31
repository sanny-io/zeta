namespace "Zeta.Validation"

class "AsyncValidator" implements "IAsyncValidator"
{
	__construct = function(self, executor)
		self.Executor = executor
	end;

	Validate = function(self, input, callback)
		self.Executor(input, callback)
	end;

	__call = function(self, ...)
		return self:Validate(...)
	end;
}