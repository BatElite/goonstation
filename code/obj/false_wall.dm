/turf/simulated/wall/false_wall
	name = "wall"
	icon = 'icons/obj/doors/Doorf.dmi'
	icon_state = "door1"
	gas_impermeable = 0
	var/operating = null
	var/visible = 1
	var/floorname
	var/floorintact
	var/floorhealth
	var/floorburnt
	var/icon/flooricon
	var/flooricon_state
	var/const/delay = 15
	var/const/prob_opens = 25
	var/list/known_by = list()
	var/can_be_auto = 1
	var/mod = null
	var/obj/overlay/floor_underlay = null
	var/dont_follow_map_settings_for_icon_state = 0

	temp
		var/was_rwall = 0

	reinforced
		icon_state = "rdoor1"
		mod = "R"

	New()
		..()
		//Hide the wires or whatever THE FUCK
		src.levelupdate()
		src.gas_impermeable = 1
		src.layer = src.layer - 0.1
		SPAWN(0)
			src.UpdateIcon()
		SPAWN(1 SECOND)
			// so that if it's getting created by the map it works, and if it isn't this will just return
			src.setFloorUnderlay('icons/turf/floors.dmi', "plating", 0, 100, 0, "plating")
			if (src.can_be_auto)
				for (var/turf/simulated/wall/auto/W in orange(1,src))
					W.UpdateIcon()
				for (var/obj/grille/G in orange(1,src))
					G.UpdateIcon()
				for (var/obj/window/auto/W in orange(1,src))
					W.UpdateIcon()
				for (var/turf/simulated/wall/false_wall/F in orange(1,src))
					F.UpdateIcon()

	Del()
		src.RL_SetSprite(null)
		if (floor_underlay)
			qdel(floor_underlay)
		..()

	proc/setFloorUnderlay(FloorIcon, FloorIcon_State, Floor_Intact, Floor_Health, Floor_Burnt, Floor_Name)
		if(floor_underlay)
			//only one underlay
			return 0
		if(!(FloorIcon || FloorIcon_State))
			return 0
		if(!Floor_Health)
			Floor_Health = 150
		if(!Floor_Burnt)
			Floor_Burnt = 0
		if(!Floor_Intact)
			Floor_Intact = 1
		if(!Floor_Name)
			Floor_Name = "floor"

		// SCREAM
		floor_underlay = new /obj/overlay(src)
		floor_underlay.icon = FloorIcon
		floor_underlay.icon_state = FloorIcon_State
		floor_underlay.layer = src.layer - 0.1
		floor_underlay.mouse_opacity = 0
		floor_underlay.plane = PLANE_FLOOR

		src.flooricon = FloorIcon
		src.flooricon_state = FloorIcon_State
		src.floorintact = Floor_Intact
		src.floorhealth = Floor_Health
		src.floorburnt = Floor_Burnt
		src.floorname = Floor_Name
		return 1

	attack_hand(mob/user)
		src.add_fingerprint(user)
		var/known = (user in known_by)
		if (src.density)
			//door is closed
			if (known)
				if (open())
					boutput(user, "<span class='notice'>The wall slides open.</span>")
			else if (prob(prob_opens))
				//it's hard to open
				if (open())
					boutput(user, "<span class='notice'>The wall slides open!</span>")
					known_by += user
			else
				return ..()
		else
			if (close())
				boutput(user, "<span class='notice'>The wall slides shut.</span>")
		return

	attackby(obj/item/S, mob/user)
		src.add_fingerprint(user)
		var/known = (user in known_by)
		if (isscrewingtool(S))
			//try to disassemble the false wall
			if (!src.density || prob(prob_opens))
				//without this, you can detect a false wall just by going down the line with screwdrivers
				//if it's already open, you can disassemble it no problem
				if (src.density && !known) //if it was closed, let them know that they did something
					boutput(user, "<span class='notice'>It was a false wall!</span>")
				//disassemble it
				boutput(user, "<span class='notice'>Now dismantling false wall.</span>")
				var/floorname1	= src.floorname
				var/floorintact1	= src.floorintact
				var/floorburnt1	= src.floorburnt
				var/icon/flooricon1	= src.flooricon
				var/flooricon_state1	= src.flooricon_state
				src.set_density(0)
				src.RL_SetOpacity(0)
				src.update_nearby_tiles()
				if (src.floor_underlay)
					qdel(src.floor_underlay)
				var/turf/simulated/floor/F = src.ReplaceWithFloor()
				F.name = floorname1
				F.icon = flooricon1
				F.icon_state = flooricon_state1
				F.setIntact(floorintact1)
				F.burnt = floorburnt1
				//a false wall turns into a sheet of metal and displaced girders
				var/atom/A = new /obj/item/sheet(F)
				var/atom/B = new /obj/structure/girder/displaced(F)
				if(src.material)
					A.setMaterial(src.material)
					B.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)
					B.setMaterial(M)
				F.levelupdate()
				logTheThing("station", user, null, "dismantles a False Wall in [user.loc.loc] ([log_loc(user)])")
				return
			else
				return ..()
		// grabsmash
		else if (istype(S, /obj/item/grab/))
			var/obj/item/grab/G = S
			if  (!grab_smash(G, user))
				return ..(S, user)
			else return
		else
			return src.Attackhand(user)

	proc/open()
		if (src.operating)
			return 0
		src.operating = 1
		src.name = "false wall"
		animate(src, time = delay, pixel_x = 25, easing = BACK_EASING)
		SPAWN(delay)
			//we want to return 1 without waiting for the animation to finish - the textual cue seems sloppy if it waits
			//actually do the opening things
			src.set_density(0)
			src.gas_impermeable = 0
			src.pathable = 1
			src.update_air_properties()
			src.RL_SetOpacity(0)
			if(!floorintact)
				src.setIntact(FALSE)
				src.levelupdate()
			if(checkForMultipleDoors())
				update_nearby_tiles()
			src.operating = 0
		return 1

	proc/close()
		if (src.operating)
			return 0
		src.operating = 1
		src.name = "wall"
		animate(src, time = delay, pixel_x = 0, easing = BACK_EASING)
		src.set_density(1)
		src.gas_impermeable = 1
		src.pathable = 0
		src.update_air_properties()
		if (src.visible)
			src.RL_SetOpacity(1)
		src.setIntact(TRUE)
		update_nearby_tiles()
		SPAWN(delay)
			//we want to return 1 without waiting for the animation to finish - the textual cue seems sloppy if it waits
			src.operating = 0
		return 1

	update_icon()
		..()
		if(dont_follow_map_settings_for_icon_state)
			return
		if (!map_settings)
			return

		if (src.can_be_auto) /// is the false wall able to mimic autowalls
			var/turf/simulated/wall/auto/wall_path = ispath(map_settings.walls) ? map_settings.walls : /turf/simulated/wall/auto
			src.icon = initial(wall_path.icon)

			if (istype(src, /turf/simulated/wall/false_wall/reinforced))
				wall_path = ispath(map_settings.rwalls) ? map_settings.rwalls : /turf/simulated/wall/auto/reinforced

			/// this was borrowed from autowalls as the code that was barely worked

			/// basically this is doing what an autowall of the path wall_path would do
			var/s_connect_overlay = initial(wall_path.connect_overlay)

			var/list/s_connects_to = list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
			/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
			/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle, /obj/machinery/door,
			/obj/window, /obj/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow,
			/turf/simulated/wall/auto/reinforced/supernorn/blackred, /turf/simulated/wall/auto/reinforced/supernorn/orange,
			/turf/simulated/wall/auto/old, /turf/simulated/wall/auto/reinforced/old,
			/turf/unsimulated/wall/auto/supernorn,/turf/unsimulated/wall/auto/reinforced/supernorn)

			var/list/s_connects_with_overlay = list(/turf/simulated/wall/auto/shuttle,
			/turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/wingrille_spawn,
			/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen)

			var/list/s_connects_with_overlay_exceptions = list()
			var/list/s_connects_to_exceptions = list(/turf/simulated/wall/auto/shuttle)

			var/s_connect_diagonal =  initial(wall_path.connect_diagonal)
			var/image/s_connect_image = initial(wall_path.connect_image)

			var/light_mod = initial(wall_path.light_mod)
			mod = initial(wall_path.mod)


			var/connectdir = get_connected_directions_bitflag(s_connects_to, s_connects_to_exceptions, TRUE, s_connect_diagonal)
			var/the_state = "[mod][connectdir]"
			icon_state = the_state

			if (light_mod)
				src.RL_SetSprite("[light_mod][connectdir]")

			if (s_connect_overlay)
				var/overlaydir = get_connected_directions_bitflag(s_connects_with_overlay, s_connects_with_overlay_exceptions, TRUE)
				if (overlaydir)
					if (!s_connect_image)
						s_connect_image = image(src.icon, "connect[overlaydir]")
					else
						s_connect_image.icon_state = "connect[overlaydir]"
					src.UpdateOverlays(s_connect_image, "connect")
				else
					src.UpdateOverlays(null, "connect")


	get_desc()
		if (!src.density)
			return "It's a false wall. It's open."

	//Temp false walls turn back to regular walls when closed.
	temp/New()
		..()
		SPAWN(1.1 SECONDS)
			src.open()

	temp/close()
		if (src.operating)
			return 0
		src.operating = 1
		src.name = "wall"
		animate(src, time = delay, pixel_x = 0, easing = BACK_EASING)
		src.icon_state = "door1"
		src.set_density(1)
		src.gas_impermeable = 1
		src.pathable = 0
		src.update_air_properties()
		if (src.visible)
			src.opacity = 0
			src.RL_SetOpacity(1)
		src.setIntact(TRUE)
		update_nearby_tiles()
		if(src.was_rwall)
			src.ReplaceWithRWall()
		else
			src.ReplaceWithWall()
		return 1

/turf/simulated/wall/false_wall/hive
	name = "strange hive wall"
	desc = "Looking more closely, these are actually really squat octagons, not hexagons! What!!"
	icon = 'icons/turf/walls.dmi'
	icon_state = "hive"
	can_be_auto = 0


/turf/simulated/wall/false_wall/centcom
	desc = "There seems to be markings on one of the edges, huh."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "leadwall"
	can_be_auto = 0


/turf/simulated/wall/false_wall/tempus
	desc = "The pattern on the wall seems to have a seam on it"
	icon = 'icons/turf/walls_tempus-green.dmi'
	icon_state = "0"

