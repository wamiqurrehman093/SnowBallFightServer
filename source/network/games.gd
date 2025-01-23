extends Node2D

var damage: int = 10
var games_info: Dictionary = {}

@rpc("authority", "call_remote", "reliable")
func create_a_new_game(players_ids: Array) -> void:
	var game_info: Dictionary = {}
	var game_id: int = games_info.size()
	game_info["id"] = game_id
	game_info["players"] = {}
	for player_id in players_ids:
		game_info["players"][player_id] = get_new_player_info(player_id)
	game_info["snow_balls"] = []
	games_info[game_id] = game_info
	for player_id in players_ids:
		rpc_id(player_id, "create_a_new_game", game_info)

@rpc("authority", "call_remote", "reliable")
func join_game(new_player_id: int, game_id: int) -> void:
	games_info[game_id]["players"][new_player_id] = get_new_player_info(new_player_id)
	rpc_id(new_player_id, "join_game", games_info[game_id])
	for player_id in games_info[game_id]["players"]:
		if player_id == new_player_id:
			continue
		_on_new_player_joined_game(player_id, new_player_id, games_info[game_id])

@rpc("authority", "call_remote", "reliable")
func _on_new_player_joined_game(player_id: int, new_player_id: int, game_info: Dictionary) -> void:
	rpc_id(player_id, "_on_new_player_joined_game", new_player_id, game_info)

func get_new_player_info(player_id: int) -> Dictionary:
	var player_info: Dictionary = {}
	player_info["id"] = player_id
	player_info["name"] = get_owner().get_node("players").get_player_name(player_id)
	player_info["spawn_position"] = randi() % 40
	player_info["position"] = Vector3.ZERO
	player_info["rotation"] = Vector3.ZERO
	player_info["chest_rotation"] = 0.0
	player_info["animation"] = "idle"
	player_info["health"] = 100
	player_info["kills"] = 0
	player_info["deaths"] = 0
	player_info["score"] = 0
	return player_info

@rpc("any_peer", "call_local", "unreliable")
func update_player_character_data(game_id: int, player_character_data: Dictionary) -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	games_info[game_id]["players"][player_id]["position"] = player_character_data["position"]
	games_info[game_id]["players"][player_id]["rotation"] = player_character_data["rotation"]
	games_info[game_id]["players"][player_id]["animation"] = player_character_data["animation"]
	for game_player_id in games_info[game_id]["players"]:
		if game_player_id == player_id:
			continue
		update_network_player_character_data(game_player_id, player_id, player_character_data)

@rpc("authority", "call_remote", "unreliable")
func update_network_player_character_data(player_id: int, network_player_id: int, network_player_character_data: Dictionary) -> void:
	rpc_id(player_id, "update_network_player_character_data", network_player_id, network_player_character_data)

@rpc("any_peer", "call_local", "reliable")
func local_player_shot(game_id: int, snow_ball_data: Dictionary) -> void:
	var shooter_id: int = multiplayer.get_remote_sender_id()
	for player_id in games_info[game_id]["players"]:
		if player_id == shooter_id:
			continue
		_on_network_player_shot(player_id, shooter_id, snow_ball_data)

@rpc("authority", "call_remote", "reliable")
func _on_network_player_shot(player_id, shooter_id, snow_ball_data) -> void:
	rpc_id(player_id, "_on_network_player_shot", shooter_id, snow_ball_data)

@rpc("any_peer", "call_local", "reliable")
func _on_snow_ball_hit_network_player(game_id: int, network_player_id: int, snow_ball_id: String) -> void:
	var shooter_id: int = multiplayer.get_remote_sender_id()
	games_info[game_id]["players"][network_player_id]["health"] -= damage
	if games_info[game_id]["players"][network_player_id]["health"] <= 0:
		games_info[game_id]["players"][network_player_id]["health"] = 0
		_on_network_player_death(game_id, network_player_id, shooter_id)
		games_info[game_id]["players"][network_player_id]["deaths"] += 1
		games_info[game_id]["players"][shooter_id]["kills"] += 1
	else:
		_on_player_hurt(game_id, network_player_id)
	_on_snow_ball_hit(game_id, snow_ball_id, shooter_id)
	games_info[game_id]["players"][shooter_id]["score"] += 10
	update_scoreboard(game_id)

@rpc("authority", "call_remote", "reliable")
func _on_network_player_death(game_id: int, network_player_id: int, shooter_id) -> void:
	for player_id in games_info[game_id]["players"]:
		if player_id == network_player_id:
			_on_player_death(player_id, shooter_id)
			continue
		rpc_id(player_id, "_on_network_player_death", network_player_id, shooter_id)

@rpc("authority", "call_remote", "reliable")
func _on_player_death(player_id: int, shooter_id: int) -> void:
	rpc_id(player_id, "_on_player_death", shooter_id)

@rpc("authority", "call_remote", "reliable")
func _on_player_hurt(game_id: int, player_id: int) -> void:
	rpc_id(player_id, "_on_player_hurt", games_info[game_id]["players"][player_id]["health"])

@rpc("authority", "call_remote", "reliable")
func _on_snow_ball_hit(game_id: int, snow_ball_id: String, shooter_id: int) -> void:
	for player_id in games_info[game_id]["players"]:
		if player_id == shooter_id:
			continue
		rpc_id(player_id, "_on_snow_ball_hit", snow_ball_id)

@rpc("any_peer", "call_local", "reliable")
func _on_snow_ball_hit_static_body(game_id: int, snow_ball_id: String) -> void:
	var shooter_id: int = multiplayer.get_remote_sender_id()
	_on_snow_ball_hit(game_id, snow_ball_id, shooter_id)

@rpc("any_peer", "call_local", "reliable")
func request_respawn(game_id: int) -> void:
	var dead_player_id: int = multiplayer.get_remote_sender_id()
	games_info[game_id]["players"][dead_player_id]["spawn_position"] = randi() % 40
	games_info[game_id]["players"][dead_player_id]["position"] = Vector3.ZERO
	games_info[game_id]["players"][dead_player_id]["rotation"] = Vector3.ZERO
	games_info[game_id]["players"][dead_player_id]["chest_rotation"] = 0.0
	games_info[game_id]["players"][dead_player_id]["animation"] = "idle"
	games_info[game_id]["players"][dead_player_id]["health"] = 100
	for player_id in games_info[game_id]["players"]:
		if player_id == dead_player_id:
			respawn_local_player(games_info[game_id]["players"][dead_player_id])
			continue
		respawn_network_player(player_id, games_info[game_id]["players"][dead_player_id])

@rpc("authority", "call_remote", "reliable")
func respawn_local_player(player_info: Dictionary) -> void:
	rpc_id(player_info["id"], "respawn_local_player", player_info)

@rpc("authority", "call_remote", "reliable")
func respawn_network_player(player_id: int, network_player_info: Dictionary) -> void:
	rpc_id(player_id, "respawn_network_player", network_player_info)

@rpc("authority", "call_remote", "reliable")
func update_scoreboard(game_id: int) -> void:
	for player_id in games_info[game_id]["players"]:
		rpc_id(player_id, "update_scoreboard", games_info[game_id]["players"])

@rpc("authority", "call_remote", "reliable")
func remove_player_from_game(game_id: int, player_id: int) -> void:
	games_info[game_id]["players"].erase(player_id)
	for game_player_id in games_info[game_id]["players"]:
		rpc_id(game_player_id, "remove_player_from_game", player_id)

@rpc("any_peer", "call_local", "reliable")
func send_message(game_id: int, new_message: String) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	for player_id in games_info[game_id]["players"]:
		if player_id == sender_id:
			continue
		_on_new_message(player_id, new_message)

@rpc("authority", "call_remote", "reliable")
func _on_new_message(player_id: int, new_message: String) -> void:
	rpc_id(player_id, "_on_new_message", new_message)
