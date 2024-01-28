@tool # Allowing current script to be loaded and executed by the editor
extends Control

## Simple Radial Menu Tool Selection Wheel


var SPRITE_SIZE: Vector2 = Vector2(32,32)

# Export Variables
@export var bg_color: Color
@export var line_color: Color
@export var highlight_color: Color

@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var line_width: int = 4

var options: Array[tool]

@export var Options: Array[tool]

var selection: int = -1


# Draw Shapes 
func _draw():
	var offset: Vector2 = SPRITE_SIZE / -2
	# Draw Outer Circle
	draw_circle(Vector2.ZERO, outer_radius, bg_color)
	# Draw Inner Circle
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, line_color, line_width, true)
	#
	draw_arc(Vector2.ZERO, outer_radius, 0, TAU, 128, line_color, line_width, true)
	# If Array Have One Element
	if len(options) == 1:
		# If you have one element put it in innner circle
		draw_texture_rect(options[0].atlas, Rect2(offset, SPRITE_SIZE),false)
		# Highlight inner circle		
		if selection == -1:
			draw_circle(Vector2.ZERO, inner_radius,highlight_color)	
			
	# If Array have more than one element
	elif len(options) > 1:
		
		#draw Separator Lines
		for i in range(len(options)):
			var rads = TAU * i / (len(options))
			var point = Vector2.from_angle(rads)
			draw_line(
				point * inner_radius,
				point * outer_radius,
				line_color,
				line_width,
				true
				)
				#
				
		# Draw tools
		for i in range(0, len(options)+1):
			var start_rads = (TAU * (i-1)) / (len(options))
			var end_rads = (TAU * (i)) / (len(options))
			var mid_rads = (start_rads + end_rads) / 2.0
			var radius_mid = (inner_radius + outer_radius) / 2.0

			var draw_pos = radius_mid * Vector2.from_angle(mid_rads) + offset
			
			draw_texture_rect(options[i-1].atlas, Rect2(draw_pos, SPRITE_SIZE), false)
		
			# Highlight selected tool Draw 
			if selection == i:
				#print("Selection: " + str(selection) + "; " + "i: " + str(i) + ";")
				var points_per_arc = 32
				var points_inner = PackedVector2Array()
				var points_outer = PackedVector2Array()
				
				for j in range(points_per_arc+1):
#
					var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
					points_inner.append(inner_radius * Vector2.from_angle(TAU-angle))
					points_outer.append(outer_radius * Vector2.from_angle(TAU-angle))
			
				points_outer.reverse()
					
				draw_polygon(points_inner + points_outer, PackedColorArray([highlight_color]))
			
func _process(_delta):
	
	# Mouse position
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	# Assign Selected tool
	# Ruturn -1 if mouse position is in of the inner circle
	if 	mouse_radius < inner_radius:
		selection = -1
	# Ruturn -2 if mouse position is out of the outer circle
	elif mouse_radius > outer_radius:
		selection = -2
	# Return Index + 1 If Mouse inside the outer circle
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1 , TAU)
		selection = ceil((mouse_rads / TAU) * (len(options)))
	# Redraw circle every frame
	queue_redraw()

func close():
	# Hide Selection wheel
	hide()

	if selection > 0 and options.size() > 1:
		return options[selection-1].Name 
	elif selection == -1:
		return options[0].Name 
	else:
		return null
		
func addOption(option: String):
	for op in options:
		if op.Name == option:
			print("Tool Exist in the Wheel!!")
			return
	
	for op in Options:
		if op.Name == option:
			options.append(op)
			return
	return "Tool Not Exist"

func removeOption(option: String):
	for op in options:
		if op.Name == option:
			option.erase(options.find(op))
			return ""
			
	return "Tool not exist!"
