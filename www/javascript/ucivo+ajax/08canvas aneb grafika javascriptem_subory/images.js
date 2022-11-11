function select_image(id, ind)
{
	$("#image").fadeOut(200, function() {	
		$(this).html('<img src="scripts/image.php?id=' + id + '&ind=' + ind + '" alt="" />');
		$(this).fadeIn();
	});
}