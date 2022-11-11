$(function() {

    $smiley_dialog = $( "#smiley-dialog" );
    $smiley_dialog.dialog({ autoOpen: false });

	$("#btn").click(function() {
        if ($("#tags").is(":visible"))
        {
            $("#tags").hide(50);
        }
        else
        {
            $("#tags").show(50);
            $("#tags").focus();
        }
	});

    $( "#smileys" ).click(function() {
        if ($smiley_dialog.dialog('isOpen'))
            $smiley_dialog.dialog('close');
        else
            $smiley_dialog.dialog('open');
	});

	function appendFound() {
		$("#message").val($("#message").val() + "@" + firstFound + "@");
        $("#tags").val('');
		$("#tags").hide(50);
		firstFound = "";
	}

	$("#tags").keydown(function(e) {
		if (e.keyCode == 13) {
                e.preventDefault();
		   }
	});

	$("#bold").click(function() {
		tagSelected('**');
    });

    $("#italic").click(function() {
        tagSelected('*');
    });

    $("#code").click(function() {
        tagSelected('[code]', '[/code]');
    });

    $("#message").keydown(function(e) {
		if(e.keyCode == 'B'.charCodeAt(0) && e.ctrlKey)
			tagSelected('**');
        if(e.keyCode == 'I'.charCodeAt(0) && e.ctrlKey)
			tagSelected('*');
	});

	function tagSelected(tag, tag2)
	{
		var start = $('#message')[0].selectionStart;
		var end = $('#message')[0].selectionEnd;
		var length = tag.length;
        var length2 = length;

        if (tag2 == undefined)
            tag2 = tag;
        else
            length2 = tag2.length;

		if (($('#message').val().substring(start - length, start) == tag) && $('#message').val().substring(end, end + length2) == tag2)
		{
			$('#message').val($('#message').val().substring(0, start - length) + $('#message').val().substring(start, end) + $('#message').val().substring(end + length2));

			$('#message').focus();
			$('#message')[0].setSelectionRange(start - length, end - length);
		}
		else
		{
			$('#message').val($('#message').val().substring(0, start) + tag + $('#message').val().substring(start, end) + tag2 + $('#message').val().substring(end));

			$('#message').focus();
			$('#message')[0].setSelectionRange(start + length, end + length);
		}
	}


});

function appendSmiley(smiley)
{
    var end = $('#message')[0].selectionEnd;

    $('#message').val($('#message').val().substring(0, end) + smiley + $('#message').val().substring(end));
    $smiley_dialog.dialog("close");
}