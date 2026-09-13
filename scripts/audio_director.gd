class_name AudioDirector
extends Node

var ambience: AudioStreamPlayer
var music: AudioStreamPlayer
var music_tween: Tween
var streams: Dictionary = {}
var music_streams: Dictionary = {}
var current_music_id: String = ""

const MUSIC_VOLUME_DB: Dictionary = {
    "title_theme": -18.0,
    "fallen_village_theme": -17.5,
    "whispering_woods_theme": -18.0,
    "sunken_keep_theme": -17.5,
    "memory_labyrinth_theme": -18.0,
    "boss_battle_theme": -13.5,
    "evil_wizard_theme": -13.0,
    "cinematic_theme": -17.0,
    "blighted_mountains_theme": -16.5,
    "black_tower_theme": -16.8,
    "tower_warden_theme": -13.0,
    "crown_chamber_theme": -16.2,
    "true_wizard_theme": -12.4,
    "ending_theme": -17.2
}

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

    var ids: Array[String] = [
        "jump","dash","slash","heavy","bash","whirlwind","hit",
        "enemy_attack","enemy_down","wizard_cast","teleport",
        "boss_phase","ultimate","checkpoint","death","boss_die",
        "ui_confirm","cinematic_advance","bell_chime",
        "rune_correct","rune_wrong","gate_open",
        "bow_shot","arrow_hit","guard","perfect_guard",
        "water_splash","trap_spike","crusher","boss_sting",
        "wind_gust","rock_crack","rock_break","ground_slam",
        "stone_roar","axe_swing","rock_impact",
        "phase_shift","mirror_turn","mirror_lock","void_pulse",
        "combat_roll","blade_clash","riposte",
        "crown_seal","sigil_shatter","true_cast","mortal_spell",
        "final_sting","final_defeat","monk_strike","inner_peace","wind_step",
        "hunt_mark","nature_favor","cleric_smite","rejuvenate","divine_intervention"
    ]
    for sfx_id: String in ids:
        var sfx_stream: AudioStream = load("res://audio/%s.wav" % sfx_id) as AudioStream
        if sfx_stream:
            streams[sfx_id] = sfx_stream

    var music_ids: Array[String] = [
        "title_theme",
        "fallen_village_theme",
        "whispering_woods_theme",
        "sunken_keep_theme",
        "memory_labyrinth_theme",
        "boss_battle_theme",
        "evil_wizard_theme",
        "cinematic_theme",
        "blighted_mountains_theme",
        "black_tower_theme",
        "tower_warden_theme",
        "crown_chamber_theme",
        "true_wizard_theme",
        "ending_theme"
    ]
    for music_id: String in music_ids:
        var loaded_music: AudioStream = load("res://audio/music/%s.wav" % music_id) as AudioStream
        if loaded_music:
            music_streams[music_id] = loaded_music

    ambience = AudioStreamPlayer.new()
    ambience.name = "WorldAmbience"
    add_child(ambience)
    var ambience_stream: AudioStream = load("res://audio/ambience.wav") as AudioStream
    if ambience_stream:
        ambience.stream = ambience_stream
        ambience.volume_db = -25.0
        ambience.finished.connect(_restart_ambience)
        ambience.play()

    music = AudioStreamPlayer.new()
    music.name = "Music"
    add_child(music)
    music.finished.connect(_restart_music)
    set_music("title_theme",0.0,true)

func _restart_ambience() -> void:
    if is_instance_valid(ambience) and ambience.stream:
        ambience.play()

func _restart_music() -> void:
    if is_instance_valid(music) and music.stream and not current_music_id.is_empty():
        music.play()

func set_music(id: String, fade_seconds: float = 1.0, force: bool = false) -> void:
    if not music_streams.has(id):
        return
    if current_music_id == id and not force:
        return

    current_music_id = id
    var next_stream: AudioStream = music_streams[id] as AudioStream
    var target_db: float = float(MUSIC_VOLUME_DB.get(id,-17.0))

    if is_instance_valid(music_tween):
        music_tween.kill()

    if fade_seconds <= 0.01 or not music.playing:
        music.stream = next_stream
        music.volume_db = target_db
        music.play()
        return

    var requested_id: String = id
    var fade_out: float = minf(0.42,fade_seconds*0.35)
    var fade_in: float = maxf(0.12,fade_seconds-fade_out)

    music_tween = create_tween()
    music_tween.tween_property(music,"volume_db",-45.0,fade_out)
    music_tween.tween_callback(func():
        if current_music_id != requested_id:
            return
        music.stream = next_stream
        music.volume_db = -45.0
        music.play()
    )
    music_tween.tween_property(music,"volume_db",target_db,fade_in)

func play_sfx(id: String, volume_db: float = -4.0, pitch: float = 1.0) -> void:
    if not streams.has(id):
        return
    var player: AudioStreamPlayer = AudioStreamPlayer.new()
    player.stream = streams[id] as AudioStream
    player.volume_db = volume_db
    player.pitch_scale = clampf(pitch,0.55,1.8)
    add_child(player)
    player.finished.connect(func():
        if is_instance_valid(player):
            player.queue_free()
    )
    player.play()
