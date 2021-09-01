/datum/game_mode/mixed/mixed_rp
	name = "mixed (mild)"
	config_tag = "mixed_rp"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_TRAITOR, ROLE_CHANGELING, ROLE_VAMPIRE, ROLE_WRESTLER, ROLE_ARCFIEND)
	traitor_types = list(ROLE_TRAITOR, ROLE_CHANGELING, ROLE_VAMPIRE, ROLE_SPY_THIEF, ROLE_ARCFIEND)

	has_wizards = 0
	has_werewolves = 0
	has_blobs = 0


/datum/game_mode/mixed/mixed_rp/announce()
	boutput(world, "<B>The current game mode is - Mixed Mild!</B>")
	boutput(world, "<B>Something could happen! Be on your guard!</B>")
