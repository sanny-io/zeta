namespace "Zeta"

enum "PromiseState"
{
	Pending = 1,
	Fulfilled = 2,
	Rejected = 3
}

class "Promise" extends "Zeta.Events.EventEmitter"
{
	__construct = function(self, functionOrPromise)
		self.State = PromiseState.Pending

		if isfunction(functionOrPromise) then
			functionOrPromise(function(value)
				self:Resolve(value)
			end, function(reason)
				self:Reject(reason)
			end)
		else
			functionOrPromise:On("Resolved", function(value)
				self:Resolve(value)
			end)
		end
	end;

	Resolve = function(self, value)
		if istable(value) and isfunction(value.Then) then
			value:Then(function(value)
				self:Resolve(value)
				self:Emit("Resolved", value)
			end, function(reason)
				self:Reject(reason)
				self:Emit("Rejected", reason)
			end)

			return
		end

		self.State = PromiseState.Fulfilled
		self.Value = value

		if self.Deferred then
			self:Handle(self.Deferred)
		end
	end;

	Reject = function(self, reason)
		self.State = PromiseState.Rejected
		self.Value = reason

		if self.Deferred then
			self:Handle(self.Deferred)
		end
	end;

	Handle = function(self, handler)
		if self:IsPending() then
			self.Deferred = handler

			return
		end

		local callback = nil

		if self:IsFulfilled() then
			callback = handler.OnFulfilled
		else
			callback = handler.OnRejected
		end

		if not callback then
			if self:IsFulfilled() then
				handler.Resolve(self.Value)
			else
				handler.Reject(self.Value)
			end

			return
		end

		if not handler.OnFulfilled then
			handler.Resolve(self.Value)

			return
		end

		local success, result = xpcall(callback, function(err)
			return err
		end, self.Value)

		if not success then
			error(result)
			handler.Reject(result)

			return
		end

		handler.Resolve(result)
	end;

	Then = function(self, onFulfilled, onRejected)
		return Zeta.Promise(function(resolve, reject)
			self:Handle({OnFulfilled = onFulfilled, OnRejected = onRejected, Resolve = resolve, Reject = reject})
		end)
	end;

	IsPending = function(self)
		return self.State == PromiseState.Pending
	end;

	IsFulfilled = function(self)
		return self.State == PromiseState.Fulfilled
	end;

	IsRejected = function(self)
		return self.State == PromiseState.Rejected
	end;

	static
	{
		-- Guarantees the order of execution for the promises.
		Do = function(...)
			local promiseFunctions = {...}
			local routine = nil

			return Zeta.Promise(function(resolve, reject)
				routine = coroutine.create(function()
					local values = {}

					if #promiseFunctions == 0 then
						resolve({})
					else
						for k, promiseFunction in ipairs(promiseFunctions) do
							local promise = promiseFunction(values[k - 1], values)

							timer.Simple(0, function()
								promise:Then(function(value)
									table.insert(values, value)
									coroutine.resume(routine)
								end, function(reason)
									reject(reason)
								end)
							end)

							coroutine.yield()
						end

						resolve(values)
					end
				end)

				coroutine.resume(routine)
			end)
		end;

		-- Does not guarantee the order of execution for the promises.
		DoAsync = function(...)
			local promiseFunctions = {...}

			return Zeta.Promise(function(resolve, reject)
				if #promiseFunctions == 0 then
					resolve({})
				else
					local values = {}
					local fulfilledPromiseCount = 0

					for k, promiseFunction in ipairs(promiseFunctions) do
						local promise = promiseFunction(values[k - 1], values)

						promise:Then(function(value)
							values[k] = value
							fulfilledPromiseCount = fulfilledPromiseCount + 1

							if fulfilledPromiseCount == #promiseFunctions then
								resolve(values)
							end
						end, function(reason)
							reject(reason)
						end)
					end
				end
			end)
		end;
	}
}