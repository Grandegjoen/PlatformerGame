class_name Player
extends KinematicBody2D

#Player Movement 
var UP = Vector2(0, -1)
const WALLGRAVITY = 25
const GRAVITY = 30
const MAXFALLSPEED = 500
const MAXFALLSPEEDWALL = 250
const MAXSPEED = 300
const JUMPFORCE = 640
const WALLJUMPFORCE = 450
const ACCELERATION = 30
onready var animation_player = $AnimationPlayer

#Time Warp variables
const time_fragment = preload("res://Scenes/Objects/TimeFragment.tscn")
var available_time_warp = false
var active_time_warp = false
var entered_portal = false
var portal_timer_timeout = true
var time_frag # Position of time fragment that player can warp to

#Lightning variables
var is_dashing : bool = false # Check if dashing
var available_lightning = false # Check if dash is available 
var dash_direction : Vector2 # Direction of the dash
var lightning_speed = 1000
var dash_length = .2
onready var dash_timer = $DashTimer

#Gravity Flip variables
var inversed_gravity = 1
var available_gravity_flip = false

#Player Movement variables
var double_jump = false
var motion = Vector2()
var touching_ground = false
var coyote_available = false
var jump_btn_pressed = false
var jump_just_pressed = false
var can_jump_right_wall = true
var can_jump_left_wall = true

#Other variables
var bonus_picked_up = false
var bonus_level: int

func _ready():
	dash_timer.connect("timeout", self, "dash_timer_timeout")

var count = 0

func _physics_process(delta):
	handle_dash(delta)
	if Input.is_action_just_pressed("ui_down"):
		game_state.save_game()

	if next_to_wall():
		motion.y += WALLGRAVITY * inversed_gravity
	else:
		motion.y += GRAVITY * inversed_gravity

	if motion.y  * inversed_gravity > MAXFALLSPEEDWALL and next_to_wall():
		motion.y = MAXFALLSPEEDWALL * inversed_gravity
	elif motion.y * inversed_gravity > MAXFALLSPEED:
		motion.y = MAXFALLSPEED * inversed_gravity

		
	
#	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	if Input.is_action_just_pressed("Time Warp") and available_time_warp:
		time_warp()
		
	if Input.is_action_just_pressed("LightningPower") and available_lightning:
		lightning_jump()
		
	if Input.is_action_just_pressed("GravityFlip") and available_gravity_flip:
		inverse_gravity()
	
	if Input.is_action_pressed("ui_right"):
		if motion.x > MAXSPEED:
			motion.x = lerp(motion.x, 0, 0.02)
		else:
			motion.x += ACCELERATION
		animation_handler("Run")
		$PlayerSprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		if motion.x < -MAXSPEED:
			motion.x = lerp(motion.x, 0, 0.02)
		else:
			motion.x -= ACCELERATION
		animation_handler("Run")
		$PlayerSprite.flip_h = true
	else:
		animation_handler("Idle")
		motion.x = lerp(motion.x, 0, 0.13)

	if not is_on_floor() and next_to_wall():
		animation_handler("WallSlide")


	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_available):
		jump_pressed()
		jump_just_pressed = true
		animation_handler("Jump")
		motion.y = 0
		motion.y -= JUMPFORCE * inversed_gravity


	elif Input.is_action_just_pressed("jump") and next_to_right_wall() and can_jump_right_wall:
		can_jump_wall("Right")
		jump_pressed()
		animation_handler("Jump")
		motion.y -= JUMPFORCE / 1.2 * inversed_gravity
		motion.x -= WALLJUMPFORCE * inversed_gravity
		
	elif Input.is_action_just_pressed("jump") and next_to_left_wall() and can_jump_left_wall:
		can_jump_wall("Left")
		jump_pressed()
		animation_handler("Jump")
		motion.y -= JUMPFORCE / 1.2 * inversed_gravity
		motion.x += WALLJUMPFORCE * inversed_gravity

		
	elif Input.is_action_just_pressed("jump") and double_jump:
		animation_handler("DoubleJump")
		motion.y = 0
		motion.y -= JUMPFORCE * inversed_gravity
		double_jump = false
		
	if is_on_floor():
		touching_ground = true
		double_jump = true
	else:
		if touching_ground and not jump_just_pressed:
			coyote_time()
		touching_ground = false
		jump_just_pressed = false
		
	if (motion.y * inversed_gravity) > 180 and (not is_on_floor() and not next_to_wall()):
		animation_handler("Falling")

	if is_dashing:
		if (count % 4 == 2 or count % 4 == 0):
			dash_animation()
		count += 1
		motion = move_and_slide(dash_direction, UP)
		if (dash_direction.y < 0):
			motion.y = -500
	else:
		motion = move_and_slide(motion, UP)


func animation_handler(animation):
	if animation == "Run" and is_on_floor():
		animation_player.play("Run")
	elif animation == "Idle" and is_on_floor():
		animation_player.play("Idle")
	elif animation == "Jump":
		animation_player.play("Jump")
	elif animation == "DoubleJump":
		animation_player.play("Somersault")
	elif animation == "Falling":
		animation_player.play("Falling")
	elif animation == "WallSlide" and !jump_btn_pressed:
		animation_player.play("WallSlide")
		if next_to_right_wall():
			$PlayerSprite.flip_h = false
		else:
			$PlayerSprite.flip_h = true

func is_controller():
	if Input.get_action_strength("lt_down") > 0.7:
		return true
	if Input.get_action_strength("lt_up") > 0.7:
		return true
	if Input.get_action_strength("lt_right") > 0.7:
		return true
	if Input.get_action_strength("lt_left") > 0.7:
		return true
	# we're not pressing a direction on the controller further enough, must be keyboard
	return false

#Removed and available_lightning from Input if statement
func handle_dash(var delta):
	if Input.is_action_just_pressed("LightningPower") and available_lightning and !touching_ground:
		dash_direction = get_direction_from_input()
		if dash_direction == Vector2(0, 0):
			return
		is_dashing = true
		available_lightning = false
		dash_timer.start(dash_length)
	if is_dashing:
		if touching_ground or is_on_wall():
			is_dashing = false


func dash_animation():
	var dash_fragment = Sprite.new()
	dash_fragment.texture = $PlayerSprite.texture
	dash_fragment.hframes = 27
	dash_fragment.frame = $PlayerSprite.frame
	dash_fragment.global_position = global_position
	dash_fragment.flip_h = $PlayerSprite.flip_h
	dash_fragment.flip_v = $PlayerSprite.flip_v
	dash_fragment.scale = Vector2(2, 2)
	dash_fragment.modulate = "7dfffb00"
	get_parent().add_child(dash_fragment)
	yield(get_tree().create_timer(.1), "timeout")
	dash_fragment.queue_free()
	


func get_direction_from_input():
	var move_dir = Vector2()
	var controller = is_controller()
	if(controller):
		move_dir.x = -Input.get_action_strength("lt_left") + Input.get_action_strength("lt_right")
		move_dir.y = Input.get_action_strength("lt_down") - Input.get_action_strength("lt_up")
	else:
		move_dir.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
		move_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	move_dir = move_dir.clamped(1)
	return move_dir * lightning_speed

func next_to_wall():
	return next_to_right_wall() or next_to_left_wall()

func next_to_right_wall():
	return $RightWall.is_colliding()
	
func next_to_left_wall():
	return $LeftWall.is_colliding()

func _on_Area2D_area_entered(area):
	if area.name == "Portal" and not entered_portal and portal_timer_timeout:
		entered_portal(area)
	elif area.name == "DissolvingBlock":
		area.get_parent().get_node("AnimationPlayer").play("DissolvingSand")
	elif area.name == "Hourglass":
		touched_hourglass(area)
	elif area.name == "GravityFlipper":
		touched_gravity(area)
	elif area.name == "Lightning":
		touched_lightning(area)
	elif area.name == "Death":
		death()
	elif area.name == "Detach":
		$AnchorCamera.current = false
		death()
	elif area.name == "Key":
		unlock_lock(area.get_parent())
	elif area.name == "Bell":
		ring_bell(area.get_parent())
	elif area.name == "CameraSettings":
		camera_settings(area.get_parent())
	elif area.name == "LevelEnd":
		end_of_level()
	else:
		print(area)

func _on_Area2D_area_exited(area):
	if area.name == "Portal":
		print("Exited portal")
		entered_portal = false

func coyote_time():
	coyote_available = true
	yield(get_tree().create_timer(.15), "timeout")
	coyote_available = false

func jump_pressed():
	jump_btn_pressed = true
	yield(get_tree().create_timer(.15), "timeout")
	jump_btn_pressed = false

func can_jump_wall(wall):
	if (wall == "Left"):
		can_jump_left_wall = false
		yield(get_tree().create_timer(.3), "timeout")
		can_jump_left_wall = true
	elif (wall == "Right"):
		can_jump_right_wall = false
		yield(get_tree().create_timer(.3), "timeout")
		can_jump_right_wall = true

func unlock_lock(key):
	var lock_id = key.lock_id
	for x in get_parent().get_node("Locks").get_children():
		if x.lock_id == lock_id:
			x.unlock()
			break
	key.queue_free()

func ring_bell(bell):
	var lock_id = bell.lock_id
	for x in get_parent().get_node("Locks").get_children():
		if x.lock_id == lock_id:
			print("Found it ")
			x.open_door()
			break

func entered_portal(area):
	entered_portal = true
	var portal = area.get_parent()
	var target_portal = find_portal(portal.portal_link)
	print(target_portal)
	$PortalTimer.start()
	portal_timer_timeout = false
	position = target_portal.global_position


func find_portal(portal_link):
	return get_parent().get_node(portal_link)
	

func _on_PortalTimer_timeout():
	portal_timer_timeout = true


func touched_hourglass(area):
	if available_time_warp:
		pass
	else:
		if area.get_parent().enabled == true:
			area.get_parent().picked_up()
			available_time_warp = true
		else:
			print("Disabled")
		
func time_warp():
	if active_time_warp:
		position = time_frag.position
		time_frag.queue_free()
		active_time_warp = false
		available_time_warp = false
	else:
		time_frag = time_fragment.instance()
		time_frag.get_node("PlayerSprite").frame = $PlayerSprite.frame
		time_frag.get_node("PlayerSprite").flip_h = $PlayerSprite.flip_h
		get_parent().add_child(time_frag)
		time_frag.position = position
		active_time_warp = true

func touched_lightning(area):
	if available_lightning:
		pass
	else:
		var result = area.get_parent().death()
		if result:
			available_lightning = true

func lightning_jump():
	pass
	
func dash_timer_timeout():
	is_dashing = false
	
func touched_gravity(area):
	available_gravity_flip = true
	$GravityTimer.start()
	area.get_parent().picked_up()
	

func inverse_gravity():
	if inversed_gravity == 1:
		$NormalCollision.disabled = true
		$FlippedCollision.disabled = false
		$PlayerSprite.flip_v = true
		inversed_gravity = -1
		UP = Vector2(0, 1)
	else:
		$NormalCollision.disabled = false
		$FlippedCollision.disabled = true
		$PlayerSprite.flip_v = false
		inversed_gravity = 1
		UP = Vector2(0, -1)


func _on_Area2D_body_entered(body):
	if (body.name == "Death"):
		print("Collided with death")
		death()
	elif (body.name == "Platform"):
		var parent_node = body.get_parent()
		if parent_node.autoplay_enabled == false:
			yield(get_tree().create_timer(.8), "timeout")
			parent_node.get_node("AnimationPlayer").play("Move")


func _on_Area2D_body_exited(body):
	if (body.name == "Platform"): 
		print("Exited")

func camera_settings(area):
	var camera = $AnchorCamera
	camera.limit_top = area.max_top
	camera.limit_bottom = area.max_bottom
	camera.limit_left = area.max_left
	camera.limit_right = area.max_right
	camera.drag_margin_h_enabled = area.drag_margin_h
	camera.drag_margin_v_enabled = area.drag_margin_v
	

func death():
	get_tree().reload_current_scene()
	
func entered_checkpoint(checkpoint):
	game_state.player_respawn_point = checkpoint.respawn_point
	game_state.lightning_available = available_lightning
	game_state.warp_available = available_time_warp

func end_of_level():
	var time_finished: float = (float(OS.get_ticks_msec()) - float(get_parent().time_started)) / 1000.0
	game_state.update_data(game_state.current_level, time_finished, bonus_picked_up, bonus_level)
	if get_parent().bonus_level:
		get_tree().change_scene("res://Levels/World.tscn")
	else:
		get_tree().change_scene(game_state.next_level)
	print("End of Level!")


func _on_GravityTimer_timeout():
	print("Gravity no mo")
	available_gravity_flip = false
