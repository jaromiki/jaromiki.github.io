$(function () {

	// menu
	menu();

  /*
   *  Bootstrap tabs
   */

  $('#najcitanejsieClankyTabs a').click(function (e) {
    e.preventDefault ? e.preventDefault() : e.returnValue = false;
    $(this).tab('show');
  });

  /*
   *  Css hasck
   */
  $('.box-small').filter(function (index) { return (index % 2 == 0); }).addClass('no-margin-left');
  $('#galeria li').filter(function (index) { return (index % 4 == 0); }).addClass('no-margin-left');

  var horoskopy = $('#horoskopy li');
  horoskopy.filter(
    function (index) { return (index % 4 == 3); }
  ).addClass('last');

  var katalogLinks = $('#katalog-links li');
  katalogLinks.filter(
    function (index) { return (index % 3 == 2); }
  ).addClass('last');

  horoskopy.filter(
    function (index) {
      return index % 12 == 8 || index % 12 == 9 || index % 12 == 10 || index % 12 == 11;
    }
  ).addClass('bottom-last');

  /*
   *  Gallery keyboard control
   */
  if ( $('a.galleryNavButton.next, a.galleryNavButton.prev').length ) {
    $(document).keydown(function(e) {
        if ( $('a.galleryNavButton.prev').length && e.keyCode === 37 ) {
            window.location.href = $('a.galleryNavButton.prev').attr('href');
        }
        if ( $('a.galleryNavButton.next').length && e.keyCode === 39 ) {
          var href = $('a.galleryNavButton.next').attr('href');
          if (href != '#') {
            window.location.href = $('a.galleryNavButton.next').attr('href');
          } else {
            $('html, body').animate({
                scrollTop: $('#galeria').offset().top
            }, 500 );
            event.preventDefault ? event.preventDefault() : event.returnValue = false;
          }
        }

    });
  }

  /*
   *  tooltip na galériu
   */
  if ( $('#galeriaTip').length > 0 ) { initGalleryTooltip(); }


  /*
   *  preklik na celý box
   */
  $('#content').find('.add-link').on('click', function(i, e){
    window.location.href = $(this).find('a.img-link').attr('href');
  });

  // FB button do popup
  $('body').on('click', '.likeArticle', function(e){
    e.preventDefault ? e.preventDefault() : e.returnValue = false;
    url = $(this).attr('href')
    fbShareBtn(url);
  });

  // ankety
  $( ".anketa a" ).click( anketa2 );
  $( ".anketa2 .answer-wrapper a" ).click( anketa2 );

});


function fbShareBtn(url) {
  var winTop = (screen.height / 2) - (520 / 2);
  var winLeft = (screen.width / 2) - (300 / 2);
  window.open(url, 'sharer', 'top=' + winTop + ',left=' + winLeft + ',toolbar=0,status=0,width=520,height=300');
}

function menu() {
	var menu_items_count = $("#primary-nav a").length;
	var relative_url = window.location.pathname;
	var menu_ready = false;
	var menu_selected = false;
	var article_regexp = /cl\/(\d+)\/(\d+)\/.*/gi;
	var section_id = false;

	if (relative_url != "/") {
		var is_article = relative_url.match(article_regexp);

		if (is_article) {
			var url_data;
			if ((url_data = article_regexp.exec(relative_url)) != null) {
				section_id = url_data[1];
				if ($("#primary-nav").find('a[href*="/se/' + section_id + '/"]').length) {
					$("#primary-nav").find('a[href*="/se/' + section_id + '/"]').parents('li').addClass('active');
					menu_selected = true;
				}
			}
		}
		if (!menu_selected) {
			var menu_item_href;
			$("#primary-nav a").each(function(index) {
				menu_item_href = $(this).attr('href');
				if (menu_item_href == "/")
					return true;

				if (relative_url.indexOf(menu_item_href) != -1) {
					$(this).parents('li').addClass('active');
					menu_selected = true;
				}

				if (menu_selected || index == menu_items_count - 1) {
					return false;
				}
			});
		}
	}
	if (!menu_selected && $('#primary-nav').data('show-first-menu-item')) {
		$("#primary-nav a:first").parent('li').addClass('active');
	}
}

function initGalleryTooltip() {
  $('#bageriaBigFoto').hover(
    function () {
      $('#galeriaTip').show();
    },
    function () {
      $('#galeriaTip').hide();
    }
  );
}

function anketa2() {
  var id = this.id;
  var tmp = id.split('poll-vote-',2)[1].split("-");
  var pid = tmp[0];
  var paid = tmp[1];
  var msg = "Nastala chyba in.";
  var parent = $(this).parent();

  $.post("/ajax/poll/vote/" + pid + "/" + paid, { cookie: "cookie" }, function(data){
    if(data.msg) {
      msg = data.msg;
    }
    var alert = $("#poll-alert-" + pid);
    alert.hide();
    alert.html(msg);
    alert.fadeIn("slow");
  }, "json");

  return false;
}