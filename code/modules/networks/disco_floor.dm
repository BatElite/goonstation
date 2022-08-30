//Packet-addressable floortiles that change colour :3

/obj/item/tile/disco

	stack_type = /obj/item/tile/disco //please don't mix these with regular floor tiles thanks



/*	disco tile packet settings cheat sheet

"" - "on", "off"

"color" or "colour" - hex code or rgb triplet

"speed" - two settings: HIGH and LOW

"" - defaults

"propagate" - toggle directions to

disco tiles don't output stuff they're gullible machines
*/

/obj/machinery/disco_tile
	name = "disco tile"
	desc = "Get down on it!"
	tile_colour = "#000000" //gotta additive this stuff //blend_mode = BLEND_ADD
	var/test_shiz = 0
	var/obj/machinery/power/data_terminal/link

	var/
	var/propagation_dirs = list(NORTH,SOUTH,WEST,EAST) //can also do ordinals but you'll have to program them for that

	New()
		link = locate() in get_turf(src.loc)
		link?.master = src

	receive_signal(datum/signal/signal, receive_method, receive_param, connection_id)
		. = ..()
		if

	process(mult)
		if (link)
			if test_shiz =
		if (color != tile_colour)
			color = tile_colour
		. = ..()

