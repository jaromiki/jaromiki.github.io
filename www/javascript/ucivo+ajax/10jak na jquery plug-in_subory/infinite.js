(function(a){var b={init:function(b){var c=a.extend({},a.fn.infiniteScroll.defaults,b),d=a("<div></div>",{"class":"ajax-loader",html:'<img src="'+c.loaderImage+'" />'+"<p>"+c.loaderMessage+"</p>"}).hide(),e=function(){var b=a(this),e=a(window),f=e.scrollTop(),g=b.find(c.handle),h={};g.length&&f+e.height()>g.offset().top&&(g.remove(),h[c.param]=g.text(),d.show(),a.get(c.url,a.extend({},c.data,h),function(c){var e=a(c);b.append(e),e.hide(),e.show(1e3,function(){d.fadeOut(500)})}))};return this.each(function(){a(window).on("scroll",a.proxy(e,this)),a(this).after(d)})}};a.fn.infiniteScroll=function(c){typeof c=="string"&&b[c]?b[c].apply(this,Array.prototype.slice.call(arguments,1)):c&&typeof c!="object"?a.error("Infinite scroll doesn't have method called "+c):b.init.call(this,c)},a.fn.infiniteScroll.defaults={loaderMessage:"Na\u010d\u00edt\u00e1m nov\u00e9 p\u0159\u00edsp\u011bvky ...",loaderImage:"images/loader.gif",handle:"#wall-timestamp",param:"timestamp",url:"404.php",type:"GET",data:{}}})(jQuery)