
###*
 * jQuery Google Analytics v0.3.0 - jQuery plugin
 * Copyright (c) 2013 cue - x-perience
 * License: http://www.opensource.org/licenses/mit-license.php
###
_gaq = _gaq || []
do($ = jQuery) ->
	ga = {}

	ga.debug = false
	ga.log = ->
		return if ga.debug != true
		arguments.join = Array.prototype.join;
		args = if arguments.length > 1 then arguments.join ' ' else arguments[0];
		if window.console && window.console.log
			window.console.log args
		return

	ga.info = ->
		return if ga.debug != true
		arguments.join = Array.prototype.join;
		args = if arguments.length > 1 then arguments.join ' ' else arguments[0];
		if window.console && window.console.info
			window.console.info args
		return

	ga._scriptLoad = false
	ga.scriptUrl = (if 'https:' == document.location.protocol then 'https://ssl' else 'http://www') + '.google-analytics.com/ga.js';
	ga._loadTime = new Date().getTime()
	ga._pageLoadTime = null


	ga.href = (elm) ->
		return $(elm).attr 'href'

	ga.url = (withSearch) ->
		return location.pathname + if withSearch then location.search else ''

	ga.location = (withSearch) ->
		ga.url(withSearch)

	ga.pageSec = ->
		d = new Date()
		return parseInt((d.getTime() - ga._loadTime) / 1000)


	ga.isScriptLoaded = ->
		return ga._scriptLoad || (window._gat != undefined && typeof window._gat is 'object')

	ga.load = ->
		return @ if ga.isScriptLoaded()
		ga._loadTime = new Date()
		script = document.createElement('script')
		script.type = 'text/javascript'
		script.async = true
		script.src = ga.scriptUrl
		s = document.getElementsByTagName('script')[0]
		s.parentNode.insertBefore(script, s)
		ga._scriptLoad = true
		@

	### gaq Methods ###
	ga.push = ->
		_gaq.push.apply(_gaq, arguments)
		@

	ga.call = (method, args, options) ->
		defaults =
			async: true
			tracker: null
			delay: 0
		settings = $.extend {}, defaults, options

		a = if $.isArray(args) then args else [args]
		$.each a, (i, v)->
			if v == null || v == undefined
				a.splice(i, 1)
				return
		m = if $.isFunction(method) then method.call null else method
		# tracer 毎にトラッキング
		do(tracker = settings.tracker) ->
			_m = m
			if tracker
				if $.isArray(tracker)
					_args = arguments
					$.each tracker, (i, v) ->
						_args.callee(v)
						return
					return
				else if typeof tracker == 'string' && tracker != ''
					_m = tracker + '.' + m
			_a = $.merge [_m], a
			ga.info _a
			# 非同期呼び出し
			if settings.async
				ga.push _a
			else
				try
					pageTracker = _gat._getTrackerByName(tracker)
					if $.isFunction pageTracker[method]
						pageTracker[method].apply pageTracker, a
			return
		@

	### Methods ###
	ga.setAccount = (accountId, opt_options) ->
		@call '_setAccount', accountId, opt_options

	ga.setDomainName = (domainName, opt_options) ->
		@call '_setDomainName', domainName, opt_options

	ga.setAllowLinker = (bool, opt_options) ->
		@call '_setAllowLinker', bool, opt_options

	ga.setCustomVar = (index, name, value, opt_scope, opt_options) ->
		@call '_setCustomVar', [index, name, value, opt_scope], opt_options

	ga.setSampleRate = (rate, opt_options) ->
		@call '_setSampleRate', rate, opt_options

	ga.setSessionCookieTimeout = (msec, opt_options) ->
		@call '_setSessionCookieTimeout', msec, opt_options

	ga.setVisitorCookieTimeout = (msec, opt_options) ->
		@call '_setVisitorCookieTimeout', msec, opt_options


	ga.trackEvent = (category, action, opt_label, opt_value, opt_noninteraction, opt_options) ->
		a = __getArgumentsAndOptions 2, arguments
		@call '_trackEvent', a.arguments, a.options

	ga.trackPageview = (uri, options) ->
		@call '_trackPageview', uri, options

	ga.trackSocial = (network, socialAction, opt_target, opt_pagePath, opt_options) ->
		a = __getArgumentsAndOptions 2, arguments
		@call '_trackEvent', a.arguments, a.options

	ga.link = (targetUrl, useHash, opt_options) ->
		@call '_link', [targetUrl, useHash], opt_options

	ga.autoTracking = (options) ->
		defaults =
			trackProtocol: true
			trackingProtocols: ['mailto:', 'tel:']
			trackExternalLink: true
			ignoreDomains: []
			externalLinkEventCategory: 'ExternalLink'
			trackDownload: true
			downloadEventCategory: 'FileDownload'
			eventAction: 'Click'
			eventLabel: ga.href
			downloadRegExp: /\.(pdf|zip|jpe?g|png|gif|mp\d?|mpe?g|flv|wmv|docx?|pptx?|xlsx?|exe)/i

		settings = $.extend {}, defaults, options
		$ ->
			$('a').
				each ->
					a = @
					$a = $ @
					host = a.hostname
					path = a.pathname + a.search
					if settings.trackProtocol && $.inArray(a.protocol, settings.trackingProtocols) >= 0
						$a.click ->
							ga.trackEvent a.protocol.replace(':', ''), settings.eventAction, settings.eventLabel this, options
					else if settings.trackExternalLink && host != location.hostname && $.inArray(host, settings.ignoreDomains) < 0
						$a.click ->
							ga.trackEvent settings.externalLinkEventCategory, settings.eventAction, settings.eventLabel this, options
					else if settings.trackDownload && path.match(settings.downloadRegExp)
						$a.click ->
							ga.trackEvent settings.downloadEventCategory, settings.eventAction, settings.eventLabel this, options
					return
			return
		@

	ga.trackScroll = (options) ->
		defaults=
			eventCategory: 'Reading'
			eventAction: 'Scroll'
			eventLabel: ga.url
			scrollMinRatio: 40
			scrollRenges: [40, 60, 80, 100]
		settings = $.extend {}, defaults, options

		_scrollMax = 0
		$(window).bind 'scroll', ->
			scrollTop = $(window).scrollTop()
			if scrollTop > _scrollMax
				_scrollMax = scrollTop
		$(window).bind 'unload', ->
			windowHeight = $(window).height()
			docHeight = $(document).height()
			scrollRatio = parseInt((_scrollMax + windowHeight) / docHeight * 100);
			if scrollRatio >= settings.scrollMinRatio
				l = 0
				for s in settings.scrollRenges
					if scrollRatio <= s
						v = l + ' - ' + s + '%'
						ga.trackEvent settings.eventCategory, settings.eventAction, settings.eventLabel, v
						return
					l = s

	ga.trackDelay = (sec, options) ->
		defaults=
			eventCategory: 'Reading'
			eventAction: 'Stay'
			eventLabel: ga.url
			scrollMinRatio: 40
			scrollRenges: [40, 60, 80, 100]
		settings = $.extend {}, defaults, options
		sec?= 15000
		setTimeout ->
			ga.trackEvent settings.eventCategory, settings.eventAction, settings.eventLabel, ga.pageSec()
		, sec


	# cookies
	ga.cookie = {}
	ga.cookie.cache = {}
	ga.cookie.config = {
		__utma: '__utma'
		__utmb: '__utmb'
		__utmz: '__utmz'
	}

	ga.cookie.get = (key) ->
		if ga.cookie.cache[key]
			return ga.cookie.cache[key]
		if window.document.cookie
			cookie = window.document.cookie.split(';')
			for c in cookie
				continue if !c
				kv = c.split('=')
				continue if !kv[1]
				name = decodeURIComponent(kv[0].replace(/(^\s+|\s+$)/g, ''))
				if name is key
					# parse __utmz
					if name is ga.cookie.config.__utmz
						kv.shift()
						val = kv.join('=')
						a = val.split(".")
						if a[4] && a[4].indexOf("|") >= 0
							l = a[4].split('|')
							o = {}
							for b in l
								m = b.split('=')
								o[m[0]] = m[1]
							a[4] = o
					else
						a = kv[1].split(".")
					ga.cookie.cache[key] = a
					return a
		return null

	ga.cookie.refresh = (key) ->
		if key
			delete ga.cookie.cache[key]
			return
		ga.cookie.cache = {}
		return

	ga.getIsVistor = ->
		return ga.getFirstVisitTime() != ga.getCurrentVisitTime()

	ga.getVisitorId = ->
		c = ga.cookie.get(ga.cookie.config.__utma)
		return if c then c[1] else null

	ga.getFirstVisitTime = ->
		c = ga.cookie.get(ga.cookie.config.__utma)
		return if c then c[2] else null

	ga.getPreviousVisitTime = ->
		c = ga.cookie.get(ga.cookie.config.__utma)
		return if c then c[3] else null

	ga.getCurrentVisitTime = ->
		c = ga.cookie.get(ga.cookie.config.__utma)
		return if c then c[4] else null

	ga.getCountOfVisits = ->
		c = ga.cookie.get(ga.cookie.config.__utma)
		return if c then c[5] else null

	ga.getCountOfPageview = ->
		c = ga.cookie.get(ga.cookie.config.__utmb)
		if c
			return if c[1] then c[1] else 1
		return null

	ga.getMedia = ->
		c = ga.cookie.get(ga.cookie.config.__utmz)
		return if c && c[4] then c[4]['utmcmd'] else null

	ga.getSource = ->
		c = ga.cookie.get(ga.cookie.config.__utmz)
		return if c && c[4] then c[4]['utmcsr'] else null

	ga.getCampaign = ->
		c = ga.cookie.get(ga.cookie.config.__utmz)
		return if c && c[4] then c[4]['utmccn'] else null

	__getArgumentsAndOptions = (requireNum, args) ->
		a = []
		options = null
		for o,i in args
			if i < requireNum
				a.push(o)
				continue
			switch typeof o
				when 'string', 'boolean', 'number' then a.push(o)
				when 'object' then options = o
				else break
		return { arguments: a, options: options }


	if $.ga
		_ga = $.ga

	$.ga = $['google-analytics'] = ga

	$ ->
		ga._pageLoadTime = new Date().getTime()
		# TODO gs.jsどのタイミングで呼ぶべき？
		if !ga.isScriptLoaded()
			ga.load()

		$.fn.trackEvent = (category, action, label, options) ->
			method = if options && options.event then options.event else 'click'
			return this.each ->
				$(this).bind method, f = ->
					_cat = if $.isFunction(category) then category.call(null, this).toString() else category
					_act = if $.isFunction(action)   then action.call(null, this).toString()   else action
					_lbl = if $.isFunction(label) then label.call(null, this).toString()    else label
					ga.trackEvent(_cat, _act, _lbl, options)
					if options && options.delay > 0 && $(this).attr('_target') != '_blank'
						_link = this
						setTimeout ->
							$(_link).unbind(method, f)
							_link[method]()
						, options.delay
						return false;
				return

		$.fn.trackPageview = (uri, options) ->
			method = if options && options.event then options.event else 'click'
			return this.each ->
				$(this).bind method, f = ->
					_uri = if $.isFunction(uri) then uri.call null, this else uri
					ga.trackPageview(_uri, options)
					if options && options.delay > 0 && $(this).attr('_target') != '_blank'
						_link = this
						setTimeout ->
							$(_link).unbind(method, f)
							_link[method]()
						, options.delay
						return false;
					return
				return

