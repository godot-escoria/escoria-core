# `accept_input [type]`
#
# Sets how much input the game is to accept. This allows for cut scenes
# in which dialogue can be skipped (if [type] is set to SKIP), and ones where
# it can't (if [type] is set to NONE).
#
# **Parameters**
#
# - *type*: Type of inputs to accept (ALL)
#   `ALL`: Accept all types of user input
#   `SKIP`: Accept skipping dialogues but nothing else
#   `NONE`: Deny all inputs (including opening menus)
#
# **Warning**: `SKIP` and `NONE` also disable autosaves.
#
# **Warning**: The type of user input accepted will persist even after the
# current event has ended. Remember to reset the input type at the end of
# cut-scenes!
#
# @ESC
extends ESCBaseCommand
class_name AcceptInputCommand


# The list of supported input types
const SUPPORTED_INPUT_TYPES = ["ALL", "NONE", "SKIP"]


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		1,
		[TYPE_STRING],
		["ALL"]
	)


# Validate whether the given arguments match the command descriptor
func validate(arguments: Array):
	if not super.validate(arguments):
		return false

	if not arguments[0] in SUPPORTED_INPUT_TYPES:
		raise_error(self, "Invalid parameter. %s is not a valid value. " +
			"Should be one of: %s"
					% [
						arguments[0],
						str(SUPPORTED_INPUT_TYPES)
					])
		return false
	return true


# Run the command
func run(command_params: Array) -> int:
	var mode = escoria.inputs_manager.INPUT_ALL
	match command_params[0]:
		"NONE":
			mode = escoria.inputs_manager.INPUT_NONE
		"SKIP":
			mode = escoria.inputs_manager.INPUT_SKIP

	escoria.inputs_manager.input_mode = mode
	return ESCExecution.RC_OK


# Function called when the command is interrupted.
func interrupt():
	# Do nothing
	pass
