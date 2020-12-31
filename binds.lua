Zeta.Binds = Zeta.Binds or {}

function Zeta.Bind(key, callback)
	if isstring(key) then
		key = _G[key]
	end

	Zeta.Binds[key] = callback
end

function Zeta.Unbind(key, callback)
	if isstring(key) then
		key = _G[key]
	end

	Zeta.Binds[key] = nil
end

hook.Add("PlayerButtonDown", "Zeta.Binds", function(ply, button)
	if IsFirstTimePredicted() then
		local callback = Zeta.Binds[button]

		if callback then
			if CLIENT then
				if ply == LocalPlayer() then
					callback()
				end
			else
				callback(ply)
			end
		end
	end
end)