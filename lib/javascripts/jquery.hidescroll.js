;(function($, window, document, undefined) {

	var name = 'hidescroll',
		defaults = {
			offset: 0,
			interval: 250,
			stickClass: 'stick',
			visibleClass: 'visible',
			hiddenClass: 'hidden'
		};

	function Hidescroll(element, options) {

		this.options = $.extend({}, defaults, options);
		this.navbar = element;

		this.init();

	}

	/**
	 * Calculate actual scroll position and direction
	 * @param  {Object} event
	 */
	Hidescroll.prototype.calculate = function(event) {

		var scroll = $(document).scrollTop();

		if (scroll > this.scroll) this.direction = -1;
		else this.direction = 1;

		this.action = true;
		this.scroll = scroll;

	};

	/**
	 * Bind navbar methods
	 */
	Hidescroll.prototype.bindings = function() {

		var o = this.options;

		this.navbar.bind({

			normalPosition: function () {
				$(this).removeClass(
					o.stickClass + ' ' + o.visibleClass + ' ' + o.hiddenClass
				);
			},
			stickHiddenPosition: function () {
				$(this).addClass(
					o.stickClass  + ' ' + o.hiddenClass
				).removeClass(o.visibleClass);
			},
			stickVisiblePosition: function () {
				$(this).addClass(o.visibleClass).removeClass(o.hiddenClass);
			},

		});

	};

	/**
	 * Handle navbar state
	 */
	Hidescroll.prototype.handle = function() {

		if(this.scroll === 0)
			return this.navbar.trigger('normalPosition');

		if (this.direction < 0 && this.scroll > this.options.offset)
			return this.navbar.trigger('stickHiddenPosition');

		else
			return this.navbar.trigger('stickVisiblePosition');

	};

	/**
	 * Events bindings
	 */
	Hidescroll.prototype.events = function () {

		$(window).on('scroll', $.proxy(this.calculate, this));

	};

	/**
	 * [status description]
	 * @return {[type]} [description]
	 */
	Hidescroll.prototype.status = function() {

		var that = this;

		setInterval(function() {
			if (that.action) {
				that.handle();
				that.action = false;
			}
		}, this.options.interval);

	};

	Hidescroll.prototype.init = function () {

		this.scroll = 0;
		this.direction = 0;
		this.options.offset = (this.options.offset === 0) ? this.navbar.outerHeight() : this.options.offset;
		this.action = true;

		this.bindings();
		this.events();
		this.status();

	};

	$.fn[name] = function(options) {
		return this.each(function () {
			if (!$.data(this, 'api_' + name)) {
				$.data(this, 'api_' + name,
					new Hidescroll($(this), options)
				);
			}
		});
	};

})(jQuery, window, document);
