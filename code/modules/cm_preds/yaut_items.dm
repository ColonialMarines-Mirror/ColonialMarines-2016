//Items specific to yautja. Other people can use em, they're not restricted or anything.
//They can't, however, activate any of the special functions.

/obj/item/weapon/twohanded/glaive
	name = "war glaive"
	icon = 'icons/Predator/items.dmi'
	icon_state = "glaive"
	item_state = "glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon."
	force = 28
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_wielded = 60
	throwforce = 50
	throw_speed = 3
	edge = 1
	sharp = 1
	flags = FPRINT | CONDUCT | NOSHIELD | TWOHANDED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")
	unacidable = 1
	attack_speed = 12 //Default is 7.

/obj/item/weapon/twohanded/glaive/update_icon()
	item_state = (flags & WIELDED) ? "glaive-wield" : "glaive"

/obj/item/weapon/twohanded/glaive/damaged
	name = "war glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon. This one is ancient and has suffered serious acid damage, making it near-useless."
	force = 18
	force_wielded = 28

/obj/item/clothing/head/helmet/space/yautja
	name = "clan mask"
	desc = "A beautifully designed metallic face mask, both ornate and functional."
	icon = 'icons/Predator/items.dmi'
	icon_state = "pred_mask1"
	item_state = "helmet"
	icon_override = 'icons/Predator/items.dmi'
	armor = list(melee = 80, bullet = 95, laser = 70, energy = 70, bomb = 65, bio = 100, rad = 100)
	anti_hug = 100
	species_restricted = null
	body_parts_covered = HEAD|FACE
	flags_inv = HIDEMASK | HIDEEARS | HIDEEYES | HIDEFACE | COVEREYES | COVERMOUTH | NOPRESSUREDMAGE | BLOCKSHARPOBJ
	var/current_goggles = 0 //0: OFF. 1: NVG. 2: Thermals. 3: Mesons
	unacidable = 1

	New()
		spawn(0)
			var/mask = rand(1,4)
			icon_state = "pred_mask[mask]"

	verb/togglesight()
		set name = "Toggle Mask Visors"
		set desc = "Toggle your mask visor sights. You must only be wearing a type of Yautja visor for this to work."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(M.species && M.species.name != "Yautja")
			M << "You have no idea how to work these things."
			return
		var/obj/item/clothing/gloves/yautja/Y = M.gloves //Doesn't actually reduce power, but needs the bracers anyway.
		if(!Y || !istype(Y))
			M << "You must be wearing your bracers, as they have the power source."
			return
		var/obj/item/G = M.glasses
		if(G)
			if(!istype(G,/obj/item/clothing/glasses/night/yautja) && !istype(G,/obj/item/clothing/glasses/meson/yautja) && !istype(G,/obj/item/clothing/glasses/thermal/yautja))
				M << "You need to remove your glasses first. Why are you even wearing these?"
				return
			M.drop_from_inventory(G) //Get rid of ye existinge gogglors
			del(G)
		switch(current_goggles)
			if(0)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/yautja(M), slot_glasses)
				M << "Low-light vision module: activated."
				if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 40, 1)
			if(1)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/yautja(M), slot_glasses)
				M << "Thermal sight module: activated."
				if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 40, 1)
			if(2)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/meson/yautja(M), slot_glasses)
				M << "Material vision module: activated."
				if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 40, 1)
			if(3)
				M << "You deactivate your visor."
				if(prob(50)) playsound(src,'sound/effects/pred_vision.ogg', 40, 1)
		M.update_inv_glasses()
		current_goggles++
		if(current_goggles > 3) current_goggles = 0

	dropped(var/mob/living/carbon/human/mob) //Clear the gogglors if the helmet is removed. This should work even though they're !canremove.
		..()
		if(!istype(mob)) return //Somehow
		var/obj/item/G = mob.glasses
		if(G)
			if(istype(G,/obj/item/clothing/glasses/night/yautja) || istype(G,/obj/item/clothing/glasses/meson/yautja) || istype(G,/obj/item/clothing/glasses/thermal/yautja))
				mob.drop_from_inventory(G)
				del(G)
				mob.update_inv_glasses()

/obj/item/clothing/suit/armor/yautja
	name = "clan armor"
	desc = "A suit of armor with heavy padding. It looks old, yet functional."
	icon = 'icons/Predator/items.dmi'
	icon_state = "halfarmor"
	item_state = "armor"
	icon_override = 'icons/Predator/items.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 70, bullet = 80, laser = 55, energy = 65, bomb = 65, bio = 50, rad = 50)
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.1
	slowdown = 0
	allowed = list(/obj/item/weapon/harpoon, //Don't ask me why this thing couldn't hold these items before... ~N
			/obj/item/weapon/gun/launcher/speargun,
			/obj/item/weapon/gun/launcher/plasmarifle,
			/obj/item/weapon/melee/yautja_chain,
			/obj/item/weapon/melee/yautja_knife,
			/obj/item/weapon/melee/yautja_sword,
			/obj/item/weapon/melee/yautja_scythe,
			/obj/item/weapon/melee/combistick,
			/obj/item/weapon/twohanded/glaive)
	unacidable = 1

/obj/item/clothing/suit/armor/yautja/full
	name = "heavy clan armor"
	desc = "A suit of armor with heavy padding. It looks old, yet functional."
	icon = 'icons/Predator/items.dmi'
	icon_state = "fullarmor"
	armor = list(melee = 80, bullet = 90, laser = 65, energy = 70, bomb = 70, bio = 70, rad = 50)

	slowdown = 1

/obj/item/weapon/harpoon/yautja
	name = "large harpoon"
	desc = "A huge metal spike, with a hook at the end. It's carved with mysterious alien writing."
	icon = 'icons/Predator/items.dmi'
	icon_state = "spike"
	item_state = "spike1"
	icon_override = 'icons/Predator/items.dmi'
	force = 15
	throwforce = 38
	attack_verb = list("jabbed","stabbed","ripped", "skewered")
	unacidable = 1
	sharp = 1

/obj/item/weapon/wristblades
	name = "wrist blades"
	desc = "A pair of huge, serrated blades extending from a metal gauntlet."
	icon = 'icons/Predator/items.dmi'
	icon_state = "wrist"
	item_state = "wristblade"
	force = 30
	w_class = 5.0
	edge = 1
	sharp = 0
	flags = NOSHIELD
	slot_flags = 0
	hitsound = 'sound/weapons/wristblades_hit.ogg'
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")
	canremove = 0
	attack_speed = 6

	New()
		..()
		if(usr)
			var/obj/item/weapon/wristblades/get_other_hand = usr.get_inactive_hand()
			if(get_other_hand && istype(get_other_hand))
				attack_speed = 4

	dropped(var/mob/living/carbon/human/mob)
		playsound(mob,'sound/weapons/wristblades_off.ogg', 30, 1)
		mob << "The wrist blades retract back into your armband."
		if(mob)
			var/obj/item/weapon/wristblades/get_other_hand = mob.get_inactive_hand()
			if(get_other_hand && istype(get_other_hand))
				get_other_hand.attack_speed = 6

		del(src)

	afterattack(obj/O as obj, mob/user as mob, proximity)
		if(!proximity || !user) return
		if(user)
			var/obj/item/weapon/wristblades/get_other_hand = user.get_inactive_hand()
			if(get_other_hand && istype(get_other_hand))
				attack_speed = 4
			else
				attack_speed = initial(attack_speed)

		if (istype(O, /obj/machinery/door/airlock) && get_dist(src,O) <= 1)
			var/obj/machinery/door/airlock/D = O
			if(!D.density)
				return

			if(D.locked)
				user << "There's some kind of lock keeping it shut."
				return

			if(D.welded)
				user << "It's welded shut. You won't be able to rip it open."
				return

			user << "\blue You jam \the [src] into [O] and strain to rip it open."
			playsound(user,'sound/weapons/wristblades_hit.ogg', 60, 1)
			if(do_after(user,30))
				D.open(1)

/obj/item/weapon/wristblades/scimitar
	name = "wrist scimitar"
	desc = "An enormous serrated blade that extends from the gauntlet."
	icon = 'icons/Predator/items.dmi'
	icon_state = "scim"
	item_state = "scim"
	force = 62
	attack_speed = 18 //slow!
	hitsound = 'sound/weapons/pierce.ogg'


/obj/item/clothing/shoes/yautja
	name = "clan greaves"
	icon = 'icons/Predator/items.dmi'
	icon_state = "y-boots"
	icon_override = 'icons/Predator/items.dmi'
	desc = "A pair of armored, perfectly balanced boots. Perfect for running through the jungle."
//	item_state = "yautja"
	unacidable = 1
	permeability_coefficient = 0.01
	flags_inv = NOSLIPPING
	body_parts_covered = FEET|LEGS
	armor = list(melee = 75, bullet = 85, laser = 60, energy = 50, bomb = 50, bio = 30, rad = 30)
	siemens_coefficient = 0.2
	cold_protection = FEET|LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET|LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null

	New()
		..()
		if(prob(50))
			icon_state = "y-boots2"

/obj/item/clothing/under/chainshirt
	name = "body mesh"
	icon = 'icons/Predator/items.dmi'
	desc = "A set of very fine chainlink in a meshwork for comfort and utility."
	icon_state = "mesh_shirt"
	icon_override = 'icons/Predator/items.dmi'
	item_color = "mesh_shirt"
	item_state = "mesh_shirt"
	has_sensor = 0
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 10, bomb = 10, bio = 10, rad = 10)
	siemens_coefficient = 0.9
	species_restricted = null

/obj/item/clothing/gloves/yautja
	name = "clan bracers"
	desc = "An extremely complex, yet simple-to-operate set of armored bracers worn by the Yautja. It has many functions, activate them to use some."
	icon = 'icons/Predator/items.dmi'
	icon_state = "bracer"
	icon_override = 'icons/Predator/items.dmi'
	item_color = "bracer"
	item_state = "bracera"
	origin_tech = "combat=8;materials=8;magnets=8;programming=8"
	//icon_state = "bracer"//placeholder
	//item_state = "bracer"
	species_restricted = null
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	canremove = 0
	body_parts_covered = HANDS
	armor = list(melee = 80, bullet = 80, laser = 55, energy = 50, bomb = 50, bio = 30, rad = 30)
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	unacidable = 1
	var/charge = 2000
	var/charge_max = 2000
	var/cloaked = 0
	var/selfdestruct = 0
	var/blades_active = 0
	var/caster_active = 0
	var/exploding = 0
	var/inject_timer = 0
	var/cloak_timer = 0
	var/upgrades = 0

	emp_act(severity)
		charge -= (severity * 500)
		if(charge < 0) charge = 0
		if(usr)
			usr.visible_message("\red You hear a hiss and crackle!","\red Your bracers hiss and spark!")
			if(cloaked)
				decloak(usr)

	//This is the main proc for checking AND draining the bracer energy. It must have M passed as an argument.
	//It can take a negative value in amount to restore energy.
	//Also instantly updates the yautja power HUD display.
	proc/drain_power(var/mob/living/carbon/human/M, var/amount)
		if(!M) return 0
		if(charge < amount)
			M << "Your bracers lack the energy. They have only <b>[charge]/[charge_max]</b> remaining and need <B>[amount]</b>."
			return 0
		charge -= amount
		var/perc = (charge / charge_max * 100)
		M.update_power_display(perc)
		return 1

	examine()
		..()
		usr << "They currently have [charge] out of [charge_max] charge."

	//Should put a cool menu here, like ninjas.
	verb/wristblades()
		set name = "Use Wrist Blades"
		set desc = "Extend your wrist blades. They cannot be dropped, but can be retracted."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(!isYautja(M))
			usr << "You have no idea how to work these things."
			return
		var/obj/item/weapon/wristblades/R = M.get_active_hand()
		if(R && istype(R)) //Turn it off.
			M << "You retract your wrist blade."
			playsound(M.loc,'sound/weapons/wristblades_off.ogg', 40, 1)
			blades_active = 0
			M.drop_item(R)
			if(R) del(R) //Just to make sure. The drop should take care of it though.
			return
		else
			if(R)
				M << "Your hand must be free to activate your wrist blade."
				return
			if(!drain_power(usr,50)) return

			var/obj/item/weapon/wristblades/W
			if(upgrades > 1)
				W = new /obj/item/weapon/wristblades/scimitar(M)
			else
				W = new /obj/item/weapon/wristblades(M)

			M.put_in_active_hand(W)
			blades_active = 1
			usr << "You activate your wrist blades."
			playsound(src,'sound/weapons/wristblades_on.ogg', 40, 1)
			usr.update_icons()

		return 1

	verb/cloaker()
		set name = "Toggle Cloaking Device"
		set desc = "Activate your suit's cloaking device. It will malfunction if the suit takes damage or gets excessively wet."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return 0
		if(cloaked) //Turn it off.
			decloak(usr)
		else //Turn it on!
			if(cloak_timer)
				if(prob(50))
					usr << "\blue Your cloaking device is still recharging! Time left: <B>[cloak_timer]</b> ticks."
				return 0
			if(!drain_power(usr,50)) return
			cloaked = 1
			usr << "\blue You are now invisible to normal detection."
			for(var/mob/O in oviewers(usr))
				O.show_message("[usr.name] vanishes into thin air!",1)
			playsound(usr.loc,'sound/effects/cloakon.ogg', 50, 1)
			usr.update_icons()
			spawn(1)
				anim(usr.loc,usr,'icons/mob/mob.dmi',,"cloak",,usr.dir)

		return 1

	proc/decloak(var/mob/user)
		if(!user) return
		user << "Your cloaking device deactivates."
		cloaked = 0
		for(var/mob/O in oviewers(user))
			O.show_message("[user.name] shimmers into existence!",1)
		playsound(user.loc,'sound/effects/cloakoff.ogg', 50, 1)
		user.update_icons()
		cloak_timer = 10
		spawn(1)
			if(user)
				anim(user.loc,user,'icons/mob/mob.dmi',,"uncloak",,user.dir)
		return

	verb/caster()
		set name = "Use Plasma Caster"
		set desc = "Activate your plasma caster. If it is dropped it will retract back into your armor."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return
		var/obj/item/weapon/gun/plasma_caster/R = usr.r_hand
		var/obj/item/weapon/gun/plasma_caster/L = usr.l_hand
		if(!istype(R) && !istype(L))
			caster_active = 0
		if(caster_active) //Turn it off.
			var/found = 0
			if(R && istype(R))
				found = 1
				usr.r_hand = null
				if(R)
					M.remove_from_mob(R)
					cdel(R)
				M.update_inv_r_hand()
			if(L && istype(L))
				found = 1
				usr.l_hand = null
				if(L)
					M.remove_from_mob(L)
					cdel(L)
				M.update_inv_l_hand()
			if(found)
				usr << "You deactivate your plasma caster."
				playsound(src,'sound/weapons/plasmacaster_off.ogg', 40, 1)
				caster_active = 0
			return
		else //Turn it on!
			if(usr.get_active_hand())
				usr << "Your hand must be free to activate your wrist blades."
				return
			if(!drain_power(usr,50)) return

			var/obj/item/weapon/gun/plasma_caster/W = new(usr)
			usr.put_in_active_hand(W)
			W.source = src
			caster_active = 1
			usr << "You activate your plasma caster."
			playsound(src,'sound/weapons/plasmacaster_on.ogg', 40, 1)
			usr.update_icons()
		return 1

	proc/explodey(var/mob/living/carbon/victim)
		playsound(src.loc,'sound/effects/pred_countdown.ogg', 80, 0)
		spawn(rand(65,85))
			var/turf/T = get_turf(victim)
			if(istype(T))
				victim.apply_damage(50,BRUTE,"chest")
				explosion(T, 1, 4, 7, -1) //KABOOM! This should be enough to gib the corpse and injure/kill anyone nearby. //Not enough ~N
				if(victim) victim.gib() //Adding one more safety.

	verb/activate_suicide()
		set name = "Final Countdown (!)"
		set desc = "Activate the explosive device implanted into your bracers. You have failed! Show some honor!"
		set category = "Yautja"

		if(!usr) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(M.stat == DEAD)
			usr << "Little too late for that now!"
			return
		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return

		var/obj/item/weapon/grab/grabbing = M.get_active_hand()
		if(istype(grabbing))
			var/mob/living/carbon/human/comrade = grabbing.affecting
			if(isYautja(comrade) && comrade.stat == DEAD)
				var/obj/item/clothing/gloves/yautja/bracer = comrade.gloves
				if(istype(bracer))
					if(alert("Are you sure you want to send this Yautja into the great hunting grounds?","Explosive Bracers", "Yes", "No") == "Yes")
						bracer.explodey(comrade)
						M.visible_message("\red [M] presses a few buttons on [comrade]'s wrist bracer.","\red You activate the timer. May [comrade]'s final hunt be swift.")
				else
					M << "Your fallen comrade does not have a bracer. <b>Report this to your elder so that it's fixed.</b>"
			else
				M << "You can only activate the bracer of another yautja, and they must have fallen in the Hunt."
			return

		if(!M.stat)
			M << "You can only do this when unconscious, you coward. Go hunting and die gloriously."
			return
		if(exploding)
			if(alert("Are you sure you want to stop the countdown? You coward.","Bracers", "Yes", "No") == "Yes")
				exploding = 0
				M << "Your bracers stop beeping. Wuss."
				return
		if((M.wear_mask && istype(M.wear_mask,/obj/item/clothing/mask/facehugger)) || M.status_flags & XENO_HOST)
			M << "Strange.. something seems to be interfering with your bracer functions.."
			return
		if(alert("Detonate the bracers? Are you sure?","Explosive Bracers", "Yes", "No") == "Yes")
			M << "\red You set the timer. May your journey to the great hunting grounds be swift."
			src.explodey(M)

	verb/injectors()
		set name = "Create Self-Heal Crystal"
		set category = "Yautja"
		set desc = "Create a focus crystal to energize your natural healing processes."

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return

		if(usr.get_active_hand())
			usr << "Your active hand must be empty."
			return 0

		if(inject_timer)
			usr << "You recently activated the healing crystal. Be patient."
			return

		if(!drain_power(usr,1000)) return

		inject_timer = 1
		spawn(1200)
			if(usr && src.loc == usr)
				usr << "\blue Your bracers beep faintly and inform you that a new healing crystal is ready to be created."
				inject_timer = 0

		usr << "\blue You feel a faint hiss and a crystalline injector drops into your hand."
		var/obj/item/weapon/reagent_containers/hypospray/autoinjector/yautja/O = new(usr)
		usr.put_in_active_hand(O)
		playsound(src,'sound/machines/click.ogg', 20, 1)
		return

	verb/call_disk()
		set name = "Call Smart-Disc"
		set category = "Yautja"
		set desc = "Call back your smart-disc, if it's in range. If not you'll have to go retrieve it."

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		if(!isYautja(usr))
			usr << "You have no idea how to work these things."
			return

		if(inject_timer)
			usr << "Your bracers need some time to recuperate first."
			return 0

		if(!drain_power(usr,70)) return
		inject_timer = 1
		spawn(100)
			inject_timer = 0

		for(var/mob/living/simple_animal/hostile/smartdisc/S in range(7))
			usr << "\blue The [S] skips back towards you!"
			new /obj/item/weapon/grenade/spawnergrenade/smartdisc(S.loc)
			del(S)

		for(var/obj/item/weapon/grenade/spawnergrenade/smartdisc/D in range(10))
			D.throw_at(usr,10,1,usr)

/obj/item/clothing/gloves/yautja/proc/translate()
	set name = "Translator"
	set desc = "Emit a message from your bracer to those nearby."
	set category = "Yautja"

	if(!usr || usr.stat) return

	if(!isYautja(usr))
		usr << "You have no idea how to work these things."
		return

	var/msg = input(usr,"Your bracer beeps and waits patiently for you to input your message.","Translator","") as text
	if(!msg || msg == "" || isnull(msg)) return

	msg = sanitize(msg)
	msg = oldreplacetext(msg, "a", "@")
	msg = oldreplacetext(msg, "b", "8")
	msg = oldreplacetext(msg, "c", "�")
	msg = oldreplacetext(msg, "d", ")")
	msg = oldreplacetext(msg, "e", "�")
	msg = oldreplacetext(msg, "h", "#")
	msg = oldreplacetext(msg, "i", "1")
	msg = oldreplacetext(msg, "j", "]")
	msg = oldreplacetext(msg, "k", "X")
	msg = oldreplacetext(msg, "l", "|")
	msg = oldreplacetext(msg, "o", "0")
	msg = oldreplacetext(msg, "p", "�")
	msg = oldreplacetext(msg, "t", "7")
	msg = oldreplacetext(msg, "u", "�")
	msg = oldreplacetext(msg, "x", "%")
	msg = oldreplacetext(msg, "y", "�")
	msg = oldreplacetext(msg, "z", "2")   //Preds now speak in bastardized 1337speak BECAUSE.

	spawn(10)
		if(!drain_power(usr,50)) return //At this point they've upgraded.
		var/mob/Q
		for(Q in hearers(usr))
			if(Q.stat == 1) continue //Unconscious
			if(isXeno(Q) && upgrades != 2) continue
			Q << "A strange voice says, '[msg]'."


/obj/item/weapon/reagent_containers/hypospray/autoinjector/yautja
	name = "unusual crysal"
	desc = "A strange glowing crystal with a spike at one end."
	icon = 'icons/Predator/items.dmi'
	icon_state = "crystal"
	item_state = "crystal"
	icon_override = 'icons/Predator/items.dmi'
	amount_per_transfer_from_this = 35
	volume = 35

	New()
		..()
		spawn(1)
			reagents.add_reagent("quickclot", 3)
			reagents.add_reagent("thwei", 30)
		return

/obj/item/weapon/gun/plasma_caster
	icon = 'icons/Predator/items.dmi'
	icon_state = "plasma"
	item_state = "plasma_wear"
	name = "plasma caster"
	desc = "A powerful, shoulder-mounted energy weapon."
	fire_sound = 'sound/weapons/plasmacaster_fire.ogg'
	default_ammo = "plasma bolt"
	muzzle_flash = null // TO DO, add a decent one.
	canremove = 0
	w_class = 5
	force = 0
	fire_delay = 3
	var/obj/item/clothing/gloves/yautja/source = null
	var/charge_cost = 100 //How much energy is needed to fire.
	var/mode = 0
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list
	accuracy = 10
	flags = FPRINT | CONDUCT | NOBLUDGEON //Can't buldgeon with this.
	gun_features = GUN_UNUSUAL_DESIGN

	New()
		..()
		verbs -= /obj/item/weapon/gun/verb/field_strip
		verbs -= /obj/item/weapon/gun/verb/toggle_burst
		verbs -= /obj/item/weapon/gun/verb/empty_mag
		verbs -= /obj/item/weapon/gun/verb/activate_attachment
		verbs -= /obj/item/weapon/gun/verb/use_unique_action

	Dispose()
		. = ..()
		source = null

	attack_self(mob/living/user as mob)
		switch(mode)
			if(2)
				mode = 0
				charge_cost = 30
				fire_delay = 5
				fire_sound = 'sound/weapons/lasercannonfire.ogg'
				user << "\red \The [src] is now set to fire light plasma bolts."
				ammo = ammo_list["plasma bolt"]
			if(0)
				mode = 1
				charge_cost = 100
				fire_delay = 16
				fire_sound = 'sound/weapons/emitter2.ogg'
				user << "\red \The [src] is now set to fire medium plasma blasts."
				ammo = ammo_list["plasma blast"]
			if(1)
				mode = 2
				charge_cost = 300
				fire_delay = 100
				fire_sound = 'sound/weapons/pulse.ogg'
				user << "\red \The [src] is now set to fire heavy plasma spheres."
				ammo = ammo_list["plasma eradication sphere"]
		return

	dropped(var/mob/living/carbon/human/user)
		..()
		user << "The plasma caster deactivates."
		playsound(user,'sound/weapons/plasmacaster_off.ogg', 40, 1)
		cdel(src)
		return

	AltClick() //No safety on these.
		return

	able_to_fire(var/mob/user as mob)
		if(!source)	return
		if(!isYautja(user))
			user << "\red You have no idea how this thing works!"
			return

		return ..()

	load_into_chamber()
		if(source.drain_power(usr,charge_cost))
			in_chamber = create_bullet(ammo)
			return in_chamber

	reload_into_chamber(var/mob/user/carbon/human/user as mob)
		return 1

	delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
		cdel(projectile_to_fire)
		if(refund)
			source.charge += charge_cost
			var/perc = source.charge / source.charge_max * 100
			var/mob/living/carbon/human/user = usr //Hacky...
			user.update_power_display(perc)
		return 1

	reload()
		return

	unload()
		return

	make_casing()
		return

/obj/item/weapon/gun/launcher/speargun
	name = "heavy speargun"
	desc = "A compact Yautja device in the shape of a crescent. It can rapidly fire damaging spikes and automatically recharges."
	icon = 'icons/Predator/items.dmi'
	icon_state = "predspeargun"
	item_state = "predspeargun"
	muzzle_flash = null // TO DO, add a decent one.
	origin_tech = "combat=7;materials=7"
	unacidable = 1
	fire_sound = 'sound/effects/woodhit.ogg' // TODO: Decent THWOK noise.
	default_ammo = "alloy spike"
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = 3 //Fits in yautja bags.
	fire_delay = 5
	var/spikes = 12
	var/max_spikes = 12
	var/last_regen
	var/image/ammo_overlay = null //overlay image.
	gun_features = GUN_UNUSUAL_DESIGN

	Dispose()
		. = ..()
		ammo_overlay = null
		processing_objects.Remove(src)

	process()
		if(spikes < max_spikes && world.time > last_regen + 100 && prob(70))
			spikes++
			last_regen = world.time
			update_icon()

	New()
		..()
		processing_objects.Add(src)
		last_regen = world.time
		ammo_overlay = new(icon, icon_state = icon_state + "3")
		overlays += ammo_overlay
		verbs -= /obj/item/weapon/gun/verb/field_strip //We don't want these to show since they're useless.
		verbs -= /obj/item/weapon/gun/verb/toggle_burst
		verbs -= /obj/item/weapon/gun/verb/empty_mag
		verbs -= /obj/item/weapon/gun/verb/activate_attachment
		verbs -= /obj/item/weapon/gun/verb/use_unique_action

	AltClick() //No safety on these.
		return

	examine()
		if(isYautja(usr))
			..()
			usr << "It currently has [spikes] / [max_spikes] spikes."
		else usr << "Looks like some kind of...mechanical donut."

	update_icon()
		overlays -= ammo_overlay
		ammo_overlay.icon_state = spikes <=1 ? null : icon_state + "[round(spikes/4, 1)]"
		overlays += ammo_overlay

	able_to_fire(mob/user)
		if(!isYautja(user))
			user << "\red You have no idea how this thing works!"
			return

		return ..()

	load_into_chamber()
		if(spikes > 0)
			in_chamber = create_bullet(ammo)
			spikes--
			return in_chamber

	reload_into_chamber(mob/user)
		update_icon()
		return 1

	delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
		cdel(projectile_to_fire)
		if(refund) spikes++
		return 1

	reload()
		return

	unload()
		return

	make_casing()
		return

/obj/item/weapon/gun/launcher/plasmarifle
	name = "plasma rifle"
	desc = "A long-barreled heavy plasma weapon capable of taking down large game. It has a mounted scope for distant shots and an integrated battery."
	icon = 'icons/Predator/items.dmi'
	icon_state = "spikelauncher"
	item_state = "spikelauncher"
	origin_tech = "combat=8;materials=7;bluespace=6"
	unacidable = 1
	fire_sound = 'sound/weapons/plasma_shot.ogg'
	default_ammo = "plasma rifle bolt"
	muzzle_flash = null // TO DO, add a decent one.
	zoomdevicename = "scope"
	slot_flags = SLOT_BACK
	w_class = 5
	accuracy = 50
	fire_delay = 10
	var/charge_time = 0
	var/last_regen = 0
	var/image/ammo_overlay = null
	gun_features = GUN_UNUSUAL_DESIGN

	Dispose()
		. = ..()
		ammo_overlay = null
		processing_objects.Remove(src)

	process()
		if(charge_time < 100)
			charge_time++
			if(charge_time == 99)
				if(ismob(loc)) loc << "\blue \The [src] hums as it achieves maximum charge."
			update_icon()

	New()
		..()
		processing_objects.Add(src)
		last_regen = world.time
		ammo_overlay = new(icon, icon_state = null)
		verbs -= /obj/item/weapon/gun/verb/field_strip
		verbs -= /obj/item/weapon/gun/verb/toggle_burst
		verbs -= /obj/item/weapon/gun/verb/empty_mag
		verbs -= /obj/item/weapon/gun/verb/activate_attachment

	AltClick()
		return

	examine()
		if(isYautja(usr))
			..()
			usr << "It currently has [charge_time] / 100 charge."
		else usr << "This thing looks like an alien rifle of some kind. Strange."

	update_icon()
		if(last_regen < charge_time + 20 || last_regen > charge_time || charge_time > 95)
			overlays -= ammo_overlay
			ammo_overlay.icon_state = charge_time <=15 ? null : icon_state + "[round(charge_time/33, 1)]"
			overlays += ammo_overlay
			last_regen = charge_time

	unique_action(mob/user)
		if(!isYautja(usr))
			user << "\red You have no idea how this thing works!"
			return
		..()
		zoom()

	able_to_fire(var/mob/user as mob)
		if(!isYautja(user))
			user << "\red You have no idea how this thing works!"
			return

		return ..()

	load_into_chamber()
		if(charge_time < 15) ammo = ammo_list["plasma rifle bolt"]
		else ammo = ammo_list["plasma rifle blast"]
		var/obj/item/projectile/P = create_bullet(ammo)
		P.damage = P.ammo.damage + charge_time
		P.ammo.accuracy = accuracy + charge_time
		P.SetLuminosity(1)
		in_chamber = P
		charge_time = round(charge_time / 2)
		return in_chamber

	reload_into_chamber(var/mob/user as mob)
		update_icon()
		return 1

	delete_bullet(var/obj/item/projectile/projectile_to_fire, refund = 0)
		cdel(projectile_to_fire)
		if(refund) charge_time *= 2
		return 1

	attack_self(mob/user as mob)
		if(!isYautja(user))
			return ..()

		if(charge_time > 10)
			user.visible_message("\blue You feel a strange surge of energy in the area.","\blue You release the rifle battery's energy.")
			var/obj/item/clothing/gloves/yautja/Y = user:gloves
			if(Y && Y.charge < Y.charge_max)
				Y.charge += charge_time * 2
				if(Y.charge > Y.charge_max) Y.charge = Y.charge_max
				charge_time = 0
				user << "Your bracers absorb some of the released energy."
				update_icon()
		else user << "The weapon's not charged enough with ambient energy."

	reload()
		return

	unload()
		return

	make_casing()
		return

//Yes, it's a backpack that goes on the belt. I want the backpack noises. Deal with it (tm)
/obj/item/weapon/storage/backpack/yautja
	name = "hunting pouch"
	desc = "A Yautja hunting pouch worn around the waist, made from a thick tanned hide. Capable of holding various devices and tools and used for the transport of trophies."
	icon = 'icons/Predator/items.dmi'
	icon_state = "beltbag"
	item_state = "beltbag"
	slot_flags = SLOT_BELT
	max_w_class = 3
	storage_slots = 10
	max_combined_w_class = 30

/obj/item/clothing/glasses/night/yautja
	name = "bio-mask nightvision"
	desc = "A vision overlay generated by the Bio-Mask. Used for low-light conditions."
	icon = 'icons/Predator/items.dmi'
	icon_state = "visor_nvg"
	item_state = "securityhud"
	darkness_view = 5 //Not quite as good as regular NVG.
	canremove = 0

	New()
		..()
		overlay = null  //Stops the green overlay.

/obj/item/clothing/glasses/thermal/yautja
	name = "bio-mask thermal"
	desc = "A vision overlay generated by the Bio-Mask. Used to sense the heat of prey."
	icon = 'icons/Predator/items.dmi'
	icon_state = "visor_thermal"
	item_state = "securityhud"
	vision_flags = SEE_MOBS
	invisa_view = 2
	canremove = 0

/obj/item/clothing/glasses/meson/yautja
	name = "bio-mask x-ray"
	desc = "A vision overlay generated by the Bio-Mask. Used to see through objects."
	icon = 'icons/Predator/items.dmi'
	icon_state = "visor_meson"
	item_state = "securityhud"
	vision_flags = SEE_TURFS
	canremove = 0

/obj/item/weapon/legcuffs/yautja
	name = "hunting trap"
	throw_speed = 2
	throw_range = 2
	icon = 'icons/Predator/items.dmi'
	icon_state = "yauttrap0"
	desc = "A bizarre Yautja device used for trapping and killing prey."
	var/armed = 0
	breakouttime = 600 // 1 minute
	layer = 2.8 //Goes under weeds.

	dropped(var/mob/living/carbon/human/mob) //Changes to "camouflaged" icons based on where it was dropped.
		..()
		if(armed)
			if(isturf(mob.loc))
				if(istype(mob.loc,/turf/unsimulated/floor/gm/dirt))
					icon_state = "yauttrapdirt"
				else if (istype(mob.loc,/turf/unsimulated/floor/gm/grass))
					icon_state = "yauttrapgrass"
				else
					icon_state = "yauttrap1"

/obj/item/weapon/legcuffs/yautja/attack_self(mob/user as mob)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "yauttrap[armed]"
		user << "<span class='notice'>\The [src] is now [armed ? "armed" : "disarmed"]</span>"

/obj/item/weapon/legcuffs/yautja/Crossed(AM as mob|obj)
	if(armed)
		if(iscarbon(AM))
			if(isturf(src.loc))
				var/mob/living/carbon/H = AM
				if(isYautja(H))
					H << "You carefully avoid stepping on the trap."
					return
				if(H.m_intent == "run")
					armed = 0
					icon_state = "yauttrap0"
					H.legcuffed = src
					src.loc = H
					H.update_inv_legcuffed()
					playsound(H,'sound/weapons/tablehit1.ogg', 50, 1)
					H << "\icon[src] \red <B>You step on \the [src]!</B>"
					H.Weaken(4)
					if(ishuman(H))
						H.emote("scream")
					feedback_add_details("handcuffs","B")
					for(var/mob/O in viewers(H, null))
						if(O == H)
							continue
						O.show_message("\icon[src] \red <B>[H] steps on \the [src].</B>", 1)
		if(isanimal(AM) && !istype(AM, /mob/living/simple_animal/parrot) && !istype(AM, /mob/living/simple_animal/construct) && !istype(AM, /mob/living/simple_animal/shade) && !istype(AM, /mob/living/simple_animal/hostile/viscerator))
			armed = 0
			var/mob/living/simple_animal/SA = AM
			SA.health -= 20
	..()

//Yautja channel. Has to delete stock encryption key so we don't receive sulaco channel.
/obj/item/device/radio/headset/yautja
	name = "vox caster"
	desc = "A strange Yautja device used for projecting the Yautja's voice to the others in its pack. Similar in function to a standard human radio."
	icon_state = "cargo_headset"
	item_state = "headset"
	frequency = CIV_GEN_FREQ
	unacidable = 1

	New()
		..()
		del(keyslot1)
		keyslot1 = new /obj/item/device/encryptionkey/yautja
		recalculateChannels()

	talk_into(mob/living/M as mob, message, channel, var/verb = "commands", var/datum/language/speaking = "Sainja")
		if(!isYautja(M)) //Nope.
			M << "You try to talk into the headset, but just get a horrible shrieking in your ears."
			return

		for(var/mob/living/carbon/hellhound/H in player_list)
			if(istype(H) && !H.stat)
				H << "\[Radio\]: [M.real_name] [verb], '<B>[message]</b>'."
		..()

	attackby()
		return

/obj/item/device/encryptionkey/yautja
	name = "\improper Yautja encryption key"
	desc = "A complicated encryption device."
	icon_state = "cypherkey"
	channels = list("Yautja" = 1)

//I need to go over these weapons and balance them out later. Right now they're pretty all over the place.
/obj/item/weapon/melee/yautja_chain
	name = "chainwhip"
	desc = "A segmented, lightweight whip made of durable, acid-resistant metal. Not very common among Yautja Hunters, but still a dangerous weapon capable of shredding prey."
	icon_state = "whip"
	item_state = "chain"
	flags = FPRINT | CONDUCT
	slot_flags = SLOT_BELT
	force = 35
	throwforce = 12
	w_class = 3
	unacidable = 1
	sharp = 0
	edge = 0
	attack_verb = list("whipped", "slashed","sliced","diced","shredded")

	attack(mob/target as mob, mob/living/user as mob)
		if(user.zone_sel.selecting == "r_leg" || user.zone_sel.selecting == "l_leg" || user.zone_sel.selecting == "l_foot" || user.zone_sel.selecting == "r_foot")
			if(prob(35) && !target.lying)
				if(isXeno(target))
					if(target:big_xeno) //Can't trip the big ones.
						return ..()
				playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
				user.visible_message("<span class = 'warning'>\The [src] lashes out and [target] goes down!</span>","<span class='warning'><b>You trip [target]!</span></b>")
				target.Weaken(5)
		return ..()

/obj/item/weapon/melee/yautja_knife
	name = "ceremonial dagger"
	desc = "A viciously sharp dagger enscribed with ancient Yautja markings. Smells thickly of blood. Carried by some hunters."
	icon = 'icons/Predator/items.dmi'
	icon_state = "predknife"
	item_state = "knife"
	flags = FPRINT | CONDUCT
	slot_flags = SLOT_POCKET
	sharp = 1
	force = 24
	w_class = 1.0
	throwforce = 28
	throw_speed = 3
	throw_range = 6
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list

	attack_self(mob/living/carbon/human/user as mob)
		if(!isYautja(user)) return
		if(!hasorgans(user)) return

		var/obj/item/weapon/reagent_containers/hypospray/autoinjector/yautja/H = user.get_inactive_hand()
		var/pain_factor = 1 //Preds don't normally feel pain. This is an exception.

		if(!istype(H) || !H.reagents.total_volume)
			H = null

		user << "\red You begin using your knife to rip shrapnel out. Hold still. This will probably hurt."

		if(do_after(user,50))
			if(isnull(H)) //No crystal, just get the shrapnel out of us.
				for(var/datum/organ/external/organ in user.organs)
					for(var/obj/S in organ.implants)
						if(istype(S)) user << "\red You dig shrapnel out of your [organ.name]."
						S.loc = user.loc
						organ.implants -= S
						pain_factor++
						organ.take_damage(rand(2,5), 0, 0)
						organ.status |= ORGAN_BLEEDING

					for(var/datum/organ/internal/I in organ.internal_organs) //Now go in and clean out the internal ones.
						for(var/obj/Q in I)
							Q.loc = user.loc
							I.take_damage(rand(1,2), 0, 0)
							pain_factor += 3 //OWWW! No internal bleeding though.

				if(pain_factor < 1)
					user << "There was nothing to dig out."
				else if(pain_factor >= 1 && pain_factor < 5)
					user << "\red That hurt like hell!!"
				else if(pain_factor >= 5)
					user.emote("roar")

			else //Yay crystal as well. Heals all internal damage.
				user << "\red You crush the <b>healing crystal</b> into a fine powder and sprinkle it on your injuries. Hold still to heal the rest!"
				if(do_after(user,10))
					for(var/datum/organ/external/organ in user.organs)
						for(var/datum/organ/internal/current_organ in organ.internal_organs)
							current_organ.rejuvenate()
							for(var/obj/B in current_organ)
								B.loc = user.loc

					user.drop_from_inventory(H)
					del(H)
					src.attack_self(user) //Do it again! No crystal this time though.
		else
			user << "You were interrupted!"
		return

/obj/item/weapon/melee/yautja_sword
	name = "clan sword"
	desc = "An expertly crafted Yautja blade carried by hunters who wish to fight up close. Razor sharp, and capable of cutting flesh into ribbons. Commonly carried by aggresive and lethal hunters."
	icon = 'icons/Predator/items.dmi'
	icon_state = "clansword"
	item_state = "clansword"
	flags = FPRINT | CONDUCT
	slot_flags = SLOT_BACK
	sharp = 1
	edge = 1
	force = 45 //More damage than other weapons like it. Considering how "strong" this sword is supposed to be, 38 damage was laughable.
	w_class = 4.0
	throwforce = 18
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
		if(!isYautja(user))
			user << "\blue You aren't strong enough to swing the sword properly!"
			force = initial(force) - 24
			if(prob(50))
				user.make_dizzy(80)
		else
			force = initial(force)

		if(isYautja(user) && prob(35) && !target.lying)
			user.visible_message("[user] slashes \the [target] so hard they go flying!")
			playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
			target.Weaken(3)
			step_away(target,user,1)
		return ..()

	pickup(mob/living/user as mob)
		if(!isYautja(user))
			user << "You struggle to pick up the huge, unwieldy sword. It makes you dizzy just trying to hold it."
			user.make_dizzy(50)

/obj/item/weapon/melee/yautja_scythe
	name = "double war scythe"
	desc = "A huge, incredibly sharp double blade used for hunting dangerous prey. This weapon is commonly carried by Yautja who wish to disable and slice apart their foes.."
	icon = 'icons/Predator/items.dmi'
	icon_state = "predscythe"
	item_state = "scythe0"
	flags = FPRINT | CONDUCT
	slot_flags = SLOT_BELT
	sharp = 1
	force = 32
	w_class = 4.0
	throwforce = 24
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	unacidable = 1

	New()
	 icon_state = pick("predscythe","predscythe_alt")

	attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
		if(!isYautja(user))
			if(prob(20))
				user.visible_message("\red <B>The [src] slips out of your hands!</b>")
				user.drop_from_inventory(src)
				return
		..()
		if(ishuman(target)) //Slicey dicey!
			if(prob(14))
				var/datum/organ/external/affecting
				affecting = target:get_organ(ran_zone(user.zone_sel.selecting,60))
				if(!affecting)
					affecting = target:get_organ(ran_zone(user.zone_sel.selecting,90)) //No luck? Try again.
				if(affecting)
					if(affecting.body_part != UPPER_TORSO && affecting.body_part != LOWER_TORSO) //as hilarious as it is
						user.visible_message("\red <B>The limb is sliced clean off!</b>","\red You slice off a limb!")
						affecting.droplimb(1,0,1) //the 0,1 is explode, and amputation. This amputates.
		else //Probably an alien
			if(prob(14))
				..() //Do it again! CRIT!

		return

/obj/item/weapon/grenade/spawnergrenade/hellhound
	name = "hellhound caller"
	spawner_type = /mob/living/carbon/hellhound
	deliveryamt = 1
	desc = "A strange piece of alien technology. It seems to call forth a hellhound."
	icon = 'icons/Predator/items.dmi'
	icon_state = "hellnade"
	force = 25
	throwforce = 55
	w_class = 1.0
	det_time = 30
	var/obj/machinery/camera/current = null
	var/turf/activated_turf = null

	dropped()
		check_eye()
		return ..()

	attack_self(mob/user as mob)
		if(!active)
			if(!isYautja(user))
				user << "What's this thing?"
				return
			user << "<span class='warning'>You activate the hellhound beacon!</span>"
			activate(user)
			add_fingerprint(user)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
		else
			if(!isYautja(user)) return
			activated_turf = get_turf(user)
			display_camera(user)
		return

	activate(mob/user as mob)
		if(active)
			return

		if(user)
			msg_admin_attack("[user.name] ([user.ckey]) primed \a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		icon_state = initial(icon_state) + "_active"
		active = 1
		if(dangerous)
			updateicon()
		spawn(det_time)
			prime()
			return

	prime()
		if(spawner_type && deliveryamt)
			// Make a quick flash
			var/turf/T = get_turf(src)
			if(ispath(spawner_type))
				new spawner_type(T)
//		del(src)
		return

	check_eye(var/mob/user as mob)
		if (user.stat || user.blinded )
			current = null
		if ( !current || get_turf(user) != activated_turf || src.loc != user ) //camera doesn't work, or we moved.
			current = null
		user.reset_view(current)
		return 1

	proc/display_camera(var/mob/user as mob)
		var/list/L = list()
		for(var/mob/living/carbon/hellhound/H in mob_list)
			L += H.real_name
		L["Cancel"] = "Cancel"

		var/choice = input(user,"Which hellhound would you like to observe? (moving will drop the feed)","Camera View") as null|anything in L
		if(!choice || choice == "Cancel" || isnull(choice))
			current = null
			user.reset_view(null)
			user.unset_machine()
			user << "Stopping camera feed."
			return

		for(var/mob/living/carbon/hellhound/Q in mob_list)
			if(Q.real_name == choice)
				current = Q.camera
				break

		if(istype(current))
			user << "Switching feed.."
			user.set_machine(current)
			user.reset_view(current)
		else
			user << "Something went wrong with the camera feed."
		return


//Telescopic baton
/obj/item/weapon/melee/combistick
	name = "combi-stick"
	desc = "A compact yet deadly personal weapon. Can be concealed when folded. Functions well as a throwing weapon or defensive tool. A common sight in Yautja packs due to its versatility."
	icon = 'icons/Predator/items.dmi'
	icon_state = "combilong"
	item_state = "combilong"
	flags = FPRINT | CONDUCT
	slot_flags = SLOT_BACK
	w_class = 4
	force = 32
	throwforce = 70
	unacidable = 1
	sharp = 1
	attack_verb = list("speared", "stabbed", "impaled")
	var/on = 1
	var/timer = 0

	IsShield()
		return on

/obj/item/weapon/melee/combistick/attack_self(mob/user as mob)
	if(timer) return
	on = !on
	if(on)
		user.visible_message("\red With a flick of their wrist, [user] extends their [src].",\
		"\red You extend the combi-stick.",\
		"You hear an ominous click.")
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		slot_flags = initial(slot_flags)
		w_class = 4
		force = 28
		throwforce = initial(throwforce)
		attack_verb = list("speared", "stabbed", "impaled")
		timer = 1
		spawn(10)
			timer = 0

		if(blood_overlay && blood_DNA && (blood_DNA.len >= 1)) //updates blood overlay, if any
			overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

			var/icon/I = new /icon(src.icon, src.icon_state)
			I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
			I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
			blood_overlay = I

			overlays += blood_overlay
	else
		user << "\blue You collapse the combi-stick for storage."
		icon_state = "combi_sheathed"
		item_state = "combishort"
		slot_flags = SLOT_POCKET
		w_class = 1
		force = 0
		throwforce = initial(throwforce) - 50
		attack_verb = list("thwacked", "smacked")
		timer = 1
		spawn(10)
			timer = 0
		overlays.Cut()

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand(0)
		H.update_inv_r_hand()

	playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
	add_fingerprint(user)

	return

/obj/item/device/yautja_teleporter
	name = "relay beacon"
	desc = "A device covered in Yautja writing. It whirrs and beeps every couple of seconds."
	icon = 'icons/Predator/items.dmi'
	icon_state = "teleporter"
	origin_tech = "materials=7;bluespace=7;engineering=7"
	flags = FPRINT | CONDUCT
	w_class = 2
	force = 1
	throwforce = 1
	unacidable = 1
	var/timer = 0

	attack_self(mob/user as mob)
		if(istype(get_area(user),/area/yautja))
			user << "Nothing happens."
			return
		var/mob/living/carbon/human/H = user
		var/sure = alert("Really trigger it?","Sure?","Yes","No")
		if(!isYautja(H))
			user << "The screen angrily flashes three times..."
			playsound(user, 'sound/effects/EMPulse.ogg', 100, 1)
			spawn(30)
				explosion(src.loc,-1,-1,2)
				del(src)
				return 0

		if(sure == "No" || !sure) return
		playsound(src,'sound/ambience/signal.ogg', 100, 1)
		timer = 1
		user.visible_message("[user] starts becoming shimmery and indistinct..")
		if(do_after(user,100))
			var/mob/living/holding = user.pulling
			user.visible_message("\icon[user] [user] disappears!")
			user.loc = pick(pred_spawn)
			timer = 0
			if(holding)
				holding.visible_message("\icon[holding] \The [holding] disappears!")
				holding.loc = pick(pred_spawn)
		else
			spawn(10)
				timer = 0

//Doesn't give heat or anything yet, it's just a light source.
/obj/structure/campfire
	name = "fire"
	desc = "A crackling fire. What is it even burning?"
	icon = 'code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi'
	icon_state = "campfire"
	density = 0
	layer = 2
	anchored = 1
	unacidable = 1

	New()
		..()
		l_color = "#FFFF0C" //Yeller
		SetLuminosity(7)
		spawn(3000)
			if(ticker && istype(ticker.mode,/datum/game_mode/huntergames)) loop_firetick()


	proc/loop_firetick() //Crackly!
		while(src && ticker)
			SetLuminosity(0)
			SetLuminosity(rand(5,6))
			sleep(rand(15,30))


/*
/obj/item/weapon/gun/launcher/netgun
	name = "Yautja Net Gun"
	desc = "A short, wide-barreled weapon that fires weighted, difficult-to-remove nets or a grappling rope to snap back unwary enemies."
	var/max_nets = 1
	var/nets = 1
	var/fire_mode = 1 //1 is net. 0 is retrieve.
	release_force = 5
	icon = 'icons/Predator/items.dmi'
	icon_state = "netgun-empty"
	item_state = "predspeargun"
	fire_sound_text = "a strange noise"
	fire_sound = 'sound/weapons/Laser2.ogg' //Vyoooo!


/obj/item/weapon/gun/launcher/netgun/examine()
	..()
	usr << "It has [nets] [nets == 1 ? "net" : "nets"] remaining."

/obj/item/weapon/gun/launcher/netgun/update_icon()
	if(!nets)
		icon_state = "netgun-empty"
	else
		if(fire_mode)
			icon_state = "netgun-ready"
		else
			icon_state = "netgun-retrieve"

/obj/item/weapon/gun/launcher/netgun/emp_act(severity)
	return

/obj/item/weapon/gun/launcher/spikethrower/special_check(user)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(!isYautja(H))
			user << "\red \The [src] does not respond to you!"
			return 0
	return 1

/obj/item/weapon/gun/launcher/netgun/update_release_force()
	return

/obj/item/weapon/gun/launcher/netgun/load_into_chamber()
	if(in_chamber) return 1
	if(nets < 1) return 0

	in_chamber = new /obj/item/weapon/net(src)
	nets--
	return 1

/obj/item/weapon/gun/launcher/netgun/afterattack(atom/target, mob/user , flag)
	if(isYautja(user))
		if(istype(user.hands,/obj/item/clothing/gloves/yautja))
			var/obj/item/clothing/gloves/yautja/G = user.hands
			if(G.cloaked)
				G.decloak(user)
	return ..()

//The "projectile".
/obj/item/weapon/net
	name = "flying net"
	anchored = 0
	density = 0
	unacidable = 1
	w_class = 1
	layer = MOB_LAYER + 1.1
	desc = "A strange, self-winding net. It constricts automatically around its prey, immobilizing them."
	icon = 'icons/Predator/items.dmi'
	icon_state = "net1"
	flags = TABLEPASS
	pass_flags = PASSTABLE
	var/state = 1 //"bunched up" state
	var/fire_mode = 1//1: net. 0: grab

	attack_hand(user as mob)
		return

	update_icon()
		icon_state = "net[state]"

	proc/wrap_person(var/mob/living/carbon/victim)
		if(isnull(victim) || !istype(victim)) return 0

	throw_at(atom/target, range, speed)
		..()
		spawn(3)
			icon_state = "net2"
			state = 2
			spawn(3)
				icon_state = "net3"
				state = 3

	throw_impact(atom/hit_atom)
		..()
		if(!istype(hit_atom,/mob/living/carbon)) return 0
*/