namespace "Zeta.Events"

class "EventEmitter"
{
	__construct = function(self)
		self.Listeners = {}
	end;

	On = function(self, event, listener)
		return self:AddListener(event, listener)
	end;

	Once = function(self, event, listener)
		return self:AddListener(event, listener, true)
	end;

	Emit = function(self, event, ...)
		if istable(event) then
			event(...)
			event = event.ClassName
		end

		local listeners = self.Listeners[event]

		if listeners and #listeners > 0 then
			local callbacks = {}

			for k, listener in ipairs(listeners) do
				callbacks[#callbacks + 1] = listener.Callback
			end

			-- Loop twice? Not ideal...but it's a bit tricky removing elements in an ordered loop. Fix later.
			for k, listener in ipairs(listeners) do
				if listener.Once then
					self:RemoveListener(event, k)
				end
			end

			for _, callback in ipairs(callbacks) do
				local results = {callback(...)}

				if #results > 0 then
					return unpack(results)
				end
			end
		end
	end;

	AddListener = function(self, event, listener, once)
		if istable(event) then
			event = event.ClassName
		end

		local listeners = self.Listeners[event] or {}

		table.insert(listeners, {Callback = listener, Once = once})
		self.Listeners[event] = listeners

		return self
	end;

	RemoveListener = function(self, event, key)
		if istable(event) then
			event = event.ClassName
		end

		if self.Listeners[event] then
			table.remove(self.Listeners[event], key)
		end

		return self
	end;

	RemoveAllListeners = function(self, event)
		if istable(event) then
			event = event.ClassName
		end

		if not event then
			table.Empty(self.Listeners)
		else
			local listeners = self.Listeners[event]

			if listeners then
				table.Empty(listeners)
			end
		end

		return self
	end;
}