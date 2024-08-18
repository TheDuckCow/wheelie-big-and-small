extends Node


# When something causes the run to end, include the source node
# the caused the end.
@warning_ignore("unused_signal")
signal run_ended(obstacle)
