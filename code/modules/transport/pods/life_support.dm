/////Handles oxygen and heating
/obj/item/shipcomponent/life_support
	name = "Nanotrasen Life-Support System"
	desc = "An advanced life-support system"
	power_used=20
	var/tempreg = 310.0
	system = "Life Support"
	icon_state = "life_support"

//If by handle you mean, the bodytemp life process checks if this thing is active then sure
//Breathing is done via remove_air() on the vehicle itself and most of the credit there goes to the atmos tank that's loaded separately
//Basically, this thing is a glorified flag
