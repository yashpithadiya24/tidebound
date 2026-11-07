extends Node
## Global signal hub. Systems talk through signals here (02 section 3).
## Each chat adds its own signals, in past tense.

## Emitted when the tide phase or the water index changes (also when an event changes the index).
@warning_ignore("unused_signal")
signal tide_phase_changed(phase: String, index: int)
