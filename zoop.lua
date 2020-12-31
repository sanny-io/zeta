local zoop = setmetatable({}, {__index = _G})
local classMeta = {}
local classes = {}

local MergeTable = table.Merge or function(destination, source)
	for k, v in pairs(source) do
		if (type(v) == "table" and type(destination[k]) == "table") then
			table.Merge(destination[k], v)
		else
			destination[k] = v
		end
	end

	return destination
end

local InheritTable = table.Inherit or function(tbl, base)
	for k, v in pairs(base) do
		if (tbl[k] == nil) then
			tbl[k] = v
		end
	end

	tbl.BaseClass = base

	return tbl
end

local CountTable = table.Count or function(tbl)
	local i = 0

	for k in pairs(tbl) do
		i = i + 1
	end

	return i
end

local CopyTable = table.Copy or function(tbl, lookupTbl)
	local copy = {}

	setmetatable(copy, debug.getmetatable(tbl))

	for k, v in pairs(tbl) do
		if (type(v) ~= "table") then
			copy[k] = v
		else
			lookupTbl = lookupTbl or {}
			lookupTbl[k] = copy

			if (lookupTbl[v]) then
				copy[k] = lookupTbl[v]
			else
				copy[k] = CopyTable(v, lookupTbl)
			end
		end
	end

	return copy
end

local function GetGlobalValue(key)
	if key == "" then
		return _G
	end

	local split = key:Split(".")
	local value

	for _, newKey in ipairs(split) do
		value = value and value[newKey] or _G[newKey]
	end

	return value
end

local function SetGlobalValue(key, value)
	local split = key:Split(".")
	local currentValue

	for i, newKey in ipairs(split) do
		if i == 1 then
			currentValue = _G[newKey] or {}
			_G[newKey] = currentValue
		elseif not currentValue[newKey] then
			if i == #split then
				currentValue[newKey] = value
			else
				currentValue[newKey] = {}
				currentValue = currentValue[newKey]
			end
		elseif i ~= #split then
			currentValue = currentValue[newKey]
		end
	end
end

local function SetNamespaceValue(key, value)
	if zoop.ActiveNamespace then
		SetGlobalValue(zoop.ActiveNamespace .. "." .. key, value)
	else
		_G[key] = value
	end
end

local function GetNamespaceValue(key)
	return GetGlobalValue(zoop.ActiveNamespace .. "." .. key) or GetGlobalValue(key)
end

local function RegisterClass(className, classBody)
	local newClass = zoop.ActiveClass
	MergeTable(newClass, classBody)
	SetNamespaceValue(className, newClass)
end

classMeta.__index = classMeta

function classMeta:IsAbstract()
	return CountTable(classes[self.FullClassName].abstracts) > 0
end

function classMeta:IsInterface()
	return classes[self.FullClassName].isInterface
end

function classMeta:DoesImplementInterfaces()
	for _, interface in ipairs(classes[self.FullClassName].interfaces) do
		if interface.abstracts then
			for methodName in pairs(interface.abstracts) do
				if not self[methodName] then
					return false
				end
			end
		end
	end

	return true
end

function classMeta:__call(...)
	assert(not self:IsInterface(), "attempt to instantiate interface " .. self.FullClassName)
	assert(not self:IsAbstract(), "attempt to instantiate abstract class " .. self.FullClassName)
	assert(self:DoesImplementInterfaces(), self.FullClassName .. " does not implement all of its interface methods")

	local object = CopyTable(self)
	local baseClass = self.BaseClass
	local baseClasses = {}

	setmetatable(object, object)

	while baseClass do
		for abstractMethod in pairs(classes[baseClass.FullClassName].abstracts) do
			if not object[abstractMethod] then
				error(("cannot instantiate %s because it does not implement %s for %s"):format(self.FullClassName, abstractMethod, baseClass.FullClassName))
			end
		end

		if baseClass.__construct then
			table.insert(baseClasses, 1, baseClass)
		end

		baseClass = baseClass.BaseClass
	end

	for _, baseClass in ipairs(baseClasses) do
		baseClass.__construct(object, ...)
	end

	if self.__finalize then
		local proxy = newproxy(true)
		local proxyMeta = getmetatable(proxy)

		proxyMeta.MetaName = self.FullClassName
		proxyMeta.__gc = function()
			local success, err = pcall(self.__finalize, object)

			assert(success, ("could not finalize %s (%s)"):format(self.FullClassName, err))
		end

		rawset(object, "__gc", proxy)
	end

	if self.__construct and (not self.BaseClass or self.__construct ~= self.BaseClass.__construct) then
		local newObject = self.__construct(object, ...)

		if newObject then
			return newObject
		end
	end

	return object
end

local function CreateClass(className, isInterface)
	local newClass = setmetatable({}, classMeta)

	newClass.ClassName = className
	newClass.FullClassName = zoop.namespace() and zoop.namespace() .. "." .. className or className
	classes[newClass.FullClassName] = {abstracts = {}, statics = {}, interfaces = {}, isInterface = isInterface}
	zoop.ActiveClass = newClass

	return function(classBody)
		return RegisterClass(className, isInterface and classes[newClass.FullClassName].abstracts or classBody)
	end
end

function zoop.class(className)
	return CreateClass(className)
end

function zoop.interface(interfaceName)
	return CreateClass(interfaceName, true)
end

function zoop.namespace(namespaceName)
	if not namespaceName then
		return zoop.ActiveNamespace
	end

	zoop.ActiveNamespace = namespaceName
	SetGlobalValue(namespaceName, {})
end

function zoop.extends(baseClassName)
	if zoop.ActiveClass then
		local baseClass = assert(GetNamespaceValue(baseClassName), "base class " .. baseClassName .. " not found")

		return function(classBody)
			InheritTable(zoop.ActiveClass, baseClass)
			return RegisterClass(zoop.ActiveClass.ClassName, classBody)
		end
	end
end

function zoop.implements(interfaceNames)
	if zoop.ActiveClass then
		interfaceNames = interfaceNames:Split(" ")

		for _, interfaceName in ipairs(interfaceNames) do
			table.insert(classes[zoop.ActiveClass.FullClassName].interfaces, (assert(GetNamespaceValue(interfaceName), "interface not valid")))
		end

		return function(classBody)
			return RegisterClass(zoop.ActiveClass.ClassName, classBody)
		end
	end
end

function zoop.abstract(abstractMethods)
	if zoop.ActiveClass then
		for abstractMethodName, abstractMethod in pairs(abstractMethods) do
			classes[zoop.ActiveClass.FullClassName].abstracts[abstractMethodName] = abstractMethod
		end
	end
end

function zoop.static(staticMethods)
	if zoop.ActiveClass then
		for staticMethodName, staticMethod in pairs(staticMethods) do
			zoop.ActiveClass[staticMethodName] = staticMethod
			classes[zoop.ActiveClass.FullClassName].statics[staticMethodName] = staticMethod
		end
	end
end

function zoop.enum(enumName)
	_G[enumName] = {}

	return function(tbl)
		for k, v in pairs(tbl) do
			_G[enumName][k] = v
		end

		return tbl
	end
end

_G.zoop = zoop

for k, v in pairs(zoop) do
	_G[k] = v
end