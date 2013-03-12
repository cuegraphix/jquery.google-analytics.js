do($ = jQuery) ->

	window._gaq = window._gaq || []
	window._gat = window._gat || []

	ga = {}

	ga.debug = false
	ga.debugWindow = false
	ga._debugWindow = null
	ga.log = ->
		return if ga.debug != true or ga.debugWindow != true
		arguments.join = Array.prototype.join;
		args = if arguments.length > 1 then arguments.join ' ' else arguments[0];
		if ga.debugWindow
			if ga._debugWindow == null
				ga._debugWindow = window.open('', '__jQueryGoogleAnalyticsConsole', 'left=0,top=0,width=480,height=800,scrollbars=yes,status=no,resizable=yes;toolbar=no');
				ga._debugWindow.opener = self
				ga._debugWindowDoc = ga._debugWindow.document
				if ga._debugWindow && ga._debugWindowDoc && ga._debugWindowDoc.body && ga._debugWindowDoc.body.id != 'console'
					ga._debugWindowDoc.open()
					ga._debugWindowDoc.write("<!DOCTYPE html>")
					ga._debugWindowDoc.write("<html><head><title>jquery.google-analytics.js console</title>\n")
					ga._debugWindowDoc.write("<style type=\"text/css\">pre{margin:0;padding:2px;border-bottom:1px solid #ccc;}pre:hover{background-color:Highlight;color:HighlightText;}</style><body style=\"margin:0;padding:0;\"></body>\n")
					ga._debugWindowDoc.write("</head><body style=\"margin:0;padding:0;\"></body>\n")
					ga._debugWindow.blur()
					ga._debugWindow.focus()
			# ポップアップブロック対策
			if ga._debugWindow
				p = ga._debugWindowDoc.createElement('pre')
				p.innerHTML = args.toString()
				ga._debugWindowDoc.body.appendChild(p)
		if window.console && window.console.log
			window.console.log args
		return

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
		@call('_setAccount', accountId, options)

	ga.setDomainName = (domainName, options) ->
		@call('_setDomainName', domainName, options)

	ga.setAllowLinker = (bool, options) ->
		@call('_setAllowLinker', bool, options)

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

