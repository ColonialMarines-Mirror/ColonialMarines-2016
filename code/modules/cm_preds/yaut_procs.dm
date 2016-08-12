//Update the power display thing. This is called in Life()
/mob/living/carbon/human/proc/update_power_display(var/perc)
	if(pred_power_icon)
		switch(perc)
			if(91 to INFINITY)
				pred_power_icon.icon_state = "powerbar100"
			if(81 to 91)
				pred_power_icon.icon_state = "powerbar90"
			if(71 to 81)
				pred_power_icon.icon_state = "powerbar80"
			if(61 to 71)
				pred_power_icon.icon_state = "powerbar70"
			if(51 to 61)
				pred_power_icon.icon_state = "powerbar60"
			if(41 to 51)
				pred_power_icon.icon_state = "powerbar50"
			if(31 to 41)
				pred_power_icon.icon_state = "powerbar40"
			if(21 to 31)
				pred_power_icon.icon_state = "powerbar30"
			if(11 to 21)
				pred_power_icon.icon_state = "powerbar20"
			else
				pred_power_icon.icon_state = "powerbar10"

//Uses the base hud_data, which is human, but just tweaks one lil thing.
/datum/hud_data/yautja
	is_yautja = 1

/mob/living/carbon/human/proc/butcher()
	set category = "Yautja"
	set name = "Butcher"
	set desc = "Butcher a corpse you're standing on for its tasty meats."

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You're not able to do that right now."
		return

	var/list/choices = list()
	for(var/mob/living/carbon/M in view(1,src))
		if(Adjacent(M) && M.stat)
			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/Q = M
				if(Q.species && Q.species.name == "Yautja")
					continue
			choices += M

	if(src in choices)
		choices -= src

	var/mob/living/carbon/T = input(src,"What do you wish to butcher?") as null|anything in choices

	if(!T || !src || !T.stat)
		src << "Nope."
		return

	if(!Adjacent(T))
		src << "You have to be next to your target."
		return

	if(istype(T,/mob/living/carbon/Xenomorph/Larva))
		src << "This tiny worm is not even worth using your tools on."
		return

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "Not right now."
		return

	if(!T) return

	if(T.butchery_progress)
		playsound(loc, 'sound/weapons/pierce.ogg', 50)
		visible_message("<b>[src] goes back to butchering \the [T].</b>","<b>You get back to butchering \the [T].</b>")
	else
		playsound(loc, 'sound/weapons/pierce.ogg', 50)
		visible_message("<b>[src] begins chopping and mutilating \the [T].</b>","<b>You take out your tools and begin your gruesome work on \the [T]. Hold still.</b>")
		T.butchery_progress = 1


	if(T.butchery_progress == 1)
		if(do_after(src,70) && Adjacent(T))
			visible_message("[src] makes careful slices and tears out the viscera in \the [T]'s abdominal cavity.","You carefully vivisect \the [T], ripping out the guts and useless organs. What a stench!")
			T.butchery_progress = 2
			playsound(loc, 'sound/weapons/slash.ogg', 50)
		else
			src << "You pause your butchering for later."

	if(T.butchery_progress == 2)
		if(do_after(src,65) && Adjacent(T))
			visible_message("[src] hacks away at \the [T]'s limbs and slices off strips of dripping meat.","You slice off a few of \the [T]'s limbs, making sure to get the finest cuts.")
			if(istype(T,/mob/living/carbon/Xenomorph) && isturf(T.loc))
				new /obj/item/weapon/reagent_containers/food/snacks/xenomeat(T.loc)
			else if(istype(T,/mob/living/carbon/human) && isturf(T.loc))
				T.apply_damage(100,BRUTE,pick("r_leg","l_leg","r_arm","l_arm"),0,1,1) //Basically just rips off a random limb.
				new /obj/item/weapon/reagent_containers/food/snacks/meat(T.loc)
			T.butchery_progress = 3
			playsound(loc, 'sound/weapons/bladeslice.ogg', 50)
		else
			src << "You pause your butchering for later."

	if(T.butchery_progress == 3)
		if(do_after(src,70) && Adjacent(T))
			visible_message("[src] tears apart \the [T]'s ribcage and begins chopping off bit and pieces.","You rip open \the [T]'s ribcage and start tearing the tastiest bits out.")
			if(istype(T,/mob/living/carbon/Xenomorph) && isturf(T.loc))
				new /obj/item/weapon/reagent_containers/food/snacks/xenomeat(T.loc)
			else if(istype(T,/mob/living/carbon/human) && isturf(T.loc))
				new /obj/item/weapon/reagent_containers/food/snacks/meat(T.loc)
			T.apply_damage(100,BRUTE,"chest",0,0,0) //Does random serious damage, so we make sure they're dead.
			T.butchery_progress = 4
			playsound(loc, 'sound/weapons/wristblades_hit.ogg', 50)
		else
			src << "You pause your butchering for later."

	if(T.butchery_progress == 4)
		if(do_after(src,90) && Adjacent(T))
			if(istype(T,/mob/living/carbon/Xenomorph) && isturf(T.loc))
				visible_message("<b>[src] flenses the last of [T]'s exoskeleton, revealing only bones!</b>.","<b>You flense the last of [T]'s exoskeleton clean off!</b>")
				new /obj/effect/decal/remains/xeno(T.loc)
				new /obj/item/stack/sheet/animalhide/xeno(T.loc)
			else if(istype(T,/mob/living/carbon/human) && isturf(T.loc))
				visible_message("<b>[src] reaches down and rips out \the [T]'s spinal cord and skull!</b>.","<b>You firmly grip the revealed spinal column and rip [T]'s head off!</b>")
				var/mob/living/carbon/human/H = T
				if(H.get_organ("head"))
					H.apply_damage(150,BRUTE,"head",0,1,1)
				else
					new /obj/item/weapon/reagent_containers/food/snacks/meat(T.loc)
				new /obj/item/stack/sheet/animalhide/human(T.loc)
				new /obj/effect/decal/remains/human(T.loc)
			T.butchery_progress = 5 //Won't really matter.
			playsound(loc, 'sound/weapons/slice.ogg', 50)
			src << "\blue You finish butchering!"
			del(T)
		else
			src << "You pause your butchering for later."

	return

/area/yautja
	name = "\improper Yautja Ship"
	icon_state = "teleporter"
	music = "signal"

/mob/living/carbon/human/proc/pred_buy()
	set category = "Yautja"
	set name = "Claim Equipment"
	set desc = "When you're on the Predator ship, claim some gear. You can only do this ONCE."

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You're not able to do that right now."
		return

	if(!isYautja(src))
		src << "How did you get this verb?"
		return

	if(!istype(get_area(src),/area/yautja))
		src << "Not here. Only on the ship."
		return

	if(pred_bought)
		return

	var/sure = alert("An array of powerful weapons are displayed to you. Pick your gear carefully. If you cancel at any point, you will not claim your equipment.","Sure?","Begin the Hunt","No, not now")
	if(sure == "Begin the Hunt")
		var/list/melee = list("The Lumbering Glaive", "The Rending Chain-Whip","The Piercing Hunting Sword","The Cleaving War-Scythe", "The Adaptive Combi-Stick")
		var/list/other = list("The Fleeting Speargun", "The Brutal Plasma Rifle", "The Purifying Smart-Disc","The Enhanced Bracer")//, "The Clever Hologram")

		var/msel = input("Which weapon shall you use on your hunt?:","Melee Weapon") as null|anything in melee
		if(!msel) return //We don't want them to cancel out then get nothing.
		var/mother_0 = input("Which secondary gear shall you take?","Item 1 (of 2)") as null|anything in other
		if(!mother_0) return
		var/mother_1 = input("And the last piece of equipment?:","Item 2 (of 2)") as null|anything in other
		if(!mother_1) return

		if(pred_bought) return //Tried to run it several times in the same loop. That's not happening.

		var/obj/item/clothing/gloves/yautja/Y = src.gloves
		pred_bought = 1		//vvvvv This is the laziest fucking way. Ever. Jesus. I am genuinely sorry (it's okai abbi) //This should be a gauntlet variable.
		switch(msel)
			if("The Lumbering Glaive")
				new /obj/item/weapon/twohanded/glaive(src.loc)
			if("The Rending Chain-Whip")
				new /obj/item/weapon/melee/yautja_chain(src.loc)
			if("The Piercing Hunting Sword")
				new /obj/item/weapon/melee/yautja_sword(src.loc)
			if("The Cleaving War-Scythe")
				new /obj/item/weapon/melee/yautja_scythe(src.loc)
			if("The Adaptive Combi-Stick")
				new /obj/item/weapon/melee/combistick(src.loc)

		switch(mother_0)
			if("The Fleeting Speargun")
				new /obj/item/weapon/gun/launcher/speargun(src.loc)
			if("The Brutal Plasma Rifle")
				new /obj/item/weapon/gun/launcher/plasmarifle(src.loc)
			if("The Purifying Smart-Disc")
				new /obj/item/weapon/grenade/spawnergrenade/smartdisc(src.loc)
			if("The Enhanced Bracer")
				if(istype(Y))
					Y.charge_max += 500
					Y.upgrades++

		switch(mother_1)
			if("The Fleeting Speargun")
				new /obj/item/weapon/gun/launcher/speargun(src.loc)
			if("The Brutal Plasma Rifle")
				new /obj/item/weapon/gun/launcher/plasmarifle(src.loc)
			if("The Purifying Smart-Disc")
				new /obj/item/weapon/grenade/spawnergrenade/smartdisc(src.loc)
			if("The Enhanced Bracer")
				if(istype(Y))
					Y.charge_max += 500
					Y.upgrades++

		if(istype(Y))
			if(Y.upgrades >= 1)
				src << "\green <B>Your [Y.name] hums as it receives a battery and translator upgrade.</b>"
				var/newverb = /obj/item/clothing/gloves/yautja/proc/translate
				Y.verbs |= newverb
			if (Y.upgrades == 2)
				src << "\green <B>Your [Y.name] can now translate to xenomorph hives as well.</b>"
				src << "\green <B>Your [Y.name] has been upgraded to carry a scimitar instead of blades.</b>"
	return