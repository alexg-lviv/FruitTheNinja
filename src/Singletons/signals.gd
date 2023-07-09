extends Node

signal camera_shake_requested(amp, dur)
signal frame_freeze_requested(delay)

signal fruit_hit(damage: int, impact_pos: Vector2)
