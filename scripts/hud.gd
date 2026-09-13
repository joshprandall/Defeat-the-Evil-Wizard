class_name GameHUD
extends CanvasLayer

signal start_requested(hero_class: String)
signal continue_requested
signal movement_lab_requested
signal shrine_upgrade_requested(upgrade_id: String)
signal pause_toggled
signal restart_requested
signal quit_requested
signal shake_changed(enabled: bool)
signal difficulty_changed(mode: String)

var health_bar: ProgressBar
var resource_bar: ProgressBar
var resource_caption: Label
var hero_label: Label
var boss_bar: ProgressBar
var boss_box: VBoxContainer
var boss_label: Label
var miniboss_box: VBoxContainer
var miniboss_bar: ProgressBar
var miniboss_label: Label
var shard_label: Label
var objective_label: Label
var message: Label
var controls: Label
var gameplay_root: Control
var title_overlay: Control
var pause_overlay: Control
var victory_overlay: Control
var resume_button: Button
var shake_toggle: CheckButton
var continue_button: Button
var shrine_overlay: Control
var shrine_title: Label
var shrine_buttons: Dictionary = {}
var dialogue_panel: Control
var dialogue_speaker: Label
var dialogue_text: Label
var interaction_label: Label
var interaction_backdrop: ColorRect
var puzzle_label: Label
var footer_backdrop: ColorRect
const TITLE_PAGE_SIZE: int = 5
var title_cards: Array[Control] = []
var title_page_containers: Array[GridContainer] = []
var title_page: int = 0
var title_page_label: Label
var title_prev_button: Button
var title_next_button: Button

func _ready() -> void:
    layer = 20
    process_mode = Node.PROCESS_MODE_ALWAYS
    var root: Control = Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root)
    gameplay_root = Control.new()
    gameplay_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    gameplay_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(gameplay_root)
    _build_gameplay_hud(gameplay_root)
    title_overlay = _build_title_overlay(root)
    pause_overlay = _build_pause_overlay(root)
    victory_overlay = _build_victory_overlay(root)
    shrine_overlay = _build_shrine_overlay(root)
    dialogue_panel = _build_dialogue_panel(root)
    pause_overlay.visible = false
    victory_overlay.visible = false
    shrine_overlay.visible = false
    dialogue_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause") and not title_overlay.visible and not victory_overlay.visible:
        pause_toggled.emit()
        get_viewport().set_input_as_handled()

func _build_gameplay_hud(root: Control) -> void:
    var vignette: ColorRect = ColorRect.new()
    vignette.position = Vector2(0,0)
    vignette.size = Vector2(1280,118)
    vignette.color = Color(0.015,0.02,0.03,0.56)
    vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(vignette)

    var panel: VBoxContainer = VBoxContainer.new()
    panel.position = Vector2(28,18)
    panel.size = Vector2(360,116)
    root.add_child(panel)

    hero_label = Label.new()
    hero_label.text = "WARRIOR  //  THE LAST ROAD"
    hero_label.add_theme_font_size_override("font_size", 15)
    hero_label.add_theme_color_override("font_color", Color("#f0c67a"))
    panel.add_child(hero_label)

    health_bar = ProgressBar.new()
    health_bar.max_value = 160
    health_bar.value = 160
    health_bar.show_percentage = false
    health_bar.custom_minimum_size = Vector2(340,20)
    _style_bar(health_bar, Color("#161c22"), Color("#b34b4c"))
    panel.add_child(health_bar)

    var health_caption: Label = Label.new()
    health_caption.text = "VITALITY"
    health_caption.add_theme_font_size_override("font_size", 10)
    health_caption.add_theme_color_override("font_color", Color(0.78,0.80,0.82,0.72))
    panel.add_child(health_caption)

    resource_bar = ProgressBar.new()
    resource_bar.max_value = 100
    resource_bar.value = 0
    resource_bar.show_percentage = false
    resource_bar.custom_minimum_size = Vector2(340,11)
    _style_bar(resource_bar, Color("#161c22"), Color("#d39a3d"))
    panel.add_child(resource_bar)

    resource_caption = Label.new()
    resource_caption.text = "RAGE  //  Q LAST STAND WHEN FULL"
    resource_caption.add_theme_font_size_override("font_size", 10)
    resource_caption.add_theme_color_override("font_color", Color(0.87,0.70,0.40,0.78))
    panel.add_child(resource_caption)

    boss_box = VBoxContainer.new()
    boss_box.visible = false
    boss_box.position = Vector2(402,22)
    boss_box.size = Vector2(500,76)
    root.add_child(boss_box)
    boss_label = Label.new()
    boss_label.text = "THE EVIL WIZARD  //  PHASE I"
    boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    boss_label.add_theme_font_size_override("font_size", 15)
    boss_label.add_theme_color_override("font_color", Color("#e9b3ff"))
    boss_box.add_child(boss_label)
    boss_bar = ProgressBar.new()
    boss_bar.max_value = 620
    boss_bar.value = 620
    boss_bar.show_percentage = false
    boss_bar.custom_minimum_size = Vector2(500,20)
    _style_bar(boss_bar, Color("#16121d"), Color("#7d3aa1"))
    boss_box.add_child(boss_bar)

    miniboss_box = VBoxContainer.new()
    miniboss_box.visible = false
    miniboss_box.position = Vector2(402,22)
    miniboss_box.size = Vector2(500,76)
    root.add_child(miniboss_box)
    miniboss_label = Label.new()
    miniboss_label.text = "THE GRAVE KNIGHT  //  VILLAGE WARDEN"
    miniboss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    miniboss_label.add_theme_font_size_override("font_size",15)
    miniboss_label.add_theme_color_override("font_color",Color("#b8d9e9"))
    miniboss_box.add_child(miniboss_label)
    miniboss_bar = ProgressBar.new()
    miniboss_bar.max_value = 360
    miniboss_bar.value = 360
    miniboss_bar.show_percentage = false
    miniboss_bar.custom_minimum_size = Vector2(500,18)
    _style_bar(miniboss_bar,Color("#111820"),Color("#667f91"))
    miniboss_box.add_child(miniboss_bar)

    shard_label = Label.new()
    shard_label.position = Vector2(1010,22)
    shard_label.size = Vector2(235,28)
    shard_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    shard_label.text = "ARCANE SHARDS  0 / 5"
    shard_label.add_theme_font_size_override("font_size",14)
    shard_label.add_theme_color_override("font_color",Color("#8edfff"))
    root.add_child(shard_label)

    objective_label = Label.new()
    objective_label.position = Vector2(875,54)
    objective_label.size = Vector2(370,54)
    objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    objective_label.text = "OBJECTIVE  //  CROSS THE FALLEN VILLAGE"
    objective_label.add_theme_font_size_override("font_size",11)
    objective_label.add_theme_color_override("font_color",Color(0.78,0.81,0.84,0.74))
    root.add_child(objective_label)

    puzzle_label = Label.new()
    puzzle_label.position = Vector2(820,96)
    puzzle_label.size = Vector2(425,42)
    puzzle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    puzzle_label.text = ""
    puzzle_label.add_theme_font_size_override("font_size",12)
    puzzle_label.add_theme_color_override("font_color",Color("#f0d082"))
    puzzle_label.add_theme_color_override("font_shadow_color",Color(0,0,0,0.88))
    puzzle_label.add_theme_constant_override("shadow_offset_x",2)
    puzzle_label.add_theme_constant_override("shadow_offset_y",2)
    puzzle_label.visible = false
    root.add_child(puzzle_label)

    message = Label.new()
    message.position = Vector2(0,155)
    message.size = Vector2(1280,110)
    message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message.add_theme_font_size_override("font_size",32)
    message.add_theme_color_override("font_color",Color("#f4dfb0"))
    message.add_theme_color_override("font_shadow_color",Color(0,0,0,0.88))
    message.add_theme_constant_override("shadow_offset_x",3)
    message.add_theme_constant_override("shadow_offset_y",3)
    root.add_child(message)

    footer_backdrop = ColorRect.new()
    footer_backdrop.position = Vector2(0,686)
    footer_backdrop.size = Vector2(1280,34)
    footer_backdrop.color = Color(0.015,0.02,0.03,0.72)
    footer_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(footer_backdrop)

    controls = Label.new()
    controls.position = Vector2(16,690)
    controls.size = Vector2(1248,24)
    controls.text = "A/D MOVE   S CROUCH   SPACE JUMP   SHIFT/F DASH/SLIDE   MOUSE AIM   LMB/J ATTACK   RMB/K HEAVY   L/I ABILITIES   Q ULT   E INTERACT"
    controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    controls.add_theme_font_size_override("font_size",9)
    controls.add_theme_color_override("font_color",Color(0.78,0.81,0.85,0.64))
    root.add_child(controls)

    interaction_backdrop = ColorRect.new()
    interaction_backdrop.position = Vector2(365,548)
    interaction_backdrop.size = Vector2(550,48)
    interaction_backdrop.color = Color(0.035,0.028,0.022,0.86)
    interaction_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    interaction_backdrop.visible = false
    root.add_child(interaction_backdrop)

    interaction_label = Label.new()
    interaction_label.position = Vector2(375,555)
    interaction_label.size = Vector2(530,34)
    interaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    interaction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    interaction_label.add_theme_font_size_override("font_size",17)
    interaction_label.add_theme_color_override("font_color",Color("#ffe19a"))
    interaction_label.add_theme_color_override("font_shadow_color",Color(0,0,0,0.94))
    interaction_label.add_theme_constant_override("shadow_offset_x",2)
    interaction_label.add_theme_constant_override("shadow_offset_y",2)
    interaction_label.visible = false
    root.add_child(interaction_label)

func _build_title_overlay(root: Control) -> Control:
    var overlay: Control = Control.new()
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    root.add_child(overlay)

    var shade: ColorRect = ColorRect.new()
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.012,0.018,0.031,0.96)
    overlay.add_child(shade)

    var crest: Label = Label.new()
    crest.text = "◆  ⚔  ◆"
    crest.position = Vector2(440,30)
    crest.size = Vector2(400,38)
    crest.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    crest.add_theme_font_size_override("font_size",24)
    crest.add_theme_color_override("font_color",Color("#d6a65a"))
    overlay.add_child(crest)

    var title: Label = Label.new()
    title.text = "DEFEAT THE EVIL WIZARD"
    title.position = Vector2(120,70)
    title.size = Vector2(1040,62)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size",44)
    title.add_theme_color_override("font_color",Color("#f1e5c8"))
    title.add_theme_color_override("font_shadow_color",Color(0.32,0.12,0.42,0.88))
    title.add_theme_constant_override("shadow_offset_x",4)
    title.add_theme_constant_override("shadow_offset_y",5)
    overlay.add_child(title)

    var subtitle: Label = Label.new()
    subtitle.text = "CHOOSE YOUR CHAMPION  //  COMPLETE ROUGH DRAFT v2.0.2"
    subtitle.position = Vector2(240,140)
    subtitle.size = Vector2(800,28)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size",14)
    subtitle.add_theme_color_override("font_color",Color(0.76,0.72,0.68,0.86))
    overlay.add_child(subtitle)

    var roster_hint: Label = Label.new()
    roster_hint.text = "15 PLAYABLE CHAMPIONS  //  ONE COMPLETE CAMPAIGN"
    roster_hint.position = Vector2(340,169)
    roster_hint.size = Vector2(600,24)
    roster_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    roster_hint.add_theme_font_size_override("font_size",10)
    roster_hint.add_theme_color_override("font_color",Color(0.60,0.66,0.70,0.70))
    overlay.add_child(roster_hint)

    # Each champion page gets its own GridContainer. Keeping all 15 cards in
    # one container and hiding individual children can leave stale Container
    # layout state on some Godot/window-scaling combinations. Separate pages
    # keep the five-card row centered and deterministic at every page.
    var cards_host: Control = Control.new()
    cards_host.position = Vector2(120,205)
    cards_host.size = Vector2(1040,220)
    overlay.add_child(cards_host)

    title_cards.clear()
    title_page_containers.clear()
    title_cards.append(_hero_card("WARRIOR","Frontline bruiser","Sword combo · Heavy cleave\nShield Bash · Whirlwind\nDash · Last Stand",Color("#d29a58"),"warrior"))
    title_cards.append(_hero_card("MAGE","Ranged control","Arcane Bolt · Charged Bolt\nFrost Nova · Flame Wave\nBlink · Meteor",Color("#69bdf0"),"mage"))
    title_cards.append(_hero_card("ROGUE","Burst mobility","Dagger chain · Backstab Rush\nSmoke Step · Fan of Knives\nDouble Jump · Shadow Dance",Color("#b477e8"),"rogue"))
    title_cards.append(_hero_card("PALADIN","Guard & sustain","Consecrated combo · Smite\nDivine Guard · Sacred Nova\nRighteous Dash · Judgment",Color("#e4cb68"),"paladin"))
    title_cards.append(_hero_card("ARCHER","Mobile ranged","Quick Shot · Power Shot\nPiercing Arrow · Arrow Rain\nVault · Perfect Volley",Color("#72d6a0"),"archer"))
    title_cards.append(_hero_card("BARBARIAN","Heavy aggression","Axe chain · Heavy Cleave\nGround Slam · Berserk\nReckless Leap · Worldbreaker",Color("#e27755"),"barbarian"))
    title_cards.append(_hero_card("FIGHTER","Technical melee","Sword chain · Breaker Thrust\nParry · Riposte\nCombat Roll · Relentless Assault",Color("#e1b76e"),"fighter"))
    title_cards.append(_hero_card("MONK","Speed & flow","Four-hit combo · Palm Strike\nFlurry · Inner Peace\nWind Step · Hundred Hands",Color("#78d8c5"),"monk"))
    title_cards.append(_hero_card("RANGER","Hybrid hunter","Marked shots · Hunter Sweep\nAimed Shot · Nature's Favor\nTrail Step · Predator's Focus",Color("#91c96d"),"ranger"))
    title_cards.append(_hero_card("CLERIC","Holy sustain","Mace chain · Radiant Bolt\nSmite · Rejuvenation\nSanctified Step · Divine Intervention",Color("#b8d8ef"),"cleric"))
    title_cards.append(_hero_card("BARD","Tempo & control","Rapier chain · Resonant Note\nDiscordant Chord · Rallying Chorus\nStage Dive · Finale",Color("#e88fc8"),"bard"))
    title_cards.append(_hero_card("DRUID","Nature control","Vine Lash · Thorn Shot\nEntangle · Regrowth\nWild Shape · Avatar of the Grove",Color("#75c77c"),"druid"))
    title_cards.append(_hero_card("SORCERER","Volatile burst","Arc Bolt · Chain Burst\nLightning Burst · Overcharge\nArc Step · Arcane Cataclysm",Color("#ff8b6b"),"sorcerer"))
    title_cards.append(_hero_card("WARLOCK","Drain & curses","Shadow Bolt · Soul Lance\nSoul Drain · Curse\nUmbral Gate · Infernal Pact",Color("#a26bd8"),"warlock"))
    title_cards.append(_hero_card("WIZARD","Precision spellcraft","Magic Missile · Arcane Lance\nMagic Missiles · Time Warp\nTeleport · Arcane Singularity",Color("#9d8cff"),"wizard"))

    var page_count: int = maxi(1,int(ceil(float(title_cards.size())/float(TITLE_PAGE_SIZE))))
    for page_index: int in range(page_count):
        var page_grid: GridContainer = GridContainer.new()
        page_grid.columns = TITLE_PAGE_SIZE
        page_grid.position = Vector2.ZERO
        page_grid.size = Vector2(1040,220)
        page_grid.add_theme_constant_override("h_separation",10)
        page_grid.add_theme_constant_override("v_separation",0)
        cards_host.add_child(page_grid)
        title_page_containers.append(page_grid)

    for i: int in range(title_cards.size()):
        var card_page: int = i / TITLE_PAGE_SIZE
        title_page_containers[card_page].add_child(title_cards[i])

    var hook: Label = Label.new()
    hook.text = "Every road can be finished by every champion. Explore, experiment, and find your own way through the realm."
    hook.position = Vector2(180,447)
    hook.size = Vector2(920,34)
    hook.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hook.add_theme_font_size_override("font_size",15)
    hook.add_theme_color_override("font_color",Color("#c9d1d6"))
    overlay.add_child(hook)

    # Compact arrow navigation deliberately avoids the large minimum width
    # used by normal menu buttons. The screenshot from v2.0 showed PREVIOUS
    # colliding with the page caption on some displays.
    title_prev_button = _title_nav_button("◀")
    title_prev_button.position = Vector2(410,492)
    title_prev_button.size = Vector2(64,44)
    title_prev_button.tooltip_text = "Previous champions"
    title_prev_button.pressed.connect(func(): _show_title_page(title_page-1))
    overlay.add_child(title_prev_button)

    title_page_label = Label.new()
    title_page_label.position = Vector2(490,496)
    title_page_label.size = Vector2(300,36)
    title_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title_page_label.add_theme_font_size_override("font_size",14)
    title_page_label.add_theme_color_override("font_color",Color("#f0d082"))
    overlay.add_child(title_page_label)

    title_next_button = _title_nav_button("▶")
    title_next_button.position = Vector2(806,492)
    title_next_button.size = Vector2(64,44)
    title_next_button.tooltip_text = "Next champions"
    title_next_button.pressed.connect(func(): _show_title_page(title_page+1))
    overlay.add_child(title_next_button)

    continue_button = _menu_button("CONTINUE")
    continue_button.custom_minimum_size = Vector2(300,50)
    continue_button.position = Vector2(115,625)
    continue_button.size = Vector2(300,50)
    continue_button.pressed.connect(func(): continue_requested.emit())
    overlay.add_child(continue_button)

    var lab_button: Button = _menu_button("MOVEMENT LAB")
    lab_button.custom_minimum_size = Vector2(300,50)
    lab_button.position = Vector2(490,625)
    lab_button.size = Vector2(300,50)
    lab_button.pressed.connect(func(): movement_lab_requested.emit())
    overlay.add_child(lab_button)

    var quit_button: Button = _menu_button("QUIT")
    quit_button.custom_minimum_size = Vector2(300,50)
    quit_button.position = Vector2(865,625)
    quit_button.size = Vector2(300,50)
    quit_button.pressed.connect(func(): quit_requested.emit())
    overlay.add_child(quit_button)

    _show_title_page(0)
    return overlay

func _show_title_page(page_index: int) -> void:
    if title_cards.is_empty():
        return
    var page_count: int = maxi(1,int(ceil(float(title_cards.size())/float(TITLE_PAGE_SIZE))))
    title_page = clampi(page_index,0,page_count-1)
    var start_index: int = title_page*TITLE_PAGE_SIZE
    var end_index: int = mini(title_cards.size(),start_index+TITLE_PAGE_SIZE)

    for i: int in range(title_page_containers.size()):
        title_page_containers[i].visible = i == title_page

    if is_instance_valid(title_page_label):
        title_page_label.text = "CHAMPIONS %d–%d OF %d" % [start_index+1,end_index,title_cards.size()]
    if is_instance_valid(title_prev_button):
        title_prev_button.visible = title_page > 0
        title_prev_button.disabled = title_page <= 0
    if is_instance_valid(title_next_button):
        title_next_button.visible = title_page < page_count-1
        title_next_button.disabled = title_page >= page_count-1

func _hero_card(name: String, role: String, kit: String, accent: Color, class_id: String) -> Control:
    var panel: VBoxContainer = VBoxContainer.new()
    panel.custom_minimum_size = Vector2(200,220)
    panel.add_theme_constant_override("separation",4)

    var title: Label = Label.new()
    title.text = name
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size",19)
    title.add_theme_color_override("font_color",accent)
    panel.add_child(title)

    var role_label: Label = Label.new()
    role_label.text = role.to_upper()
    role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    role_label.add_theme_font_size_override("font_size",9)
    role_label.add_theme_color_override("font_color",Color(0.72,0.75,0.78,0.80))
    panel.add_child(role_label)

    var kit_label: Label = Label.new()
    kit_label.text = kit
    kit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    kit_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    kit_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    kit_label.add_theme_font_size_override("font_size",9)
    kit_label.add_theme_color_override("font_color",Color("#e2e7ea"))
    kit_label.custom_minimum_size = Vector2(194,96)
    panel.add_child(kit_label)

    var choose: Button = _menu_button("PLAY %s" % name)
    choose.custom_minimum_size = Vector2(194,40)
    choose.add_theme_font_size_override("font_size",12)
    choose.add_theme_stylebox_override("hover",_panel_style(accent.darkened(0.55),accent,2))
    choose.add_theme_stylebox_override("focus",_panel_style(accent.darkened(0.55),accent,2))
    choose.pressed.connect(func(): start_requested.emit(class_id))
    panel.add_child(choose)
    return panel

func _build_pause_overlay(root: Control) -> Control:
    var overlay: Control = Control.new()
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    root.add_child(overlay)
    var shade: ColorRect = ColorRect.new()
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.015,0.02,0.03,0.86)
    overlay.add_child(shade)
    var panel: VBoxContainer = VBoxContainer.new()
    panel.position = Vector2(430,170)
    panel.size = Vector2(420,390)
    panel.add_theme_constant_override("separation",13)
    overlay.add_child(panel)
    var title: Label = Label.new()
    title.text = "THE ROAD WAITS"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size",38)
    title.add_theme_color_override("font_color",Color("#f1e5c8"))
    panel.add_child(title)
    var spacer: Control = Control.new()
    spacer.custom_minimum_size = Vector2(1,18)
    panel.add_child(spacer)
    resume_button = _menu_button("RESUME")
    resume_button.pressed.connect(func(): pause_toggled.emit())
    panel.add_child(resume_button)
    var restart: Button = _menu_button("RESTART RUN")
    restart.pressed.connect(func(): restart_requested.emit())
    panel.add_child(restart)
    shake_toggle = CheckButton.new()
    shake_toggle.text = "Camera impact shake"
    shake_toggle.button_pressed = true
    shake_toggle.custom_minimum_size = Vector2(400,46)
    shake_toggle.add_theme_font_size_override("font_size",16)
    shake_toggle.toggled.connect(func(enabled): shake_changed.emit(enabled))
    panel.add_child(shake_toggle)
    var difficulty_label: Label = Label.new()
    difficulty_label.text = "DIFFICULTY"
    difficulty_label.add_theme_font_size_override("font_size",13)
    difficulty_label.add_theme_color_override("font_color",Color("#d8dde1"))
    panel.add_child(difficulty_label)
    var difficulty: OptionButton = OptionButton.new()
    difficulty.add_item("STORY — forgiving damage")
    difficulty.add_item("ADVENTURER — intended balance")
    difficulty.add_item("LEGEND — dangerous combat")
    difficulty.selected = 1
    difficulty.custom_minimum_size = Vector2(400,42)
    difficulty.item_selected.connect(func(index: int):
        var mode: String = "adventurer"
        if index==0: mode="story"
        elif index==2: mode="legend"
        difficulty_changed.emit(mode)
    )
    panel.add_child(difficulty)
    var quit_button: Button = _menu_button("QUIT TO DESKTOP")
    quit_button.pressed.connect(func(): quit_requested.emit())
    panel.add_child(quit_button)
    return overlay

func _build_victory_overlay(root: Control) -> Control:
    var overlay: Control = Control.new()
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    root.add_child(overlay)
    var shade: ColorRect = ColorRect.new()
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.02,0.024,0.035,0.92)
    overlay.add_child(shade)
    var title: Label = Label.new()
    title.name = "VictoryTitle"
    title.text = "THE WIZARD FALLS"
    title.position = Vector2(180,160)
    title.size = Vector2(920,90)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size",52)
    title.add_theme_color_override("font_color",Color("#f4d58a"))
    overlay.add_child(title)
    var body: Label = Label.new()
    body.name = "VictoryBody"
    body.text = "The Black Gate opens. The realm breathes again."
    body.position = Vector2(240,282)
    body.size = Vector2(800,80)
    body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    body.add_theme_font_size_override("font_size",21)
    body.add_theme_color_override("font_color",Color("#d8e1e5"))
    overlay.add_child(body)
    var replay: Button = _menu_button("CHOOSE ANOTHER CHAMPION")
    replay.position = Vector2(440,430)
    replay.size = Vector2(400,50)
    replay.pressed.connect(func(): restart_requested.emit())
    overlay.add_child(replay)
    var quit_button: Button = _menu_button("QUIT TO DESKTOP")
    quit_button.position = Vector2(440,496)
    quit_button.size = Vector2(400,50)
    quit_button.pressed.connect(func(): quit_requested.emit())
    overlay.add_child(quit_button)
    return overlay


func _build_shrine_overlay(root: Control) -> Control:
    var overlay: Control = Control.new()
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    root.add_child(overlay)
    var shade: ColorRect = ColorRect.new()
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.01,0.025,0.035,0.93)
    overlay.add_child(shade)

    shrine_title = Label.new()
    shrine_title.position = Vector2(190,105)
    shrine_title.size = Vector2(900,68)
    shrine_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    shrine_title.text = "SHRINE OF THE LAST ROAD"
    shrine_title.add_theme_font_size_override("font_size",40)
    shrine_title.add_theme_color_override("font_color",Color("#a7f0dc"))
    overlay.add_child(shrine_title)

    var instruction: Label = Label.new()
    instruction.position = Vector2(250,174)
    instruction.size = Vector2(780,42)
    instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    instruction.text = "Choose one permanent blessing. Each shrine remembers your choice."
    instruction.add_theme_font_size_override("font_size",16)
    instruction.add_theme_color_override("font_color",Color("#d4e5df"))
    overlay.add_child(instruction)

    var options: VBoxContainer = VBoxContainer.new()
    options.position = Vector2(350,218)
    options.size = Vector2(580,440)
    options.add_theme_constant_override("separation",5)
    overlay.add_child(options)

    var vitality: Button = _menu_button("VITALITY  //  +24 MAX HEALTH")
    vitality.pressed.connect(func(): shrine_upgrade_requested.emit("vitality"))
    options.add_child(vitality)
    shrine_buttons["vitality"] = vitality

    var might: Button = _menu_button("MIGHT  //  +12% DAMAGE")
    might.pressed.connect(func(): shrine_upgrade_requested.emit("might"))
    options.add_child(might)
    shrine_buttons["might"] = might

    var swift: Button = _menu_button("SWIFTNESS  //  FASTER MOVE, JUMP & DASH")
    swift.pressed.connect(func(): shrine_upgrade_requested.emit("swiftness"))
    options.add_child(swift)
    shrine_buttons["swiftness"] = swift

    var resilience: Button = _menu_button("RESILIENCE  //  -10% INCOMING DAMAGE")
    resilience.pressed.connect(func(): shrine_upgrade_requested.emit("resilience"))
    options.add_child(resilience)
    shrine_buttons["resilience"] = resilience

    var devotion: Button = _menu_button("DEVOTION  //  +20% RESOURCE GAIN")
    devotion.pressed.connect(func(): shrine_upgrade_requested.emit("devotion"))
    options.add_child(devotion)
    shrine_buttons["devotion"] = devotion

    var renewal: Button = _menu_button("RENEWAL  //  +25% HEALING RECEIVED")
    renewal.pressed.connect(func(): shrine_upgrade_requested.emit("renewal"))
    options.add_child(renewal)
    shrine_buttons["renewal"] = renewal

    var steadfast: Button = _menu_button("STEADFAST  //  -25% KNOCKBACK")
    steadfast.pressed.connect(func(): shrine_upgrade_requested.emit("steadfast"))
    options.add_child(steadfast)
    shrine_buttons["steadfast"] = steadfast

    var ascension: Button = _menu_button("ASCENSION  //  START WITH 35% RESOURCE")
    ascension.pressed.connect(func(): shrine_upgrade_requested.emit("ascension"))
    options.add_child(ascension)
    shrine_buttons["ascension"] = ascension
    return overlay

func _build_dialogue_panel(root: Control) -> Control:
    var panel: Control = Control.new()
    panel.position = Vector2(170,485)
    panel.size = Vector2(940,145)
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(panel)

    var bg: ColorRect = ColorRect.new()
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.025,0.03,0.045,0.94)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(bg)

    dialogue_speaker = Label.new()
    dialogue_speaker.position = Vector2(24,16)
    dialogue_speaker.size = Vector2(890,26)
    dialogue_speaker.add_theme_font_size_override("font_size",16)
    dialogue_speaker.add_theme_color_override("font_color",Color("#f0d082"))
    panel.add_child(dialogue_speaker)

    dialogue_text = Label.new()
    dialogue_text.position = Vector2(24,48)
    dialogue_text.size = Vector2(890,66)
    dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_text.add_theme_font_size_override("font_size",17)
    dialogue_text.add_theme_color_override("font_color",Color("#e1e7ea"))
    panel.add_child(dialogue_text)

    var next: Label = Label.new()
    next.position = Vector2(24,112)
    next.size = Vector2(890,22)
    next.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    next.text = "E  CONTINUE"
    next.add_theme_font_size_override("font_size",12)
    next.add_theme_color_override("font_color",Color(0.75,0.82,0.86,0.74))
    panel.add_child(next)
    return panel

func _title_nav_button(text: String) -> Button:
    var button: Button = Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(64,44)
    button.add_theme_font_size_override("font_size",18)
    var normal: StyleBoxFlat = _panel_style(Color("#202832"), Color("#576675"), 1)
    var hover: StyleBoxFlat = _panel_style(Color("#303847"), Color("#d0a45b"), 2)
    var pressed: StyleBoxFlat = _panel_style(Color("#3b2c42"), Color("#e7bd72"), 2)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_color_override("font_color", Color("#e8e0cf"))
    button.add_theme_color_override("font_hover_color", Color("#fff1c9"))
    return button

func _menu_button(text: String) -> Button:
    var button: Button = Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(400,50)
    button.add_theme_font_size_override("font_size",17)
    var normal: StyleBoxFlat = _panel_style(Color("#202832"), Color("#576675"), 1)
    var hover: StyleBoxFlat = _panel_style(Color("#303847"), Color("#d0a45b"), 2)
    var pressed: StyleBoxFlat = _panel_style(Color("#3b2c42"), Color("#e7bd72"), 2)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_color_override("font_color", Color("#e8e0cf"))
    button.add_theme_color_override("font_hover_color", Color("#fff1c9"))
    return button

func _style_bar(bar: ProgressBar, background: Color, fill: Color) -> void:
    bar.add_theme_stylebox_override("background", _panel_style(background, Color(0.25,0.29,0.33,0.7), 1))
    bar.add_theme_stylebox_override("fill", _panel_style(fill, fill.lightened(0.12), 0))

func _panel_style(color: Color, border: Color, border_width: int) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = color
    style.border_color = border
    style.border_width_left = border_width
    style.border_width_top = border_width
    style.border_width_right = border_width
    style.border_width_bottom = border_width
    style.corner_radius_top_left = 6
    style.corner_radius_top_right = 6
    style.corner_radius_bottom_left = 6
    style.corner_radius_bottom_right = 6
    return style

func bind_player(player: Hero) -> void:
    player.health_changed.connect(func(v, m):
        health_bar.max_value = m
        health_bar.value = v
    )
    player.resource_changed.connect(func(v, m):
        resource_bar.max_value = m
        resource_bar.value = v
    )
    player.identity_changed.connect(_on_identity_changed)
    _on_identity_changed(player.display_name, player.resource_name, player.resource_color, player.resource_help)
    health_bar.max_value = player.max_health
    health_bar.value = player.health
    resource_bar.max_value = player.max_resource
    resource_bar.value = player.resource

func _on_identity_changed(name: String, resource_name_value: String, resource_color_value: Color, help: String) -> void:
    hero_label.text = "%s  //  THE LAST ROAD" % name
    var hero_color: Color = Color("#f0c67a")
    if name == "MAGE":
        hero_color = Color("#79cfff")
    elif name == "ROGUE":
        hero_color = Color("#c48cff")
    elif name == "PALADIN":
        hero_color = Color("#f1dc82")
    elif name == "ARCHER":
        hero_color = Color("#7fe0a7")
    elif name == "BARBARIAN":
        hero_color = Color("#e77d5b")
    elif name == "FIGHTER":
        hero_color = Color("#e4bd73")
    elif name == "MONK":
        hero_color = Color("#7fe2cf")
    elif name == "RANGER":
        hero_color = Color("#91d16f")
    elif name == "CLERIC":
        hero_color = Color("#b9dcef")
    hero_label.add_theme_color_override("font_color",hero_color)
    resource_caption.text = "%s  //  %s" % [resource_name_value, help]
    resource_caption.add_theme_color_override("font_color", resource_color_value.lightened(0.16))
    _style_bar(resource_bar, Color("#161c22"), resource_color_value)

func set_shards(current: int, total: int) -> void:
    shard_label.text = "ARCANE SHARDS  %d / %d" % [current,total]
    if current >= total:
        shard_label.add_theme_color_override("font_color",Color("#d9f6ff"))

func set_objective(text: String) -> void:
    objective_label.text = "OBJECTIVE  //  %s" % text.to_upper()

func bind_miniboss(miniboss: Node, title: String = "THE GRAVE KNIGHT  //  VILLAGE WARDEN") -> void:
    miniboss_box.visible = true
    boss_box.visible = false
    miniboss_label.text = title
    var maximum: float = float(miniboss.get("max_health"))
    var current: float = float(miniboss.get("health"))
    miniboss_bar.max_value = maximum
    miniboss_bar.value = current
    miniboss.connect("health_changed",func(v: float, m: float):
        miniboss_bar.max_value = m
        miniboss_bar.value = v
    )

func hide_miniboss() -> void:
    miniboss_box.visible = false

func bind_boss(boss: EvilWizardBoss) -> void:
    miniboss_box.visible = false
    boss_box.visible = true
    boss.health_changed.connect(func(v, m):
        boss_bar.max_value = m
        boss_bar.value = v
    )
    boss.phase_changed.connect(set_boss_phase)
    set_boss_phase(boss.phase)

func set_boss_phase(phase: int) -> void:
    var roman: String = "I"
    if phase == 2:
        roman = "II"
    elif phase >= 3:
        roman = "III"
    boss_label.text = "THE EVIL WIZARD  //  PHASE %s" % roman

func bind_true_wizard(boss: Node) -> void:
    miniboss_box.visible = false
    boss_box.visible = true
    var maximum: float = float(boss.get("max_health"))
    var current: float = float(boss.get("health"))
    boss_bar.max_value = maximum
    boss_bar.value = current
    boss.connect("health_changed",func(v: float, m: float):
        boss_bar.max_value = m
        boss_bar.value = v
    )
    boss.connect("phase_changed",_set_true_wizard_phase)
    _set_true_wizard_phase(int(boss.get("phase")))

func _set_true_wizard_phase(phase_value: int) -> void:
    var roman: String = "I"
    if phase_value == 2:
        roman = "II"
    elif phase_value == 3:
        roman = "III"
    elif phase_value >= 4:
        roman = "IV"
    boss_label.text = "THE TRUE EVIL WIZARD  //  PHASE %s" % roman

func hide_boss() -> void:
    boss_box.visible = false

func show_title() -> void:
    title_overlay.visible = true
    pause_overlay.visible = false
    victory_overlay.visible = false
    gameplay_root.visible = false
    _show_title_page(title_page)

func hide_title() -> void:
    title_overlay.visible = false
    gameplay_root.visible = true

func show_pause() -> void:
    pause_overlay.visible = true
    resume_button.grab_focus()

func hide_pause() -> void:
    pause_overlay.visible = false

func show_victory(hero_name: String) -> void:
    gameplay_root.visible = false
    pause_overlay.visible = false
    victory_overlay.visible = true
    var body: Label = victory_overlay.get_node("VictoryBody") as Label
    body.text = "%s crossed the Last Road and broke the Wizard's hold.\nThe realm breathes again." % hero_name.capitalize()


func set_continue_available(available: bool) -> void:
    if not is_instance_valid(continue_button):
        return
    continue_button.disabled = not available
    continue_button.text = "CONTINUE" if available else "NO SAVED JOURNEY"

func show_shrine_choices(stage: int, owned_upgrades: Array[String]) -> void:
    var stage_name: String = "VILLAGE"
    if stage == 2:
        stage_name = "BLACK ROAD"
    elif stage == 3:
        stage_name = "DEEPWOOD"
    elif stage == 4:
        stage_name = "SUNKEN KEEP"
    elif stage == 5:
        stage_name = "MEMORY LABYRINTH"
    elif stage == 6:
        stage_name = "BLIGHTED MOUNTAINS"
    elif stage == 7:
        stage_name = "BLACK TOWER"
    elif stage >= 8:
        stage_name = "CROWN CHAMBER"
    shrine_title.text = "SHRINE OF THE LAST ROAD  //  %s" % stage_name

    var available_labels: Dictionary = {
        "vitality":"VITALITY  //  +24 MAX HEALTH",
        "might":"MIGHT  //  +12% DAMAGE",
        "swiftness":"SWIFTNESS  //  FASTER MOVE, JUMP & DASH",
        "resilience":"RESILIENCE  //  -10% INCOMING DAMAGE",
        "devotion":"DEVOTION  //  +20% RESOURCE GAIN",
        "renewal":"RENEWAL  //  +25% HEALING RECEIVED",
        "steadfast":"STEADFAST  //  -25% KNOCKBACK",
        "ascension":"ASCENSION  //  START WITH 35% RESOURCE"
    }
    var owned_labels: Dictionary = {
        "vitality":"VITALITY  //  ALREADY CLAIMED",
        "might":"MIGHT  //  ALREADY CLAIMED",
        "swiftness":"SWIFTNESS  //  ALREADY CLAIMED",
        "resilience":"RESILIENCE  //  ALREADY CLAIMED",
        "devotion":"DEVOTION  //  ALREADY CLAIMED",
        "renewal":"RENEWAL  //  ALREADY CLAIMED",
        "steadfast":"STEADFAST  //  ALREADY CLAIMED",
        "ascension":"ASCENSION  //  ALREADY CLAIMED"
    }

    for upgrade_id: String in shrine_buttons.keys():
        var button: Button = shrine_buttons[upgrade_id] as Button
        var owned: bool = upgrade_id in owned_upgrades
        button.disabled = owned
        button.text = str(owned_labels[upgrade_id] if owned else available_labels[upgrade_id])

    shrine_overlay.visible = true
    for upgrade_id: String in shrine_buttons.keys():
        var button: Button = shrine_buttons[upgrade_id] as Button
        if not button.disabled:
            button.grab_focus()
            break

func hide_shrine_choices() -> void:
    shrine_overlay.visible = false

func show_dialogue(speaker: String, text: String) -> void:
    dialogue_speaker.text = speaker.to_upper()
    dialogue_text.text = text
    dialogue_panel.visible = true

func hide_dialogue() -> void:
    dialogue_panel.visible = false

func set_interaction_prompt(text: String) -> void:
    interaction_label.text = text
    var visible_now: bool = not text.is_empty()
    interaction_label.visible = visible_now
    if is_instance_valid(interaction_backdrop):
        interaction_backdrop.visible = visible_now

func set_puzzle_status(title: String, current: int, total: int, hint: String = "") -> void:
    if title.is_empty() or total <= 0:
        puzzle_label.text = ""
        puzzle_label.visible = false
        return
    var marks: String = ""
    for i: int in range(total):
        marks += "◆ " if i < current else "◇ "
    puzzle_label.text = "%s  %d / %d   %s" % [title.to_upper(),current,total,marks.strip_edges()]
    if not hint.is_empty():
        puzzle_label.text += "\n%s" % hint.to_upper()
    puzzle_label.visible = true

func clear_puzzle_status() -> void:
    puzzle_label.text = ""
    puzzle_label.visible = false

func announce(text: String, seconds: float = 2.4) -> void:
    message.text = text
    message.modulate.a = 1.0
    var tween: Tween = create_tween()
    tween.tween_interval(seconds)
    tween.tween_property(message,"modulate:a",0.0,0.65)
