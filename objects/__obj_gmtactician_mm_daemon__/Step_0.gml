///@desc Keep ticking
if (is_struct(tree) && !ready) {
	// Use TCP Reno algorithm to adjust ticksPerStep
	var referenceFPS = (os_browser == browser_not_a_browser) ? fps_real : fps;
	if (referenceFPS < game_get_speed(gamespeed_fps)*congestionFactor) {
		ticksPerStep = max(ticksPerStep*(1-congestionCut), minTicksPerStep);
	} else {
		ticksPerStep += slowStartIncrement;
	}
	// Run ticks determined above until quota is met or tree is ready
	var ticksThisStep = 0;
	do {
		tree.evaluateTick();
	} until (++ticksThisStep >= ticksPerStep || tree.ready);
	progress = tree.getProgress();
	// If done
	if (tree.ready) {
		// Show that I'm done
		ready = true;
		progress = 1;
		// If the callback is given, run it and self-destruct
		bestMove = tree.getBestMove();
		if (!is_undefined(callback)) {
			if (is_method(callback)) {
				callback(bestMove)
			} else {
				script_execute(callback, bestMove);
			}
			instance_destroy();
		}
	}
}
