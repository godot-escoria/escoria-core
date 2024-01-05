# Manages settings
class_name ESCSettingsManager


# Template for settings filename
const SETTINGS_TEMPLATE: String = "settings.tres"

# Variable containing the settings folder obtained from Project Settings
var settings_folder: String

# Dictionary containing specific settings that gamedev wants to save in settings
# This variable is access-free. Getting its content is gamedev's duty.
# It is saved with other Escoria settings data when save_settings() is called.
var custom_settings: Dictionary


# Constructor of ESCSaveManager object.
func _init():
	# We leave the calls to ProjectSettings as-is since this constructor can be
	# called from escoria.gd's own.
	settings_folder = ProjectSettings.get_setting("escoria/main/settings_path")


# Apply the loaded settings
func apply_settings() -> void:
	if not Engine.is_editor_hint():
		escoria.logger.info(
			self,
			"******* settings loaded"
		)
		
		var bus_master := AudioServer.get_bus_index(escoria.BUS_MASTER)
		var bus_sfx := AudioServer.get_bus_index(escoria.BUS_SFX)
		var bus_music := AudioServer.get_bus_index(escoria.BUS_MUSIC)
		var bus_speech := AudioServer.get_bus_index(escoria.BUS_SPEECH)

		if bus_master >= 0:
			AudioServer.set_bus_volume_db(
				bus_master,
				linear2db(
					ESCProjectSettingsManager.get_setting(
						ESCProjectSettingsManager.MASTER_VOLUME
					)
				)
			)
		else:
			escoria.logger.error(
				self,
				"Missing audio bus %s!" % escoria.BUS_MASTER
			)
		
		if bus_sfx >= 0:
			AudioServer.set_bus_volume_db(
				bus_sfx,
				linear2db(
					ESCProjectSettingsManager.get_setting(
						ESCProjectSettingsManager.SFX_VOLUME
					)
				)
			)
		else:
			escoria.logger.error(
				self,
				"Missing audio bus %s!" % escoria.BUS_SFX
			)
		
		if bus_music >= 0:
			AudioServer.set_bus_volume_db(
				bus_music,
				linear2db(
					ESCProjectSettingsManager.get_setting(
						ESCProjectSettingsManager.MUSIC_VOLUME
					)
				)
			)
		else:
			escoria.logger.error(
				self,
				"Missing audio bus %s!" % escoria.BUS_MUSIC
			)
		
		if bus_speech >= 0:
			AudioServer.set_bus_volume_db(
				bus_speech,
				linear2db(
					ESCProjectSettingsManager.get_setting(
						ESCProjectSettingsManager.SPEECH_VOLUME
					)
				)
			)
		else:
			escoria.logger.error(
				self,
				"Missing audio bus %s!" % escoria.BUS_SPEECH
			)
		
		OS.window_fullscreen = ESCProjectSettingsManager.get_setting(
			ESCProjectSettingsManager.FULLSCREEN
		)
		TranslationServer.set_locale(
			ESCProjectSettingsManager.get_setting(
				ESCProjectSettingsManager.TEXT_LANG
			)
		)

		escoria.game_scene.apply_custom_settings(custom_settings)


func save_settings_resource_to_project_settings(settings: ESCSaveSettings):
	ESCProjectSettingsManager.set_setting(
		ESCProjectSettingsManager.TEXT_LANG,
		settings.text_lang
	)
	ESCProjectSettingsManager.set_setting(
		ESCProjectSettingsManager.VOICE_LANG,
		settings.voice_lang
	)
	ESCProjectSettingsManager.set_setting(
		ESCProjectSettingsManager.SPEECH_ENABLED,
		settings.speech_enabled
	)
	ESCProjectSettingsManager.set_setting(
		ESCProjectSettingsManager.MASTER_VOLUME,
		settings.master_volume
	)
	ESCProjectSettingsManager.set_setting(
		ESCProjectSettingsManager.MUSIC_VOLUME,
		settings.music_volume
	)
	ESCProjectSettingsManager.set_setting(
		ESCProjectSettingsManager.SFX_VOLUME,
		settings.sfx_volume
	)
	ESCProjectSettingsManager.set_setting(
		ESCProjectSettingsManager.SPEECH_VOLUME,
		settings.speech_volume
	)
	ESCProjectSettingsManager.set_setting(
		ESCProjectSettingsManager.FULLSCREEN,
		settings.fullscreen
	)
	custom_settings = settings.custom_settings


# Load the game settings from the settings file
func load_settings():
	var save_settings_path: String = \
			settings_folder.plus_file(SETTINGS_TEMPLATE)
	var file: File = File.new()
	if not file.file_exists(save_settings_path):
		escoria.logger.warn(
			self,
			"Settings file %s doesn't exist" % save_settings_path
					+ "Setting default settings."
		)
		save_settings()

	var settings: ESCSaveSettings = load(save_settings_path)
	save_settings_resource_to_project_settings(settings)


func get_settings() -> ESCSaveSettings:
	var settings: ESCSaveSettings = ESCSaveSettings.new()
	var plugin_config = ConfigFile.new()
	plugin_config.load("res://addons/escoria-core/plugin.cfg")
	settings.escoria_version = plugin_config.get_value("plugin", "version")

	settings.text_lang = ESCProjectSettingsManager.get_setting(
		ESCProjectSettingsManager.TEXT_LANG
	)
	settings.voice_lang = ESCProjectSettingsManager.get_setting(
		ESCProjectSettingsManager.VOICE_LANG
	)
	settings.speech_enabled = ESCProjectSettingsManager.get_setting(
		ESCProjectSettingsManager.SPEECH_ENABLED
	)
	settings.master_volume = ESCProjectSettingsManager.get_setting(
		ESCProjectSettingsManager.MASTER_VOLUME
	)
	settings.music_volume = ESCProjectSettingsManager.get_setting(
		ESCProjectSettingsManager.MUSIC_VOLUME
	)
	settings.sfx_volume = ESCProjectSettingsManager.get_setting(
		ESCProjectSettingsManager.SFX_VOLUME
	)
	settings.speech_volume = ESCProjectSettingsManager.get_setting(
		ESCProjectSettingsManager.SPEECH_VOLUME
	)
	settings.fullscreen = ESCProjectSettingsManager.get_setting(
		ESCProjectSettingsManager.FULLSCREEN
	)
	settings.custom_settings = custom_settings

	return settings



# Save the game settings in the settings file.
func save_settings():
	var settings = get_settings()

	var directory: Directory = Directory.new()
	if not directory.dir_exists(settings_folder):
		directory.make_dir_recursive(settings_folder)

	var save_path = settings_folder.plus_file(SETTINGS_TEMPLATE)
	var error: int = ResourceSaver.save(save_path, settings)
	if error != OK:
		escoria.logger.error(
			self,
			"There was an issue writing settings %s" % save_path
		)
