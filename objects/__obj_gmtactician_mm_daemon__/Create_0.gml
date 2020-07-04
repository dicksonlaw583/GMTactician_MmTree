///@desc Setup
if (os_browser == browser_not_a_browser) {
	congestionFactor = nativeCongestionFactor;
	congestionCut = nativeCongestionCut;
	slowStartIncrement = nativeSlowStartIncrement;
} else {
	congestionFactor = html5CongestionFactor;
	congestionCut = html5CongestionCut;
	slowStartIncrement = html5SlowStartIncrement;
}
tree = undefined;
callback = undefined;
progress = 0;
ready = false;
bestMove = undefined;
