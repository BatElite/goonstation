/obj/machinery/computer/robot_module_rewriter
	name = "cyborg module rewriter"
	desc = "A machine used to reconfigure cyborg modules."
	icon_state = "robot_module_rewriter"
	anchored = 1
	density = 1
	light_r =1
	light_g = 0.4
	light_b = 0
	circuit_type = /obj/item/circuitboard/robot_module_rewriter
	var/list/obj/item/robot_module/modules = null //modules loaded inside the rewriter
	var/list/obj/item/robot_module/borg_modules = list() //modules inside nearby borgs
	var/obj/item/robot_module/selectedModule = null
	var/picked_tool = null //storage for picking and inserting tools

/obj/machinery/computer/robot_module_rewriter/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/robot_module))
		user.drop_item()
		I.set_loc(src)
		LAZYLISTADD(src.modules, I)
		boutput(user, "<span class=\"notice\">You insert [I] into \the [src].</span>")
		tgui_process.update_uis(src)
	else
		..()

/obj/machinery/computer/robot_module_rewriter/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		if (isrobot(user))
			var/mob/living/silicon/robot/borg = user
			if (borg.module)
				borg_modules[borg.module] = borg
		ui = new(user, src, "CyborgModuleRewriter", src.name)
		ui.open()

/obj/machinery/computer/robot_module_rewriter/ui_data(mob/user)
	var/list/modulesData = list()

	var/list/availableModulesData = list()
	for (var/obj/item/robot_module/module in src.modules)
		var/list/availableModuleData = list()
		availableModuleData["name"] = module.name
		availableModuleData["ref"] = "\ref[module]"
		availableModuleData["in_borg"] = FALSE
		// wrapping in a list to append actual list rather than contents
		availableModulesData += list(availableModuleData)

	for (var/obj/item/robot_module/module in src.borg_modules) //same deal but in-borg modules
		var/list/availableModuleData = list()
		availableModuleData["name"] = "[module.name] ([borg_modules[module].name])"
		availableModuleData["ref"] = "\ref[module]"
		availableModuleData["in_borg"] = TRUE
		availableModulesData += list(availableModuleData)
	modulesData["available"] = availableModulesData

	var/list/selectedModuleData = null
	if (src.selectedModule)
		selectedModuleData = list()
		selectedModuleData["ref"] = "\ref[src.selectedModule]"
		var/list/selectedModuleToolsData = list()
		for (var/obj/item/tool in src.selectedModule.tools)
			var/list/toolData = list()
			toolData["name"] = tool.name
			toolData["ref"] = "\ref[tool]"
			// wrapping in a list to append actual list rather than contents
			selectedModuleToolsData += list(toolData)
		selectedModuleData["tools"] = selectedModuleToolsData
	modulesData["selected"] = selectedModuleData

	// "modules" is the only key in our return list, so could be flattened,
	// but there is intent to add more features in the near future
	. = list("modules" = modulesData)
	//. = list("modules" = modulesData, "picked" = picked_tool)

/obj/machinery/computer/robot_module_rewriter/ui_close(mob/user)
	if (isrobot(user))
		var/mob/living/silicon/robot/borg = user
		if (borg.module)
			borg_modules -= borg.module
	..()


/obj/machinery/computer/robot_module_rewriter/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if (.)
		return
	var/moduleRef = params["moduleRef"]
	if (!moduleRef)
		return
	var/toolRef = params["toolRef"]

	var/mob/user = ui.user
	var/module_in_borg = FALSE
	//Find our fabled module
	var/obj/item/robot_module/module = locate(moduleRef) in src.modules
	if (module)
		if (module.loc != src)
			// sanity check, tidy up modules list if not in the machine for some reason
			LAZYLISTREMOVE(src.modules, module)
			src.selectedModule = null //this was in half the
	else //borg list time
		module = locate(moduleRef) in src.borg_modules
		if (!module || user != borg_modules[module]) // second clause is to prevent anyone but the borg from messing with their own module
			return //couldn't find anything
		module_in_borg = TRUE

	switch (action)

		if ("module-eject")
			if (module_in_borg)
				src.borg_modules -= module
			else if (module.loc == src)
				user.put_in_hand_or_eject(module)
			if (module == src.selectedModule)
				src.selectedModule = null
				picked_tool = null
			. = TRUE

		if ("module-reset")
			var/moduleId = params["moduleId"]
			if (!moduleId)
				return
			if (!module_in_borg) //Making borgs reassign internal module is probably as simple as calling the module adding and removing procs on the borg but I'm not doing that atm
				if (module == src.selectedModule)
					picked_tool = null
					var/moduleResetType
					switch (moduleId)
						if ("brobocop")
							moduleResetType = /obj/item/robot_module/brobocop
						if ("chemistry")
							moduleResetType = /obj/item/robot_module/chemistry
						if ("civilian")
							moduleResetType = /obj/item/robot_module/civilian
						if ("engineering")
							moduleResetType = /obj/item/robot_module/engineering
						if ("medical")
							moduleResetType = /obj/item/robot_module/medical
						if ("mining")
							moduleResetType = /obj/item/robot_module/mining
					if (moduleResetType)
						var/obj/item/robot_module/replacementModule = new moduleResetType(src)
						var/moduleIndex = src.modules.Find(module)
						if (moduleIndex)
							src.modules[moduleIndex] = replacementModule
							src.selectedModule = replacementModule
							qdel(module)
			. = TRUE

		if ("module-select")
			src.selectedModule = module
			picked_tool = null
			. = TRUE

		if ("tool-move")
			var/dir = params["dir"]
			if (toolRef)
				if (module != src.selectedModule)
					return
				var/obj/item/tool = locate(toolRef) in module
				if (!tool)
					return
				var/toolIndex = module.tools.Find(tool)
				switch (dir)
					if ("down")
						if (toolIndex > 0 && toolIndex < module.tools.len)
							module.tools.Swap(toolIndex, toolIndex + 1)
					if ("up")
						if (toolIndex >= 2)
							module.tools.Swap(toolIndex, toolIndex - 1)
			. = TRUE

		if ("tool-remove")
			if (toolRef)
				if (module != src.selectedModule)
					return
				var/obj/item/tool = locate(toolRef) in module.tools
				if (tool == picked_tool)
					picked_tool = null
				if (tool)
					module.tools -= tool
					qdel(tool)
			. = TRUE

		//These last two are basically cut and paste, have you seen how huge borg module lists are?
		if ("tool-pick")
			picked_tool = null
			if (toolRef)
				if (module != src.selectedModule)
					return
				picked_tool = locate(toolRef) in module.tools
			. = picked_tool

		if ("tool-insert") //Important: toolRef in this instance is the tool we're inserting below, picked_tool is what gets inserted.
			if (!picked_tool)
				return
			if (toolRef)
				if (module != src.selectedModule)
					return
				if (!locate(picked_tool) in module.tools) //I think I've covered my ass enough nulling picked_tool but just to be safe
					return
				var/obj/item/otherthing = locate(toolRef) in module.tools
				if (otherthing)
					module.tools -= picked_tool
					module.tools.Insert(module.tools.Find(otherthing), picked_tool)
					picked_tool = null
					. = TRUE
