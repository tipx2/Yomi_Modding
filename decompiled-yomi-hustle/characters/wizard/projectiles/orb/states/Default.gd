extends ObjectState

export  var LIFETIME = 3000

func _tick():
	if host.frozen:
		return 
	if not host.locked:
		host.travel_towards_creator()
	host.attempt_triggered_attack()
	if current_tick > LIFETIME:
		host.disable()
	if host.push_ticks > 0:
		host.push_ticks -= 1
