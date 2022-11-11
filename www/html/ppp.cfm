<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Playit</title>
	<link rel="stylesheet" type="text/css" href="/tryit.css" />
	<script type="text/javascript">
	<!--
	function playit_onload()
	{
	var preval=""
	preval=document.getElementById("preselectedValue").value
	if (preval!="")
		{
		change_position(preval)
		var x=document.getElementsByTagName("input")
		var l=x.length
		for (i=0;i<l;i++)
			{
			if (x[i].value==preval)
				{
				x[i].checked=true
				}
			}
			document.getElementById("playitcontainer").style.display="block";
			}
	}
	
	function click_position(obj)
	{
	change_position(obj.value)
	displayad()
	}
	
	function change_position(val)
	{
	
	var s="demoDIV"
	
	s="myDIV"
		
	document.getElementById(s).style.borderImage=val;
	
	document.getElementById(s).style.WebkitBorderImage=val;
	
	document.getElementById(s).style.MozBorderImage=val;
	
	document.getElementById(s).style.OBorderImage=val;
		
	var x="border-image:<span id='enlargecssprop'>" + val + "</span>"
	var y="#myDIV<br />	{<br />	border-width:15px;<br />	width:250px;<br />	padding:10px 20px;<br />	###CSSPROP###;<br />	}<br />"
	var z=y.replace("###CSSPROP###",x)
	
		document.getElementById("styleDIV").innerHTML=z
	
	}
	
	function displayad()
	{
	//document.getElementById("adframe").src="/tryitbanner.asp?secid=playcss&rnd=" + Math.random();
	}
	//-->
	</script>
	<style type="text/css"> 
	body
	{
	font-family:verdana;
	font-size:12px;
	}
	
	#playitcontainer
	{
	width:960px;
	background-color:#e5eecc;
	border:1px solid #98bf21;
	margin:auto;
	
	}
	
	#enlargecssprop
	{
	font-weight:bold;
	font-size:14px;
	color:#000000;
	}
	
	#demoDIV
	{
	margin-left:10px;
	margin-top:3px;
	background-color:#ffffff;
	border:1px solid #c3c3c3;
	height:280px;
	width:430px;
	
	}
	
	#myDIV
	{
	border-width:15px;
	width:250px;
	padding:10px 20px;
	border-image:url(obr\border.png) 30 30 stretch;
	}	
	
	#styleDIV
	{
	font-family:courier new;
	margin-left:10px;
	background-color:#f1f1f1;
	border:1px solid #c3c3c3;
	width:424px;
	padding:3px;
	color:#222222;
	}
	
	div.demoHeader
	{
	font-size:14px;
	margin-top:5px;
	margin-left:5px;
	margin-bottom:2px;
	color:#617f10;
	}
	
	div.playitFooter
	{
	font-size:13px;
	color:#617f10;
	padding:10px;
	}
	
	#footer
	{
	margin:15px;
	}
	
	#myDIV
	{
	-webkit-border-image:url(obr\border.png) 30 30 stretch;
	-moz-border-image:url(obr\border.png) 30 30 stretch;	
	-o-border-image:url(obr\border.png) 30 30 stretch;		
	}
	</style>

	</head>
	<body onload="playit_onload()">
		
	<div id="playitcontainer">
	
		<div style="width:450px;float:left;">
				<div class="demoHeader">CSS Property:</div>

				<div style="font-size:14px;margin:10px;font-weight:bold;">border-image:</div>				
				
				<form style="margin:15px;" action="javascript:return false;">
					<input type="hidden" id="preselectedValue" value="" />
					
					<div><input autocomplete="off" type="radio" name="radio_position" onclick="click_position(this)" id="value_1" value="url(border.png) 30 30 stretch" checked='checked' /><label for="value_1">url(border.png) 30 30 stretch</label></div>
					
					<div><input autocomplete="off" type="radio" name="radio_position" onclick="click_position(this)" id="value_2" value="url(border.png) 30 30 round" /><label for="value_2">url(border.png) 30 30 round</label></div>
								
				</form>
				<div id="footer"><footer><p>Here is the image used:</p>

	<img src="obr\border.png"/></footer></div>
		</div>
		<div style="width:450px;float:left;">
			<div class="demoHeader">Result:</div>
	
			<div id="demoParent">
				<div id="demoDIV"><div id="myDIV">
	<b>Note:</b> Internet Explorer does not support the border-image property.
	</div></div>

			</div>
			<div class="demoHeader">CSS Code:</div>
			<div id="styleDIV">
			#myDIV<br />	{<br />	border-width:15px;<br />	width:250px;<br />	padding:10px 20px;<br />	border-image:<span id='enlargecssprop'>url(border.png) 30 30 stretch</span>;<br />	}<br />

			</div>
		</div>
		<div style="clear:both;"></div>
	
		<div class="playitFooter" style="float:left;">Click the property values 
			above to see the result</div>
		<div class="playitFooter" style="text-align:right;">
			<a style="color:#617f10" href="http://www.w3schools.com">
			W3Schools.com</a> - Play it
		</div>

		<div style="clear:both;"></div>
	</div>
	</body>