(function( $ ) {

	var _autocomplete_append = 'append',
		_autocomplete_replace = 'replace';

	var defaults = {
		url: '../scripts/get_members_nicks.php',
		avatarDefault: '../images/img/person.png',
		avatarDir: '../images/avatars/{id}',
		profilePath: 'http://www.devbook.cz/portfolio/{id}',
		maxResults: 8,
		method: _autocomplete_replace,
		renderer: function(person) {
			return '@' + person.name + '|' + person.id + '@';
		}
	}

	/**
	 * User list model
	 * @param {String} url
	 * @constructor
	 */
	var UserList = function( url ) {
		this.url = url;
		this._users = [];
		this._updating = false;
	};

	UserList.prototype = {

		/**
		 * Load data
		 * @private
		 */
		_load: function(handle) {
			if (this._users.length || this._updating) {
				handle.call(this, this._users);
				return;
			}

			this._updating = true;
			$.getJSON(this.url, $.proxy(function( data ) {
				this._users = this._users = data;
				this._updating = false;
				this._sort();
				handle.call(this, this._users);
			}, this));
		},

		/**
		 * Sort data
		 * @private
		 */
		_sort: function() {
			this._users = this._users.sort(function(user1, user2) {
				if (!user1.name || !user2.name) {
					throw new Error('Invalid JSON users format in Autocomplete plug-in.');
				}
				return user1.name.charCodeAt(0)-user2.name.charCodeAt(0);
			});
		},

		/**
		 * Webalize value
		 * @param {String} value
		 */
		webalize: function(value) {
			var nodiac = {
				'á': 'a', 'č': 'c', 'ď': 'd', 'é': 'e', 'ě': 'e',
				'í': 'i', 'ň': 'n', 'ó': 'o', 'ř': 'r', 'š': 's',
				'ť': 't', 'ú': 'u', 'ů': 'u', 'ý': 'y', 'ž': 'z'
			};

			value = value.toLowerCase();
			var value2 = '';
			for (var i = 0; i < value.length; i++) {
				value2 += (typeof nodiac[value.charAt(i)] != 'undefined' ? nodiac[value.charAt(i)] : value.charAt(i));
			}
			return value2.replace(/[^a-z0-9_]+/g, '-').replace(/^-|-$/g, '');
		},

		/**
		 * Find result by given string
		 * @param {String} str
		 * @param {Function} handle
		 */
		findBy: function( str, handle ) {
			this._load($.proxy(function(data) {
				var filtered = this._users.filter($.proxy(function(user) {
					var name = this.webalize(user.name.toLocaleLowerCase().toLowerCase());
					return name.match(new RegExp("^" + str.toLocaleLowerCase()));
				}, this));
				handle.call(this, filtered);

			}, this));
		}

	};

	/**
	 * Autocomplete plug-in
	 * @constructor
	 */
	var Autocomplete = function( element, options ) {
		this.options = $.extend({}, defaults, options);
		this.element = $(element);
		this.targetElement = $(this.options.target || this.element);
		this.list = new UserList(this.options.url);

		var self = this;
		this.element.on('keyup', function(e) {
			var element = $(this);
			self.show();
			self.showResults(element.val());
		});

		this.element.on('focus', function(e) {
			self.show();
		});

		this.element.on('blur', function(e) {
			self.hide();
		});
	}

	Autocomplete.prototype = {

		/**
		 * Link user in target element
		 * @param {Object} person
		 */
		linkUser: function(person) {
			var text = this.options.renderer(person);
			if (this.options.method === _autocomplete_replace)
				this.targetElement.val(text);
			else if (this.options.method === _autocomplete_append)
				this.targetElement.val(this.targetElement.val() + text);
			else
				throw new Error('User not found.');
		},

		/**
		 * Hide results
		 */
		hide: function() {
			this.listElement && this.listElement.fadeOut(100);
		},

		/**
		 * Show results
		 */
		show: function() {
			this.listElement && this.listElement.fadeIn(100);
		},

		/**
		 * Show autocomplete results
		 * @param {String} str
		 */
		showResults: function(str) {
			this.listElement && this.listElement.remove();
			this.listElement = this._createListElement();
			this.listElement.css('top', this.element.offset().top + this.element.outerHeight())
			this.list.findBy(str, $.proxy(function(users) {
				if (!users.length || !str.length) {
					this.listElement.remove();
					return false;
				}

				for (var i in users) {
					if (i > this.options.maxResults) break;
					this.listElement.append(this._createListItem(users[i]));
				}
				this.targetElement.after(this.listElement);

			}, this));
		},

		/**
		 * Create list element
		 * @return {*|jQuery|HTMLElement}
		 * @private
		 */
		_createListElement: function() {
			return $('<ul></ul>', { 'class': 'autocomplete-results' });
		},

		/**
		 * Create list item
		 * @param user
		 * @return {*|jQuery|HTMLElement}
		 * @private
		 */
		_createListItem: function(user) {
			var self = this;
			var avatarPath = user.avatar == 1 ?
				this.options.avatarDir.replace('{id}', user.id) :
				this.options.avatarDefault;

			var item = $('<li></li>');
			item.data('person', user);
			item.click(function() {
				if (!item.data('person')) {
					return;
				}
				self.linkUser.call(self, item.data('person'));
				self.hide();
			});

			var image = $('<div><img /></div>');
			image.addClass('autocomplete-avatar');
			image.find('img').attr('src', avatarPath);

			var span = $('<span></span>', {	'text': user.name });
			span.append(
				$('<a></a>', {
					'html': 'Zobrazit profil &raquo;',
					'href': this.options.profilePath.replace('{id}', user.id)
				})
			);

			var br = $('<br />', { 'clear': 'all' });

			item.append(image, span, br);
			return item;
		}

	};

	Autocomplete.APPEND = _autocomplete_append;
	Autocomplete.REPLACE = _autocomplete_replace;

	$(function() {
		var element = $('[data-trigger="autocomplete"]');
		element.data('autocomplete', new Autocomplete(element, element.data()));
	});

})( jQuery );