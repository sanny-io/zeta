Zeta.Vgui = Zeta.Vgui or {}

function Zeta.Vgui.Line(parent, dockType, ...)
	local panels = {...}
	local container = parent:Add("Panel")

	container:Dock(FILL)
	container:InvalidateParent(true)

	for k, panel in ipairs(panels) do
		panel = container:Add(panel)
		panel:Dock(dockType or TOP)
		panel:InvalidateParent(true)
		panels[k] = panel
	end

	return container, unpack(panels)
end

function Zeta.Vgui.Column(parent, ...)
	return Zeta.Vgui.Line(parent, TOP, ...)
end

function Zeta.Vgui.Row(parent, ...)
	return Zeta.Vgui.Line(parent, LEFT, ...)
end

-- VGUI and Panel and extensions.
do
	if not Zeta.Vgui.Overriden then
		local vguiRegister = vgui.Register
		local _, PanelFactory = debug.getupvalue(vgui.Create, 1)

		function vgui.Register(...)
			local panel = vguiRegister(...)
			local panelMeta = getmetatable(panel)

			function panelMeta:__call(...)
				return vgui.CreateFromTable(self, nil, nil, ...)
			end

			return panel
		end

		function vgui.Create(className, parent, name, ...)
			if (PanelFactory[className]) then
				local metatable = PanelFactory[className]
				local panel = vgui.Create(metatable.Base, parent, name or className, ...)

				if not panel then
					Error("Tried to create panel with invalid base '" .. metatable.Base .. "'\n")
				end

				table.Merge(panel:GetTable(), metatable)

				panel.BaseClass = PanelFactory[metatable.Base]
				panel.ClassName = className

				if panel.Init then
					panel:Init(...)
				end

				panel:Prepare()

				return panel
			end

			return vgui.CreateX(className, parent, name or className)
		end

		function vgui.CreateFromTable(metatable, parent, name, ...)
			if not istable(metatable) then return nil end

			local panel = vgui.Create(metatable.Base, parent, name, ...)

			table.Merge(panel:GetTable(), metatable)

			panel.BaseClass = PanelFactory[metatable.Base]
			panel.ClassName = className

			if panel.Init then
				panel:Init(...)
			end

			panel:Prepare()

			return panel
		end

		do
			local panelMeta = FindMetaTable("Panel")

			function panelMeta:Add(panel, ...)
				if isstring(panel) then
					panel = vgui.Create(panel, self, nil, ...)
				elseif istable(panel) then
					panel = vgui.CreateFromTable(panel, self, nil, ...)
				else -- It's already a valid panel.
					panel:SetParent(self)
				end

				return panel
			end

			function panelMeta:DockChildren(...)
				local args = {...}

				self.OnChildAdded = Zeta.DetourAfter(self.OnChildAdded or Zeta.EmptyFunction, function(_, child)
					child:Dock(unpack(args))
				end)
			end

			function panelMeta:DockMarginChildren(...)
				local args = {...}

				self.OnChildAdded = Zeta.DetourAfter(self.OnChildAdded or Zeta.EmptyFunction, function(_, child)
					child:DockMargin(unpack(args))
				end)
			end

			function panelMeta:DockPaddingChildren(...)
				local args = {...}

				self.OnChildAdded = Zeta.DetourAfter(self.OnChildAdded or Zeta.EmptyFunction, function(_, child)
					child:DockPadding(unpack(args))
				end)
			end
		end

		Zeta.Vgui.Overriden = true
	end
end