class_name Weapon

var name: String
var recoil_multiplier: float
var max_air_shots: int
var fire_rate: float  # seconds between shots
var is_automatic: bool

func _init(name: String = "Default Gun", recoil_multiplier: float = 0.7, max_air_shots: int = 1, fire_rate: float = 0.3, is_automatic: bool = false):
	self.name = name
	self.recoil_multiplier = recoil_multiplier
	self.max_air_shots = max_air_shots
	self.fire_rate = fire_rate
	self.is_automatic = is_automatic
