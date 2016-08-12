/*
This is a collection of procs related to CM and spawning aliens/predators/survivors. With this centralized system,
you can spawn them at round start in any game mode. You can also add additional categories, and they will be supported
at round start with no conflict. Individual game modes may override these settings to have their own unique
spawns for the various factions. It's also a bit more robust with some added parameters. For example, if xeno_required_num
is 0, you don't need aliens at the start of the game. If aliens are required for win conditions, tick it to 1 or more.

This is a basic outline of how things should function in code.
You can see a working example in the Colonial Marines game mode.

	//Minds are not transferred/made at this point, so we have to check for them so we don't double dip.
	can_start() //This should have the following in order:
		initialize_special_clamps()
		initialize_starting_predator_list()
		if(!initialize_starting_xenomorph_list()) //If we don't have the right amount of xenos, we can't start.
			return
		initialize_starting_survivor_list()

		return 1

	pre_setup()
		//Other things can take place, such as game mode specific setups.

		return 1

	post_setup()
		initialize_post_xenomorph_list()
		initialize_post_survivor_list()
		initialize_post_predator_list()

		return 1

*/

//Additional game mode variables.
/datum/game_mode
	var/datum/mind/aliens[] = list() //These are our basic lists to keep track of who is in the game.
	var/datum/mind/survivors[] = list()
	var/datum/mind/predators[] = list()
	var/datum/mind/hellhounds[] = list() //Hellhound spawning is not supported at round start.
	var/pred_keys[] = list() //People who are playing predators, we can later reference who was a predator during the round.
	var/queen_death_timer = 0 //How long ago did the queen die?
	var/xeno_required_num = 0 //We need at least one. You can turn this off in case we don't care if we spawn or don't spawn xenos.
	var/xeno_starting_num = 0 //To clamp starting xenos.
	var/surv_starting_num = 0 //To clamp starting survivors.
	var/pred_current_num = 0 //How many are there now?
	var/pred_maximum_num = 3 //How many are possible per round? Does not count elders.
	var/pred_round_status = 0 //Is it actually a predator round?
	var/pred_round_chance = 20 //%

//===================================================\\

				//GAME MODE INITIATLIZE\\

//===================================================\\

datum/game_mode/proc/initialize_special_clamps()
	var/ready_players = num_players() // Get all players that have "Ready" selected
	xeno_starting_num = Clamp((ready_players/5), xeno_required_num, 14) //(n, minimum, maximum)
	surv_starting_num = Clamp((ready_players/7), 0, 3) //(n, minimum, maximum)

//===================================================\\

				//PREDATOR INITIATLIZE\\

//===================================================\\

/datum/game_mode/proc/initialize_predator(var/mob/living/carbon/human/new_predator)
	predators += new_predator.mind //Add them to the proper list.
	pred_keys += new_predator.key //Add their key.
	if(!is_alien_whitelisted(new_predator,"Yautja Elder")) pred_current_num++ //If they are not an elder, tick up the max.

/datum/game_mode/proc/initialize_starting_predator_list()
	if(prob(pred_round_chance)) //First we want to determine if it's actually a predator round.
		pred_round_status = 1 //It is now a predator round.
		var/list/datum/mind/possible_predators = get_whitelisted_predators() //Grabs whitelisted preds who are ready at game start.
		var/i = pred_maximum_num //Only three can actually join at round start, the rest can late join. This shouldn't usually happen anyway.
		var/datum/mind/new_pred
		while(i>0)
			if(!possible_predators.len) break
			new_pred = pick(possible_predators)
			if(!istype(new_pred)) continue
			new_pred.assigned_role = "MODE" //So they are not chosen later for another role.
			possible_predators -= new_pred
			predators += new_pred
			i--

/datum/game_mode/proc/initialize_post_predator_list() //TO DO: Possibly clean this using tranfer_to.
	var/temp_pred_list[] = predators //We don't want to use the actual predator list as it will be overriden.
	predators = list() //Empty it. The temporary minds we used aren't going to be used much longer.
	for(var/datum/mind/new_pred in temp_pred_list)
		if(!istype(new_pred)) continue
		transform_predator(new_pred)

/datum/game_mode/proc/force_predator_spawn() //Forces the spawn.
	var/possible_predators[] = get_whitelisted_predators(0) //0 = not care about ready state
	var/i = pred_maximum_num
	var/datum/mind/new_pred
	while(i > 0)
		if(!possible_predators.len) break
		new_pred = pick(possible_predators)
		if(!istype(new_pred)) continue
		transform_predator(new_pred) //It may fail, if it does we just keep going.
		possible_predators -= new_pred //Remove from list.
		i--

/datum/game_mode/proc/get_whitelisted_predators(var/readied = 1)
	// Assemble a list of active players who are whitelisted.
	var/list/players = list()

	for(var/mob/player in player_list)
		if(!player.client) continue //No client. DCed.
		if(isYautja(player)) continue //Already a predator. Might be dead, who knows.
		if(readied) //Ready check for new players.
			var/mob/new_player/new_pred = player
			if(!istype(new_pred)) continue //Have to be a new player here.
			if(!new_pred.ready) continue //Have to be ready.
		else
			if(!istype(player,/mob/dead)) continue //Otherwise we just want to grab the ghosts.

		if(is_alien_whitelisted(player,"Yautja") || is_alien_whitelisted(player,"Yautja Elder"))  //Are they whitelisted?
			if(!player.client.prefs)
				player.client.prefs = new /datum/preferences(player.client) //Somehow they don't have one.

			if(player.client.prefs.be_special & BE_PREDATOR) //Are their prefs turned on?
				if(!player.mind) //They have to have a key if they have a client.
					player.mind_initialize() //Will work on ghosts too, but won't add them to active minds.
				players += player.mind
	return players

/datum/game_mode/proc/transform_predator(var/datum/mind/ghost_mind)
	var/mob/living/carbon/human/new_predator

	if( is_alien_whitelisted(ghost_mind.current,"Yautja Elder") ) new_predator = new (pick(pred_elder_spawn))
	else new_predator = new (pick(pred_spawn))

	new_predator.key = ghost_mind.key //This will initialize their mind.

	if(!new_predator.key) //Something went wrong.
		message_admins("\red <b>Warning</b>: null client in transform_predator, key: [new_predator.key]")
		del(new_predator)
		return

	new_predator.set_species("Yautja")

	if(new_predator.client.prefs) //They should have these set, but it's possible they don't have them.
		new_predator.real_name = new_predator.client.prefs.predator_name
		new_predator.gender = new_predator.client.prefs.predator_gender
	else
		new_predator.client.prefs = new /datum/preferences(new_predator.client) //Let's give them one.
		new_predator.gender = "male"

	if(!new_predator.real_name) //In case they don't have a name set or no prefs, there's a name.
		new_predator.real_name = "Le'pro"
		new_predator << "<b>\red You forgot to set your name in your preferences. Please do so next time.</b>"

	if(is_alien_whitelisted(new_predator,"Yautja Elder"))
		new_predator.real_name = "Elder [new_predator.real_name]"
		new_predator.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/yautja/full(new_predator), slot_wear_suit)
		new_predator.equip_to_slot_or_del(new /obj/item/weapon/twohanded/glaive(new_predator), slot_l_hand)

		spawn(10)
			new_predator << "\red <B> Welcome Elder!</B>"
			new_predator << "You are responsible for the well-being of your pupils. Hunting is secondary in priority."
			new_predator << "That does not mean you can't go out and show the youngsters how it's done."
			new_predator << "<B>You come equipped as an Elder should, with a bonus glaive and heavy armor.</b>"
	else
		spawn(12)
			new_predator << "You are <B>Yautja</b>, a great and noble predator!"
			new_predator << "Your job is to first study your opponents. A hunt cannot commence unless intelligence is gathered."
			new_predator << "Hunt at your discretion, yet be observant rather than violent."
			new_predator << "And above all, listen to your Elders!"

	new_predator.mind.assigned_role = "MODE"
	new_predator.mind.special_role = "Predator"
	new_predator.update_icons()

	if(ticker && ticker.mode) //Let's get them set up.
		var/datum/game_mode/predator_round = ticker.mode
		predator_round.initialize_predator(new_predator)

	if(ghost_mind.current) del(ghost_mind.current) //Get rid of the old body if it still exists.

	return new_predator

//===================================================\\

			//XENOMORPH INITIATLIZE\\

//===================================================\\

//If we are selecting xenomorphs, we NEED them to play the round. This is the expected behavior.
//If this is an optional behavior, just override this proc or make an override here.
/datum/game_mode/proc/initialize_starting_xenomorph_list()
	var/list/datum/mind/possible_aliens = get_players_for_role(BE_ALIEN)
	if(possible_aliens.len < xeno_required_num) //We don't have enough aliens.
		world << "<h2 style=\"color:red\">Not enough players have chosen to be a xenomorph in their character setup. <b>Aborting</b>.</h2>"
		return

	//Minds are not transferred at this point, so we have to clean out those who may be already picked to play.
	for(var/datum/mind/A in possible_aliens)
		if(A.assigned_role == "MODE")
			possible_aliens -= A

	var/i = xeno_starting_num
	var/datum/mind/new_alien
	while(i > 0) //While we can still pick someone for the role.
		if(!possible_aliens.len) break //We ran out of candidates, time to back out. Shouldn't happen though.
		new_alien = pick(possible_aliens)
		if(!new_alien) break  //Looks like we didn't get anyone. Back out.
		new_alien.assigned_role = "MODE"
		new_alien.special_role = "Alien"
		possible_aliens -= new_alien
		aliens += new_alien
		i--

	/*
	Our list is empty. This can happen if we had someone ready as alien and predator, and predators are picked first.
	So they may have been removed from the list, oh well.
	*/
	if(aliens.len < xeno_required_num)
		world << "<h2 style=\"color:red\">Could not find any candidates after initial alien list pass. <b>Aborting</b>.</h2>"
		return

	return 1

/datum/game_mode/proc/initialize_post_xenomorph_list()
	for(var/datum/mind/alien in aliens) //Build and move the xenos.
		transform_xeno(alien)

/datum/game_mode/proc/transform_xeno(var/datum/mind/ghost)
	var/mob/living/carbon/Xenomorph/Larva/new_xeno = new(pick(xeno_spawn))
	new_xeno.amount_grown = 100
	var/mob/original = ghost.current
	ghost.transfer_to(new_xeno)

	new_xeno << "<B>You are now an alien!</B>"
	new_xeno << "<B>Your job is to spread the hive and protect the Queen. You can become the Queen yourself by evolving into a drone.</B>"
	new_xeno << "Talk in Hivemind using <strong>:a</strong> (e.g. ':aMy life for the queen!')"

	new_xeno.update_icons()

	if(original) del(original) //Just to be sure.

//===================================================\\

			//SURVIVOR INITIATLIZE\\

//===================================================\\

//We don't actually need survivors to play, so long as aliens are present.
/datum/game_mode/proc/initialize_starting_survivor_list()
	var/list/datum/mind/possible_survivors = get_players_for_role(BE_SURVIVOR)
	if(possible_survivors.len) //We have some, it looks like.
		for(var/datum/mind/A in possible_survivors) //Strip out any xenos first so we don't double-dip.
			if(A.assigned_role == "MODE")
				possible_survivors -= A

		if(possible_survivors.len) //We may have stripped out all the contendors, so check again.
			var/i = surv_starting_num
			var/datum/mind/new_survivor
			while(i > 0)
				if(!possible_survivors.len) break  //Ran out of candidates! Can't have a null pick(), so just stick with what we have.
				new_survivor = pick(possible_survivors)
				if(!new_survivor) break  //We ran out of survivors!
				new_survivor.assigned_role = "MODE"
				new_survivor.special_role = "Survivor"
				possible_survivors -= new_survivor
				survivors += new_survivor
				i--

/datum/game_mode/proc/initialize_post_survivor_list()
	for(var/datum/mind/survivor in survivors)
		transform_survivor(survivor)
	tell_survivor_story()

//Start the Survivor players. This must go post-setup so we already have a body.
//No need to transfer their mind as they begin as a human.
/datum/game_mode/proc/transform_survivor(var/datum/mind/ghost)
	var/mob/living/carbon/human/new_survivor = ghost.current

	new_survivor.loc = pick(surv_spawn)

	//Damage them for realism purposes
	new_survivor.take_organ_damage(rand(0,15), rand(0,15))

	//Give them proper jobs and stuff here later
	var/random_job = rand(0,10)
	switch(random_job)
		if(0) //assistant
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), slot_shoes)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(new_survivor), slot_back)
		if(1) //civilian in pajamas
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/pj/red(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), slot_shoes)
		if(2) //Scientist
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(new_survivor), slot_wear_suit)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), slot_shoes)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_tox(new_survivor), slot_back)
		if(3) //Doctor
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(new_survivor), slot_wear_suit)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), slot_shoes)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical(new_survivor), slot_belt)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_med(new_survivor), slot_back)
		if(4) //Chef!
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(new_survivor), slot_wear_suit)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), slot_shoes)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(new_survivor), slot_back)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/kitchen/rollingpin(new_survivor), slot_l_hand)
		if(5) //Botanist
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(new_survivor), slot_wear_suit)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), slot_shoes)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/hatchet(new_survivor), slot_belt)
		if(6)//Atmos
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), slot_shoes)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/atmostech(new_survivor), slot_belt)
		if(7) //Chaplain
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chaplain(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), slot_shoes)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/bible/booze(new_survivor), slot_l_hand)
		if(8) //Miner
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/pickaxe(new_survivor), slot_l_hand)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), slot_shoes)
		if(9) //Corporate guy
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(new_survivor), slot_wear_suit)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), slot_shoes)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase(new_survivor), slot_l_hand)
		if(10) //Colonial Marshal
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/CMB(new_survivor), slot_wear_suit)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/CM_uniform(new_survivor), slot_w_uniform)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(new_survivor), slot_shoes)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/cmb(new_survivor), slot_l_hand)

	var/random_gear = rand(0,20) //slot_l_hand and slot_r/l_store are taken above.
	switch(random_gear)
		if(0)
			new_survivor.equip_to_slot_or_del(new /obj/item/device/camera/fluff/oldcamera(new_survivor), slot_r_hand)
		if(1)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/crowbar(new_survivor), slot_r_hand)
		if(2)
			new_survivor.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(new_survivor), slot_r_hand)
		if(3)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/wrench(new_survivor), slot_r_hand)
		if(4)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/surgicaldrill(new_survivor), slot_r_hand)
		if(5)
			new_survivor.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack(new_survivor), slot_r_hand)
		if(6)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/butterfly/switchblade(new_survivor), slot_r_hand)
		if(7)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(new_survivor), slot_r_hand)
		if(8)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice(new_survivor), slot_r_hand)
		if(9)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/dblue(new_survivor), slot_r_hand)
		if(10)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/weldingtool/largetank(new_survivor), slot_r_hand)

	new_survivor.equip_to_slot_or_del(new /obj/item/device/flashlight(new_survivor), slot_r_store)
	new_survivor.equip_to_slot_or_del(new /obj/item/weapon/crowbar(new_survivor), slot_l_store)

	new_survivor.update_icons()

	//Give them some information
	spawn(4)
		new_survivor << "<h2>You are a survivor!</h2>"
		new_survivor << "\blue You are a survivor of the attack on LV-624. You worked or lived in the archaeology colony, and managed to avoid the alien attacks...until now."
		new_survivor << "\blue You are fully aware of the xenomorph threat and are able to use this knowledge as you see fit."
		new_survivor << "\blue You are NOT aware of the marines or their intentions, and lingering around arrival zones will get you survivor-banned."
	return 1

/datum/game_mode/proc/tell_survivor_story()
	var/list/survivor_story = list(
								"You watched as a larva burst from the chest of your friend, {name}. You tried to capture the alien thing, but it escaped through the ventilation.",
								"{name} was attacked by a facehugging alien, which impregnated them with an alien lifeform. {name}'s chest exploded in gore as some creature escaped.",
								"You watched in horror as {name} got the alien lifeform's acid on their skin, melting away their flesh. You can still hear the screaming and panic...",
								"The Head of Security, {name}, made an announcement that the hostile lifeforms killed killed many, and that everyone should hide or stay behind closed doors.",
								"You were there when the alien lifeforms broke into the mess hall and dragged away the others. It was a terrible sight, and you have tried avoid open space since.",
								"It was horrible, as you watched your friend, {name}, get mauled by the horrible monsters. Their screams of agony hunt you in your dreams, leading to insomnia.",
								"You tried your best to hide, and you have seen the creatures travel through the underground tunnels and ventilation shafts. They seem to like the dark.",
								"When you woke up, it felt like you've slept for years. You don't recall much about your old life, except maybe your name. Just what the hell happened to you?",
								"You were on the front lines, trying to fight the aliens. You have seen them hatch more monsters from other humans, and you know better than to fight against death.",
								"You found something, something incredible. But your discovery was cut short when the monsters appeared and began taking people. Damn the beasts!",
								"{name} protected you when the aliens came. You don't know what happened to them, but that was some time ago, and you haven't seen them since. Maybe they are alive..."
								)
	var/list/survivor_multi_story = list(
										"You were separated from your friend, {surv}. You hope they're still alive...",
										"You were having some drinks at the bar with {surv} and {name} when an alien crawled out of the vent and dragged {name} away. You and {surv} split up to find help.",
										"Something spooked you when you were out with {surv}, scavenging. You took off in the opposite direction from them, and you haven't seen them since.",
										"When {name} became infected, you and {surv} argued over what to do with the afflicted. You nearly came to blows before walking away, leaving them behind.",
										"You ran into {surv} when out looking for supplies. After a tense stand off, you agreed to stay out of each other's way. They didn't seem so bad.",
										"A lunatic by the name of {name} was preaching some doomsday to anyone who would listen. {surv} was there too, and you two shared a laugh before the creatures arrived...",
										"Your last decent memory before everything went to hell is of {surv}. They were generally a good person to have around, and they helped you through tough times.",
										"When {name} called for evacuation, {surv} came with you. The aliens appeared soon after and everyone scattered. You hope your friend {surv} is alright.",
										"You remember an explosion... Then everything went dark. You can only recall {name} and {surv}, who were there. Maybe they know what really happened?",
										"The aliens took your mutual friend, {name}. {surv} helped with the rescue. When you got to the alien hive, your friend was dead. You took different passages out.",
										"You were playing basketball with {surv} when the creatures descended. You bolted in opposite directions, and actually managed to lose the monsters, somehow."
										)

	var/current_survivors[] = survivors //These are the current survivors, so we can remove them once we tell a story.
	var/story //The actual story they will get to read.
	var/random_name
	var/datum/mind/survivor
	while(current_survivors.len)
		survivor = pick(current_survivors)
		if(!istype(survivor))
			current_survivors -= survivor
			continue //Not a mind? How did this happen?

		random_name = pick(random_name(FEMALE),random_name(MALE))

		if(current_survivors.len > 1) //If we have another survivor to pick from.
			if(survivor_multi_story.len) //Unlikely.
				var/datum/mind/another_survivor = pick(current_survivors)
				current_survivors -= another_survivor
				if(!istype(another_survivor)) continue//If somehow this thing screwed up, we're going to run another pass.
				story = pick(survivor_multi_story)
				survivor_multi_story -= story
				story = replacetext(story, "{name}", "[random_name]")
				spawn(6)
					var/temp_story = "<b>Your story thus far</b>: " + replacetext(story, "{surv}", "[another_survivor.current.real_name]")
					survivor.current <<  temp_story
					survivor.memory += temp_story //Add it to their memories.
					temp_story = "<b>Your story thus far</b>: " + replacetext(story, "{surv}", "[survivor.current.real_name]")
					another_survivor.current << temp_story
					another_survivor.memory += temp_story
		else
			if(survivor_story.len) //Shouldn't happen, but technically possible.
				story = pick(survivor_story)
				survivor_story -= story
				spawn(6)
					var/temp_story = "<b>Your story thus far</b>: " + replacetext(story, "{name}", "[random_name]")
					survivor.current << temp_story
					survivor.memory += temp_story
		current_survivors -= survivor
	return 1
