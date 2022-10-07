/image/fullbright
	icon = 'icons/effects/white.dmi'
	plane = PLANE_LIGHTING
	layer = LIGHTING_LAYER_FULLBRIGHT
	blend_mode = BLEND_OVERLAY
	appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_ALPHA | RESET_COLOR

/image/ambient
	icon = 'icons/effects/white.dmi'
	plane = PLANE_LIGHTING
	layer = LIGHTING_LAYER_BASE
	blend_mode = BLEND_ADD
	appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_ALPHA | RESET_COLOR

/obj/ambient
	icon = 'icons/effects/white.dmi'
	plane = PLANE_LIGHTING
	layer = LIGHTING_LAYER_BASE
	blend_mode = BLEND_ADD
	appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_ALPHA | RESET_COLOR


/area
	var
		force_fullbright = 0
		ambient_light = null //rgb(0.025 * 255, 0.025 * 255, 0.025 * 255)

	New()
		..()
		if (force_fullbright)
			src.UpdateOverlays(new /image/fullbright, "fullbright")
		else if (ambient_light)
			var/image/I = new /image/ambient
			I.color = ambient_light
			overlays += I

	proc/update_fullbright()
		if (force_fullbright)
			src.UpdateOverlays(new /image/fullbright, "fullbright")
		else
			src.UpdateOverlays(null, "fullbright")
			for (var/turf/T as anything in src)
				T.RL_Init()

/turf
	luminosity = 1

	var
		fullbright = 0

	New()
		..()
		var/area/A = loc

		#ifdef UNDERWATER_MAP //FUCK THIS SHIT. NO FULLBRIGHT ON THE MINING LEVEL, I DONT CARE.
		if (z == AST_ZLEVEL) return
		#endif

		// if the area's fullbright we'll use a single overlay on the area instead
		#ifdef SIMPLELIGHT_STAR_LIGHT
		if (!istype(src, /turf/space) && !A.force_fullbright && fullbright) // space handles its own lighting via simple lights which already cover the turf itself too
		#else
		if (!A.force_fullbright && fullbright) // except if we don't use the simplelights :) (I'm still pissed)
		#endif
			src.UpdateOverlays(new /image/fullbright, "fullbright")
