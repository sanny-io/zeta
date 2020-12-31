namespace "Zeta"

interface "ILogger"
{
	Debug = function(message, ...) end;
	Info = function(message, ...) end;
	Message = function(message, ...) end;
	Warning = function(message, ...) end;
	Error = function(message, ...) end;
	Critical = function(message, ...) end;
}