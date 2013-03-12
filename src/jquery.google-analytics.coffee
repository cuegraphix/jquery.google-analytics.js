do($ = jQuery) ->

	window._gaq = window._gaq || []
	window._gat = window._gat || []

	ga = {}

	ga.debug = false
	ga.log = ->
		return if ga.debug != true
		if window.console && window.console.log
			arguments.join = Array.prototype.join;
			args = if arguments.length > 1 then arguments.join ' ' else arguments[0];
			window.console.log args

	ga.scriptLoaded = false
	ga.scriptUrl = (if 'https:' == document.location.protocol then 'https://ssl' else 'http://www') + '.google-analytics.com/ga.js';

	ga.href = (elm) ->
		return elm.href

	ga.load = ->
		script = document.createElement('script')
		script.type = 'text/javascript'
		script.async = true
		script.src = ga.scriptUrl
		s = document.getElementsByTagName('script')[0]
		s.parentNode.insertBefore(script, s)
		ga.scriptLoaded = true
		return @

	ga.push = ->
		_gaq.push.call(window, arguments)

	ga.call = (method, args, options) ->
		defaults =
			tracker: null
		settings = $.extend {}, defaults, options

		a = if $.isArray(args) then args else [args]
		$.each a, (i, v)->
			if v == null || v == undefined
				a.splice(i, 1)
				return
		m = if $.isFunction(method) then method.call null else method
		do(tracker = settings.tracker) ->
			_m = m
			if tracker
				if $.isArray(tracker)
					_args = arguments
					$.each tracker, (i, v) ->
						_args.callee(v)
					return
				else if typeof tracker == 'string' && tracker != ''
					_m = tracker + '.' + m
			a.unshift(_m)
			ga.log(a)
			ga.push(a)
			a.shift()

		if !ga.scriptLoaded
			ga.load()
		return @

	ga.setAccount = (accountId, options) ->
		@call('_setAccount', [accountId], options)

	ga.setDomainName = (domainName, options) ->
		@call('_setDomainName', [domainName], options)

	ga.setCustomVar = (index, name, value, scope, options) ->
		@call('_setCustomVar', [index, name, value, scope], options)

	ga.trackEvent = (category, action, label, options) ->
		@call('_trackEvent', [category, action, label], options)

	ga.trackPageview = (uri, options) ->
		@call('_trackPageview', uri, options)

	ga.autoTracking = (options) ->
		defaults =
			trackProtocol: true
			trackingProtocols: ['mailto:', 'tel:']
			trackExternalLink: true
			ignoreDomains: []
			externalLinkEventCategory: 'ExternalLink'
			trackFileDownload: true
			fileDownloadEventCategory: 'FileDownload'
			fileDownloadRegExp: /\.(doc|eps|svg|xls|ppt|pdf|zip|vsd|vxd|rar|exe|wma|mov|avi|wmv|mp3|mp4|jpg|zip|sit|exe|sea|gif)/i

		settings = $.extend {}, defaults, options
		$(document).ready ->
			$('a').
				each ->
					a = @
					$a = $(@)
					host = a.hostname
					path = a.pathname + a.search
					if settings.trackProtocol && $.inArray(a.protocol, settings.trackingProtocols) >= 0
						$a.click ->
							ga.trackEvent(a.protocol.replace(':', ''), 'Click', $.ga.href(this), options)
					else if settings.trackExternalLink && host != location.hostname && $.inArray(host, settings.ignoreDomains) < 0
						$a.click ->
							ga.trackEvent(settings.externalLinkEventCategory, 'Click', $.ga.href(this), options)
					else if settings.trackFileDownload && path.match(settings.fileDownloadRegExp)
						$a.click ->
							ga.trackEvent(settings.fileDownloadEventCategory, 'Click', $.ga.href(this), options)
					return
			return
		return

	$ ->
		if $.ga
			_ga = $.ga

		$.ga = $['google-analytics'] = ga

		$.fn.trackEvent = (category, action, label, options) ->
			method = if options && options.event then options.event else 'click'
			return this.each ->
				$(this).on method, ->
					_cat = if $.isFunction(category) then category.call null, this else category
					_act = if $.isFunction(action)   then action.call null, this   else action
					_lbl = if $.isFunction(label) then label.call null, this    else label
					ga.trackEvent(_cat, _act, _lbl, options)

		$.fn.trackPageview = (uri, options) ->
			method = options.event || 'click'
			return this.each ->
				$(this).on method, ->
					_uri = if $.isFunction(uri) then uri.call null, this else uri
					ga.trackPageview(_uri, options)

