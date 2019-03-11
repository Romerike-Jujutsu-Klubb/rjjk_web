function ScrollSpy (wrapper, opt) {

  this.doc = document;
  this.wrapper = (typeof wrapper === 'string') ? this.doc.querySelector(wrapper) : wrapper;
  this.nav = this.wrapper.querySelectorAll(opt.nav);

  this.contents = [];
  this.win = window;

  this.winH = this.win.innerHeight;

  this.className = opt.className;

  this.callback = opt.callback;

  this.init();
}

ScrollSpy.prototype.init = function () {
  this.contents = this.getContents();
  this.attachEvent();
};

ScrollSpy.prototype.getContents = function () {
  var targetList = [];

  for (var i = 0, max = this.nav.length; i < max; i++) {
    var href = this.nav[i].href;

    targetList.push(this.doc.getElementById(href.split('#')[1]));
  }

  return targetList;
};

ScrollSpy.prototype.attachEvent = function () {
  this.win.addEventListener('load', (function () {
    this.spy(this.callback);
  }).bind(this));


  var scrollingTimer;

  this.win.addEventListener('scroll', (function () {
    if (scrollingTimer) {
      clearTimeout(scrollingTimer);
    }

    var _this = this;

    scrollingTimer = setTimeout(function () {
      _this.spy(_this.callback);
    }, 10);
  }).bind(this));


  var resizingTimer;

  this.win.addEventListener('resize', (function () {
    if (resizingTimer) {
      clearTimeout(resizingTimer);
    }

    var _this = this;

    resizingTimer = setTimeout(function () {
      _this.spy(_this.callback);
    }, 10);
  }).bind(this));
};

ScrollSpy.prototype.spy = function (cb) {
  var elems = this.getElemsViewState();

  this.markNav(elems);

  if (typeof cb === 'function') {
    cb(elems);
  }
};

ScrollSpy.prototype.getElemsViewState = function () {
  var elemsInView = [],
    elemsOutView = [],
    viewStatusList = [];

  for (var i = 0, max = this.contents.length; i < max; i++) {
    var currentContent = this.contents[i],
      isInView = this.isInView(currentContent);

    if (isInView) {
      elemsInView.push(currentContent);
    } else {
      elemsOutView.push(currentContent);
    }
    viewStatusList.push(isInView);
  }

  return {
    inView: elemsInView,
    outView: elemsOutView,
    viewStatusList: viewStatusList
  };
};

ScrollSpy.prototype.isInView = function (el) {
  var winH = this.winH,
    scrollTop = this.doc.documentElement.scrollTop || this.doc.body.scrollTop,
    scrollBottom = scrollTop + winH,
    rect = el.getBoundingClientRect(),
    elTop = rect.top + scrollTop,
    elBottom = elTop + el.offsetHeight;

  return (elTop < scrollBottom) && (elBottom > scrollTop);
};

ScrollSpy.prototype.markNav = function (elems) {
  var navItems = this.nav,
    isAlreadyMarked = false;

  for (var i = 0, max = navItems.length; i < max; i++) {
    if (elems.viewStatusList[i] && !isAlreadyMarked) {
      isAlreadyMarked = true;
      jQuery(navItems[i]).addClass(this.className);
    } else {
      jQuery(navItems[i]).removeClass(this.className);
    }
  }
};
/*
     FILE ARCHIVED ON 22:08:50 Feb 02, 2019 AND RETRIEVED FROM THE
     INTERNET ARCHIVE ON 19:17:18 Mar 11, 2019.
     JAVASCRIPT APPENDED BY WAYBACK MACHINE, COPYRIGHT INTERNET ARCHIVE.

     ALL OTHER CONTENT MAY ALSO BE PROTECTED BY COPYRIGHT (17 U.S.C.
     SECTION 108(a)(3)).
*/
/*
playback timings (ms):
  LoadShardBlock: 184.909 (3)
  esindex: 0.012
  captures_list: 251.026
  CDXLines.iter: 18.495 (3)
  PetaboxLoader3.datanode: 264.106 (4)
  exclusion.robots: 0.421
  exclusion.robots.policy: 0.396
  RedisCDXSource: 41.11
  PetaboxLoader3.resolve: 34.096
  load_resource: 1426.144
*/