/obj/machinery/computer/bridge_computer
	name = "shuttle bridge console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "atmos_key"
	icon_screen = "shuttle"
	circuit = null

	var/shuttle_tag  // Used to coordinate data in shuttle controller.
	var/hacked = 0   // Has been emagged, no access restrictions.

	var/ui_template = "shuttle_control_console.tmpl"
	var/datum/shuttle/autodock/shuttle

	var/desired_name = ""
	var/shuttle_type = 1 // 1 = faction shuttle, 2 = personal shuttle
	var/locked_to = "" // either the real_name or the faction_uid
	var/ready = 0 // this is set to 1 to confirm construction is completed, and then the dock finalizes it

/obj/machinery/computer/bridge_computer/attack_hand(user as mob)
	if(..(user))
		return
	//src.add_fingerprint(user)	//shouldn't need fingerprints just for looking at it.
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return 1

	ui_interact(user)

/obj/machinery/computer/bridge_computer/proc/get_ui_data()
	if(!shuttle)
		return list()
	var/shuttle_state
	switch(shuttle.moving_status)
		if(SHUTTLE_IDLE) shuttle_state = "idle"
		if(SHUTTLE_WARMUP) shuttle_state = "warmup"
		if(SHUTTLE_INTRANSIT) shuttle_state = "in_transit"

	var/shuttle_status
	switch (shuttle.process_state)
		if(IDLE_STATE)
			if (shuttle.in_use)
				shuttle_status = "Busy."
			else
				shuttle_status = "Standing-by at [shuttle.current_location]."

		if(WAIT_LAUNCH, FORCE_LAUNCH)
			shuttle_status = "Shuttle has recieved command and will depart shortly."
		if(WAIT_ARRIVE)
			shuttle_status = "Proceeding to [shuttle.next_location]."
		if(WAIT_FINISH)
			shuttle_status = "Arriving at destination now."

	return list(
		"name" = shuttle.name,
		"shuttle_status" = shuttle_status,
		"shuttle_state" = shuttle_state,
		"has_docking" = shuttle.active_docking_controller? 1 : 0,
		"docking_status" = shuttle.active_docking_controller? shuttle.active_docking_controller.get_docking_status() : null,
		"docking_override" = shuttle.active_docking_controller? shuttle.active_docking_controller.override_enabled : null,
		"can_launch" = shuttle.can_launch(),
		"can_cancel" = shuttle.can_cancel(),
		"can_force" = shuttle.can_force(),
	)

/obj/machinery/computer/bridge_computer/proc/handle_topic_href(var/datum/shuttle/autodock/shuttle, var/list/href_list)
	if(!istype(shuttle))
		return

	if(href_list["move"])
		if(!shuttle.next_location.is_valid(shuttle))
			to_chat(usr, "<span class='warning'>Destination zone is invalid or obstructed.</span>")
			return
		shuttle.launch(src)
	else if(href_list["force"])
		shuttle.force_launch(src)
	else if(href_list["cancel"])
		shuttle.cancel_launch(src)

/obj/machinery/computer/bridge_computer/proc/get_docks(mob/user)
	var/list/beacons = list()
	for(var/obj/machinery/docking_beacon/beacon in GLOB.all_docking_beacons)
		if(beacon.visible_mode)
			if(beacon.visible_mode == 1)
				beacons[beacon] = 1
			else
				if(beacon.allowed(user))
					beacons[beacon] = 1
				else
					beacons[beacon] = 2
		else
			if(beacon.allowed(user))
				beacons[beacon] = 1
	return beacons

/obj/machinery/computer/bridge_computer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/list/data = get_ui_data()
	if(shuttle)
		data["connected"] = 1
		var/list/beacons = get_docks(user)
		for(var/obj/machinery/docking_beacon/beacon in beacons)
			break
			return 1

	else
		data["desired_name"] = desired_name != "" ? desired_name : "Unset!"
		data["shuttle_type"] = shuttle_type
		data["locked_to"] = locked_to

	ui = GLOB.nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, ui_template, "[shuttle_tag] Shuttle Control", 470, 450)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/bridge_computer/Topic(href, href_list)
	if(..())
		return 1

	handle_topic_href(shuttle_controller.shuttles[shuttle_tag], href_list)

/obj/machinery/computer/bridge_computer/emag_act(var/remaining_charges, var/mob/user)
	if (!hacked)
		req_access = list()
		req_one_access = list()
		hacked = 1
		to_chat(user, "You short out the console's ID checking system. It's now available to everyone!")
		return 1

/obj/machinery/computer/bridge_computer/bullet_act(var/obj/item/projectile/Proj)
	visible_message("\The [Proj] ricochets off \the [src]!")

/obj/machinery/computer/bridge_computer/ex_act()
	return

/obj/machinery/computer/bridge_computer/emp_act()
	return







/obj/machinery/computer/shuttle_control
	name = "shuttle control console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "atmos_key"
	icon_screen = "shuttle"
	circuit = null

	var/shuttle_tag  // Used to coordinate data in shuttle controller.
	var/hacked = 0   // Has been emagged, no access restrictions.

	var/ui_template = "shuttle_control_console.tmpl"


/obj/machinery/computer/shuttle_control/attack_hand(user as mob)
	if(..(user))
		return
	//src.add_fingerprint(user)	//shouldn't need fingerprints just for looking at it.
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return 1

	ui_interact(user)

/obj/machinery/computer/shuttle_control/proc/get_ui_data(var/datum/shuttle/autodock/shuttle)
	var/shuttle_state
	switch(shuttle.moving_status)
		if(SHUTTLE_IDLE) shuttle_state = "idle"
		if(SHUTTLE_WARMUP) shuttle_state = "warmup"
		if(SHUTTLE_INTRANSIT) shuttle_state = "in_transit"

	var/shuttle_status
	switch (shuttle.process_state)
		if(IDLE_STATE)
			if (shuttle.in_use)
				shuttle_status = "Busy."
			else
				shuttle_status = "Standing-by at [shuttle.current_location]."

		if(WAIT_LAUNCH, FORCE_LAUNCH)
			shuttle_status = "Shuttle has recieved command and will depart shortly."
		if(WAIT_ARRIVE)
			shuttle_status = "Proceeding to [shuttle.next_location]."
		if(WAIT_FINISH)
			shuttle_status = "Arriving at destination now."

	return list(
		"shuttle_status" = shuttle_status,
		"shuttle_state" = shuttle_state,
		"has_docking" = shuttle.active_docking_controller? 1 : 0,
		"docking_status" = shuttle.active_docking_controller? shuttle.active_docking_controller.get_docking_status() : null,
		"docking_override" = shuttle.active_docking_controller? shuttle.active_docking_controller.override_enabled : null,
		"can_launch" = shuttle.can_launch(),
		"can_cancel" = shuttle.can_cancel(),
		"can_force" = shuttle.can_force(),
	)

/obj/machinery/computer/shuttle_control/proc/handle_topic_href(var/datum/shuttle/autodock/shuttle, var/list/href_list)
	if(!istype(shuttle))
		return

	if(href_list["move"])
		if(!shuttle.next_location.is_valid(shuttle))
			to_chat(usr, "<span class='warning'>Destination zone is invalid or obstructed.</span>")
			return
		shuttle.launch(src)
	else if(href_list["force"])
		shuttle.force_launch(src)
	else if(href_list["cancel"])
		shuttle.cancel_launch(src)

/obj/machinery/computer/shuttle_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/datum/shuttle/autodock/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		to_chat(usr,"<span class='warning'>Unable to establish link with the shuttle.</span>")
		return

	var/list/data = get_ui_data(shuttle)

	ui = GLOB.nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, ui_template, "[shuttle_tag] Shuttle Control", 470, 450)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/shuttle_control/Topic(href, href_list)
	if(..())
		return 1

	handle_topic_href(shuttle_controller.shuttles[shuttle_tag], href_list)

/obj/machinery/computer/shuttle_control/emag_act(var/remaining_charges, var/mob/user)
	if (!hacked)
		req_access = list()
		req_one_access = list()
		hacked = 1
		to_chat(user, "You short out the console's ID checking system. It's now available to everyone!")
		return 1

/obj/machinery/computer/shuttle_control/bullet_act(var/obj/item/projectile/Proj)
	visible_message("\The [Proj] ricochets off \the [src]!")

/obj/machinery/computer/shuttle_control/ex_act()
	return

/obj/machinery/computer/shuttle_control/emp_act()
	return
