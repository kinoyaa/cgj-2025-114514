class_name Fan extends Node2D

@export var speed: float = 200
@export var radius: int = 3
@export var direction: Vector2i = Vector2i.RIGHT
var player_inside: bool = false

func _process(_delta: float) -> void:
    var sprite: Sprite2D = $Sprite2D
    if Engine.get_process_frames() % 16 == 0:
        sprite.frame = (sprite.frame + 1) % (sprite.hframes * sprite.vframes)

func _physics_process(delta: float) -> void:
    var player: CharacterBody2D = get_tree().current_scene.get_node_or_null("player")
    if player == null:
        return
    var player_coords: Vector2i = player._local_to_tilemap()
    var fan_coords: Vector2i = player.tilemap.local_to_map(global_position)
    var rect: Rect2i
    if direction == Vector2i.LEFT:
        rect = Rect2i(fan_coords.x - 1, fan_coords.y, -radius, 1).abs()
    if direction == Vector2i.RIGHT:
        rect = Rect2i(fan_coords.x + 1, fan_coords.y, radius, 1).abs()
    if direction == Vector2i.UP:
        rect = Rect2i(fan_coords.x, fan_coords.y - 1, 1, -radius).abs()
    if direction == Vector2i.DOWN:
        rect = Rect2i(fan_coords.x, fan_coords.y + 1, 1, radius).abs()
    if rect.has_point(player_coords):
        player.state = player.State.FLOATING
        #player.step_over.connect(func(): 
        #    var t = create_tween()
        #    t.tween_property(
        #        player, "position", player.tilemap.map_to_local(player_coords + direction), 0.15
        #        ).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
        #, CONNECT_ONE_SHOT)
        player.move_and_collide(direction * speed * delta)
    elif player.state == player.State.FLOATING:
        player.state = player.State.WALKING
        player.make_inside()

#func _on_area_2d_body_entered(body: Node2D) -> void:
#    player_inside = true
#    var player: CharacterBody2D = body as CharacterBody2D
#    if player != null:
#        player.state = player.State.FLOATING
#
#func _on_area_2d_body_exited(body: Node2D) -> void:
#    player_inside = false
#    var player: CharacterBody2D = body as CharacterBody2D
#    if player != null:
#        player.state = player.State.WALKING
