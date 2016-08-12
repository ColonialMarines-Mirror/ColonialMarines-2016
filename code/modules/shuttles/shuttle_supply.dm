




/datum/shuttle/ferry/supply
	var/away_location = 1	//the location to hide at while pretending to be in-transit
	var/late_chance = 10
	var/max_late_time = 300

/datum/shuttle/ferry/supply/short_jump(var/area/origin,var/area/destination)
	if(moving_status != SHUTTLE_IDLE)
		return

	if(isnull(location))
		return

	recharging = 1

	if(!destination)
		destination = get_location_area(!location)
	if(!origin)
		origin = get_location_area(location)

	//it would be cool to play a sound here
	moving_status = SHUTTLE_WARMUP
	spawn(warmup_time*10)
		if (moving_status == SHUTTLE_IDLE)
			return	//someone cancelled the launch

		if (at_station() && forbidden_atoms_check())
			//cancel the launch because of forbidden atoms. announce over supply channel?
			moving_status = SHUTTLE_IDLE
			return

		if (!at_station())	//at centcom
			supply_controller.buy()

		//We pretend it's a long_jump by making the shuttle stay at centcom for the "in-transit" period.
		var/area/away_area = get_location_area(away_location)
		moving_status = SHUTTLE_INTRANSIT

		//If we are at the away_area then we are just pretending to move, otherwise actually do the move
		if (origin != away_area)
			for(var/obj/structure/engine_startup_sound/L in origin)
				playsound(L.loc, 'sound/effects/engine_cargoshuttle_startup.ogg', 100, 0, 10, -100)
			sleep(80)
			move(origin, away_area)

		//wait ETA here.
		arrive_time = world.time + supply_controller.movetime
		while (world.time <= arrive_time)
			sleep(5)

		if (destination != away_area)
			//late
			if (prob(late_chance))
				sleep(rand(0,max_late_time))

			for(var/obj/structure/engine_landing_sound/L in destination)
				playsound(L.loc, 'sound/effects/engine_cargoshuttle_landing.ogg', 100, 0, 10, -100)
			sleep(100)
			move(away_area, destination)

		moving_status = SHUTTLE_IDLE

		if (!at_station())	//at centcom
			supply_controller.sell()

		spawn(0)
			recharging = 0

// returns 1 if the supply shuttle should be prevented from moving because it contains forbidden atoms
/datum/shuttle/ferry/supply/proc/forbidden_atoms_check()
	if (!at_station())
		return 0	//if badmins want to send mobs or a nuke on the supply shuttle from centcom we don't care

	return supply_controller.forbidden_atoms_check(get_location_area())

/datum/shuttle/ferry/supply/proc/at_station()
	return (!location)

//returns 1 if the shuttle is idle and we can still mess with the cargo shopping list
/datum/shuttle/ferry/supply/proc/idle()
	return (moving_status == SHUTTLE_IDLE)

//returns the ETA in minutes
/datum/shuttle/ferry/supply/proc/eta_minutes()
	var/ticksleft = arrive_time - world.time
	return round(ticksleft/600,1)
