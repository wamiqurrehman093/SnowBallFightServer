extends Node2D

const PORT = 3030
const MAX_CLIENTS = 64

func _ready() -> void:
	create_server()
	connect_signals()

func connect_signals() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	var created_successfully = peer.create_server(PORT, MAX_CLIENTS)
	if created_successfully == OK:
		print("Server created successfully.")
	else:
		print("Couldn't create the server.")
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(id: int) -> void:
	print("Player connected with id " + str(id) + ".")

func _on_peer_disconnected(id: int) -> void:
	print("Player disconnected with id " + str(id) + ".")
	$players.remove_player_name(id)
	$lobbies.remove_player(id)
