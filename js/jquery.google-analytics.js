// Generated by CoffeeScript 1.6.1

(function($) {
  var ga, _ga;
  window._gaq = window._gaq || [];
  ga = {};
  ga.debug = false;
  ga.log = function() {
    var args;
    if (ga.debug !== true) {
      return;
    }
    arguments.join = Array.prototype.join;
    args = arguments.length > 1 ? arguments.join(' ') : arguments[0];
    if (window.console && window.console.log) {
      window.console.log(args);
    }
  };
  ga.info = function() {
    var args;
    if (ga.debug !== true) {
      return;
    }
    arguments.join = Array.prototype.join;
    args = arguments.length > 1 ? arguments.join(' ') : arguments[0];
    if (window.console && window.console.info) {
      window.console.info(args);
    }
  };
  ga._scriptLoad = false;
  ga.scriptUrl = ('https:' === document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  ga._loadTime = null;
  ga.href = function(elm) {
    return elm.href;
  };
  ga.isScriptLoaded = function() {
    return ga._scriptLoad || (window._gat !== void 0 && typeof window._gat === 'object');
  };
  /**
   * load
   * Google Analytics スクリプト（ga.js）をロードします。
   * @return $.gaオブジェクト
  */

  ga.load = function() {
    var s, script;
    if (ga.isScriptLoaded()) {
      return this;
    }
    ga._loadTime = new Date();
    script = document.createElement('script');
    script.type = 'text/javascript';
    script.async = true;
    script.src = ga.scriptUrl;
    s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(script, s);
    ga._scriptLoad = true;
    return this;
  };
  /**
      * push
      * _gaq.push のラッパー関数
      * @param array
      * @return $.gaオブジェクト
  */

  ga.push = function() {
    window._gaq.push.apply(window._gaq, arguments);
    return this;
  };
  /**
      * call
      * _gaq.push のラッパー関数
      * @return $.gaオブジェクト
  */

  ga.call = function(method, args, options) {
    var a, defaults, m, settings;
    defaults = {
      tracker: null
    };
    settings = $.extend({}, defaults, options);
    a = $.isArray(args) ? args : [args];
    $.each(a, function(i, v) {
      if (v === null || v === void 0) {
        a.splice(i, 1);
      }
    });
    m = $.isFunction(method) ? method.call(null) : method;
    (function(tracker) {
      var _args, _m;
      _m = m;
      if (tracker) {
        if ($.isArray(tracker)) {
          _args = arguments;
          $.each(tracker, function(i, v) {
            _args.callee(v);
          });
          return;
        } else if (typeof tracker === 'string' && tracker !== '') {
          _m = tracker + '.' + m;
        }
      }
      a.unshift(_m);
      ga.info(a);
      ga.push(a);
      a.shift();
    })(settings.tracker);
    if (!ga.isScriptLoaded()) {
      ga.load();
    }
    return this;
  };
  ga.setAccount = function(accountId, opt_options) {
    return this.call('_setAccount', accountId, opt_options);
  };
  ga.setDomainName = function(domainName, opt_options) {
    return this.call('_setDomainName', domainName, opt_options);
  };
  ga.setAllowLinker = function(bool, opt_options) {
    return this.call('_setAllowLinker', bool, opt_options);
  };
  ga.setCustomVar = function(index, name, value, scope, opt_options) {
    return this.call('_setCustomVar', [index, name, value, scope], opt_options);
  };
  ga.trackEvent = function(category, action, opt_label, opt_value, opt_noninteraction, opt_options) {
    var a, i, o, options;
    a = [category, action];
    i = 2;
    o = arguments[i];
    options = null;
    while (o) {
      switch (typeof o) {
        case 'string':
          a.push(o);
          break;
        case 'object':
          options = o;
          break;
        default:
          break;
      }
      o = arguments[++i];
    }
    return this.call('_trackEvent', a, options);
  };
  ga.trackPageview = function(uri, options) {
    return this.call('_trackPageview', uri, options);
  };
  ga.trackSocial = function(network, socialAction, opt_target, opt_pagePath, opt_options) {
    var a, i, o, options;
    a = [network, socialAction];
    i = 2;
    o = arguments[i];
    options = null;
    while (o) {
      switch (typeof o) {
        case 'string':
          a.push(o);
          break;
        case 'object':
          options = o;
          break;
        default:
          break;
      }
      o = arguments[++i];
    }
    return this.call('_trackSocial', a, options);
  };
  ga.link = function(targetUrl, useHash, opt_options) {
    return this.call('_link', [targetUrl, useHash], opt_options);
  };
  ga.autoTracking = function(options) {
    var defaults, settings;
    defaults = {
      trackProtocol: true,
      trackingProtocols: ['mailto:', 'tel:'],
      trackExternalLink: true,
      ignoreDomains: [],
      externalLinkEventCategory: 'ExternalLink',
      trackFileDownload: true,
      fileDownloadEventCategory: 'FileDownload',
      fileDownloadRegExp: /\.(doc|eps|svg|xls|ppt|pdf|zip|vsd|vxd|rar|exe|wma|mov|avi|wmv|mp3|mp4|jpg|zip|sit|exe|sea|gif)/i
    };
    settings = $.extend({}, defaults, options);
    $(document).ready(function() {
      $('a').each(function() {
        var $a, a, host, path;
        a = this;
        $a = $(this);
        host = a.hostname;
        path = a.pathname + a.search;
        if (settings.trackProtocol && $.inArray(a.protocol, settings.trackingProtocols) >= 0) {
          $a.click(function() {
            return ga.trackEvent(a.protocol.replace(':', ''), 'Click', $.ga.href(this), options);
          });
        } else if (settings.trackExternalLink && host !== location.hostname && $.inArray(host, settings.ignoreDomains) < 0) {
          $a.click(function() {
            return ga.trackEvent(settings.externalLinkEventCategory, 'Click', $.ga.href(this), options);
          });
        } else if (settings.trackFileDownload && path.match(settings.fileDownloadRegExp)) {
          $a.click(function() {
            return ga.trackEvent(settings.fileDownloadEventCategory, 'Click', $.ga.href(this), options);
          });
        }
      });
    });
  };
  ga.cookie = {};
  ga.cookie.cache = {};
  ga.cookie.config = {
    __utma: '__utma',
    __utmb: '__utmb',
    __utmz: '__utmz'
  };
  ga.cookie.get = function(key) {
    var a, b, c, cookie, kv, l, m, name, o, val, _i, _j, _len, _len1;
    if (ga.cookie.cache[key]) {
      return ga.cookie.cache[key];
    }
    if (window.document.cookie) {
      cookie = window.document.cookie.split(';');
      for (_i = 0, _len = cookie.length; _i < _len; _i++) {
        c = cookie[_i];
        if (!c) {
          continue;
        }
        kv = c.split('=');
        if (!kv[1]) {
          continue;
        }
        name = decodeURIComponent(kv[0].replace(/(^\s+|\s+$)/g, ''));
        if (name === key) {
          if (name === ga.cookie.config.__utmz) {
            kv.shift();
            val = kv.join('=');
            a = val.split(".");
            if (a[4] && a[4].indexOf("|") >= 0) {
              l = a[4].split('|');
              o = {};
              for (_j = 0, _len1 = l.length; _j < _len1; _j++) {
                b = l[_j];
                m = b.split('=');
                o[m[0]] = m[1];
              }
              a[4] = o;
            }
          } else {
            a = kv[1].split(".");
          }
          ga.cookie.cache[key] = a;
          return a;
        }
      }
    }
    return null;
  };
  ga.cookie.refresh = function(key) {
    if (key) {
      delete ga.cookie.cache[key];
      return;
    }
    ga.cookie.cache = {};
  };
  ga.getIsVistor = function() {
    return ga.getFirstVisitTime() !== ga.getCurrentVisitTime();
  };
  ga.getVisitorId = function() {
    var c;
    c = ga.cookie.get(ga.cookie.config.__utma);
    if (c) {
      return c[1];
    } else {
      return null;
    }
  };
  ga.getFirstVisitTime = function() {
    var c;
    c = ga.cookie.get(ga.cookie.config.__utma);
    if (c) {
      return c[2];
    } else {
      return null;
    }
  };
  ga.getPreviousVisitTime = function() {
    var c;
    c = ga.cookie.get(ga.cookie.config.__utma);
    if (c) {
      return c[3];
    } else {
      return null;
    }
  };
  ga.getCurrentVisitTime = function() {
    var c;
    c = ga.cookie.get(ga.cookie.config.__utma);
    if (c) {
      return c[4];
    } else {
      return null;
    }
  };
  ga.getCountOfVisits = function() {
    var c;
    c = ga.cookie.get(ga.cookie.config.__utma);
    if (c) {
      return c[5];
    } else {
      return null;
    }
  };
  ga.getCountOfPageview = function() {
    var c;
    c = ga.cookie.get(ga.cookie.config.__utmb);
    if (c) {
      if (c[1]) {
        return c[1];
      } else {
        return 1;
      }
    }
    return null;
  };
  ga.getMedia = function() {
    var c;
    c = ga.cookie.get(ga.cookie.config.__utmz);
    if (c && c[4]) {
      return c[4]['utmcmd'];
    } else {
      return null;
    }
  };
  ga.getSource = function() {
    var c;
    c = ga.cookie.get(ga.cookie.config.__utmz);
    if (c && c[4]) {
      return c[4]['utmcsr'];
    } else {
      return null;
    }
  };
  ga.getCampaign = function() {
    var c;
    c = ga.cookie.get(ga.cookie.config.__utmz);
    if (c && c[4]) {
      return c[4]['utmccn'];
    } else {
      return null;
    }
  };
  if ($.ga) {
    _ga = $.ga;
  }
  $.ga = $['google-analytics'] = ga;
  return $(function() {
    $.fn.trackEvent = function(category, action, label, options) {
      var method;
      method = options && options.event ? options.event : 'click';
      return this.each(function() {
        $(this).on(method, function() {
          var _act, _cat, _lbl;
          _cat = $.isFunction(category) ? category.call(null, this) : category;
          _act = $.isFunction(action) ? action.call(null, this) : action;
          _lbl = $.isFunction(label) ? label.call(null, this) : label;
          ga.trackEvent(_cat, _act, _lbl, options);
        });
      });
    };
    return $.fn.trackPageview = function(uri, options) {
      var method;
      method = options.event || 'click';
      return this.each(function() {
        $(this).on(method, function() {
          var _uri;
          _uri = $.isFunction(uri) ? uri.call(null, this) : uri;
          ga.trackPageview(_uri, options);
        });
      });
    };
  });
})(jQuery);
