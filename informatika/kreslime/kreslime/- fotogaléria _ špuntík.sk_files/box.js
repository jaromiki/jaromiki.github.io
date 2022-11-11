/**
* Swipr 1.1
*
* Upravena verzia. Pridal som fallback pre $.fn.on()
*
*
* A responsive, mobile friendly, javascript and CSS3 slider
*
* @author Björn Wikström <bjorn@welcom.se>
* @license LGPL v3 <http://www.gnu.org/licenses/lgpl.html>
* @version 1.1
* @copyright Welcom Web i Göteborg AB 2013
*/
;(function(window,document,$,undef){if(typeof window.Swipr!==typeof undef)return;var Swipr=function(el,options){this.options=$.extend({auto:0,speed:500,resizable:true,startAt:0,selector:".swipe-item",onSwipeStart:function(){},onSwipeEnd:function(){}},options);this.$container=$(el);this.$items=$(this.options.selector,el);this._index=this.options.startAt||0;this._intervalId=0;var LEFT=-1,RIGHT=1;var _touchStartEvent=function(){return window.navigator.msPointerEnabled?"MSPointerDown":"touchstart"}(),
_touchMoveEvent=function(){return window.navigator.msPointerEnabled?"MSPointerMove":"touchmove"}(),_touchEndEvent=function(){return window.navigator.msPointerEnabled?"MSPointerUp":"touchend"}();this.has=function(){return{"touch":!!function(){return"ontouchstart"in window||(window.DocumentTouch&&document instanceof DocumentTouch||window.navigator.msMaxTouchPoints)}(),"transitions":!!function(){var style=document.createElement("div").style;return"transition"in style||("WebkitTransition"in style||("MozTransition"in
style||("msTransition"in style||"OTransition"in style)))}()}}();this.next=function(){if(this._index===this.$items.length-1)this._index=0;else this._index++;this.slideTo(this._index)};this.prev=function(){if(this._index===0)this._index=this.$items.length-1;else this._index--;this.slideTo(this._index)};this.index=function(){return this._index};this.stop=function(){clearInterval(this._intervalId)};this.restart=function(){if(this.options.auto){var self=this;this._intervalId=setInterval(function(){self.next()},
this.options.auto)}};var _animate=function(fromPosX,toPosX){var left=this.$movable.position().left;var style=this.$movable.get(0).style;style.webkitTransitionDuration=style.MozTransitionDuration=style.msTransitionDuration=style.OTransitionDuration=style.transitionDuration="0ms";style.webkitTransform="translate3d("+(left+(toPosX-fromPosX))+"px,0,0)";style.msTransform=style.MozTransform=style.OTransform="translateX("+(left+(toPosX-fromPosX))+"px)"};this.slideTo=function(index,speed,force){index=index>=
0?index:0;index=index<this.$items.length?index:this.$items.length-1;this.options.onSwipeStart.call(this,index);this._index=index;var style=this.$movable.get(0).style,posX=-1*(this.$container.width()*index);speed=speed||this.options.speed;var self=this;setTimeout(function(){self.options.onSwipeEnd.call(self,index)},speed);if(!this.has.transitions||force){_animatedSlide.call(this,posX,speed,index);return}style.webkitTransitionDuration=style.MozTransitionDuration=style.msTransitionDuration=style.OTransitionDuration=
style.transitionDuration=speed+"ms";style.webkitTransform="translate3d("+posX+"px,0,0)";style.msTransform=style.MozTransform=style.OTransform="translateX("+posX+"px)"};var _animatedSlide=function(posX,speed,index){var self=this;this.$movable.animate({"left":posX+"px"},speed)};var self=this;var _ontouch=function(e){this._x=e.touches?e.touches[0].pageX:e.pageX;this._y=e.touches?e.touches[0].pageY:e.pageY;this._scroll=false;this._direction=undef;this._reset=false;this._offset=self.$movable.offset().left;
this._timeId=0};var _onmove=function(e){if(e.touches&&e.touches.length>1)return;var pageX=e.touches?e.touches[0].pageX:e.pageX,pageY=e.touches?e.touches[0].pageY:e.pageY;if(!this._scroll&&Math.abs(Math.abs(this._y)-Math.abs(pageY))>Math.abs(Math.abs(this._x)-Math.abs(pageX)))return;e.preventDefault();self.stop();this._scroll=true;this._direction=this._x<pageX?RIGHT:LEFT;if(window.navigator.msPointerEnabled&&(pageX<self.$container.offset().left||pageX>self.$container.offset().left+self.$container.width()))_onend.call(this,
null,true);_animate.call(self,this._x,pageX);this._x=pageX};var _onend=function(e,forceAnimation){if(this._scroll){self._index-=this._direction;if(self._index>self.$items.length-1)self._index=self.$items.length-1;if(self._index<1)self._index=0;self.slideTo(self._index,100,!!forceAnimation)}};var _resetSizes=function(){this.$items.css({"width":this.$container.width()+"px"});this.$movable.css({"width":"99999px"});this._offset=this.$movable.offset().left};var _init=function(){if(this.$items.length<2)return;
var self=this;this.$movable=$('<div style="overflow: hidden; position: relative;"></div>');this.$items.appendTo(this.$movable.appendTo(self.$container));_startTouchSwipe.call(self);_resetSizes.call(this);if(this.options.auto)this._intervalId=setInterval(function(){self.next()},this.options.auto);if(this.options.resizable){var timeoutId=0;if(typeof $.fn.on!="undefined")$(window).on("resize",function(){clearTimeout(timeoutId);timeoutId=setTimeout(function(){_resetSizes.call(self);self.slideTo(self.index(),
0)},50)});else $(window).bind("resize",function(){clearTimeout(timeoutId);timeoutId=setTimeout(function(){_resetSizes.call(self);self.slideTo(self.index(),0)},50)})}};var _startTouchSwipe=function(){if(this.has.touch){if(window.navigator.msPointerEnabled)this.$container.css("-ms-touch-action","pan-y");this.$container.get(0).addEventListener(_touchStartEvent,_ontouch,false);this.$container.get(0).addEventListener(_touchMoveEvent,_onmove,false);this.$container.get(0).addEventListener(_touchEndEvent,
_onend,false)}};_init.call(this)};window.Swipr=Swipr;$.fn.Swipr=function(options){$.each(this,function(){new Swipr(this,options)})}})(window,window.document,jQuery);

/**
* Swipr Batteries 1.0
*
* Upravena verzia. Pridal som fallback pre $.fn.on()
* Extensions for Swipr, with UI elements and functionality
* for different use cases.
*
* @author Björn Wikström <bjorn@welcom.se>
* @license LGPL v3 <http://www.gnu.org/licenses/lgpl.html>
* @version 1.0
* @copyright Welcom Web i Göteborg AB 2013
*/
;(function(window,document,$,undef){if(!window.Swipr)throw{"type":"InitializationException","message":"Swipr.Batteries can not be loaded before Swipr."};var attachIndicators=function(swipr,options){var original_slideTo=swipr.slideTo;var opts=$.extend({"container-class":"swipr-indicators","indicator-class":"swipr-indicator"},options);var $container=$('<div class="'+opts["container-class"]+'"></div>'),$indicators=[];var _indicatorUpdate=function(){$indicators.removeClass("active").eq(swipr.index()).addClass("active")};
var _slideTo=function(index,speed,force){original_slideTo.call(swipr,index,speed,force);setTimeout(function(){_indicatorUpdate()},speed)};var _setup=function(){$container.appendTo(this.$container);this.$items.each(function(){$container.append('<span class="'+opts["indicator-class"]+'"></span>')});$indicators=$("span",$container);$indicators.first().addClass("active");if(typeof $.fn.on!="undefined")$indicators.on("click",function(e){swipr.stop();swipr.slideTo($(this).index(),swipr.options.speed,false)});
else $indicators.bind("click",function(e){swipr.stop();swipr.slideTo($(this).index(),swipr.options.speed,false)})};_setup.call(swipr);swipr.slideTo=_slideTo};var attachSlideControls=function(swipr,options){var opts=$.extend({"base-ctrl-class":"swipr-control-base","prev-ctrl-class":"swipr-control-prev","next-ctrl-class":"swipr-control-next","prev-ctrl-html":"<span></span>","next-ctrl-html":"<span></span>"},options);var $ctrlPrev=$("<div></div>"),$ctrlNext=$("<div></div>"),$container=$("<div></div>");
if(typeof $.fn.on!="undefined"){$ctrlPrev.on("click",function(e){swipr.stop();swipr.prev()});$ctrlNext.on("click",function(e){swipr.stop();swipr.next()})}else{$ctrlPrev.bind("click",function(e){swipr.stop();swipr.prev()});$ctrlNext.bind("click",function(e){swipr.stop();swipr.next()})}var _setup=function(){$ctrlPrev.addClass(opts["prev-ctrl-class"]+" "+opts["base-ctrl-class"]).html(opts["prev-ctrl-html"]);$ctrlNext.addClass(opts["next-ctrl-class"]+" "+opts["base-ctrl-class"]).html(opts["next-ctrl-html"]);
$container.css({"width":this.$container.width()+"px","overflow-x":"hidden"});$container.prependTo(this.$container);this.$movable.appendTo($container);this.$container.css("overflow","visible");this.$container.append($ctrlPrev).append($ctrlNext)};_setup.call(swipr)};window.Swipr.Batteries=function(){return{"attachIndicators":attachIndicators,"attachSlideControls":attachSlideControls}}()})(window,window.document,jQuery);




// box init
;(function(){

  var BoxiParkTab = {
    name: '',
    title: '',
    image: '',
    discount: '',
    price: '',
    url: '',
    maxItems: 10,

    generate: function(tab) {

      var discount = tab.discount[0].value;
      //var discount_parse = tab.discount[0].value.match(/(\d{1,3}%)$/);
      var discount_parse = tab.discount[0].value.match(/(-?[0-9]\d%)/);
      if (discount_parse) {
        discount = '<i>' + discount_parse[1] + '</i>';
      }

      var html = '<div class="tab clearfix">';
      html += '<a href="' + tab.url[0].value + '" target="_blank" class="clearfix">';
      html += '<img src="' + tab.image[0].value + '" alt="" width="120" />';
      html += '<b class="nazov">' + tab.name[0].value + '</b>';
      html += '<span class="autor">' + tab.title[0].value + '</span>';
      html += '<div class="holder">';
      html += '<span class="cena">' + tab.price[0].value + '</span>';
      html += '<span class="zlava">' + discount + '</span>';
      html += '</div>';
      html += '</a></div>';

      return html;
    }
  };

  var BoxiPark = {
    identifier: '#box-ipark',
    tabs: [],
    settings: {
      title: '',
      id: 'iPark-banner',
      feed: 'default',
      cssVer: 6
    },

    init: function() {
      BoxiPark.getSettings();
      BoxiPark.getData();
    },
    isValid: function() {
      return true;
    },
    tabsCount: function() {
      return BoxiPark.tabs.length;
    },
    getSettings: function() {
      var dataFeed = $(BoxiPark.identifier).attr('data-feed');
      if ( dataFeed != 'undefined' || 'default' ) {
        BoxiPark.settings.feed = dataFeed;
      }
    },
    getData: function() {
      var timestamp = parseInt(new Date().getTime() / 900000);
      var filename = 'ipark_'+BoxiPark.settings.feed+'.json';
      $.ajax({
        type: "GET",
        url: "http://img.topky.sk/json/"+filename+"?t="+timestamp,
        dataType: "jsonp",
        jsonp : "callback",
        scriptCharset: 'utf-8',
        contentType: "application/json; charset=utf-8",
        jsonpCallback: "BoxiPark_zjsonp",
        success: function (data){
          BoxiPark.zjsonp(data);
        },
        error: function (e) {
          //console.log(e.message);
        }
      });
    },
    zjsonp: function(data) {
      // zamiesame
      shuffledData = BoxiPark.shuffle(data.data[0].item);
      // orezeme na pocet maxItems
      BoxiPark.tabs = shuffledData.slice(0,BoxiParkTab.maxItems);

      if (BoxiPark.tabsCount()) {
        BoxiPark.generate();
      }
    },
    generate: function() {
      if (!BoxiPark.isValid()) {
        return false;
      }

      var html_data = '<div id="' + BoxiPark.settings.id + '" class="clearfix hidden">';
      html_data += '<a href="http://www.ipark.sk/" id="ipark-logo"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFQAAAAVCAYAAADYb8kIAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAABqhJREFUeNrsWV1sFFUUPjPdtrAL3eUnRIuk29KAfTBdlAq+wBSNDyDQRB6sP3QbH0yMwEStIYKwoA2oiSyJ0VATGIyE8uQSfkyI4hYTXyplGwkaUmQBg5gozLrbZf9mxnNn7mzvTGe2FY0JSW9yOjP3d+a73/nOuVsOKpTC0dUNeAlRI0VGS9R0nh6AqeJYOKfK/BdrVmJLBG8Fl3Gy+sfFGA6PTN+SvDYFowug+cPP+PEiYW1HpUGaUgBVvkwfONH7+tX9Tv36D23bgpcAmfO57t7/FXhceydeCCkA1+b+g/lW4iVOHyM45y6nfh7zJndwrV9TtTjj3u6A5rMAJd58jGY/bAp5e37pdugaNW+yHy1M4iXsMmUSNIh737hy+H5naBlQUBF9jhsP5ox5wM9uBG5OE6i//Qja7ato1wEUnu0Vzu5tTni3jtiZam5QAhR9bqHCu4SzHzSLpI/3rZHUfQ1orm/dTgTUAiY3pxE8y18Gvv6RscolnfqlNChB8dzHyNS0hY2j7y2K+bZfLrs2ukV7maF7mtn5iawkDbrrkhCm0hDCZwLqrvsW0LufrPdriiZawJzbCNVreoGr9TkPagsDv2AZ5D7fiLthAZVoVjejO60UqIR24xjbT/LtGClnCtne5oim6BkEKR0moDi+gbI6yGQZRI9TtN1vShTWDdD+pqyEXLTQz2YtOG54gj763BPoq/mdyFAVX4DjAuXWGh/UrDXA1PKjyMZ+UH4+CxoBjuehun0TeFqeBP6BFqhesQkKX+2xuG3mnRZxxrs/pRgNJYAIWoF3fSHvtpFUZvuiOO0boh8UddHcCLYLFIiQGSiwjmxEjOmXcFmOjRNk/mEbOF107QBTRzZSdAGzS/c4uiavKZyABqZVLVpVZmbh1F4oXTgJnG8ecDMfBPXPW5hSbYbikPHe1cs3Yv1DRoAyTeEcMwSt6LHYuPaCJ2i0Vcn0Y8LlgGWAkKTPATbYWWRkjMXARGT24w8xYJJIfdghkkt0DZnOIVNLujAzymygwKup2yGtUEQgQDe+aZneqty4CMqV88A3Lofazn0wresAeN88gwDOh8Lx98uTVi1+CrQSx1rQkRc5j9VoSb8W8qc3tx6CvCdotFXHaIpFGBHG+0aqxSHmo5yCGwFBxL6zaJokO6Rw5iZJLmkPOy9Zu53MR2XISRbiDPikf4rX5DtB9eZ1UIj9fhNpmTcAvfQdqLd+Bc/Dq8a0dXodVLUggJlRUEYGjbqaOitDS86ujcxjLf7Xq0s0YprKyVqJDxv1vIzjzdxxv8kgypwwyxJaZ2EoGVMhhywzCft1TyK+hCkDwUlnGTB13Tf7eKBEc95SifxBJFUzjQLSpmXTVmAyab2em11v6TdhKUx4xMC0jRdn9g1dYwJSpELuOj6XdS8xl3sn2RApUISVHfgecQf9FBkwZVaveXTRuMVlsxkjkj++Xn/OnzqA2nnTwOTsESh+fwJloA1z0/kGwCpnd3lnhub4MSvwIrJSYCxQ99mF9rq+oWFGmxIMmHEKrnSP2UzAFtRanTpRqRFs+ms+B13mC5gnMspQ684Wvj4CntZ24OfUw7QXd0NO2gGjb69m8tN6qH22B5gDgU5smyuMB9QqBYlA/2ClVCRic6fjzHHyXgubBRD3b3cBlWxqO/WQKB0XcPAUiWGyiP2J9g/w6K4xVv+US0MYxb81ovgT68DXexqqhRegamEb1G7oAd/2Y1C1YDEDKMfoJyfX9Q07A4UaabFJMooB0z+ZY7GbHtJ5TCYJNEjZtbaBrmOyNeoyn6nDIhP8JDLWU3cwcTz10qNJltJ3+yLAbZmJ+eZS4OciUzt7xkviuRNQs2KtzlCtaLo5F3X9pBL/TwCQmY/8knH/4L2gyaRHUWYe4voxyjSBAU+kuinbNjBp12ECOvaN0o0ic4rGV5ZwkSJhEbVUBrK7X4G7n0agdOn8mNuOpqEwcAIyW5+HHLaRq5bOmOOSmHa5AjoZnbW5POuq5gsn/s2xkJ6wRMYLJAa0ELNhAl03yGyE5DLnLgbsiJ4Q+o8ODcgbHovSc/QYC785qZtbWFZGLuuG9zLw0BHoP59y0BkjKVfLgWWiiKzrGO58iH58kPaXKKCibY6Ii3bHbRtTlhCcm43SIgVPooxbScENmIcKWt9QYa0OM1e1UEVev3Sf5nLEquSeHAdCIPbD8NTPyw6/2N9Z04b5kk7xyehVHJkZnnVycOpX+0r/AtGBfbqtC920A8EVbHlXUk/CeZBmnRmc+t+SrfwtwACLkQjsCMv6owAAAABJRU5ErkJggg==" alt="iPark.sk" width="84" height="21"/></a>';
      html_data += '<div id="iPark-banner-tabs">';

      $.each(BoxiPark.tabs, function(index, value) {
        html_data += BoxiParkTab.generate(BoxiPark.tabs[index]);
      });

      html_data += '</div></div>';

      if ( $(BoxiPark.identifier).attr('data-feed') === 'sportky' || ( $(BoxiPark.identifier).attr('data-feed') === 'feminity' && $(BoxiPark.identifier).attr('data-type') !== 'new' ) ) {
        $('#getIparkBox').append(html_data);
      } else {
        $(BoxiPark.identifier).after(html_data);
      }

      return true;
    },
    shuffle: function (array) {
      // http://stackoverflow.com/questions/2450954/how-to-randomize-shuffle-a-javascript-array
      var currentIndex = array.length
        , temporaryValue
        , randomIndex
        ;

      // While there remain elements to shuffle...
      while (0 !== currentIndex) {

        // Pick a remaining element...
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex -= 1;

        // And swap it with the current element.
        temporaryValue = array[currentIndex];
        array[currentIndex] = array[randomIndex];
        array[randomIndex] = temporaryValue;
      }

      return array;
    }

  }

  BoxiPark.init();

  $(window).load(function () {
    var swipr = new Swipr($('#iPark-banner-tabs'), {
      auto: 3000,     // in ms
      speed: 500,     // in ms
      resizable: false,
      selector: '.tab'
    });
    Swipr.Batteries.attachSlideControls(swipr);
    $('#' + BoxiPark.settings.id).removeClass('hidden');
  });

  // natiahneme Google Font
  WebFontConfig = {
    google: { families: [ 'Roboto+Condensed:400,700,300:latin,latin-ext' ] }
  };
  var wf = document.createElement('script');
  wf.src = ('https:' == document.location.protocol ? 'https' : 'http') +
    '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
  wf.type = 'text/javascript';
  wf.async = 'true';
  document.getElementsByTagName('head')[0].appendChild( wf );

  // natiahneme css pre box
  var boxCSS = document.createElement('link');

  var magazine = $('#box-ipark').attr('data-feed');
  switch (magazine) {
    case 'titulka':
      boxCSS.href = 'http://zoznamstatic.sk/box/ipark/css/box-titulka.min.css?v='+BoxiPark.settings.cssVer;
      break;
    case 'vysetrenie':
      boxCSS.href = 'http://zoznamstatic.sk/box/ipark/css/box-vysetrenie.min.css?v='+BoxiPark.settings.cssVer;
      break;
    case 'podkapotou':
      boxCSS.href = 'http://zoznamstatic.sk/box/ipark/css/box-podkapotou.min.css?v='+BoxiPark.settings.cssVer;
      break;
    case 'feminity':
    case 'feminityNew':
      boxCSS.href = 'http://zoznamstatic.sk/box/ipark/css/box-feminity.min.css?v='+BoxiPark.settings.cssVer;
      break;
    case 'sibyla':
      boxCSS.href = 'http://zoznamstatic.sk/box/ipark/css/box-sibyla.min.css?v='+BoxiPark.settings.cssVer;
      break;
    default:
    case 'undefined':
      boxCSS.href = 'http://zoznamstatic.sk/box/ipark/css/box.min.css?v='+BoxiPark.settings.cssVer;
      break;
  }

  boxCSS.rel = 'stylesheet';
  document.getElementsByTagName('head')[0].appendChild( boxCSS );

})();
