extends Node2D

signal segment_destroyed

@export var segment_count: int = 10
@export var segment_size: float = 20.0
@export var speed: float = 100.0
@export var change_direction_timer: float = 2.0

var segments: Array[Node2D] = []
var direction: Vector2 = Vector2.RIGHT
var time_until_direction_change: float = 0.0

func _ready():
	_create_segments()

func _create_segments():
	for i in range(segment_count):
		var segment = Node2D.new()
		segment.position = Vector2(i * segment_size, 0)
		
		# Create sprite for segment
		var sprite = Sprite2D.new()
		var texture = ImageTexture.new()
		var image = Image.create(int(segment_size), int(segment_size), false, Image.FORMAT_RGB8)
		image.fill(Color.TRANSPARENT)
		
		# Draw segment as a bright square
		for y in range(int(segment_size)):
			for x in range(int(segment_size)):
				if x > 2 and x < segment_size - 2 and y > 2 and y < segment_size - 2:
					var color = Color(0.8, 0.2, 0.2) if i == 0 else Color(0.6, 0.1, 0.1)
					image.set_pixel(x, y, color)
		
		texture.set_image(image)
		sprite.texture = texture
		segment.add_child(sprite)
		
		# Add collision and area
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(segment_size - 4, segment_size - 4)
		collision.shape = shape
		area.add_child(collision)
		segment.add_child(area)
		
		# Connect signal for collision
		area.body_entered.connect(_on_segment_hit.bind(segment, i))
		
		add_child(segment)
		segments.append(segment)

func _process(delta):
	if not Global.game_active or segments.size() == 0:
		return
	
	# Update direction change timer
	time_until_direction_change -= delta
	if time_until_direction_change <= 0:
		_change_direction()
		time_until_direction_change = change_direction_timer
	
	# Move head
	if segments.size() > 0:
		segments[0].position += direction * speed * delta
		
		# Keep head on screen
		var screen_size = get_viewport().get_visible_rect().size
		var head_pos = segments[0].global_position
		
		if head_pos.x <= segment_size or head_pos.x >= screen_size.x - segment_size:
			direction.x *= -1
		if head_pos.y <= segment_size or head_pos.y >= screen_size.y - segment_size:
			direction.y *= -1
	
	# Update segment positions
	for i in range(1, segments.size()):
		var target_pos = segments[i-1].position - direction.normalized() * segment_size
		segments[i].position = segments[i].position.lerp(target_pos, delta * 10)

func _change_direction():
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var new_dir = directions[randi() % directions.size()]
	if new_dir != -direction:
		direction = new_dir

func _on_segment_hit(segment: Node2D, index: int, body: Node):
	if body.name == "Bullet":
		# Remove segment
		segments.erase(segment)
		segment.queue_free()
		segment_destroyed.emit()
		
		# Create explosion effect
		_create_explosion(segment.global_position)
		
		# If head was destroyed, create new head
		if index == 0 and segments.size() > 0:
			segments[0].modulate = Color(0.8, 0.2, 0.2)  # Make new head red

func _create_explosion(pos: Vector2):
	var particles = CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.amount = 10
	particles.lifetime = 0.5
	particles.direction = Vector2.ZERO
	particles.spread = 360
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 100
	particles.color = Color(0.8, 0.2, 0.2)
	get_tree().current_scene.add_child(particles)
	await get_tree().create_timer(1.0).timeout
	particles.queue_free()