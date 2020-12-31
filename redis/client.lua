if not Zeta.SafeRequire("redis.core") then return end

namespace "Zeta.Redis"

class "Client" extends "Zeta.Events.EventEmitter"
{
	__construct = function(self, ipAddress, port)
		self.Object = redis.CreateClient()
		self.Object.OnDisconnected = function()
			self:Emit("Disconnected")
		end

		self.Object:Connect(ipAddress, port or 6379)

		hook.Add("Think", tostring(self), function()
			self.Object:Poll()
		end)
	end;

	__finalize = function(self)
		if self:IsConnected() then
			self:Disconnect()
		end

		hook.Remove("Think", tostring(self))
	end;

	Send = function(self, command, ...)
		local args = {...}

		self:RequiresConnection()

		return Zeta.Promise(function(resolve, reject)
			if self.Object:Send({command, unpack(args)}, function(_, data)
				resolve(data)
			end) then
				self.Object:Commit()
			else
				reject()
			end
		end)
	end;

	IsConnected = function(self)
		return self.Object:IsConnected()
	end;

	RequiresConnection = function(self)
		assert(self:IsConnected(), "database not connected")
	end;

	Disconnect = function(self)
		self:RequiresConnection()
		self.Object:Disconnect()
	end;

	__call = function(self, ...)
		return self:Send(...)
	end;

	__tostring = function(self)
		return ("[%s] %d"):format(Zeta.AddressOf(self))
	end;
}