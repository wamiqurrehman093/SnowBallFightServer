extends Node2D

var lobbies_info: Dictionary = {}

@rpc("any_peer", "call_local", "reliable")
func create_lobby(lobby_info: Dictionary) -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	var lobby_id: int = lobbies_info.size()
	var lobby_players: Array = []
	lobby_players.append(player_id)
	lobby_info["players"] = lobby_players
	lobby_info["id"] = lobby_id
	lobbies_info[lobby_id] = lobby_info
	print("Created Lobby: ")
	print(lobbies_info[lobby_id])
	_on_lobby_created(player_id, lobby_info)

@rpc("authority", "call_remote", "reliable")
func _on_lobby_created(player_id: int, lobby_info: Dictionary) -> void:
	rpc_id(player_id, "_on_lobby_created", lobby_info)
	refresh_lobbies_info()
	get_node("games").create_a_new_game(lobby_info["players"])

@rpc("any_peer", "call_local", "reliable")
func fetch_lobbies_info() -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	_on_lobbies_info_fetched(player_id)

@rpc("authority", "call_remote", "reliable")
func _on_lobbies_info_fetched(player_id: int) -> void:
	rpc_id(player_id, "_on_lobbies_info_fetched", lobbies_info)

@rpc("authority", "call_remote", "reliable")
func refresh_lobbies_info() -> void:
	rpc("refresh_lobbies_info", lobbies_info)

@rpc("any_peer", "call_local", "reliable")
func join_lobby(lobby_login_info: Dictionary) -> void:
	var lobby_info: Dictionary = {}
	var lobby_id: int = lobby_login_info["id"]
	var player_id: int = multiplayer.get_remote_sender_id()
	if lobbies_info.has(lobby_id):
		lobby_info = lobbies_info[lobby_id]
	else:
		_on_lobby_joining_failed(player_id, lobby_info, "Invalid id.")
		return
	if lobby_info["password"] == lobby_login_info["password"]:
		lobbies_info[lobby_id]["players"].append(player_id)
		_on_successfully_lobby_joined(player_id, lobby_info)
	else:
		_on_lobby_joining_failed(player_id, lobby_info, "Invalid password.")

@rpc("authority", "call_remote", "reliable")
func _on_successfully_lobby_joined(player_id: int, lobby_info: Dictionary) -> void:
	rpc_id(player_id, "_on_successfully_lobby_joined", lobby_info)
	var game_id: int = lobby_info["id"]
	get_node("games").join_game(player_id, game_id)

@rpc("authority", "call_remote", "reliable")
func _on_lobby_joining_failed(player_id: int, lobby_info: Dictionary, reason: String) -> void:
	rpc_id(player_id, "_on_lobby_joining_failed", lobby_info, reason)

func remove_player(player_id: int) -> void:
	for lobby_id in lobbies_info:
		for lobby_player_id in lobbies_info[lobby_id]["players"]:
			if lobby_player_id == player_id:
				remove_player_from_lobby(lobby_id, player_id)
				return

@rpc("authority", "call_remote", "reliable")
func remove_player_from_lobby(lobby_id: int, player_id: int) -> void:
	lobbies_info[lobby_id]["players"].erase(player_id)
	if lobby_is_empty(lobby_id):
		erase_lobby_and_game(lobby_id)
		return
	for lobby_player_id in lobbies_info[lobby_id]["players"]:
		rpc_id(lobby_player_id, "remove_player_from_lobby", lobby_id, player_id)
	$games.remove_player_from_game(lobby_id, player_id)

func lobby_is_empty(lobby_id: int) -> bool:
	return lobbies_info[lobby_id]["players"].size() == 0

func erase_lobby_and_game(id: int) -> void:
	lobbies_info.erase(id)
	$games.games_info.erase(id)

@rpc("any_peer", "call_local", "reliable")
func leave_lobby(lobby_id: int) -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	remove_player_from_lobby(lobby_id, player_id)
