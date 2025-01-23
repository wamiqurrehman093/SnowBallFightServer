extends Node2D

var players_names: Dictionary = {}

@rpc("any_peer", "call_local", "reliable")
func save_player_name(player_name: String) -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	players_names[player_id] = player_name
	print("Saved player name: " + player_name + " for player id: " + str(player_id))

func get_player_name(player_id: int) -> String:
	return players_names[player_id]

func remove_player_name(player_id: int) -> void:
	players_names.erase(player_id)
