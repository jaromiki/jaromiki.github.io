
function addsmiley(emoticon) {
	document.signform.message.value=document.signform.message.value+emoticon;
	document.signform.message.focus();
	return;
}

function answer(user_id, user_name) {
	$("#odpovida_na").val(user_id);
	if (user_name == '')
		$("#odpovida").html('<strong>Napsat novou zprávu</strong>');
	else
		$("#odpovida").html('<strong>Odpovídáš na příspěvek od ' + user_name + '</strong> <a href="javascript: answer(\'\', \'\');">(zrušit odpověď)</a>');
	window.location.hash = '#komentuj';
	return;
} 

function hash(hash){
	window.location.hash = hash;
}




function focuson() { 
	document.signform.zprava.focus()
}

function check() {
	if(document.signform.jmeno.value==0)
	{
	alert("Zadej prosím své jméno nebo svůj nick.");
	document.signform.jmeno.focus();
	return false;
	}
	
	if(document.signform.zprava.value==0)
	{
    alert("Nenapsal/a jsi nic do pole se zprávou ...");
    document.signform.zprava.focus();
    return false;
    }
		
	if(document.signform.nazev_vlakna.value==0)
    {
    alert("Zadejte název vlákna.");
    document.signform.nazev_vlakna.focus();
    return false;
    }
}
