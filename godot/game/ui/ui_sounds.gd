class_name UiSounds
extends Node
## Tiny generated DS-style UI tones; no external audio asset or load hitch.

var _player: AudioStreamPlayer
var _had_focus := false


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.volume_db = -16.0
	add_child(_player)
	get_viewport().gui_focus_changed.connect(func(control: Control) -> void:
		if control is Button:
			if _had_focus:
				play_move()
			_had_focus = true)


func play_move() -> void:
	_play_tone(520.0, 0.025)


func play_confirm() -> void:
	_play_tone(760.0, 0.045)


func play_cancel() -> void:
	_play_tone(310.0, 0.055)


func play_error() -> void:
	_play_tone(165.0, 0.09)


func play_purchase() -> void:
	_play_tone(980.0, 0.08)


func _play_tone(frequency: float, duration: float) -> void:
	const MIX_RATE := 22050
	var frames := int(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for frame in frames:
		var envelope := 1.0 - float(frame) / frames
		var sample := int(sin(TAU * frequency * frame / MIX_RATE) * envelope * 9000.0)
		bytes.encode_s16(frame * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.data = bytes
	_player.stream = stream
	_player.play()
