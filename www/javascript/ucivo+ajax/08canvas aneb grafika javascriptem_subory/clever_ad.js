function clever_ad() {	
	var left = $("#container").offset().left - 162;

	$(".clever_ad").css("position", "fixed");
	$(".clever_ad").css("left", left);
	$(".clever_ad").css("top", 350);
}
			
$(window).scroll(function() {clever_ad();});
$(window).resize(function() {clever_ad();});