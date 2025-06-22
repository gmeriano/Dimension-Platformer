class_name PlayerState extends State

var player: Player
var state_machine: StateMachine

func _init(init_player: Player) -> void:
	player = init_player
	state_machine = init_player.state_machine
