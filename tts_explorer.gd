extends CanvasLayer


@export var language_dropdown: OptionButton:
	set(value):
		language_dropdown = value
		language_dropdown.item_selected.connect(_on_language_selected)

@export var voices_dropdown: OptionButton:
	set(value):
		voices_dropdown = value
		voices_dropdown.item_selected.connect(_on_voice_selected)

@export var speaking_pitch: HSlider

@export var speaking_rate: HSlider

@export var speak_text: TextEdit

@export var speak_button: Button:
	set(value):
		speak_button = value
		speak_button.pressed.connect(_on_speak_button_pressed)

var _languages: Array[String] = []

var _voices: Dictionary = {}

var _voice_map: Array[TTSVoice] = []


func _ready():
	if not ProjectSettings.get_setting("audio/general/text_to_speech"):
		OS.alert("Before running this demo, please first enable TTS support in the Project Settings ('audio/general/text_to_speech').", "TTS not enabled.")
		get_tree().quit()
		return
	if OS.has_feature("web"):
		OS.alert("Text-to-speech is not supported for web exports", "TTS not supported.")
		get_tree().quit()
		return
	_detect_voices()
	_populate_languages()
	_populate_voice_selection()


func _populate_languages():
	for language: String in _languages:
		language_dropdown.add_item(language)


func _on_language_selected(_value):
	_populate_voice_selection()


func _on_voice_selected(_value):
	_on_speak_button_pressed()


func _get_current_language() -> String:
	if language_dropdown.selected > -1:
		return _languages[language_dropdown.selected]
	return ""


func _populate_voice_selection():
	var language = _get_current_language()
	if not language:
		return
	voices_dropdown.clear()
	_voice_map.clear()
	for voice_name: String in _voices:
		var voice: TTSVoice = _voices[voice_name]
		if voice.speaks(language):
			_voice_map.append(voice)
			voices_dropdown.add_item("%s" % [voice.name], _voice_map.find(voice))


func _detect_voices():
	var voices: Array[Dictionary] = DisplayServer.tts_get_voices()
	for v: Dictionary in voices:
		# Track the list of 1unique languages
		if not _languages.has(v.language):
			_languages.append(v.language)
		
		# Build out the voice data model
		var voice: TTSVoice
		if not _voices.has(v.name):
			voice = TTSVoice.new()
			voice.name = v.name
			_voices[v.name] = voice
		voice = _voices[v.name]
		voice.add_language(v.id, v.language)

		print("Name: %20s ID: %s Lang: %s" % [v.name, v.id, v.language])


func _on_speak_button_pressed():
	var language = _get_current_language()
	var voice_id = _voice_map[voices_dropdown.selected].get_id_from_language(language)
	
	if DisplayServer.tts_is_speaking():
		DisplayServer.tts_stop()
	
	DisplayServer.tts_speak(speak_text.text, voice_id, 100, speaking_pitch.value, speaking_rate.value)


class TTSVoice:
	
	## The name of the voice
	var name: String
	
	## List of languages the voice supports
	var languages: Array[TTSLanguage]
	
	## Adds a the voice ID and language_name for a particular language the voice supports
	func add_language(id: String, language_name: String):
		var language := TTSLanguage.new()
		language.id = id
		language.name = language_name
		languages.append(language)

	## Retrieves the TTS Voice ID for a particular language
	func get_id_from_language(language_name: String) -> String:
		for language in languages:
			if language.name == language_name:
				return language.id
		return ""
	
	## Whether the voice supports the [param language_name].
	func speaks(language_name: String) -> bool:
		for language in languages:
			if language.name == language_name:
				return true
		return false


class TTSLanguage:
	var id: String
	var name: String
