/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	var/id = null
	var/height = 0							//the 'height' of the ladder. higher numbers are considered physically higher
	var/obj/structure/ladder/down = null	//the ladder below this one
	var/obj/structure/ladder/up = null		//the ladder above this one
	anchored = 1
	unacidable = 1
	var/is_watching = 0
	var/obj/machinery/camera/cam

/obj/structure/ladder/New()
	spawn(8)
		cam = new /obj/machinery/camera(src)
		cam.network = list("LADDER")
		cam.c_tag = name

		for(var/obj/structure/ladder/L in world)
			if(L.id == id)
				if(L.height == (height - 1))
					down = L
					continue
				if(L.height == (height + 1))
					up = L
					continue

			if(up && down)	//if both our connections are filled
				break
		update_icon()

/obj/structure/ladder/update_icon()
	if(up && down)
		icon_state = "ladder11"

	else if(up)
		icon_state = "ladder10"

	else if(down)
		icon_state = "ladder01"

	else	//wtf make your ladders properly assholes
		icon_state = "ladder00"

/obj/structure/ladder/attack_hand(mob/user as mob)
	if(up && down)
		switch( alert("Go up or down the ladder?", "Ladder", "Up", "Down", "Cancel") )
			if("Up")
				user << "You start climbing up the ladder.."
				if(do_after(user,20))

					user.visible_message("<span class='notice'>[user] climbs up \the [src]!</span>", \
										 "<span class='notice'>You climb up \the [src]!</span>")
					user.loc = get_turf(up)
					up.add_fingerprint(user)
					if(user.pulling && get_dist(src,user.pulling) <= 2)
						user.pulling.loc = up.loc

			if("Down")
				user << "You start climbing down the ladder.."
				if(do_after(user,20))
					user.visible_message("<span class='notice'>[user] climbs down \the [src]!</span>", \
										 "<span class='notice'>You climb down \the [src]!</span>")
					user.loc = get_turf(down)
					if(user.pulling && get_dist(src,user.pulling) <= 2)
						user.pulling.loc = down.loc
					down.add_fingerprint(user)

			if("Cancel")
				return

	else if(up)
		user << "You start climbing up the ladder.."
		if(do_after(user,20))
			user.visible_message("<span class='notice'>[user] climbs up \the [src]!</span>", \
								 "<span class='notice'>You climb up \the [src]!</span>")
			user.loc = get_turf(up)
			if(user.pulling && get_dist(src,user.pulling) <= 2)
				user.pulling.loc = up.loc
			up.add_fingerprint(user)

	else if(down)
		user << "You start climbing down the ladder.."
		if(do_after(user,20))
			user.visible_message("<span class='notice'>[user] climbs down \the [src]!</span>", \
								 "<span class='notice'>You climb down \the [src]!</span>")
			user.loc = get_turf(down)
			if(user.pulling && get_dist(src,user.pulling) <= 2)
				user.pulling.loc = down.loc
			down.add_fingerprint(user)

	add_fingerprint(user)

/obj/structure/ladder/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/ladder/check_eye(var/mob/user as mob)
	//Are we capable of looking?
	if (is_watching)
		if (user.stat || get_dist(user, src) > 1 || user.blinded || user.lying)
			user.unset_machine()
			is_watching = 0

	//Are ladder cameras ok?
	if (is_watching == 1)
		if (!down.cam || !down.cam.can_use()) //camera doesn't work or is gone
			is_watching = 0
			user.unset_machine()
	else if (is_watching == 2)
		if (!up.cam || !up.cam.can_use()) //camera doesn't work or is gone
			is_watching = 0
			user.unset_machine()

	//Where are we looking? 			//THIS NEEDS TO BE OPTIMISED!
	if(is_watching == 1)					//IT RESETS VIEW EVERY TICK EVEN IF NOT NEEDED
		user.reset_view(down.cam)
	else if(is_watching == 2)
		user.reset_view(up.cam)
	else if (!is_watching)
		user.reset_view(null) //Stop the camera if they move away.
	return 1


//Peeking up/down
/obj/structure/ladder/MouseDrop(over_object, src_location, over_location)
	if((over_object == usr && (in_range(src, usr))))
		if(isXenoLarva(usr) || isobserver(usr) || usr.stat)
			usr << "You can't do that"
			return
		if(up && down)
			switch( alert("Look up or down the ladder?", "Ladder", "Up", "Down", "Cancel") )
				if("Up")
					usr.visible_message("<span class='notice'>[usr] looks up \the [src]!</span>", \
										 "<span class='notice'>You look up \the [src]!</span>")
					usr.set_machine(src)
					is_watching = 2
					check_eye(usr)

				if("Down")
					usr.visible_message("<span class='notice'>[usr] looks down \the [src]!</span>", \
										 "<span class='notice'>You look down \the [src]!</span>")
					usr.set_machine(src)
					is_watching = 1
					check_eye(usr)

				if("Cancel")
					return

		else if(up)
			usr.visible_message("<span class='notice'>[usr] looks up \the [src]!</span>", \
								 "<span class='notice'>You look up \the [src]!</span>")
			usr.set_machine(src)
			is_watching = 2
			check_eye(usr)

		else if(down)
			usr.visible_message("<span class='notice'>[usr] looks down \the [src]!</span>", \
								 "<span class='notice'>You look down \the [src]!</span>")
			usr.set_machine(src)
			is_watching = 1
			check_eye(usr)

	add_fingerprint(usr)

/obj/structure/ladder/attack_robot(mob/user as mob)
	return attack_hand(user)

/obj/structure/ladder/ex_act(severity)
	return

//Throwing Shiet
/obj/structure/ladder/attackby(obj/item/weapon/W, mob/user as mob)
	if(W && !isnull(W))
		//Throwing Grenades
		if(istype(W,/obj/item/weapon/grenade))
			if(!W:active)
				if(up && down)
					switch( alert("Throw up or down?", "Ladder", "Up", "Down", "Cancel") )
						if("Up")
							user << "You take the position to throw the [W]."
							if(do_after(user,10))
								user.visible_message("<span class='warning'>[user] throws \the [W] up \the [src]!</span>", \
													 "<span class='warning'>You throw \the [W] up \the [src]</span>")
								user.drop_item()
								W.loc = get_turf(up)
								W.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
								step_away(W,src,rand(1,5))
								W:activate(user)

						if("Down")
							user << "You take the position to throw the [W]."
							if(do_after(user,10))
								user.visible_message("<span class='warning'>[user] throws \the [W] down \the [src]!</span>", \
													 "<span class='warning'>You throw \the [W] down \the [src]</span>")
								user.drop_item()
								W.loc = get_turf(down)
								W.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
								step_away(W,src,rand(1,5))
								W:activate(user)

						if("Cancel")
							return

				else if(up)
					user << "You take the position to throw the [W]."
					if(do_after(user,10))
						user.visible_message("<span class='warning'>[user] throws \the [W] up \the [src]!</span>", \
											 "<span class='warning'>You throw \the [W] up \the [src]</span>")
						user.drop_item()
						W.loc = get_turf(up)
						W.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
						step_away(W,src,rand(1,5))
						W:activate(user)

				else if(down)
					user << "You take the position to throw the [W]."
					if(do_after(user,10))
						user.visible_message("<span class='warning'>[user] throws \the [W] down \the [src]!</span>", \
											 "<span class='warning'>You throw \the [W] down \the [src]</span>")
						user.drop_item()
						W.loc = get_turf(down)
						W.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
						step_away(W,src,rand(1,5))
						W:activate(user)

		//Throwing Flares and flashlights
		else if(istype(W,/obj/item/device/flashlight))
			if(up && down)
				switch( alert("Throw up or down?", "Ladder", "Up", "Down", "Cancel") )
					if("Up")
						user << "You take the position to throw the [W]."
						if(do_after(user,10))
							user.visible_message("<span class='warning'>[user] throws \the [W] up \the [src]!</span>", \
												 "<span class='warning'>You throw \the [W] up \the [src]</span>")
							user.drop_item()
							W.loc = get_turf(up)
							W.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
							step_away(W,src,rand(1,5))
							W.SetLuminosity(0)
							if(W:on && src.loc != user)
								W.SetLuminosity(W:brightness_on)

					if("Down")
						user << "You take the position to throw the [W]."
						if(do_after(user,10))
							user.visible_message("<span class='warning'>[user] throws \the [W] down \the [src]!</span>", \
												 "<span class='warning'>You throw \the [W] down \the [src]</span>")
							user.drop_item()
							W.loc = get_turf(down)
							W.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
							step_away(W,src,rand(1,5))
							W.SetLuminosity(0)
							if(W:on && src.loc != user)
								W.SetLuminosity(W:brightness_on)

					if("Cancel")
						return

			else if(up)
				user << "You take the position to throw the [W]."
				if(do_after(user,10))
					user.visible_message("<span class='warning'>[user] throws \the [W] up \the [src]!</span>", \
										 "<span class='warning'>You throw \the [W] up \the [src]</span>")
					user.drop_item()
					W.loc = get_turf(up)
					W.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
					step_away(W,src,rand(1,5))
					W.SetLuminosity(0)
					if(W:on && src.loc != user)
						W.SetLuminosity(W:brightness_on)

			else if(down)
				user << "You take the position to throw the [W]."
				if(do_after(user,10))
					user.visible_message("<span class='warning'>[user] throws \the [W] down \the [src]!</span>", \
										 "<span class='warning'>You throw \the [W] down \the [src]</span>")
					user.drop_item()
					W.loc = get_turf(down)
					W.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
					step_away(W,src,rand(1,5))
					W.SetLuminosity(0)
					if(W:on && src.loc != user)
						W.SetLuminosity(W:brightness_on)
		else
			return attack_hand(user)
	else
		return attack_hand(user)