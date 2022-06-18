/obj/givemerhinovirus
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"

	attack_hand(mob/living/user)
		user.contract_disease(/datum/ailment/disease/dnaspread, null, null, TRUE)
		. = ..()

///Modernized 2022-6-18
/datum/ailment/disease/dnaspread
	name = "Space Rhinovirus"
	max_stages = 4
	spread = "Airborne"
	cure = "Antibiotics"
	associated_reagent = "liquid dna"
	affected_species = list("Human")
	stage_prob = 10 //I don't wanna waste ages while testing
	//Also important for rhinovirus is strain_data on ailment_data, which is where the bioholders transformed from/to are stored

/datum/ailment/disease/dnaspread/on_infection(mob/living/affected_mob, datum/ailment_data/D)
	..()
	D.strain_data["orig_bioholder"]
	if (!D.strain_data["pzero_bioholder"]) // Oh-hoh-hoo, patient zero~
		D.strain_data["pzero_bioholder"] = affected_mob.bioHolder
		D.state = "Asymptomatic" //We wouldn't turn into ourselves now would we?

/datum/ailment/disease/dnaspread/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	..()
	switch(D.stage)
		if(2, 3) //Pretend to be a cold and give time to spread.
			if(probmult(8))
				affected_mob.emote("sneeze")
			if(probmult(8))
				affected_mob.emote("cough")
			if(probmult(1))
				boutput(affected_mob, "<span class='alert'>Your muscles ache.</span>")
				if(prob(20))
					random_brute_damage(affected_mob, 1)
			if(probmult(1))
				boutput(affected_mob, "<span class='alert'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.take_toxin_damage(2)
		if(4)
			if (probmult(20) && !D.strain_data["pzero_bioholder"])
				affected_mob.ailments -= src
				return
			//Save original dna for when the disease is cured.

			D.strain_data["orig_bioholder"] = affected_mob.bioHolder

			//This is copied from mutagen, I haven't bothered with mutagen-blocked mutantraces
			affected_mob.bioHolder.CopyOther(D.strain_data["pzero_bioholder"])
			affected_mob.real_name = affected_mob.bioHolder.ownerName
			if (affected_mob.bioHolder?.mobAppearance?.mutant_race)
				affected_mob.set_mutantrace(affected_mob.bioHolder.mobAppearance.mutant_race.type)
			affected_mob.UpdateName()

			boutput(affected_mob, "<span class='alert'>You don't feel like yourself..</span>")

			//src.transformed = 1
			D.state = "Dormant" //Just chill out at stage 4
	return

/datum/ailment/disease/dnaspread/on_remove(mob/living/affected_mob, datum/ailment_data/D)
	if (affected_mob)
		if (D.strain_data["orig_bioholder"])
			affected_mob.bioHolder.CopyOther(D.strain_data["orig_bioholder"])
			affected_mob.real_name = affected_mob.bioHolder.ownerName
			if (affected_mob.bioHolder?.mobAppearance?.mutant_race)
				affected_mob.set_mutantrace(affected_mob.bioHolder.mobAppearance.mutant_race.type)
			affected_mob.UpdateName()
			boutput(affected_mob, "<span class='notice'>You feel more like yourself.</span>")
	..()

// This is the old stage_act and stuff, I've kept it in case I fucked up modernising it cuz its a years out of date disease and I can't test it well on my own.
// That said you can absolutely yeet it once rhinovirus looks alright and stable, but it might be nice to get an idea of what it was trying to do.
/*
/datum/ailment/disease/dnaspread/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	..()
	switch(stage)
		if(2, 3) //Pretend to be a cold and give time to spread.
			if(prob(8))
				affected_mob.emote("sneeze")
			if(prob(8))
				affected_mob.emote("cough")
			if(prob(1))
				boutput(affected_mob, "<span class='alert'>Your muscles ache.</span>")
				if(prob(20))
					random_brute_damage(affected_mob, 1)
			if(prob(1))
				boutput(affected_mob, "<span class='alert'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.take_toxin_damage(2)
		if(4)
			if(!src.transformed)
				if ((!strain_data["name"]) || (!strain_data["UI"]) || (!strain_data["SE"]))
					affected_mob.ailments -= src
					return

				//Save original dna for when the disease is cured.
				src.original_dna["name"] = affected_mob.real_name
				src.original_dna["UI"] = affected_mob.dna.uni_identity
				src.original_dna["SE"] = affected_mob.dna.struc_enzymes

				boutput(affected_mob, "<span class='alert'>You don't feel like yourself..</span>")
				affected_mob.dna.uni_identity = strain_data["UI"]
				updateappearance(affected_mob, affected_mob.dna.uni_identity)
				affected_mob.dna.struc_enzymes = strain_data["SE"]
				affected_mob.real_name = strain_data["name"]
				domutcheck(affected_mob)

				src.transformed = 1
				src.carrier = 1 //Just chill out at stage 4

	return

/datum/ailment/disease/dnaspread/disposing()
	if (affected_mob)
		if ((original_dna["name"]) && (original_dna["UI"]) && (original_dna["SE"]))
			affected_mob.dna.uni_identity = original_dna["UI"]
			updateappearance(affected_mob, affected_mob.dna.uni_identity)
			affected_mob.dna.struc_enzymes = original_dna["SE"]
			affected_mob.real_name = original_dna["name"]

			boutput(affected_mob, "<span class='notice'>You feel more like yourself.</span>")
		affected_mob = null
	..()
*/
