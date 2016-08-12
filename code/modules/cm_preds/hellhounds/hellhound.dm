/mob/living/carbon/hellhound
	name = "hellhound"
	desc = "A ferocious monster!"
	voice_name = "hellhound"
	speak_emote = list("roars","grunts","rumbles")
	icon = 'icons/Predator/hellhound.dmi'
	icon_state = "hellhound"
	gender = NEUTER
	update_icon = 0		///no need to call regenerate_icon
	health = 120 //Kinda tough. They heal quickly.
	maxHealth = 120

	var/obj/item/device/radio/headset/yautja/radio
	var/obj/machinery/camera/camera
	var/mob/living/carbon/human/master
	var/speed = -0.6
	var/attack_timer = 0

/mob/living/carbon/hellhound/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	add_language("Sainja") //They can only understand it though.

	if(name == initial(name))
		name = "[name] ([rand(1, 1000)])"
		real_name = name

	radio = new /obj/item/device/radio/headset/yautja(src)
	camera = new /obj/machinery/camera(src)
	camera.network = list("PRED")
	camera.c_tag = src.real_name
	..()

	sight |= SEE_MOBS
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8

	for(var/mob/dead/observer/M in player_list)
		M << "\red <B>A hellhound is now available to play!</b> Please be sure you can follow the rules."
		M << "\red Click 'Join as hellhound' in the ghost panel to become one. First come first serve!"
		M << "\red If you need help during play, click adminhelp and ask."


/mob/living/carbon/hellhound/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 2

	if(stat > 0)
		return //Can't click on shit buster!

	if(attack_timer)
		return

	if(get_dist(src,A) > 1) return

	if(istype(A,/mob/living/carbon/human))
		bite_human(A)
	else if(istype(A,/mob/living/carbon/Xenomorph))
		bite_xeno(A)
	else if(istype(A,/mob/living))
		bite_animal(A)
	else
		A.attack_animal(src)

	attack_timer = 1
	spawn(12)
		attack_timer = 0

/mob/living/carbon/hellhound/proc/bite_human(var/mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(a_intent == "help")
		if(isYautja(H))
			visible_message("[src] licks [H].", "You slobber on [H].")
		else
			visible_message("[src] sniffs at [H].", "You sniff at [H].")
		return
	else if(a_intent == "disarm")
		if(isYautja(H))
			visible_message("[src] shoves [H].", "You shove [H].")
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		else
			if (!(H.paralysis ))
				H.Paralyse(3)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] knocks down [H]!</B>", src), 1)
		return
	else if(a_intent == "grab")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\red [] has grabbed [H] in their jaws!", src), 1)
		src.start_pulling(H)
	else
		if(isYautja(H))
			src << "Your loyalty to the Yautja forbids you from harming them."
			return

		var/dmg = rand(10,25)
		H.apply_damage(dmg,BRUTE,edge = 1) //Does NOT check armor.
		visible_message("\red <B>[src] mauls [H]!</b>","\red <B>You maul [H]!</b>")
		playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
	return

/mob/living/carbon/hellhound/proc/bite_xeno(var/mob/living/carbon/Xenomorph/X)
	if(!istype(X))
		return

	if(a_intent == "help")
		visible_message("[src] growls at [X].", "You growl at [X].")
		return
	else if(a_intent == "disarm")
		if (!(X.paralysis ) && !(X.big_xeno) && !(X.adjust_pixel_x))
			if(prob(40))
				X.Paralyse(4)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				visible_message("\red [src] knocks down [X]!","\red You knock down [X]!")
				return
		visible_message("\red [src] shoves at [X]!","\red You shove at [X]!")
		return
	else if(a_intent == "grab")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		visible_message("\red <B>[src] grabs [X] in their jaws!</B>","\red <B>You grab [X] in your jaws!</b>")
		src.start_pulling(X)
	else
		var/dmg = rand(20,32)
		X.apply_damage(dmg,BRUTE,edge = 1) //Does NOT check armor.
		visible_message("\red <B>[src] mauls [X]!</b>","\red <B>You maul [X]!</b>")
		playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
	return

/mob/living/carbon/hellhound/proc/bite_animal(var/mob/living/H)
	if(!istype(H))
		return

	if(a_intent == "help")
		visible_message("[src] growls at [H].", "You growl at [H].")
		return
	else if(a_intent == "disarm")
		if(istype(H,/mob/living/carbon/hellhound))
			return
		if(istype(H,/mob/living/carbon/monkey))
			if (!(H.paralysis ))
				H.Paralyse(8)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				visible_message("\red [src] knocks down [H]!","\red You knock down [H]!")
				return
		visible_message("\red [src] shoves at [H]!","\red You shove at [H]!")
		return
	else if(a_intent == "grab")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		visible_message("\red <B>[src] grabs [H] in their jaws!</B>","\red <B>You grab [H] in your jaws!</b>")
		src.start_pulling(H)
		return
	else
		if(istype(H,/mob/living/simple_animal/corgi)) //Kek
			src << "Awww.. it's so harmless. Better leave it alone."
			return
		if(isYautja(H))
			return
		var/dmg = rand(3,8)
		H.apply_damage(dmg,BRUTE,edge = 1) //Does NOT check armor.
		visible_message("\red <B>[src] mauls [H]!</b>","\red <B>You maul [H]!</b>")
		playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
	return

/mob/living/carbon/hellhound/attack_paw(mob/M as mob)
	..()

	if (M.a_intent == "help")
		help_shake_act(M)
	else
		if (M.a_intent == "hurt")
			if ((prob(75) && health > 0))
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[M.name] has bit [name]!</B>", 1)
				var/damage = rand(2, 4)
				adjustBruteLoss(damage)
			else
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[M.name] has attempted to bite [name]!</B>", 1)
	return

//punched by a hu-man
/mob/living/carbon/hellhound/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (M.a_intent == "help")
		help_shake_act(M)
	else
		if (M.a_intent == "hurt")
			var/datum/unarmed_attack/attack = M.species.unarmed
			if ((prob(75) && health > 0))
				visible_message("\red <B>[M] [pick(attack.attack_verb)]ed [src]!</B>")

				playsound(loc, "punch", 25, 1, -1)
				var/damage = rand(3, 7)

				adjustBruteLoss(damage)

				M.attack_log += text("\[[time_stamp()]\] <font color='red'>[pick(attack.attack_verb)]ed [src.name] ([src.ckey])</font>")
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [pick(attack.attack_verb)]ed by [M.name] ([M.ckey])</font>")
				msg_admin_attack("[key_name(M)] [pick(attack.attack_verb)]ed [key_name(src)]")

				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("\red <B>[M] tried to [pick(attack.attack_verb)] [src]!</B>")
		else
			if (M.a_intent == "grab")
				if (M == src || anchored)
					return

				var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src )

				M.put_in_active_hand(G)

				G.synch()

				LAssailant = M

				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red [] has grabbed [name] passively!", M), 1)
			else
				if (!( paralysis ))
					if (prob(25))
						Paralyse(2)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has pushed down [name]!</B>", M), 1)
					else
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] shoves at [name]!</B>", M), 1)
	return

/mob/living/carbon/hellhound/attack_animal(mob/living/M as mob)

	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/hellhound/ex_act(severity)
	if(!blinded)
		flick("flash", flash)

	switch(severity)
		if(1.0)
			if (stat != 2)
				adjustBruteLoss(500)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
			return
		if(2.0)
			if (stat != 2)
				adjustBruteLoss(rand(60,200))
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
				Paralyse(12)
			return
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(rand(30,100))
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
				Paralyse(5)
			return

/mob/living/carbon/hellhound/IsAdvancedToolUser()
	return 0

/mob/living/carbon/hellhound/gib()
	..(null,1)

/mob/living/carbon/hellhound/dust()
	..("dust-m")

/mob/living/carbon/hellhound/death(gibbed)
	emote("roar")
	..(gibbed,"lets out a horrible roar as it collapses and stops moving...")

/mob/living/carbon/hellhound/say(var/message)
	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (Muted)."
			return
	message =  trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(stat == 2)
		return say_dead(message)

	if(stat) return //Unconscious? Nope.

	if(copytext(message,1,2) == "*") //Emotes.
		return emote(copytext(message,2))
	var/verb_used = pick("growls","rumbles","howls","grunts")
	if(length(message) >= 2 && radio)
		var/radio_prefix = copytext(message,1,2)
		if(radio_prefix == ":" || radio_prefix == ";") //Hellhounds do not actually get to talk on the radios, only listen.
			message = trim(copytext(message,2))
			if(!message) return
			for(var/mob/living/carbon/hellhound/M in living_mob_list)
				M << "\blue <B>\[RADIO\]</b>: [src.name] [verb_used], '<B>[message]<B>'."
			return

	message = capitalize(trim_left(message))
	if(!message || stat)
		return

	src << "\blue You say, '<B>[message]</b>'."
	for(var/mob/living/carbon/hellhound/H in orange(9))
		H << "\blue [src.name] [verb_used], '[message]'."

	for(var/mob/living/carbon/C in orange(6))
		if(!istype(C,/mob/living/carbon/hellhound))
			C << "\blue [src.name] [verb_used]."
	return

/mob/living/carbon/hellhound/movement_delay()
	if(stat)
		return 0 //Shouldn't really matter, but still calculates if we're being dragged.

	var/tally = 0

	tally = speed

	if (istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	if(istype(loc,/turf/unsimulated/floor/gm/river)) //Rivers slow you down
		tally += 1.3

	if(src.pulling)  //Dragging stuff slows you down a bit.
		tally += 1.5

	return (tally)

/mob/living/carbon/hellhound/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()

	if(stat == DEAD)
		icon_state = "hellhound_dead"
	else
		if(lying)
			if(resting)
				icon_state = "hellhound_sleeping"
			else
				icon_state = "hellhound_ko"
		else
			icon_state = "hellhound"

		if(src.health < 30)
			var/image/bloody = image("icon" = src.icon, "icon_state" = "bloodsmear")
			overlays += bloody