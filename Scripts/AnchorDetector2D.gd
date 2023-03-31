class_name AnchorDetector2D
extends Area2D

# Emitted when entering an anchor area.
signal anchor_detected(anchor)
# Emitted after exiting all anchor areas.
signal anchor_detached

func _on_area_entered(area: Anchor2D) -> void:
	print("Anchor has been detected!!!")
	emit_signal("anchor_detected", area)

# When exiting an area, we have to ensure we're not entering another anchor.
func _on_area_exited(area: Anchor2D) -> void:
	print("Left the Anchor!")
	var areas: Array = get_overlapping_areas()
	# To do so, we check that's there's but one overlapping area left and that it's
	# the one passed to this callback function.
	if get_overlapping_areas().size() == 1 and not area == areas[0]:
		emit_signal("anchor_detected", areas[0])
		print("XX 1!")
	else:
		print("XX 2!")
		emit_signal("anchor_detached")
