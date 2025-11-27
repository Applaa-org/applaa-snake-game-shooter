extends CharacterBody2D

signal shoot_bullet(bullet_scene: PackedScene, position: Vector2, direction: Vector2)

@export var speed: float = 300.0
@export var bullet_scene: PackedScene

var can_shoot: bool = true
var shoot_cooldown: float = 0.3

func _ready():
	# Create triangle shape
	_create_triangle_sprite()

func _create_triangle_sprite():
	var sprite = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(32, 32, false, Image.FORMAT_RGB8)
	image.fill(Color.TRANSPARENT)
	
	# Draw triangle pointing up
	for y in range(32):
		for x in range(32):
			if y >= 20 and y <= 30:
				var width = (y - 20) * 3
				if x >= 16 - width/2 and x <= 16 + width/2:
					image.set_pixel(x, y, Color(0.2, 0.8, 0.2))
	
	texture.set_image(image)
	sprite.texture = texture
	sprite.position = Vector2(0, 0)
	add_child(sprite)
	
	# Add collision
	var collision = CollisionShape2D.new()
	var shape = CapsuleShape2D.new()
	shape.height = 20
	shape.radius = 8
	collision.shape = shape
	add_child(collision)

func _physics_process(delta):
	if not Global.game_active:
		return
	
	# Movement
	var direction = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1
	
	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 2 * delta)
	
	move_and_slide()
	
	# Keep player on screen
	var screen_size = get_viewport().get_visible_rect().size
	position.x = clamp(position.x, 16, screen_size.x - 16)
	position.y = clamp(position.y, 16, screen_size.y - 16)
	
	# Shooting
	if can_shoot and (Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		_shoot()
		can_shoot = false
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true

func _shoot():
	var shoot_direction = Vector2.UP
	shoot_bullet.emit(bullet_scene, global_position, shoot_direction)