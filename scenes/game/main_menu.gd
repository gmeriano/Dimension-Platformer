extends Node

const PLAYER = preload("res://scenes/player/Player.tscn")
@onready var multiplayer_ui = $UI/Multiplayer
@onready var player_1_spawn: Marker2D = $Player1Spawn
@onready var player_2_spawn: Marker2D = $Player2Spawn
@onready var room_code: LineEdit = $UI/Multiplayer/VBoxContainer/RoomCode
@onready var host: Button = $UI/Multiplayer/VBoxContainer/Host
@onready var join: Button = $UI/Multiplayer/VBoxContainer/Join
@onready var local: Button = $UI/Multiplayer/VBoxContainer/Local
@onready var start: Button = $UI/Multiplayer/VBoxContainer/Start
@onready var loading: Label = $UI/Multiplayer/VBoxContainer/Loading
@onready var http_request: HTTPRequest = $HTTPRequest

var peer
var controls1 = preload("res://assets/resources/player1_movement.tres")
var controls2 = preload("res://assets/resources/player2_movement.tres")
var noray_oid = ""
var in_game = false

func _ready():
	set_oid()
	host.disabled = true
	join.disabled = true
	start.disabled = true
	http_request.request_completed.connect(_on_request_completed)
	room_code.text_changed.connect(_on_room_code_text_changed)

func _on_room_code_text_changed(new_text: String) -> void:
	if not in_game:
		join.disabled = new_text.strip_edges() == ""
		host.disabled = new_text.strip_edges() == ""
		start.disabled = new_text.strip_edges() == ""

func _on_request_completed(result, response_code, headers, body):
	if response_code == 201:
		print("Set Room Code")
	elif response_code == 200:
		var json = JSON.new()
		var parse_status = json.parse(body.get_string_from_utf8())

		if parse_status == OK:
			var data = json.data
			if data.size() > 0:
				var oid = data[0]["oid"]
				print("Found Room")
				loading.visible = false
				room_code.editable = false
				disable_buttons()
				in_game = true
				Multiplayer.join(oid)
			else:
				loading.text = "Room code not found."
		else:
			loading.text = "Room code not found."
	else:
		loading.text = "Error"

func set_oid():
	await Multiplayer.noray_connected
	noray_oid = Noray.oid

func disable_buttons():
	host.disabled = true
	join.disabled = true
	local.disabled = true

func _physics_process(delta: float) -> void:
	if GameManager.get_player_1():
		if GameManager.get_player_1().global_position.y - player_1_spawn.global_position.y > 500:
			GameManager.get_player_1().global_position = player_1_spawn.global_position
	if GameManager.get_player_2():
		if GameManager.get_player_2().global_position.y - player_2_spawn.global_position.y > 500:
			GameManager.get_player_2().global_position = player_2_spawn.global_position

func _on_host_pressed():
	disable_buttons()
	Global.IS_ONLINE_MULTIPLAYER = true
	Multiplayer.host()
	in_game = true
	room_code.editable = false
	add_room_code_to_db(room_code.text, noray_oid)
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
			add_player_online(pid)
	)
	
	add_player_online(multiplayer.get_unique_id())

func add_room_code_to_db(room_code: String, oid: String) -> void:
	var url := "https://khavewafdyrnurcujojk.supabase.co/rest/v1/room-codes"
	var headers = [
		"apikey: " + Keys.SUPABASE_API_KEY,
		"Authorization: Bearer " + Keys.SUPABASE_API_KEY,
		"Content-Type: application/json"
	]
	var payload = {
		"room_code": room_code,
		"oid": oid
	}
	var json_body = JSON.stringify(payload)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)

func _on_join_pressed():
	loading.visible = true
	Global.IS_ONLINE_MULTIPLAYER = true
	fetch_oid_from_room_code(room_code.text)

func fetch_oid_from_room_code(room_code: String):
	var url := "https://khavewafdyrnurcujojk.supabase.co/rest/v1/room-codes" \
		+ "?room_code=eq." + room_code \
		+ "&order=created_at.desc" \
		+ "&limit=1"

	var headers = [
		"apikey: " + Keys.SUPABASE_API_KEY,
		"Authorization: Bearer " + Keys.SUPABASE_API_KEY
	]
	var err = $HTTPRequest.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		print("Request error: ", err)

func add_player_online(pid):
	var player = PLAYER.instantiate()
	player.name = str(pid)
	player.set_multiplayer_authority(int(str(pid)))
	
	add_child(player)
	
	set_player_positions_in_menu.rpc(player.name)

@rpc("any_peer", "call_local")
func set_player_positions_in_menu(player_name: String):
	var player = get_node(player_name)
	if player.is_multiplayer_authority():
		if multiplayer.is_server():
			player.global_position = player_1_spawn.global_position
		else:
			player.global_position = player_2_spawn.global_position
		

func _on_local_pressed() -> void:
	disable_buttons()
	start.disabled = false
	in_game = true
	var player1 = PLAYER.instantiate()
	player1.controls = load("res://assets/resources/player1_movement.tres")
	var player2 = PLAYER.instantiate()
	player2.controls = load("res://assets/resources/player2_movement.tres")
	player1.color = Color.GREEN
	player2.color = Color.RED
	player1.global_position = player_1_spawn.global_position
	player2.global_position = player_2_spawn.global_position
	player2.current_dimension = 1
	player2.original_dimension = 1
	GameManager.set_player_1(player1)
	GameManager.set_player_2(player2)
	add_child(player1)
	add_child(player2)

func _on_start_pressed() -> void:
	start_game.rpc()

@rpc("any_peer", "call_local")
func start_game() -> void:
	if GameManager.is_player_1_set() && GameManager.is_player_2_set():
		remove_child(GameManager.get_player_1())
		remove_child(GameManager.get_player_2())
		GameManager.set_players_state_respawn()
		TransitionScreen.transition()
		TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_start_game"))
		TransitionScreen.connect("on_fade_to_normal_finished", Callable(GameManager, "_on_fade_to_normal_finished_can_move_true"))

func _on_transition_finished_start_game():
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_start_game"))
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
