extends Area2D

var direction: Vector2 = Vector2.UP
var speed: float = 500.0
var lifetime: float = 2.0

func _ready():
	# Create bullet sprite
	var sprite = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(8, 16, false, Image.FORMAT_RGB8)
	image.fill(Color.TRANSPARENT)
	
	# Draw bullet as a bright rectangle
	for y in range(16):
		for x in range(8):
			if x >= 2 and x <= 5 and y >= 2 and y <= 13:
				image.set_pixel(x, y, Color(0.2, 1.0, 0.2))
	
	texture.set_image(image)
	sprite.texture = texture
	add_child(sprite)
	
	# Add collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(6, 12)
	collision.shape = shape
	add_child(collision)
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta
	
	# Remove if off screen
	var screen_size = get_viewport().get_visible_rect().size
	if position.x < -50 or position.x > screen_size.x + 50 or \
	   position.y < -50 or position.y > screen_size.y + 50:
		queue_free()

func _on_body_entered(body):
	if body.name != "Player":
		queue_free()