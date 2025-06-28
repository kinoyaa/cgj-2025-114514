class_name Fan extends Node2D

@export var speed: float = 100
#@export var radius: int = 3
@export var direction: Vector2i = Vector2i.RIGHT
var player_inside: bool = false

func _process(_delta: float) -> void:
    var sprite: Sprite2D = $Sprite2D
    if Engine.get_process_frames() % 16 == 0:
        sprite.frame = (sprite.frame + 1) % (sprite.hframes * sprite.vframes)

func _physics_process(delta: float) -> void:
    if player_inside:
        var player: CharacterBody2D = get_tree().current_scene.get_node_or_null("player")
        if player != null:
            player.move_and_collide(direction * speed * delta)

func _on_area_2d_body_entered(body: Node2D) -> void:
    player_inside = true
    var player: CharacterBody2D = body as CharacterBody2D
    if player != null:
        player.state = player.State.FLOATING

func _on_area_2d_body_exited(body: Node2D) -> void:
    player_inside = false
    var player: CharacterBody2D = body as CharacterBody2D
    if player != null:
        player.state = player.State.WALKING
