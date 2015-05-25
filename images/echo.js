/*! echo.js v1.6.0 | (c) 2014 @toddmotto | https://github.com/toddmotto/echo */
(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define(factory);
  } else if (typeof exports === 'object') {
    module.exports = factory;
  } else {
    root.echo = factory(root);
  }
})(this, function (root) {

  'use strict';

  var echo = {};

  var callback = function () {};

  var offset, poll, throttle, unload;

  var inView = function (element, view) {
    var box = element.getBoundingClientRect();
    return (box.right >= view.l && box.bottom >= view.t && box.left <= view.r && box.top <= view.b);
  };

  var debounce = function () {
    clearTimeout(poll);
    poll = setTimeout(echo.render, throttle);
  };

  var addClass, removeClass, hasClass;

  hasClass = function(elem, className) {
    return new RegExp(" " + className + " ").test(" " + elem.className + " ");
  };

  addClass = function(elem, className) {
    if (!hasClass(elem, className)) {
      return elem.className += " " + className;
    }
  };

  removeClass = function(elem, className) {
    var newClass;
    newClass = " " + elem.className.replace(/[\t\r\n]/g, " ") + " ";
    if (hasClass(elem, className)) {
      while (newClass.indexOf(" " + className + " ") >= 0) {
        newClass = newClass.replace(" " + className + " ", " ");
      }
      return elem.className = newClass.replace(/^\s+|\s+$/g, "");
    }
  };

  echo.init = function (opts) {
    opts = opts || {};
    var offsetAll = opts.offset || 0;
    var offsetVertical = opts.offsetVertical || offsetAll;
    var offsetHorizontal = opts.offsetHorizontal || offsetAll;
    var optionToInt = function (opt, fallback) {
      return parseInt(opt || fallback, 10);
    };
    offset = {
      t: optionToInt(opts.offsetTop, offsetVertical),
      b: optionToInt(opts.offsetBottom, offsetVertical),
      l: optionToInt(opts.offsetLeft, offsetHorizontal),
      r: optionToInt(opts.offsetRight, offsetHorizontal)
    };
    throttle = optionToInt(opts.throttle, 250);
    unload = !!opts.unload;
    callback = opts.callback || callback;
    echo.render();
    if (document.addEventListener) {
      root.addEventListener('scroll', debounce, false);
      root.addEventListener('load', debounce, false);
    } else {
      root.attachEvent('onscroll', debounce);
      root.attachEvent('onload', debounce);
    }
  };

  echo.render = function () {
    var nodes = document.querySelectorAll('[data-lazy-load]');
    var length = nodes.length;
    var src, elem;
    var view = {
      l: 0 - offset.l,
      t: 0 - offset.t,
      b: (root.innerHeight || document.documentElement.clientHeight) + offset.b,
      r: (root.innerWidth || document.documentElement.clientWidth) + offset.r
    };
    for (var i = 0; i < length; i++) {
      elem = nodes[i];
      addClass(elem, 'lazy--pre')
      if (inView(elem, view)) {
        if (unload) {
          elem.setAttribute('data-lazy-load-placeholder', elem.src);
        }
        if (elem.tagName != 'IMG') {
          var img;
          img = document.createElement('IMG')
          img.src = elem.getAttribute('data-lazy-load')

          var applyBgImage = function(e) {
            var ele = e.target.stashedEle

            ele.style.backgroundImage = 'url( ' + ele.getAttribute('data-lazy-load') + ')'
            addClass(ele, 'lazy--post')
            removeClass(ele, 'lazy--pre')

            // if (!unload) {
            //   ele.removeAttribute('data-lazy-load');
            // }
            callback(ele, 'load');

          }
          img.stashedEle = elem
          img.addEventListener('load', applyBgImage, false)

        } else {
          var img;
          img = document.createElement('IMG')
          img.src = ele.getAttribute('data-lazy-load')

          var applyImage = function(e) {
            var ele = e.target.stashedEle
            ele.src = ele.getAttribute('data-lazy-load');
            addClass(ele, 'lazy--post')
            removeClass(ele, 'lazy--pre')

            // if (!unload) {
            //   ele.removeAttribute('data-lazy-load');
            // }
            callback(ele, 'load');

          }
          img.stashedEle = elem
          img.addEventListener('load', applyImage, false)

        }


      } else if (unload && !!(src = elem.getAttribute('data-lazy-load-placeholder'))) {

        if (elem.tagName != 'IMG') {
          elem.style.backgroundImage = 'url( ' + src + ')'
        } else {
          elem.src = src;
        }
        elem.removeAttribute('data-lazy-load-placeholder');
        callback(elem, 'unload');
      }
    }
    if (!length) {
      echo.detach();
    }
  };

  echo.detach = function () {
    if (document.removeEventListener) {
      root.removeEventListener('scroll', debounce);
    } else {
      root.detachEvent('onscroll', debounce);
    }
    clearTimeout(poll);
  };

  return echo;

});
