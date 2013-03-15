do($ = jQuery) ->

	window._gaq = window._gaq || []

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
	ga._loadTime = null


	ga.href = (elm) ->
		return elm.href

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
		return @

	ga.push = ->
		window._gaq.push.apply(window._gaq, arguments)

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
			a.unshift(_m)
			ga.info(a)
			ga.push(a)
			a.shift()
			return

		if !ga.isScriptLoaded()
			ga.load()
		return @

	ga.setAccount = (accountId, opt_options) ->
		@call('_setAccount', accountId, opt_options)

	ga.setDomainName = (domainName, opt_options) ->
		@call('_setDomainName', domainName, opt_options)

	ga.setAllowLinker = (bool, opt_options) ->
		@call('_setAllowLinker', bool, opt_options)

	ga.setCustomVar = (index, name, value, scope, opt_options) ->
		@call('_setCustomVar', [index, name, value, scope], opt_options)

	ga.trackEvent = (category, action, opt_label, opt_value, opt_noninteraction, opt_options) ->
		a = [category, action]
		i = 2
		o = arguments[i]
		options = null
		while o
			switch typeof o
				when 'string' then a.push(o)
				when 'object' then options = o
				else break
			o = arguments[++i]
		@call('_trackEvent', a, options)

	ga.trackPageview = (uri, options) ->
		@call('_trackPageview', uri, options)

	ga.trackSocial = (network, socialAction, opt_target, opt_pagePath, opt_options) ->
		a = [network, socialAction]
		i = 2
		o = arguments[i]
		options = null
		while o
			switch typeof o
				when 'string' then a.push(o)
				when 'object' then options = o
				else break
			o = arguments[++i]
		@call('_trackSocial', a, options)

	ga.link = (targetUrl, useHash, opt_options) ->
		@call('_link', [targetUrl, useHash], opt_options)

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



	if $.ga
		_ga = $.ga

	$.ga = $['google-analytics'] = ga

	$ ->
		$.fn.trackEvent = (category, action, label, options) ->
			method = if options && options.event then options.event else 'click'
			return this.each ->
				$(this).on method, ->
					_cat = if $.isFunction(category) then category.call null, this else category
					_act = if $.isFunction(action)   then action.call null, this   else action
					_lbl = if $.isFunction(label) then label.call null, this    else label
					ga.trackEvent(_cat, _act, _lbl, options)
					return
				return

		$.fn.trackPageview = (uri, options) ->
			method = options.event || 'click'
			return this.each ->
				$(this).on method, ->
					_uri = if $.isFunction(uri) then uri.call null, this else uri
					ga.trackPageview(_uri, options)
					return
				return

