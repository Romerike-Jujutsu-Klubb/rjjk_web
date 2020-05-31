function isIE(e, t) {
  var i = jQuery('<div style="display:none;"/>').appendTo(jQuery("body"));
  i.html("\x3c!--[if " + (t || "") + " IE " + (e || "") + "]><a>&nbsp;</a><![endif]--\x3e");
  var n = i.find("a").length;
  return i.remove(), n
}

function preselection() {
  jQuery("body").append('<div id="preselector" class="hidden-phone" style="position:fixed;width:290px;height:705px;top:107px;right:-260px;z-index:10000;"></div>');
  var e = jQuery("#preselector");
  jQuery("body").hasClass("gw_light") ? (e.append('<div id="preselectorbody" style="position:absolute; padding:20px; box-sizing:border-box; -webkit-box-sizing:border-box; -moz-box-sizing:border-box;top:0px; right:0px;width:260px;height:705px;background:#fff;background:rgba(255,255,255,0.5);border-radius:10px 0px 0px 10px;-moz-border-radius:10px 0px 0px 10px;-webkit-border-radius:10px 0px 0px 10px"></div>'), e.append('<div id="preselectorbutton" style="cursor:pointer;position:absolute;width:30px;height:250px;background:url(/wp-content/themes/goodweb/images/assets/switcherbutton_light.png) no-repeat; top:10px;left:0px;"></div>')) : (e.append('<div id="preselectorbody" style="position:absolute; padding:20px; box-sizing:border-box; -webkit-box-sizing:border-box; -moz-box-sizing:border-box;top:0px; right:0px;width:260px;height:705px;background:#000;background:rgba(0,0,0,0.5);border-radius:10px 0px 0px 10px;-moz-border-radius:10px 0px 0px 10px;-webkit-border-radius:10px 0px 0px 10px"></div>'), e.append('<div id="preselectorbutton" style="cursor:pointer;position:absolute;width:30px;height:250px;background:url(/wp-content/themes/goodweb/images/assets/switcherbutton.png) no-repeat; top:10px;left:0px;"></div>'));
  var t = jQuery("#preselectorbody"), i = jQuery("#preselectorbutton"),
      n = '<div class="item preselectorimg" style="position:relative; margin-bottom:5px;">\t<div class="mediawall-mediacontainer" style="position:relative;border:3px solid #e5e5e5;border:3px solid rgba(0,0,0,0.05); box-sizing:border-box;-moz-box-sizing:border-box;-webkit-box-sizing:border-box;"><img  src="https://web.archive.org/web/20190202220907/http://goodwebtheme.com/goodwebpreview/switcher##i##.png" style="width:100%;position:relative;">\t\t<a href="##link##"><div class="mediawall-overlay"></div></a>\t</div>\t<a href="##link2##"><div class="mediawall-content" style="position:absolute; top:50px;">\t\t<h4 class="mediawall-teamname txtshadow" style="border-bottom:none !important">##title##</h4>\t</div><div class="clear"></div></a>';
  t.append('<h4 class="headline-title  gw-rft relative">Select Preview</h4>');
  for (var a = 0; a < 4; a++) 0 == a ? (newbasic = n.replace("##link##", "https://web.archive.org/web/20190202220907/http://light.goodwebtheme.com/"), newbasic = newbasic.replace("##link2##", "https://web.archive.org/web/20190202220907/http://light.goodwebtheme.com/"), newbasic = newbasic.replace("##i##", "_light"), newbasic = newbasic.replace("##title##", "Light")) : 1 == a ? (newbasic = n.replace("##link##", "https://web.archive.org/web/20190202220907/http://minimallight.goodwebtheme.com/"), newbasic = newbasic.replace("##link2##", "https://web.archive.org/web/20190202220907/http://minimallight.goodwebtheme.com/"), newbasic = newbasic.replace("##i##", "_minlight"), newbasic = newbasic.replace("##title##", "Minimal Light")) : 2 == a ? (newbasic = n.replace("##link##", "https://web.archive.org/web/20190202220907/http://dark.goodwebtheme.com/"), newbasic = newbasic.replace("##link2##", "https://web.archive.org/web/20190202220907/http://dark.goodwebtheme.com/"), newbasic = newbasic.replace("##i##", "_dark"), newbasic = newbasic.replace("##title##", "Dark")) : 3 == a && (newbasic = n.replace("##link##", "https://web.archive.org/web/20190202220907/http://minimaldark.goodwebtheme.com/"), newbasic = newbasic.replace("##link2##", "https://web.archive.org/web/20190202220907/http://minimaldark.goodwebtheme.com/"), newbasic = newbasic.replace("##i##", "_mindark"), newbasic = newbasic.replace("##title##", "Minimal Dark")), t.append(newbasic);
  t.append('<a href="https://web.archive.org/web/20190202220907/http://themeforest.net/item/goodweb-one-multi-page-wordpress-theme/5896610?ref=themepunch" class="smoothscroll" target="clean" ><button style="margin-top:20px;color:#ffffff;background-color:#67ae73" class="btn noncentered txtshadow fullwidth "><i class="demoicon icon-basket-1" style="margin-top:2px"></i>Purchase Theme</button></a>');
  var r = "off";
  i.on('click', function() {
    "off" == r ? TweenLite.to(e, .4, {
      x: 0, right: 0, ease: Back.easeIn, onComplete: function() {
        r = "on"
      }
    }) : TweenLite.to(e, .4, {
      right: -260, ease: Back.easeOut, onComplete: function() {
        r = "off"
      }
    })
  }), t.find(".preselectorimg").on('hover', function() {
    var e = jQuery(this), t = e.find(".mediawall-mediacontainer"), i = e.find(".mediawall-overlay"),
        n = e.find(".mediawall-content"), a = e.find(".mediawall-lightbox"),
        r = e.find(".mediawall-link"), o = (1 * (o = t.width()) - o) / 2,
        s = (1 * (s = t.height()) - s) / 2;
    isIE(8) && (s = o = 0), TweenLite.to(e, .4, {zIndex: 100}), TweenLite.fromTo(i, .4, {opacity: 0}, {
      display: "block",
      opacity: 1,
      ease: Power3.easeOut
    }), TweenLite.fromTo(n, .4, {transformPerspective: 500, scale: 1.2, z: 10, opacity: 0}, {
      scale: 1,
      display: "block",
      opacity: 1,
      z: 1,
      ease: Power2.easeOut
    }), TweenLite.fromTo(a, .6, {
      scale: .8,
      transformOrigin: "center top",
      opacity: 0,
      transformPerspective: 500,
      rotationX: 90,
      x: o,
      y: s - 10
    }, {
      scale: 1,
      rotationX: 0,
      x: o,
      y: s,
      display: "block",
      opacity: 1,
      ease: Power3.easeOut
    }), TweenLite.fromTo(r, .8, {
      scale: .8,
      transformOrigin: "center top",
      opacity: 0,
      transformPerspective: 500,
      rotationX: 90,
      x: o,
      y: s - 10
    }, {
      scale: 1,
      rotationX: 0,
      x: o,
      y: s,
      display: "block",
      opacity: 1,
      ease: Power3.easeOut
    }), TweenLite.to(t, .6, {
      scale: 1,
      transformPerspective: 500,
      ease: Power3.easeOut,
      overwrite: "all"
    })
  }, function() {
    var e = jQuery(this), t = e.find(".mediawall-mediacontainer"), i = e.find(".mediawall-overlay"),
        n = e.find(".mediawall-content"), a = e.find(".mediawall-lightbox"),
        r = e.find(".mediawall-link");
    TweenLite.to(e, .2, {zIndex: 1}), TweenLite.to(i, .3, {
      display: "none",
      opacity: 0
    }), TweenLite.to(n, .5, {
      scale: .5,
      transformPerspective: 500,
      opacity: 0,
      display: "none"
    }), TweenLite.to(a, .4, {
      scale: .8,
      display: "none",
      opacity: 0,
      transformPerspective: 500,
      rotationX: 90,
      ease: Power3.easeOut,
      overwrite: "all"
    }), TweenLite.to(r, .4, {
      scale: .8,
      display: "none",
      opacity: 0,
      transformPerspective: 500,
      rotationX: 90,
      ease: Power3.easeOut,
      overwrite: "all"
    }), TweenLite.to(t, .3, {
      scale: 1,
      transformPerspective: 500,
      rotationY: 0,
      rotationX: 0,
      ease: Power4.easeOut,
      overwrite: "all"
    })
  })
}

function mapgyver() {
  var e = jQuery("#mapgyver_holder"), t = e.data("height");
  e.wrap('<div class="mapviewport"></div>'), e.css({minHeight: t});
  var i = e.find(".content-behind-map");
  i.css({minHeight: t}), e.height(i.outerHeight());
  var n = e.data("address"), a = e.data("zoom");
  if (0 != e.length) {
    TweenLite.set(e, {opacity: 0}), e.append('<div class="originalmap" style="min-height:' + t + 'px"></div>');
    var r = e, o = e.width(), s = o / 5;
    if (!is_mobile()) for (var l = 0; l < 5; l++) r.append('<div class="nextdepth overlaymaps" id="overlaymap' + l + '" style="width:' + s + 'px;"><div class="mapgyver-outterpam"><div class="mapgyver-innermap" style="width:' + o + "px;left:" + (0 - 100 * l) + '%"></div><div class="shadowoverlay"></div></div></div>'), r = r.find(".nextdepth");
    var c, u, d = e.find(".originalmap");
    d.wrapInner('<div class="originalmap-inner" style="min-height:' + t + 'px"></div>'), (d = d.find(".originalmap-inner")).gmap3({
      marker: {address: n},
      map: {
        address: n,
        options: {
          zoom: a,
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          mapTypeConrol: !0,
          navigationControl: !0,
          scrollwheel: !1,
          streetViewControl: !1
        },
        events: {
          idle: function() {
            setTimeout(function() {
              jQuery("#mapgyver_holder").addClass("mapisready")
            }, 1500)
          }, bounds_changed: function() {
            clearTimeout(c), c = setTimeout(function() {
              jQuery("#mapgyver_holder").addClass("mapisready")
            }, 1500)
          }
        }
      }
    }), is_mobile() ? (createMobileMaps(), jQuery(window).on('resize', function() {
      clearTimeout(u), u = setTimeout(function() {
        var e = jQuery("#mapgyver_holder"), t = e.find(".content-behind-map");
        e.height(t.outerHeight()), 767 < jQuery(window).width() ? e.find(".originalmap").css({maxWidth: "60%"}) : e.find(".originalmap").css({maxWidth: "100%"})
      }, 300)
    })) : (createMapClones(), jQuery(window).on('resize', function() {
      clearTimeout(u), u = setTimeout(function() {
        var e = jQuery("#mapgyver_holder"), t = e.find(".content-behind-map");
        e.height(t.outerHeight());
        var i = e.width(), n = i / 5;
        jQuery(".overlaymaps").each(function(e) {
          var t = jQuery(this);
          t.width(n), t.find(".mapgyver-innermap").width(i), 0 != e && TweenLite.to(t, .3, {
            x: n,
            ease: Power2.easeOut
          })
        }), recreateMapClones()
      }, 300)
    }))
  }
}

function createMobileMaps() {
  var e = jQuery("#mapgyver_holder");
  TweenLite.to(e, .4, {opacity: 1}), 767 < jQuery(window).width() ? e.find(".originalmap").css({maxWidth: "60%"}) : e.find(".originalmap").css({maxWidth: "100%"})
}

function createMapClones() {
  var e = setInterval(function() {
    jQuery("#mapgyver_holder").hasClass("mapisready") && (setTimeout(function() {
      recreateMapClones(), foldMapHandler()
    }, 300), clearInterval(e))
  }, 50)
}

function recreateMapClones() {
  jQuery("#mapgyver_holder").removeClass("mapisready");
  var e = jQuery("#mapgyver_holder .originalmap .originalmap-inner");
  e.find(".gmnoprint, .gmnoscreen, .gmn, .gm-style, .gm-style-mtc").each(function() {
    TweenLite.set(jQuery(this), {transformPerspective: 7e3, rotationY: 0, rotationZ: 0})
  });
  for (var t = 0; t < 5; t++) {
    var i = jQuery("#overlaymap" + t + " .mapgyver-innermap");
    i.html("").css({width: i.closest("#mapgyver_holder").width()}), e.clone().appendTo(i)
  }
}

function foldMapHandler() {
  var e = jQuery("#mapgyver_holder"), t = e.find(".originalmap"), i = e.find(".content-behind-map");
  TweenLite.to(e, .4, {opacity: 1}), foldMaps();
  var n = !1, a = "open";
  t.on('hover', function() {
    n = !0
  }, function() {
    n = !1
  }), setInterval(function() {
    1 == n && "open" == a && (unFoldMaps(), i.css({zIndex: 0}), setTimeout(function() {
      a = "close"
    }, 500), a = "closing"), 0 == n && "close" == a && (recreateMapClones(), foldMaps(), setTimeout(function() {
      a = "open", i.css({zIndex: 110})
    }, 500), a = "opening")
  }, 300)
}

function foldMaps() {
  var e = jQuery("#mapgyver_holder"), t = e.find(".originalmap");
  e.find(".content-behind-map"), TweenLite.to(t, .1, {opacity: 0, overwrite: "all"});
  for (var i = 0; i < 5; i++) {
    var n = jQuery("#overlaymap" + i), a = -60;
    2 == i && (a = 120), 3 == i && (a = -120), 4 == i && (a = 120), 5 == i && (a = -120);
    var r = n.width();
    0 < i && (TweenLite.set(n, {x: r}), TweenLite.to(n, .9, {
      transformPerspective: 7e3,
      transformOrigin: "left center",
      rotationY: a,
      ease: Power3.easeInOut,
      overwrite: "auto"
    })), n.find(".shadowoverlay").each(function() {
      TweenLite.to(jQuery(this), .85, {
        transformPerspective: 7e3,
        opacity: 1,
        overwrite: "all",
        ease: Power3.easeInOut
      })
    })
  }
}

function unFoldMaps() {
  var e = jQuery("#mapgyver_holder"), t = e.find(".originalmap");
  e.find(".content-behind-map"), TweenLite.to(t, .6, {opacity: 1, delay: .4, overwrite: "all"});
  for (var i = 0; i < 5; i++) {
    var n = jQuery("#overlaymap" + i);
    TweenLite.to(n, .6, {
      rotationY: 0,
      ease: Power3.easeInOut,
      overwrite: "auto"
    }), n.find(".shadowoverlay").each(function() {
      TweenLite.to(jQuery(this), .6, {opacity: 0, overwrite: "all", ease: Power3.easeInOut})
    })
  }
}

function initBlogOverview() {
  jQuery("body").append('<div id="unvisibleblogholder"></div>'), jQuery(".bo-post").appendTo("#unvisibleblogholder"), jQuery(document).on("click", "#bo-loadmorebutton", function() {
    jQuery.waypoints("refresh");
    var e = jQuery(window).scrollTop();
    loadMoreBlog(), jQuery(".bo-posts-list").waitForImages(function() {
      setTimeout(function() {
        setBoMediaHeight(), jQuery(".fitvideo").fitVids(), reBuildBlogOverview(.8, !0), setBoMediaHeight(), jQuery(window).scrollTop(e)
      }, 200)
    })
  }), loadMoreBlog(!0), reBuildBlogOverview(0), setBoMediaHeight(), jQuery(".bo-posts-list").waitForImages(function() {
    setTimeout(function() {
      reBuildBlogOverview(.8), setBoMediaHeight()
    }, 100)
  }), jQuery(window).on('resize', function() {
    var e = jQuery("body");
    jQuery(".container").first().width() != e.data("bo-lastcontainerwidth") && (e.data("bo-lastcontainerwidth", jQuery(".container").first().width()), clearTimeout(void 0), setBoMediaHeight(), reBuildBlogOverview(.8))
  })
}

function loadMoreBlog(e) {
  jQuery(".bo-posts-list").each(function() {
    var t, i = jQuery(this);
    0 != (t = e ? i.data("showfirst") : i.data("showatonce")) && null != t || (t = 9999), jQuery("#unvisibleblogholder").find(".bo-post").each(function(n) {
      if (n < t) {
        var a = jQuery(this);
        a.find(".bo-mediaholder").each(function() {
          var e = jQuery(this);
          e.append(e.find(".be-mediasource").data("mediasrc"));
          var t = e.find(".bo-seomedia");
          if (0 < t.length) {
            var i = t.attr("src");
            e.append('<div class="bo-media" style="background:url(' + i + ')"></div>')
          }
        }), a.appendTo(jQuery(".bo-posts-list")).css({top: i.height() + 1500}), e || a.addClass("bo-newloadedpost")
      }
    })
  })
}

function setBoMediaHeight() {
  jQuery(".bo-post.bo-left, .bo-post.bo-right").each(function(e) {
    var t = jQuery(this), i = t.find(".bo-mediaholder"), n = t.find(".bo-details");
    i.css({height: n.outerHeight() + "px"})
  })
}

function reBuildBlogOverview(e, t) {
  jQuery(".bo-posts-list").each(function() {
    var i = jQuery(this), n = 0, a = 0, r = 0, o = "", s = "", l = 110, c = "toleft", u = 95, d = 0;
    jQuery(window).width() < 1200 && (u = 70), jQuery(window).width() < 769 && (d = 1);
    var p = 0, h = 40;
    if (1 == d && (h = 0), i.find(".bo-post").each(function(p) {
      var m = jQuery(this), f = jQuery(this).data("day"), y = jQuery(this).data("month"),
          w = jQuery(this).data("year");
      if (w != o || y != s && 1 != d) {
        0 == jQuery("#" + y + w).length && i.append('<div class="bo-datedivider" id="' + y + w + '" ><p class="bo-month">' + y + '</p><p class="bo-year">' + w + "</p></div>");
        var g = jQuery("#" + (s = y) + (o = w));
        a < n ? a = n : n = a, TweenLite.to(g, e, {
          top: n,
          transformPerspective: 500,
          ease: Power3.easeOut
        }), 100 == (l = n + 50) && (l = 110), n += 90, a += 90
      }
      n <= a ? (1 != d ? 1 == t && m.hasClass("bo-newloadedpost") ? TweenLite.fromTo(m, .8, {
        x: 0,
        transformPerspective: 500,
        top: n + "px",
        transformOrigin: "-20% 50%",
        opacity: 0,
        z: -190,
        rotationY: 90
      }, {rotationY: 0, z: 0, opacity: 1, ease: Power3.easeOut}) : TweenLite.to(m, e, {
        x: 0,
        transformPerspective: 500,
        top: n + "px",
        ease: Power3.easeOut
      }) : TweenLite.to(m, e, {
        x: 0,
        transformPerspective: 500,
        top: "0px",
        ease: Power3.easeOut
      }), n = (r = n) + m.height() + h, i.css({height: n + "px"}), c = "toleft") : (1 != d ? 1 == t && m.hasClass("bo-newloadedpost") ? TweenLite.fromTo(m, .8, {
        x: i.width() / 2 + u,
        transformPerspective: 500,
        top: a + "px",
        transformOrigin: "120% 50%",
        opacity: 0,
        z: -190,
        rotationY: -90
      }, {
        rotationY: 0,
        z: 0,
        opacity: 1,
        ease: Power3.easeOut
      }) : TweenLite.to(m, e, {
        x: i.width() / 2 + u,
        transformPerspective: 500,
        top: a + "px",
        ease: Power3.easeOut
      }) : TweenLite.to(m, e, {
        x: 0,
        transformPerspective: 500,
        top: "0px",
        ease: Power3.easeOut
      }), a = (r = a) + m.height() + h, i.css({height: a + "px"}), c = "toright"), m.hasClass("bo-newloadedpost") && m.removeClass("bo-newloadedpost"), 1 == d && (a < n ? a = n : n = a);
      var v = r + 25, b = v + m.height() - 25, j = l + 60;
      j < v && (j = v + 10), b < j && (j = b - 10), l = j;
      var Q = y + w + f + "-" + p;
      0 == jQuery("#" + Q).length && i.append('<div id="' + Q + '" class="bo-daydivider"><p class="bo-day">' + f + ".</p></div>");
      var T = jQuery("#" + Q);
      T.removeClass("toright").removeClass("toleft").addClass(c), T.data("maxbottom", b), T.data("topme", j)
    }), 0 < jQuery("#unvisibleblogholder").find(".bo-post").length) {
      0 == jQuery("#bo-loadmorebutton").length && i.append('<div class="bo-datedivider" id="bo-loadmorebutton" ><div class="emptyholder"></div><p class="bo-month">' + goodweb_theme_vars.load + '</p><p class="bo-year">' + goodweb_theme_vars.more + "</p></div>");
      var m = jQuery("#bo-loadmorebutton");
      m.appendTo(i), a < n ? a = n : n = a, TweenLite.to(m, .8, {
        top: n,
        transformPerspective: 500,
        ease: Power3.easeOut
      }), l = n + 50, m.data("topme", l), TweenLite.to(i, .8, {
        height: l + "px",
        transformPerspective: 500,
        ease: Power3.easeOut
      }), 100 == l && (l = 110), n += 90, a += 90
    } else jQuery("#bo-loadmorebutton").remove();
    if (1 != d) {
      var f, y = 0, w = 0;
      if (i.find(".bo-daydivider").each(function() {
        var t = jQuery(this), i = t.data("topme"), n = t.data("maxbottom");
        if (0 != y) {
          var a = ((i < w ? i - 50 : w - 50) - y) / 2;
          TweenLite.to(f, e, {
            top: f.data("topme") + a,
            transformPerspective: 500,
            ease: Power3.easeOut
          })
        }
        y = i, w = n, f = t
      }), 0 != y) {
        var g = (w - 25 - y) / 2;
        TweenLite.to(f, e, {
          top: f.data("topme") + g,
          transformPerspective: 500,
          ease: Power3.easeOut
        })
      }
      try {
        p = f.data("topme") + g + 25, 0 < jQuery("#bo-loadmorebutton").length && (p = jQuery("#bo-loadmorebutton").data("topme") + 20), jQuery(".bo-middledivider").height(p)
      } catch (p) {
      }
    }
  })
}

function initInputFields() {
  jQuery("#Form_Search").on('focus', function() {
    jQuery("#searchform").addClass("onfocus")
  }), jQuery("#Form_Search").on('blur', function() {
    jQuery("#searchform").removeClass("onfocus")
  }), jQuery("body, html, #allcontent").on('click', function() {
    jQuery("#searchfrom").trigger('blur')
  }), jQuery(".prepared-input, .searchinput").each(function() {
    var e = jQuery(this);
    e.data("standard", e.val())
  }), jQuery(".prepared-input, .searchinput").on('focus', function() {
    var e = jQuery(this);
    e.val(e.val() == e.data("standard") ? "" : e.val())
  }), jQuery(".prepared-input, .searchinput").on('blur', function() {
    var e = jQuery(this);
    e.val("" == e.val() ? e.data("standard") : e.val())
  })
}

function initModuleAnims() {
  var e = jQuery(".container").first().width() / 2;
  jQuery(".module-title, .headline-title").addClass("gw-rft"), jQuery(".bo-datedivider, .bo-daydivider ").each(function(e) {
    jQuery(this).data("delay", 30 * e).addClass("gw-zin")
  }), jQuery(".bo-post").each(function(t) {
    var i = jQuery(this);
    i.data("delay", 30 * t), i.position().left < e ? i.addClass("gw-rfl") : i.addClass("gw-rfr")
  }), jQuery(".mediawall-filters, .nav.nav-tabs").each(function() {
    jQuery(this).find("li").each(function(e) {
      jQuery(this).data("delay", 100 * e).addClass("gw-sfr")
    })
  }), jQuery(".mediawall-gallery").addClass("gw-sfl"), jQuery(".row, .row-fluid").each(function() {
    if (0 == jQuery(this).closest("#subfooter").length && 0 == jQuery(this).closest("#footer").length && "maincontent" != jQuery(this).parent().attr("id")) {
      var e = jQuery(this).width() / 2 - 50;
      jQuery(this).find(".span1, .span2, .span3, .span4, .span5, .span6, .span7, .span8, .span9, .span10, .span11, .span12 ").each(function(t) {
        var i = jQuery(this);
        0 < i.find(".fbuilder_row").length || i.hasClass("thesidebar") || (i.data("delay", 50 * t), i.position().left < e ? i.addClass("gw-rfl") : i.addClass("gw-rfr"))
      })
    }
  }), jQuery(".thesidebar .widget").each(function(t) {
    var i = jQuery(this);
    i.data("delay", 50 * (t + 1)), i.position().left < e ? i.addClass("gw-rfl") : i.addClass("gw-rfr")
  }), jQuery(".fbuilder_row").each(function() {
    var e = jQuery(this).width() / 2 - 50, t = 0;
    jQuery(this).find(".fbuilder_column").each(function() {
      if (!jQuery(this).hasClass("fbuilder_column-1-1")) {
        var i = jQuery(this);
        i.data("delay", 50 * t), i.position().left < e ? i.addClass("gw-rfl") : i.addClass("gw-rfr"), t += 1
      }
    })
  }), jQuery(".pricingtable").each(function() {
    jQuery(this).find("li").each(function(e) {
      jQuery(this).data("delay", 10 * e).addClass("gw-zin")
    })
  }), jQuery(".accordion").each(function() {
    jQuery(this).find(".accordion-group ").each(function(e) {
      jQuery(this).data("delay", 10 * e).addClass("gw-zin")
    })
  }), addAnimateEffects()
}

function addAnimateEffects() {
  jQuery(".gw-rfl, .gw-zin, .gw-rfr, .gw-sfb, .gw-rft, .gw-sfl, .gw-sfr, .gw-rsfl, .gw-rsfr").each(function() {
    var e = jQuery(this);
    "absolute" != e.css("position") && e.addClass("relative"), e.hasClass("gw-rfl") ? e.data("anim", TweenLite.fromTo(e, .8, {
      transformStyle: "flat",
      transformOrigin: "-20% 50%",
      opacity: 0,
      z: -19,
      transformPerspective: 500,
      rotationY: 90
    }, {
      rotationY: 0, z: 0, opacity: 1, ease: Power3.easeOut, onComplete: function() {
        e.removeClass("gw-rfl")
      }
    })) : e.hasClass("gw-rfr") ? e.data("anim", TweenLite.fromTo(e, .8, {
      transformStyle: "flat",
      transformOrigin: "120% 50%",
      opacity: 0,
      z: -19,
      transformPerspective: 500,
      rotationY: -90
    }, {
      rotationY: 0, z: 0, opacity: 1, ease: Power3.easeOut, onComplete: function() {
        e.removeClass("gw-rfr")
      }
    })) : e.hasClass("gw-rft") ? e.data("anim", TweenLite.fromTo(e, 1.2, {
      transformStyle: "flat",
      transformOrigin: "center -20px",
      opacity: 0,
      z: -50,
      transformPerspective: 500,
      rotationX: 90,
      y: -20
    }, {
      x: 0, rotationX: 0, y: 0, z: 0, opacity: 1, ease: Power3.easeOut, onComplete: function() {
        e.removeClass("gw-rft")
      }
    })) : e.hasClass("gw-zin") ? e.data("anim", TweenLite.fromTo(e, 1.4, {
      transformStyle: "flat",
      transformOrigin: "center -20px",
      opacity: 0,
      z: 30,
      transformPerspective: 500,
      rotationX: 100,
      scale: 0
    }, {
      rotationX: 0, z: 0, scale: 1, opacity: 1, ease: Back.easeOut, onComplete: function() {
        e.removeClass("gw-zin")
      }
    })) : e.hasClass("gw-sfb") ? e.data("anim", TweenLite.fromTo(e, .8, {
      transformStyle: "flat",
      opacity: 0,
      transformPerspective: 500,
      y: 100
    }, {
      y: 0, opacity: 1, ease: Power3.easeOut, onComplete: function() {
        e.removeClass("gw-sfb")
      }
    })) : e.hasClass("gw-sfl") ? e.data("anim", TweenLite.fromTo(e, .8, {
      transformStyle: "flat",
      opacity: 0,
      transformPerspective: 500,
      x: -100
    }, {
      x: 0, opacity: 1, ease: Power3.easeOut, onComplete: function() {
        e.removeClass("gw-sfl")
      }
    })) : e.hasClass("gw-sfr") && e.data("anim", TweenLite.fromTo(e, .8, {
      transformStyle: "flat",
      opacity: 0,
      transformPerspective: 500,
      x: 100
    }, {
      x: 0, opacity: 1, ease: Power3.easeOut, onComplete: function() {
        e.removeClass("gw-sfr")
      }
    })), e.data("anim").seek(0).pause(), setTimeout(function() {
      e.waypoint(function(t) {
        if ("down" == t) {
          var i = e.data("delay");
          null == i && (i = Math.round(300 * Math.random() + 100)), setTimeout(function() {
            e.data("anim").restart()
          }, i), e.waypoint("destroy")
        }
      }, {offset: "82%"})
    }, 500)
  })
}

function initSkills() {
  jQuery(".skill-scale").each(function() {
    var e = jQuery(this);
    e.append('<div class="skill-underlay"><div class="skill-overlay" style="width:0%"></div></div>'), is_mobile() ? e.find(".skill-overlay").css({width: e.data("scale") + "%"}).append('<div class="skillproc">' + e.data("scale") + "%</div>") : e.waypoint(function(t) {
      "down" == t && (e.find(".skill-overlay").css({width: e.data("scale") + "%"}).append('<div class="skillproc">' + e.data("scale") + "%</div>"), e.waypoint("destroy"))
    }, {offset: "90%"})
  })
}

function initAccordions() {
  jQuery(".accordion-toggle").each(function() {
    jQuery(this).on('click', function() {
      var e = jQuery(this).closest(".accordion");
      e.find(".accordion-toggle").addClass("collapsed"), e.find(".in.collapse").each(function() {
        var t = jQuery(this);
        e.find(t.data("parent")).find(".accordion-toggle").removeClass("collapsed")
      })
    })
  })
}

function checkie() {
  var e = !jQuery.support.opacity, t = jQuery.fn.jquery.split("."), i = parseFloat(t[0]);
  return parseFloat(t[1]), parseFloat(t[2] || "0"), 1 < i && (opt.ie = !1), e
}

function checkie9() {
  return 9 == document.documentMode
}

function buildPagination(e, t) {
  var i = e.find(".mediawall-gallery");
  e.find(".mediawall-filter-wrapper.media-pagination li").remove(), e.find(t).length;
  for (var n = i.data("maxshownitems"), a = 0; a < 20; a++) i.find(".mwpage" + a).removeClass("mwpage" + a);
  var r = 0, o = 1;
  if (i.find(".item").each(function() {
    var e = jQuery(this);
    e.hasClass(t) && (n < (r += 1) && (o += r = 1), e.addClass("mwpage" + o))
  }), 1 < o) {
    for (0 == e.find(".mediawall-filter-wrapper.media-pagination").length && e.append('<article class="mediawall-filter-wrapper media-pagination"><ul class="mediawall-filters"></ul><div class="clear"></div></article>'), a = 1; a <= o; a++) e.find(".media-pagination .mediawall-filters").append('<li class="media-pagination-filter-button"><a class="mediawall-filter media-pagination-filter-button" data-filter="mwpage' + a + '">' + a + "</a></li>");
    e.find(".media-pagination .mediawall-filter").first().addClass("selected")
  }
  e.find(".media-pagination .mediawall-filter").unbind("click"), e.find(".media-pagination .mediawall-filter").on("click", function() {
    var t = jQuery(this);
    t.closest("ul").find(".mediawall-filter").removeClass("selected"), t.addClass("selected");
    var n = "";
    return e.find(".mediawall-filter.selected").each(function() {
      n = n + "." + jQuery(this).data("filter")
    }), i.isotope({filter: n}), !1
  })
}

function initMediaWall() {
  var e;
  jQuery(".mediawall-content").each(function() {
    var e = jQuery(this);
    e.css({marginTop: (e.parent().height() - e.outerHeight()) / 2 + "px"})
  }), jQuery(window).on('resize', function() {
    clearTimeout(e), e = setTimeout(function() {
      jQuery(".mediawall-content").each(function() {
        var e = jQuery(this);
        e.css({marginTop: (e.parent().height() - e.outerHeight()) / 2 + "px"})
      })
    }, 1e3)
  }), jQuery(".mediawall").each(function() {
    var e = jQuery(this), t = e.find(".mediawall-gallery");
    t.find(".item").addClass("allitem");
    var i = e.find(".mediawall-filter.selected").data("filter");
    buildPagination(e, i);
    var n, a = "";
    e.find(".mediawall-filter.selected").each(function() {
      a = a + "." + jQuery(this).data("filter")
    }), t.isotope({
      itemSelector: ".item",
      layoutMode: "fitRows",
      filter: a
    }), t.waitForImages(function() {
      t.isotope("reLayout"), e.find(".mediawall-content").each(function() {
        var e = jQuery(this);
        e.css({marginTop: (e.parent().height() - e.outerHeight()) / 2 + "px"})
      })
    }), e.find(".mediawall-filter").on("click", function() {
      var i = jQuery(this);
      i.closest("ul").find(".mediawall-filter").removeClass("selected"), i.addClass("selected"), i.hasClass("media-pagination-filter-button") || buildPagination(e, i.data("filter"));
      var n = "";
      return e.find(".mediawall-filter.selected").each(function() {
        n = n + "." + jQuery(this).data("filter")
      }), t.isotope({filter: n}), jQuery(".isotope-item").each(function(e) {
        var t = n.split(".");
        curfilter = "allitem", jQuery.each(t, function(e, t) {
          0 < t.length && t.split("mwpage").length < 2 && (curfilter = t)
        });
        var i = jQuery(this);
        i.hasClass(curfilter) ? i.find(".puncbox-notactive").removeClass("puncbox-notactive").addClass("punchbox") : i.find(".punchbox").addClass("puncbox-notactive").removeClass("punchbox")
      }), !1
    }), e.find(".mediawall-content").each(function() {
      var e = jQuery(this);
      e.css({marginTop: (e.parent().height() - e.height()) / 2 + "px"})
    }), jQuery(window).on('resize', function() {
      clearTimeout(n), n = setTimeout(function() {
        t.isotope("reLayout")
      }, 1e3)
    }), t.find(".item").each(function() {
      var e = jQuery(this).find(".mediawall-mediacontainer"), t = "0px 0px 0px 0px rgba(0,0,0,0)";
      jQuery("body").hasClass("gw_light") && (t = "0px 0px 0px 0px rgba(0,0,0,0)"), TweenLite.set(e, {boxShadow: t})
    }), t.find(".item").on('hover', function() {
      var e = jQuery(this), t = e.find(".mediawall-mediacontainer"),
          i = e.find(".mediawall-overlay"), n = e.find(".mediawall-content"),
          a = e.find(".mediawall-lightbox"), r = e.find(".mediawall-link"),
          o = "0px 0px 25px 0px rgba(0,0,0,0.5)";
      jQuery("body").hasClass("gw_light") && (o = "0px 0px 25px 0px rgba(0,0,0,0.1)");
      var s = (1.15 * (s = t.width()) - s) / 2, l = (1.15 * (l = t.height()) - l) / 2;
      isIE(8) && (l = s = 0), TweenLite.to(e, .4, {zIndex: 100}), TweenLite.fromTo(i, .4, {opacity: 0}, {
        display: "block",
        opacity: 1,
        ease: Power3.easeOut
      }), TweenLite.fromTo(n, .4, {
        transformPerspective: 500,
        scale: 1.2,
        z: 10,
        opacity: 0
      }, {
        scale: 1,
        display: "block",
        opacity: 1,
        z: 1,
        ease: Power2.easeOut
      }), TweenLite.fromTo(a, .6, {
        scale: .8,
        transformOrigin: "center top",
        opacity: 0,
        transformPerspective: 500,
        rotationX: 90,
        x: s,
        y: l - 10
      }, {
        scale: 1,
        rotationX: 0,
        x: s,
        y: l,
        display: "block",
        opacity: 1,
        ease: Power3.easeOut
      }), TweenLite.fromTo(r, .8, {
        scale: .8,
        transformOrigin: "center top",
        opacity: 0,
        transformPerspective: 500,
        rotationX: 90,
        x: s,
        y: l - 10
      }, {
        scale: 1,
        rotationX: 0,
        x: s,
        y: l,
        display: "block",
        opacity: 1,
        ease: Power3.easeOut
      }), TweenLite.to(t, .6, {
        scale: 1.15,
        transformPerspective: 500,
        boxShadow: o,
        ease: Power3.easeOut,
        overwrite: "all"
      })
    }, function() {
      var e = jQuery(this), t = e.find(".mediawall-mediacontainer"),
          i = e.find(".mediawall-overlay"), n = e.find(".mediawall-content"),
          a = e.find(".mediawall-lightbox"), r = e.find(".mediawall-link"),
          o = "0px 0px 0px 0px rgba(0,0,0,0)";
      jQuery("body").hasClass("gw_light") && (o = "0px 0px 0px 0px rgba(0,0,0,0)"), TweenLite.to(e, .2, {zIndex: 1}), TweenLite.to(i, .3, {
        display: "none",
        opacity: 0
      }), TweenLite.to(n, .5, {
        scale: .5,
        transformPerspective: 500,
        opacity: 0,
        display: "none"
      }), TweenLite.to(a, .4, {
        scale: .8,
        display: "none",
        opacity: 0,
        transformPerspective: 500,
        rotationX: 90,
        ease: Power3.easeOut,
        overwrite: "all"
      }), TweenLite.to(r, .4, {
        scale: .8,
        display: "none",
        opacity: 0,
        transformPerspective: 500,
        rotationX: 90,
        ease: Power3.easeOut,
        overwrite: "all"
      }), TweenLite.to(t, .3, {
        scale: 1,
        transformPerspective: 500,
        rotationY: 0,
        rotationX: 0,
        boxShadow: o,
        ease: Power4.easeOut,
        overwrite: "all"
      })
    });
    var r = e.data("autoplay"), o = e.data("autoplaydelay");
    null == r && (r = "disabled"), null == o && (o = 5e3);
    var s = e.punchBox({
      items: ".punchbox",
      navigation: {container: "insidemedia", position: "dettached", autoplay: r, autoplaydelay: o},
      metaInfo: {
        showMeta: !0,
        orderMarkup: "%n / %m",
        metaMarkup: '<div class="pb-metawrapper"><div class="pb-title">%title%</div><div class="pb-metadata">%metadata%</div><div class="pb-order">%ordermarkup%</div></div>'
      },
      callbacks: {
        ready: function(e, t) {
        }, beforeAnim: function(e, t) {
        }, afterAnim: function(e, t) {
        }
      }
    });
    s.on("pause", function() {
    }), s.on("resume", function() {
    }), s.on("beforeanim", function() {
    }), s.on("afteranim", function() {
    })
  })
}

function initShowbizSimple() {
  jQuery(".mediawallshowbiz").find("li").each(function() {
    jQuery(this).on('hover', function() {
      var e = jQuery(this), t = e.find(".mediawall-mediacontainer"),
          i = e.find(".mediawall-overlay"), n = e.find(".mediawall-content"),
          a = e.find(".mediawall-lightbox"), r = e.find(".mediawall-link");
      jQuery("body").hasClass("gw_light"), n.css({marginTop: (t.height() - n.outerHeight()) / 2 + "px"}), TweenLite.to(e, .4, {zIndex: 100}), TweenLite.fromTo(i, .4, {opacity: 0}, {
        display: "block",
        opacity: 1,
        ease: Power3.easeOut
      }), TweenLite.fromTo(n, .4, {
        transformPerspective: 500,
        scale: 1.2,
        z: 10,
        opacity: 0
      }, {
        scale: 1,
        display: "block",
        opacity: 1,
        z: 1,
        ease: Power2.easeOut
      }), TweenLite.fromTo(a, .6, {
        scale: .8,
        transformOrigin: "center top",
        opacity: 0,
        transformPerspective: 500,
        rotationX: 90
      }, {
        scale: 1,
        rotationX: 0,
        display: "block",
        opacity: 1,
        ease: Power3.easeOut
      }), TweenLite.fromTo(r, .8, {
        scale: .8,
        transformOrigin: "center top",
        opacity: 0,
        transformPerspective: 500,
        rotationX: 90
      }, {scale: 1, rotationX: 0, display: "block", opacity: 1, ease: Power3.easeOut})
    }, function() {
      var e = jQuery(this), t = (e.find(".mediawall-mediacontainer"), e.find(".mediawall-overlay")),
          i = e.find(".mediawall-content"), n = e.find(".mediawall-lightbox"),
          a = e.find(".mediawall-link");
      TweenLite.to(e, .2, {zIndex: 1}), TweenLite.to(t, .3, {
        display: "none",
        opacity: 0
      }), TweenLite.to(i, .5, {
        scale: .5,
        transformPerspective: 500,
        opacity: 0,
        display: "none"
      }), TweenLite.to(n, .4, {
        scale: .8,
        display: "none",
        opacity: 0,
        transformPerspective: 500,
        rotationX: 90,
        ease: Power3.easeOut,
        overwrite: "all"
      }), TweenLite.to(a, .4, {
        scale: .8,
        display: "none",
        opacity: 0,
        transformPerspective: 500,
        rotationX: 90,
        ease: Power3.easeOut,
        overwrite: "all"
      })
    })
  })
}

function resetMenuButtonContent() {
  if (768 < jQuery(window).width() && "MENU" == jQuery("#current-menu-txt").text()) {
    jQuery("#current-menu-txt-new").remove();
    var e = jQuery("menu .active").text();
    "" == e && (e = jQuery("body").data("menutitle")), jQuery("#current-menu-txt").html(e), jQuery("#current-menu-txt").data("curhtml", e), jQuery("#current-menu-txt").parent().width(jQuery("#current-menu-txt").width() + 65)
  }
  jQuery(window).width() < 768 && "MENU" != jQuery("#current-menu-txt").html() && (jQuery("#current-menu-txt-new").remove(), jQuery("#current-menu-txt").html("MENU"))
}

function setHeightOfMenuHolder() {
  if (is_mobile()) jQuery("#headerwrapper").css({paddingTop: "30px"}), jQuery("#maincontent").css({marginTop: "30px"}), jQuery("#mainmenuholder").css({height: "100%"}), resetMenuButtonContent(); else if (!is_mobile()) {
    var e = jQuery("#navigation").height();
    jQuery("#headerwrapper").css({paddingTop: 30 + e}), jQuery("#maincontent").css({marginTop: 50 + e}), setTimeout(function() {
      jQuery("#mainmenuholder").css({height: e})
    }, 1e3)
  }
}

function initMenuFunctions() {
  var e, t;
  if (t = -1 != navigator.userAgent.indexOf("Mac OS X") ? 3 : 30, !is_mobile() && jQuery("body").hasClass("menuonleft")) {
    jQuery("#navigation").jScrollPane({mouseWheelSpeed: t});
    var i = jQuery("#navigation").data("jsp")
  } else is_mobile() && jQuery("body").removeClass("menuontop"), jQuery("body").hasClass("menuontop") ? (TweenLite.fromTo(jQuery(".menuontop menu"), .4, {
    y: -200,
    autoAlpha: 0
  }, {
    autoAlpha: 1,
    y: 0,
    delay: 1.2,
    ease: Power3.easeInOut
  }), jQuery("#navigation").css({overflow: "hidden"}), jQuery(window).on('resize', function() {
    setHeightOfMenuHolder()
  }), setHeightOfMenuHolder(), jQuery(window).trigger("resize"), jQuery(".menu-item-has-children .menu-item-has-children").on('hover', function() {
    var e = jQuery(this);
    e.removeClass("submenutoleft"), jQuery(window).width() - (e.find(">ul").width() + e.offset().left) < 200 && e.addClass("submenutoleft")
  })) : jQuery("#navigation").css({overflow: "scroll"});

  var n, a = jQuery("#navigation ul").first();
  if (jQuery(window).on('resize', function() {
    try {
      clearTimeout(e), e = setTimeout(function() {
        a.css({height: "auto"}), a.outerHeight() > jQuery(window).height() && a.css({height: a.outerHeight() + 200 + "px"}), i && i.reinitialise()
      }, 450)
    } catch (e) {
    }
  }), jQuery("menu #navigation li").each(function() {
    jQuery(this).find("ul").length && jQuery(this).addClass("hassubmenu")
  }), $str = window.location.href, 0 < $str.search("altoros.com") && jQuery(".menuontop menu #navigation>ul>li .menubutton").css("padding", "0px 17.5px 0px 17.5px"), jQuery(".hassubmenu a").each(function() {
    jQuery(this).on('click', function() {
      try {
        setTimeout(function() {
          a.css({height: "auto"}), a.outerHeight() > jQuery(window).height() && a.css({height: a.outerHeight() + 200 + "px"}), i && i.reinitialise()
        }, 450)
      } catch (e) {
      }
      jQuery(this).closest("li");
      var e = jQuery("body").data("topos");
      setTimeout(function() {
        jQuery(window).scrollTop(e)
      }, 1)
    })
  }), jQuery(".header-menu-wrapper, .header-menu-closer").on('click', function() {
    var e = jQuery("#navigation"), t = jQuery("menu"), n = jQuery("#allcontent"),
        r = jQuery(".cinematic"), o = jQuery("#headerwrapper");
    try {
      setTimeout(function() {
        a.css({height: "auto"}), a.outerHeight() > jQuery(window).height() && a.css({height: a.outerHeight() + 200 + "px"}), i && i.reinitialise()
      }, 150)
    } catch (e) {
    }
    if (768 < jQuery(window).width()) {
      var s = jQuery(window).width();
      e.hasClass("opened") ? (jQuery("body").data("topos"), TweenLite.to(jQuery(".menucloser"), .4, {
        opacity: 0,
        overwrite: "true"
      }), TweenLite.to(n, .5, {left: 0, ease: Power2.easeInOut}), TweenLite.to(r, .5, {
        left: 0,
        transformPerspective: 10,
        ease: Power2.easeInOut
      }), is_mobile() || TweenLite.to(o, .5, {
        left: 0,
        transformPerspective: 10,
        ease: Power2.easeInOut
      }), e.removeClass("opened"), jQuery(".header-menu-wrapper").removeClass("active"), t.css({"z-index": 0}), TweenLite.to(jQuery(".header-menu-wrapper"), .3, {
        x: 0,
        overwrite: "auto"
      }), setTimeout(function() {
        t.css({display: "none"}), setTimeout(function() {
          jQuery(".fakebgformobile").remove()
        }, 100), n.css({position: "static", width: "auto", height: "auto"}), setMainContentMargin()
      }, 850)) : (jQuery("body").append('<div class="fakebgformobile"></div>'), jQuery("body").data("topos", jQuery(window).scrollTop()), jQuery("body").data("topos"), n.css({
        position: "absolute",
        width: "100%",
        height: "100%",
        top: "0px"
      }), setMainContentMargin(24), t.css({display: "block"}), TweenLite.fromTo(jQuery(".menucloser"), .4, {opacity: 0}, {
        opacity: 1,
        ease: Power2.easeOut,
        delay: 1
      }), TweenLite.to(n, .5, {
        left: 275,
        ease: Power2.easeInOut,
        delay: .1
      }), TweenLite.to(r, .5, {
        left: 275,
        transformPerspective: 10,
        ease: Power2.easeInOut,
        delay: .1
      }), (s < 1250 && 1200 < s || s < 1020 && 980 < s) && TweenLite.to(jQuery(".header-menu-wrapper"), .3, {x: 30}), is_mobile() || TweenLite.to(o, .5, {
        left: 275,
        transformPerspective: 10,
        ease: Power2.easeInOut,
        delay: .1
      }), TweenLite.to(e, .5, {
        width: 275,
        left: 0,
        ease: Power2.easeInOut,
        overwrite: "true"
      }), TweenLite.to(t, .5, {
        width: 275,
        left: 0,
        ease: Power2.easeInOut,
        overwrite: "true"
      }), e.addClass("opened"), jQuery(".header-menu-wrapper").addClass("active"), setTimeout(function() {
        e.hasClass("opened") && t.css({"z-index": 1001})
      }, 1100))
    } else e.hasClass("opened") ? (e.removeClass("opened"), jQuery(".header-menu-wrapper").removeClass("active"), TweenLite.to(t, .5, {
      left: 0 - jQuery(window).width(),
      width: jQuery(window).width(),
      ease: Power2.easeInOut,
      delay: .1
    })) : (t.css({"z-index": 1001}), TweenLite.fromTo(t, .5, {
      left: 0 - jQuery(window).width(),
      width: jQuery(window).width()
    }, {
      display: "block",
      left: 0,
      ease: Power2.easeInOut,
      delay: .1
    }), e.addClass("opened"), jQuery(".header-menu-wrapper").addClass("active"))
  }), jQuery(window).on('resize', function() {
    clearTimeout(n), n = setTimeout(function() {
      var e = jQuery(window).width(), t = jQuery("#navigation"), i = jQuery("menu"),
          n = jQuery("#allcontent"), a = jQuery(".cinematic"), r = jQuery("#headerwrapper");
      t.hasClass("opened") && (768 < jQuery(window).width() ? (TweenLite.to(n, .3, {
        left: 275,
        ease: Power2.easeInOut
      }), TweenLite.to(a, .3, {
        left: 275,
        transformPerspective: 10,
        ease: Power2.easeInOut
      }), e < 1250 && 1200 < e || e < 1020 && 980 < e ? TweenLite.to(jQuery(".header-menu-wrapper"), .3, {x: 30}) : TweenLite.to(jQuery(".header-menu-wrapper"), .3, {x: 0}), is_mobile() || TweenLite.to(r, .3, {
        left: 275,
        transformPerspective: 10,
        ease: Power2.easeInOut
      }), TweenLite.to(t, .3, {
        width: 275,
        left: 0,
        ease: Power2.easeInOut,
        overwrite: "true"
      }), TweenLite.to(i, .3, {
        width: 275,
        left: 0,
        ease: Power2.easeInOut,
        overwrite: "true"
      })) : (TweenLite.to(i, .3, {
        left: 0,
        width: jQuery(window).width(),
        ease: Power2.easeInOut
      }), TweenLite.to(t, .3, {width: "100%", left: 0, ease: Power2.easeInOut})))
    }, 150)
  }), !isIE(8)) {
    var r = "#" + location.hash.split("#")[1];
    r = r.replace("!", "");
    var o = new Array, s = jQuery("#headerwrapper").outerHeight() + 60, l = !1;
    jQuery("menu .internallink").each(function(e) {
      var t = "#" + jQuery(this).attr("href").split("#")[1];
      t = t.replace("!", "");
      var i = jQuery(t);
      i.data("menutolink", jQuery(this)), i.data("menutolink-id", e), o.push(i), i.waypoint(function(e) {
        if ("down" == e) var t = jQuery(this).data("menutolink"); else 0 == (n = jQuery(this).data("menutolink-id")) && (n = 1), t = o[n - 1].data("menutolink");
        var i = t.text(), n = "#" + t.attr("href").split("#")[1];
        console.log("id shoud. " + n), n = n.replace("!", ""), jQuery("menu .active").removeClass("active"), t.closest("li").addClass("active");
        var a = n.replace("#", "#!");
        history.pushState ? history.pushState(null, null, a) : location.hash = a, 768 < jQuery(window).width() ? i != jQuery("#current-menu-txt").text() && (jQuery("#current-menu-txt-new").remove(), jQuery(".header-menu-wrapper").append('<div id="current-menu-txt-new">' + i + "</div>"), jQuery("#current-menu-txt").parent().width(jQuery("#current-menu-txt-new").width() + 65), "down" == e ? (TweenLite.fromTo(jQuery("#current-menu-txt-new"), .4, {
          y: 30,
          opacity: 0
        }, {
          y: 0,
          opacity: 1,
          ease: Power2.easeInOut,
          overwrite: "auto"
        }), TweenLite.fromTo(jQuery("#current-menu-txt"), .4, {y: 0, opacity: 1}, {
          y: -30,
          opacity: 0,
          ease: Power2.easeInOut,
          overwrite: "auto",
          onComplete: function() {
            jQuery("#current-menu-txt").html(i), jQuery("#current-menu-txt-new").remove(), TweenLite.to(jQuery("#current-menu-txt"), 0, {
              y: 0,
              opacity: 1
            }), jQuery("#current-menu-txt").parent().width(jQuery("#current-menu-txt").width() + 65)
          }
        })) : (jQuery("#current-menu-txt").parent().width(jQuery("#current-menu-txt-new").width() + 65), TweenLite.fromTo(jQuery("#current-menu-txt-new"), .4, {
          y: -30,
          opacity: 0
        }, {
          y: 0,
          opacity: 1,
          ease: Power2.easeInOut,
          overwrite: "auto"
        }), TweenLite.fromTo(jQuery("#current-menu-txt"), .4, {y: 0, opacity: 1}, {
          y: 30,
          opacity: 0,
          ease: Power2.easeInOut,
          overwrite: "auto",
          onComplete: function() {
            jQuery("#current-menu-txt").html(i), jQuery("#current-menu-txt-new").remove(), TweenLite.to(jQuery("#current-menu-txt"), 0, {
              y: 0,
              opacity: 1
            }), jQuery("#current-menu-txt").parent().width(jQuery("#current-menu-txt").width() + 65)
          }
        }))) : (jQuery("#current-menu-txt-new").remove(), jQuery("#current-menu-txt").html("MENU"))
      }, {offset: "49%"}), jQuery(window).on('resize', function() {
        resetMenuButtonContent()
      }), t == r && (jQuery("menu .active").removeClass("active"), jQuery(this).closest("li").addClass("active"), setTimeout(function() {
        var e = jQuery(t);
        l = !0, setTimeout(function() {
          var t = e.offset().top - s;
          e.hasClass("noheadline") && (t += 40);
          var i = 0;
          1e3 < t && (i = 200), 3e3 < t && (i = 400), 5e3 < t && (i = 700), jQuery("html, body").animate({scrollTop: t}, {duration: i})
        }, 850);
        var i = t.replace("#", "#!");
        history.pushState ? history.pushState(null, null, i) : location.hash = i
      }, 200, i))
    })
  }
  l || jQuery("#current-menu-txt").parent().width(jQuery("#current-menu-txt").width() + 65), jQuery("#current-menu-txt").data("txt", jQuery("#current-menu-txt").text()), TweenLite.fromTo(jQuery("#headerwrapper"), .1, {opacity: 0}, {
    visibility: "visible",
    opacity: 1,
    overwrite: "all",
    ease: Power3.easeIn
  }), jQuery("body").on("click", "a.smoothscroll", function() {
    var e = jQuery(this).attr("href"), t = jQuery(e);
    if (0 != t.length) {
      var i = t.offset().top - s;
      t.hasClass("noheadline") && (i += 40);
      var n = i / 5;
      return jQuery("html, body").animate({scrollTop: i}, {duration: n}), !1
    }
  }), jQuery(".internallink").each(function() {
    jQuery(this).on('click', function() {
      if (!jQuery(this).hasClass("nolink")) {
        jQuery("#navigation").hasClass("opened") && jQuery(".header-menu-wrapper").trigger('click');
        var e = "#" + jQuery(this).attr("href").split("#")[1], t = jQuery(e);
        if (t.length) {
          var i = jQuery("#headerwrapper").outerHeight() + 60;
          t.hasClass("noheadline") && (i -= 40);
          var n = t.offset().top - i;
          return jQuery("menu .active").removeClass("active"), jQuery(this).closest("li").addClass("active"), setTimeout(function() {
            jQuery("html, body").animate({scrollTop: n}, {duration: 1e3})
          }, 350), history.pushState ? history.pushState(null, null, e) : location.hash = e, !1
        }
      }
    })
  }), is_mobile() ? jQuery(".cinematic-down").on('click', function() {
    var e = jQuery(window).height();
    jQuery("html, body").animate({scrollTop: e}, {duration: 1e3})
  }) : jQuery(".cinematic-down").on('click', function() {
    var e = jQuery(window).height() - 3 * jQuery("#headerwrapper").height() - jQuery("#mainmenuholder").height();
    jQuery("html, body").animate({scrollTop: e}, {duration: 1e3})
  })
}

function setMainContentMargin(e) {
  null == e && (e = 0);
  var t = jQuery("#maincontent");
  null == t.data("topmargin") && t.data("topmargin", parseInt(t.css("marginTop"), 0));
  var i = t.data("topmargin");
  0 < jQuery("#cinematic-title-wrapper").length ? t.css({marginTop: jQuery(window).height() + e + "px"}) : t.css({marginTop: i + e + "px"})
}

function drawSliders(e, n) {
  e.find(".slide-background-image").each(function(e) {
    var t = jQuery(this);
    t.closest("li").css({width: n + "%"});
    var i = "visible";
    if (0 != e && (i = "hidden"), t.append('<div class="cinematic-basicimage-wrapper"><div class="cinematicmedia_outter_wrapper"><div class="cinematicmedia_inner_wrapper" style="visible:' + i + '"></div></div></div>'), 0 == e) {
      var a = new Image;
      a.onload = function() {
        TweenLite.to(jQuery(".cinematic.original, .cinematic.overheader"), .7, {
          opacity: 1,
          ease: Power3.easeInOut
        })
      };
      a.src = t.data("src")
    }
    var r = null == t.data("size") ? "cover" : t.data("size"),
        o = null == t.data("blursize") ? "cover" : t.data("blursize"),
        s = null == t.data("containrepeat") ? "no-repeat" : t.data("containrepeat"),
        l = null == t.data("containblurrepeat") ? "no-repeat" : t.data("containblurrepeat");
    1 != t.data("repeatbg") && (t.find(".cinematicmedia_inner_wrapper").append('<div class="cinematic-basicimage fullscreenimgs"></div>'), t.find(".cinematic-basicimage").css({
      backgroundRepeat: s,
      backgroundImage: "url(" + t.data("src") + ")",
      backgroundSize: r,
      backgroundPosition: "center center",
      width: "100%",
      height: "100%"
    }));
    1 == t.data("repeatbg") && (t.find(".cinematicmedia_inner_wrapper").append('<div class="cinematic-basicimage fullscreenimgs"></div>'), t.find(".cinematic-basicimage").css({
      backgroundImage: "url(" + t.data("src") + ")",
      backgroundPosition: "center center",
      width: "100%",
      height: "100%",
      backgroundRepeat: "repeat"
    }));
    if (!is_mobile()) {
      t.append('<div class="cinematic-blurryimage-wrapper"><div class="cinematicmedia_outter_wrapper"><div class="cinematicmedia_inner_wrapper" style="visible:' + i + '"></div></div></div>');
      1 != t.data("repeatbg2") && (t.find(".cinematic-blurryimage-wrapper .cinematicmedia_inner_wrapper").append('<div class="cinematic-blurryimage fullscreenimgs"></div>'), t.find(".cinematic-blurryimage").css({
        backgroundRepeat: l,
        backgroundImage: "url(" + t.data("srcblur") + ")",
        backgroundSize: o,
        backgroundPosition: "center center",
        width: "100%",
        height: "100%"
      }));
      1 == t.data("repeatbg2") && (t.find(".cinematic-blurryimage-wrapper .cinematicmedia_inner_wrapper").append('<div class="cinematic-blurryimage fullscreenimgs"></div>'), t.find(".cinematic-blurryimage").css({
        backgroundImage: "url(" + t.data("srcblur") + ")",
        backgroundPosition: "center center",
        width: "100%",
        height: "100%",
        backgroundRepeat: "repeat"
      }));
      0 == e && jQuery(".single_blurredbg").each(function() {
        var e = jQuery(this), i = t.data("width"), n = t.data("height");
        e.data("width", i);
        e.data("height", n);
        jQuery("body").hasClass("nobluredcontainers") ? e.css({background: "transparent"}) : e.css({backgroundImage: "url(" + t.data("srcblur") + ")"});
        calculateBlurredBackgrounds()
      });
    }
    t.waitForImages(function() {
      jQuery(this).find(".fullscreenimgs").addClass("loaded")
    });
    jQuery(".cinematic.overheader .cinematic-basicimage-wrapper").height(jQuery(".cinematic.original").height());
    jQuery(".cinematic.overheader .cinematic-blurryimage-wrapper").height(jQuery(".cinematic.original").height())
  });
  100 < jQuery(window).scrollTop() && TweenLite.to(jQuery(".cinematic .cinematic-blurryimage-wrapper"), .6, {autoAlpha: 1});
}

function initBackgroundSlider() {
  var e;
  is_mobile() && jQuery(".cinematic").css({width: "100.39%"}), jQuery(".cinematic").addClass("original"), is_mobile() ? jQuery("#headerwrapper").css({position: "absolute"}) : (jQuery(".cinematic").clone().appendTo(jQuery("#allcontent")).addClass("overheader"), jQuery(".overheader").removeClass("original"), jQuery("overheader").data("contentholder", ""), jQuery(".overheader").find(".slidercontent").each(function() {
    jQuery(this).remove()
  }));

  jQuery(".cinematic").each(function() {
    var e = jQuery(this);
    e.data("atslide", 0);
    if (e.hasClass("original")) {
      setMainContentMargin();
      jQuery("#maincontent, #footer, #subfooter").css({display: "block"});
    }
    var t = e.find("ul li .slide-background-image").length;
    i = 100 * t;
    n = 100 / t;
    e.find("ul").first().css({
      width: i + "%",
      left: "0px"
    });
    0 < e.find(".slide-background-image").length && TweenLite.set(jQuery(".cinematic.original, .cinematic.overheader"), {
      opacity: 0,
      transformPerspective: 500
    });
    e.find(".slide-background-image").length < 2 && jQuery("#cinematic-navigation").css({display: "none"});
    if (document.readyState === 'complete') {
      drawSliders(e, n);
    } else {
      jQuery(window).on("load", drawSliders(e, n));
    }
    e.hasClass("original") && (showNextSliderContent(e, 1), jQuery("#cinematic-navigation .cinematic-left").on("click", function() {
      horizontalScrollHandler(-1)
    }), jQuery("#cinematic-navigation .cinematic-right").on("click", function() {
      horizontalScrollHandler(1)
    }), document.getElementById("allcontent"), is_mobile())
  });

  jQuery("body").hasClass("withsoftedge") ? jQuery(".cinematic.overheader").height(jQuery("#headerwrapper").outerHeight() + 30) : (jQuery("body svg #m1").remove(), jQuery(".cinematic.overheader").css({"-webkit-mask-image": "none"}), jQuery(".cinematic.overheader").height(jQuery("#headerwrapper").outerHeight())), jQuery(window).on("resize", function() {
    var t = jQuery("body");
    jQuery(".single_blurredbg").each(function() {
      TweenLite.set(jQuery(this), {opacity: 0})
    }), calculateBlurredBackgrounds(), jQuery("body").hasClass("withsoftedge") ? jQuery(".cinematic.overheader").height(jQuery("#headerwrapper").outerHeight() + 30) : jQuery(".cinematic.overheader").height(jQuery("#headerwrapper").outerHeight()), jQuery(window).width() == t.data("lastwidth") && jQuery(window).height() == t.data("lastheight") || (t.data("lastwidth", jQuery(window).width()), t.data("lastheight", jQuery(window).height()), jQuery(".cinematic.overheader .cinematic-basicimage-wrapper").height(jQuery(".cinematic.original").height()), jQuery(".cinematic.overheader .cinematic-blurryimage-wrapper").height(jQuery(".cinematic.original").height()), clearTimeout(e), e = setTimeout(function() {
      jQuery(".single_blurredbg").each(function() {
        TweenLite.to(jQuery(this), .3, {opacity: 1})
      }), setMainContentMargin(), horizontalScrollHandler(0, 0), clearTimeout(jQuery("body").data("timer")), jQuery("body").data("inanimation", 0)
    }, 300))
  }), is_mobile() || (jQuery(window).waypoint(function(e) {
    jQuery(".header-menu-wrapper").hasClass("opened") || ("down" == e ? TweenLite.to(jQuery(".cinematic .cinematic-blurryimage-wrapper"), .6, {autoAlpha: 1}) : TweenLite.to(jQuery(".cinematic .cinematic-blurryimage-wrapper"), .6, {autoAlpha: 0}))
  }, {offset: -100}), isIE(8) || jQuery(window).waypoint(function(e) {
    jQuery(".header-menu-wrapper").hasClass("opened") || ("down" == e && jQuery(".fakebgformobile").length < 1 ? TweenLite.to(jQuery("#cinematic-title-wrapper"), .5, {
      y: -200,
      autoAlpha: 0,
      ease: Power3.easeOut,
      overwrite: "auto"
    }) : TweenLite.to(jQuery("#cinematic-title-wrapper"), .5, {
      y: 0,
      autoAlpha: 1,
      ease: Power3.easeOut,
      overwrite: "auto"
    }))
  }, {
    offset: function() {
      return -jQuery(this).height() / 2
    }
  }));
  var t = document.body;
  if (is_mobile()) if (768 < jQuery(window).width()) try {
    Hammer(t).on("release", function(e) {
      setTimeout(function() {
        jQuery(".header-menu-wrapper").hasClass("opened") || checkMobilePosition()
      }, 100)
    }), Hammer(t).on("dragup", function(e) {
      checkMobilePosition()
    }), Hammer(t).on("dragdown", function(e) {
      checkMobilePosition()
    })
  } catch (t) {
  } else jQuery(".cinematic .cinematic-blurryimage-wrapper").addClass("blurred");
  var i = jQuery(".cinematic-right"), n = jQuery(".cinematic-left"), a = jQuery(".cinematic-down");
  if (is_mobile() || jQuery("body").hasClass("withoutmoduleanimations") || isIE(8)) TweenLite.set(i, {
    autoAlpha: 1,
    scale: 1,
    ease: Power3.easeOut
  }), TweenLite.set(n, {autoAlpha: 1, scale: 1, ease: Power3.easeOut}), TweenLite.set(a, {
    autoAlpha: 1,
    scale: 1,
    ease: Power3.easeOut
  }); else try {
    TweenLite.set(i, {
      transformOrigin: "50% 50%",
      opacity: 0,
      scale: .25,
      x: 5,
      y: 0,
      transformPerspective: 500
    }), TweenLite.set(n, {
      transformOrigin: "50% 50%",
      opacity: 0,
      scale: .45,
      x: -5,
      y: 0,
      transformPerspective: 500
    }), TweenLite.set(a, {
      transformOrigin: "50% 50%",
      opacity: 0,
      scale: .5,
      y: 5,
      transformPerspective: 500
    }), setTimeout(function() {
      TweenLite.to(i, .4, {opacity: 1, scale: 1, z: 0, x: 0, y: 0, rotationY: 0, ease: Back.easeOut})
    }, 2e3), setTimeout(function() {
      TweenLite.to(n, .3, {opacity: 1, scale: 1, z: 0, x: 0, y: 0, rotationY: 0, ease: Back.easeOut})
    }, 2400), setTimeout(function() {
      TweenLite.to(a, .5, {opacity: 1, scale: 1, z: 0, y: 0, rotationY: 0, ease: Back.easeOut})
    }, 2200)
  } catch (t) {
  }
  setTimeout(function() {
    if (jQuery(".cinematic-navbutton").on("mouseover", function() {
      TweenLite.to(jQuery(this), .3, {scale: 1.25, ease: Power3.easeOut})
    }), jQuery(".cinematic-navbutton").on("mouseout", function() {
      TweenLite.to(jQuery(this), .3, {scale: 1, ease: Power3.easeOut})
    }), null != jQuery("body").data("autoslider") /* && !is_mobile() */ && 0 < parseInt(jQuery("body").data("autoslider"), 0)) {
      var e = parseInt(jQuery("body").data("autoslider"), 0);
      jQuery("body").append('<div id="slidertimera" style="position:fixed;bottom:0px;left:0px;width:100%;z-index:10000;height:3px;background:#fff"></div>'), TweenLite.set(jQuery("#slidertimera"), {
        width: "0%",
        opacity: .2
      }), TweenLite.fromTo(jQuery("#slidertimera"), e, {width: "0%"}, {
        width: "100%",
        ease: Linear.easeNone
      });
      var t = setInterval(function() {
        TweenLite.fromTo(jQuery("#slidertimera"), e, {width: "0%"}, {
          width: "100%",
          ease: Linear.easeNone
        }), jQuery(".cinematic-right.cinematic-navbutton").trigger('click')
      }, 1e3 * e);
      null == jQuery("body").data("alwaysscroll") && jQuery(window).on("scroll", function() {
        300 < jQuery(window).scrollTop() && (clearInterval(t), TweenLite.set(jQuery("#slidertimera"), {
          width: "0%",
          overwrite: "all"
        }), jQuery("#slidertimera").remove())
      })
    }
  }, 2e3)
}

function calculateBlurredBackgrounds() {
  jQuery(".single_blurredbg").each(function() {
    var e = jQuery(this), t = jQuery(window).width(), i = 1.15 * jQuery(window).height();
    TweenLite.set(e, {transformPerspective: 300, transformOrigin: "center center"});
    var n = calculateOffsets(e.data("width"), e.data("height")), a = n[0] - e.offset().left,
        r = n[1] - e.offset().top + jQuery(window).scrollTop();
    e.css({width: t, height: i, backgroundPosition: a + "px " + r + "px"})
  })
}

function calculateOffsets(e, t) {
  var i = jQuery(window).width(), n = 1.15 * jQuery(window).height(), a = i / e, r = n / t,
      o = Math.max(a, r), s = new Array;
  return s[0] = Math.ceil(o * e), s[1] = Math.ceil(o * t), s[0] = (i - s[0]) / 2, s[1] = (n - s[1]) / 2, s
}

function checkMobilePosition() {
  var e = jQuery("#cinematic-title-wrapper");
  50 < jQuery(window).scrollTop() && 1 != e.data("gone") && (e.data("gone", 1), jQuery(".cinematic .cinematic-blurryimage-wrapper").addClass("blurred"), jQuery(window).height() < 960 ? jQuery(".cinematic .cinematic-blurryimage-wrapper").addClass("quickanim") : jQuery(".cinematic .cinematic-blurryimage-wrapper").addClass("slowanim")), jQuery(window).scrollTop() < 51 && 1 == e.data("gone") && (e.data("gone", 0), jQuery(".cinematic .cinematic-blurryimage-wrapper").removeClass("blurred"))
}

function showNextSliderContent(e, t) {
  var i = e.data("atslide");
  if (e.hasClass("original")) {
    var n = e.find("ul").first();
    if (0 < e.find("li").length) {
      var a, r = n.find("li:nth(" + i + ") .slidercontent"),
          o = jQuery("body").find(e.data("contentholder"));
      o.find(".newwrap").addClass("removeme-content").removeClass("newwrap"), o.find(".removeme-content").length || o.wrapInner('<div class="removeme-content"></div>'), TweenLite.to(o.find(".removeme-content"), .4, {
        x: -60 * t,
        transformPerspective: 100,
        autoAlpha: 0,
        ease: Power3.easeOut,
        overwrite: "auto"
      }), o.append('<div class="newwrap"></div>'), o.find(".newwrap").css({
        position: "absolute",
        visibility: "hidden"
      }).html(r.html()), a = o.find(".newwrap").height(), setTimeout(function() {
        TweenLite.set(o.find(".newwrap"), {
          display: "block",
          opacity: 1,
          visibility: "visible",
          position: "relative"
        }), a = 0 == (a = o.find(".newwrap").height()) ? 79 : a, TweenLite.to(jQuery("#slidercontent-wrapper"), .25, {
          height: a,
          minHeight: a
        }), TweenLite.fromTo(o.find(".newwrap"), .6, {
          position: "relative",
          x: 60 * t,
          transformPerspective: 100,
          opacity: 0,
          display: "none"
        }, {
          display: "block",
          x: 0,
          opacity: 1,
          ease: Power3.easeOut,
          delay: .25,
          overwrite: "all"
        })
      }, 410), r.html().length && 0 != r.children().length || o.parent().parent().addClass("empty"), setTimeout(function() {
        (r.html().length || 0 != r.children().length) && o.parent().parent().removeClass("empty"), o.find(".removeme-content").remove()
      }, 400)
    }
  }
}

function horizontalScrollHandler(e, t) {
  jQuery(".cinematic").each(function(n) {
    var a = jQuery(this), r = a.find("ul").first();
    if (0 == r.find("li").length) return !1;
    var o = a.data("atslide"), s = a.find("ul li .slide-background-image").length,
        l = r.find("li").first().width(), c = l / 1.5, u = 0;
    if (c < 1e3 && (c = 1e3), 2e3 < c && (c = 2e3), c = 600, 0 == t && (c = 1e3, u = 1), 1 != jQuery("body").data("inanimation")) {
      if (-1 == e) (d = o - 1) < 0 && (d = s - 1, u = 1); else if (1 == e) (d = o + 1) == s && (d = 0, u = 1); else if (0 == e) var d = o;
      a.data("atslide", d);
      var p = jQuery(".slide-background-image").width();
      0 < n && jQuery("body").data("inanimation", 1), 0 == n && showNextSliderContent(a, e);
      var h = jQuery(".cinematic.original ul li:eq(" + d + ") .slide-background-image");
      jQuery(".single_blurredbg").each(function() {
        var e = jQuery(this), t = h.data("width"), i = h.data("height");
        e.data("width", t), e.data("height", i), jQuery("body").hasClass("nobluredcontainers") ? e.css({background: "transparent"}) : e.css({backgroundImage: "url(" + h.data("srcblur") + ")"}), calculateBlurredBackgrounds(), TweenLite.set(e, {opacity: 0}), TweenLite.to(e, .3, {
          opacity: 1,
          delay: .7
        })
      }), TweenLite.to(r, c / 1e3, {left: 0 - p * d, ease: Power3.easeInOut});
      var m = Math.round(Math.abs(r.position().left / jQuery(window).width())),
          f = Math.round(Math.abs((0 - p * d) / jQuery(window).width()));
      a.find(".slide-background-image").each(function(t) {
        var i = 0;
        0 == u ? (1 == e ? d <= t && (i = -.7 * l) : -1 == e ? t <= d && (i = .7 * l) : i = 0, jQuery(this).find(".cinematicmedia_inner_wrapper").each(function() {
          var e = jQuery(this);
          t == m || t == f ? TweenLite.fromTo(e, c / 1e3, {
            visibility: "visible",
            left: i
          }, {left: 0, ease: Power3.easeInOut}) : e.css({visibility: "hidden"})
        })) : jQuery(this).find(".cinematicmedia_inner_wrapper").each(function() {
          jQuery(this).css({visibility: "visible"})
        })
      }), 0 < n && (clearTimeout(jQuery("body").data("timer")), jQuery("body").data("timer", setTimeout(function() {
        jQuery("body").data("inanimation", 0), jQuery(this).find(".cinematicmedia_inner_wrapper").each(function() {
          var e = jQuery(this);
          i == m || i == f ? e.css({visibility: "visible"}) : e.css({visibility: "hidden"})
        })
      }, c - 150)))
    }
  })
}

function is_mobile() {
  var e,
      t = ["android", "webos", "iphone", "ipad", "blackberry", "Android", "webos", "iPod", "iPhone", "iPad", "Blackberry", "BlackBerry"],
      i = !1;
  for (e in t) 1 < navigator.userAgent.split(t[e]).length && (i = !0);
  return i
}

(function() {
  var e, t, i = [].indexOf || function(e) {
    for (var t = 0, i = this.length; t < i; t++) if (t in this && this[t] === e) return t;
    return -1
  }, n = [].slice;
  e = this, t = function(e, t) {
    var a, r, o, s, l, c, u, d, p, h, m, f, y, w, g, v;
    return a = e(t), d = 0 <= i.call(t, "ontouchstart"), s = {
      horizontal: {},
      vertical: {}
    }, u = {}, c = "waypoints-context-id", m = "resize.waypoints", f = "scroll.waypoints", y = l = 1, w = "waypoints-waypoint-ids", g = "waypoint", v = "waypoints", r = function() {
      function i(i) {
        var n = this;
        this.$element = i, this.element = i[0], this.didResize = !1, this.didScroll = !1, this.id = "context" + l++, this.oldScroll = {
          x: i.scrollLeft(),
          y: i.scrollTop()
        }, this.waypoints = {
          horizontal: {},
          vertical: {}
        }, i.data(c, this.id), u[this.id] = this, i.on(f, function() {
          var i;
          if (!n.didScroll && !d) return n.didScroll = !0, i = function() {
            return n.doScroll(), n.didScroll = !1
          }, t.setTimeout(i, e[v].settings.scrollThrottle)
        }), i.on(m, function() {
          var i;
          if (!n.didResize) return n.didResize = !0, i = function() {
            return e[v]("refresh"), n.didResize = !1
          }, t.setTimeout(i, e[v].settings.resizeThrottle)
        })
      }

      return i.prototype.doScroll = function() {
        var t, i = this;
        return t = {
          horizontal: {
            newScroll: this.$element.scrollLeft(),
            oldScroll: this.oldScroll.x,
            forward: "right",
            backward: "left"
          },
          vertical: {
            newScroll: this.$element.scrollTop(),
            oldScroll: this.oldScroll.y,
            forward: "down",
            backward: "up"
          }
        }, !d || t.vertical.oldScroll && t.vertical.newScroll || e[v]("refresh"), e.each(t, function(t, n) {
          var a, r, o;
          return o = [], r = n.newScroll > n.oldScroll, a = r ? n.forward : n.backward, e.each(i.waypoints[t], function(e, t) {
            var i, a;
            return n.oldScroll < (i = t.offset) && i <= n.newScroll ? o.push(t) : n.newScroll < (a = t.offset) && a <= n.oldScroll ? o.push(t) : void 0
          }), o.sort(function(e, t) {
            return e.offset - t.offset
          }), r || o.reverse(), e.each(o, function(e, t) {
            if (t.options.continuous || e === o.length - 1) return t.trigger([a])
          })
        }), this.oldScroll = {x: t.horizontal.newScroll, y: t.vertical.newScroll}
      }, i.prototype.refresh = function() {
        var t, i, n, a = this;
        return n = e.isWindow(this.element), i = this.$element.offset(), this.doScroll(), t = {
          horizontal: {
            contextOffset: n ? 0 : i.left,
            contextScroll: n ? 0 : this.oldScroll.x,
            contextDimension: this.$element.width(),
            oldScroll: this.oldScroll.x,
            forward: "right",
            backward: "left",
            offsetProp: "left"
          },
          vertical: {
            contextOffset: n ? 0 : i.top,
            contextScroll: n ? 0 : this.oldScroll.y,
            contextDimension: n ? e[v]("viewportHeight") : this.$element.height(),
            oldScroll: this.oldScroll.y,
            forward: "down",
            backward: "up",
            offsetProp: "top"
          }
        }, e.each(t, function(t, i) {
          return e.each(a.waypoints[t], function(t, n) {
            var a, r, o, s, l;
            if (a = n.options.offset, o = n.offset, r = e.isWindow(n.element) ? 0 : n.$element.offset()[i.offsetProp], e.isFunction(a) ? a = a.apply(n.element) : "string" == typeof a && (a = parseFloat(a), -1 < n.options.offset.indexOf("%") && (a = Math.ceil(i.contextDimension * a / 100))), n.offset = r - i.contextOffset + i.contextScroll - a, (!n.options.onlyOnScroll || null == o) && n.enabled) return null !== o && o < (s = i.oldScroll) && s <= n.offset ? n.trigger([i.backward]) : null !== o && o > (l = i.oldScroll) && l >= n.offset ? n.trigger([i.forward]) : null === o && i.oldScroll >= n.offset ? n.trigger([i.forward]) : void 0
          })
        })
      }, i.prototype.checkEmpty = function() {
        if (e.isEmptyObject(this.waypoints.horizontal) && e.isEmptyObject(this.waypoints.vertical)) return this.$element.unbind([m, f].join(" ")), delete u[this.id]
      }, i
    }(), o = function() {
      function t(t, i, n) {
        var a, r;
        "bottom-in-view" === (n = e.extend({}, e.fn[g].defaults, n)).offset && (n.offset = function() {
          var t;
          return t = e[v]("viewportHeight"), e.isWindow(i.element) || (t = i.$element.height()), t - e(this).outerHeight()
        }), this.$element = t, this.element = t[0], this.axis = n.horizontal ? "horizontal" : "vertical", this.callback = n.handler, this.context = i, this.enabled = n.enabled, this.id = "waypoints" + y++, this.offset = null, this.options = n, i.waypoints[this.axis][this.id] = this, s[this.axis][this.id] = this, (a = null != (r = t.data(w)) ? r : []).push(this.id), t.data(w, a)
      }

      return t.prototype.trigger = function(e) {
        if (this.enabled) return null != this.callback && this.callback.apply(this.element, e), this.options.triggerOnce ? this.destroy() : void 0
      }, t.prototype.disable = function() {
        return this.enabled = !1
      }, t.prototype.enable = function() {
        return this.context.refresh(), this.enabled = !0
      }, t.prototype.destroy = function() {
        return delete s[this.axis][this.id], delete this.context.waypoints[this.axis][this.id], this.context.checkEmpty()
      }, t.getWaypointsByElement = function(t) {
        var i, n;
        return (n = e(t).data(w)) ? (i = e.extend({}, s.horizontal, s.vertical), e.map(n, function(e) {
          return i[e]
        })) : []
      }, t
    }(), h = {
      init: function(t, i) {
        return null == i && (i = {}), null == i.handler && (i.handler = t), this.each(function() {
          var t, n, a, s;
          return t = e(this), a = null != (s = i.context) ? s : e.fn[g].defaults.context, e.isWindow(a) || (a = t.closest(a)), a = e(a), (n = u[a.data(c)]) || (n = new r(a)), new o(t, n, i)
        }), e[v]("refresh"), this
      }, disable: function() {
        return h._invoke(this, "disable")
      }, enable: function() {
        return h._invoke(this, "enable")
      }, destroy: function() {
        return h._invoke(this, "destroy")
      }, prev: function(e, t) {
        return h._traverse.call(this, e, t, function(e, t, i) {
          if (0 < t) return e.push(i[t - 1])
        })
      }, next: function(e, t) {
        return h._traverse.call(this, e, t, function(e, t, i) {
          if (t < i.length - 1) return e.push(i[t + 1])
        })
      }, _traverse: function(i, n, a) {
        var r, o;
        return null == i && (i = "vertical"), null == n && (n = t), o = p.aggregate(n), r = [], this.each(function() {
          var t;
          return t = e.inArray(this, o[i]), a(r, t, o[i])
        }), this.pushStack(r)
      }, _invoke: function(t, i) {
        return t.each(function() {
          var t;
          return t = o.getWaypointsByElement(this), e.each(t, function(e, t) {
            return t[i](), !0
          })
        }), this
      }
    }, e.fn[g] = function() {
      var t, i;
      return i = arguments[0], t = 2 <= arguments.length ? n.call(arguments, 1) : [], h[i] ? h[i].apply(this, t) : e.isFunction(i) ? h.init.apply(this, arguments) : e.isPlainObject(i) ? h.init.apply(this, [null, i]) : i ? e.error("The " + i + " method does not exist in jQuery Waypoints.") : e.error("jQuery Waypoints needs a callback function or handler option.")
    }, e.fn[g].defaults = {
      context: t,
      continuous: !0,
      enabled: !0,
      horizontal: !1,
      offset: 0,
      triggerOnce: !1
    }, p = {
      refresh: function() {
        return e.each(u, function(e, t) {
          return t.refresh()
        })
      }, viewportHeight: function() {
        var e;
        return null != (e = t.innerHeight) ? e : a.height()
      }, aggregate: function(t) {
        var i, n, a;
        return i = s, t && (i = null != (a = u[e(t).data(c)]) ? a.waypoints : void 0), i ? (n = {
          horizontal: [],
          vertical: []
        }, e.each(n, function(t, a) {
          return e.each(i[t], function(e, t) {
            return a.push(t)
          }), a.sort(function(e, t) {
            return e.offset - t.offset
          }), n[t] = e.map(a, function(e) {
            return e.element
          }), n[t] = e.unique(n[t])
        }), n) : []
      }, above: function(e) {
        return null == e && (e = t), p._filter(e, "vertical", function(e, t) {
          return t.offset <= e.oldScroll.y
        })
      }, below: function(e) {
        return null == e && (e = t), p._filter(e, "vertical", function(e, t) {
          return t.offset > e.oldScroll.y
        })
      }, left: function(e) {
        return null == e && (e = t), p._filter(e, "horizontal", function(e, t) {
          return t.offset <= e.oldScroll.x
        })
      }, right: function(e) {
        return null == e && (e = t), p._filter(e, "horizontal", function(e, t) {
          return t.offset > e.oldScroll.x
        })
      }, enable: function() {
        return p._invoke("enable")
      }, disable: function() {
        return p._invoke("disable")
      }, destroy: function() {
        return p._invoke("destroy")
      }, extendFn: function(e, t) {
        return h[e] = t
      }, _invoke: function(t) {
        var i;
        return i = e.extend({}, s.vertical, s.horizontal), e.each(i, function(e, i) {
          return i[t](), !0
        })
      }, _filter: function(t, i, n) {
        var a, r;
        return (a = u[e(t).data(c)]) ? (r = [], e.each(a.waypoints[i], function(e, t) {
          if (n(a, t)) return r.push(t)
        }), r.sort(function(e, t) {
          return e.offset - t.offset
        }), e.map(r, function(e) {
          return e.element
        })) : []
      }
    }, e[v] = function() {
      var e, t;
      return t = arguments[0], e = 2 <= arguments.length ? n.call(arguments, 1) : [], p[t] ? p[t].apply(null, e) : p.aggregate.call(null, t)
    }, e[v].settings = {resizeThrottle: 100, scrollThrottle: 30}, a.on('load', function() {
      return e[v]("refresh")
    })
  }, "function" == typeof define && define.amd ? define("waypoints", ["jquery"], function(i) {
    return t(i, e)
  }) : t(e.jQuery, e)
}).call(this), "function" != typeof revslider_showDoubleJqueryError && function(e, t) {
  "use strict";
  var i = function(e, t) {
    return new i.Instance(e, t || {})
  };
  i.defaults = {
    stop_browser_behavior: {
      userSelect: "none",
      touchAction: "none",
      touchCallout: "none",
      contentZooming: "none",
      userDrag: "none",
      tapHighlightColor: "rgba(0,0,0,0)"
    }
  }, i.HAS_POINTEREVENTS = navigator.pointerEnabled || navigator.msPointerEnabled, i.HAS_TOUCHEVENTS = "ontouchstart" in e, i.MOBILE_REGEX = /mobile|tablet|ip(ad|hone|od)|android/i, i.NO_MOUSEEVENTS = i.HAS_TOUCHEVENTS && navigator.userAgent.match(i.MOBILE_REGEX), i.EVENT_TYPES = {}, i.DIRECTION_DOWN = "down", i.DIRECTION_LEFT = "left", i.DIRECTION_UP = "up", i.DIRECTION_RIGHT = "right", i.POINTER_MOUSE = "mouse", i.POINTER_TOUCH = "touch", i.POINTER_PEN = "pen", i.EVENT_START = "start", i.EVENT_MOVE = "move", i.EVENT_END = "end", i.DOCUMENT = document, i.plugins = {}, i.READY = !1, i.Instance = function(e, t) {
    var n = this;
    return function() {
      if (!i.READY) {
        for (var e in i.event.determineEventTypes(), i.gestures) i.gestures.hasOwnProperty(e) && i.detection.register(i.gestures[e]);
        i.event.onTouch(i.DOCUMENT, i.EVENT_MOVE, i.detection.detect), i.event.onTouch(i.DOCUMENT, i.EVENT_END, i.detection.detect), i.READY = !0
      }
    }(), this.element = e, this.enabled = !0, this.options = i.utils.extend(i.utils.extend({}, i.defaults), t || {}), this.options.stop_browser_behavior && i.utils.stopDefaultBrowserBehavior(this.element, this.options.stop_browser_behavior), i.event.onTouch(e, i.EVENT_START, function(e) {
      n.enabled && i.detection.startDetect(n, e)
    }), this
  }, i.Instance.prototype = {
    on: function(e, t) {
      for (var i = e.split(" "), n = 0; i.length > n; n++) this.element.addEventListener(i[n], t, !1);
      return this
    }, off: function(e, t) {
      for (var i = e.split(" "), n = 0; i.length > n; n++) this.element.removeEventListener(i[n], t, !1);
      return this
    }, trigger: function(e, t) {
      var n = i.DOCUMENT.createEvent("Event");
      n.initEvent(e, !0, !0), n.gesture = t;
      var a = this.element;
      return i.utils.hasParent(t.target, a) && (a = t.target), a.dispatchEvent(n), this
    }, enable: function(e) {
      return this.enabled = e, this
    }
  };
  var n = null, a = !1, r = !1;
  i.event = {
    bindDom: function(e, t, i) {
      for (var n = t.split(" "), a = 0; n.length > a; a++) e.addEventListener(n[a], i, !1)
    }, onTouch: function(e, t, o) {
      var s = this;
      this.bindDom(e, i.EVENT_TYPES[t], function(l) {
        var c = l.type.toLowerCase();
        if (!c.match(/mouse/) || !r) {
          (c.match(/touch/) || c.match(/pointerdown/) || c.match(/mouse/) && 1 === l.which) && (a = !0), c.match(/touch|pointer/) && (r = !0);
          var u = 0;
          a && (i.HAS_POINTEREVENTS && t != i.EVENT_END ? u = i.PointerEvent.updatePointer(t, l) : c.match(/touch/) ? u = l.touches.length : r || (u = c.match(/up/) ? 0 : 1), 0 < u && t == i.EVENT_END ? t = i.EVENT_MOVE : u || (t = i.EVENT_END), u || null === n ? n = l : l = n, o.call(i.detection, s.collectEventData(e, t, l)), i.HAS_POINTEREVENTS && t == i.EVENT_END && (u = i.PointerEvent.updatePointer(t, l))), u || (n = null, r = a = !1, i.PointerEvent.reset())
        }
      })
    }, determineEventTypes: function() {
      var e;
      e = i.HAS_POINTEREVENTS ? i.PointerEvent.getEvents() : i.NO_MOUSEEVENTS ? ["touchstart", "touchmove", "touchend touchcancel"] : ["touchstart mousedown", "touchmove mousemove", "touchend touchcancel mouseup"], i.EVENT_TYPES[i.EVENT_START] = e[0], i.EVENT_TYPES[i.EVENT_MOVE] = e[1], i.EVENT_TYPES[i.EVENT_END] = e[2]
    }, getTouchList: function(e) {
      return i.HAS_POINTEREVENTS ? i.PointerEvent.getTouchList() : e.touches ? e.touches : [{
        identifier: 1,
        pageX: e.pageX,
        pageY: e.pageY,
        target: e.target
      }]
    }, collectEventData: function(e, t, n) {
      var a = this.getTouchList(n, t), r = i.POINTER_TOUCH;
      return (n.type.match(/mouse/) || i.PointerEvent.matchType(i.POINTER_MOUSE, n)) && (r = i.POINTER_MOUSE), {
        center: i.utils.getCenter(a),
        timeStamp: (new Date).getTime(),
        target: n.target,
        touches: a,
        eventType: t,
        pointerType: r,
        srcEvent: n,
        preventDefault: function() {
          this.srcEvent.preventManipulation && this.srcEvent.preventManipulation(), this.srcEvent.preventDefault && this.srcEvent.preventDefault()
        },
        stopPropagation: function() {
          this.srcEvent.stopPropagation()
        },
        stopDetect: function() {
          return i.detection.stopDetect()
        }
      }
    }
  }, i.PointerEvent = {
    pointers: {}, getTouchList: function() {
      var e = this, t = [];
      return Object.keys(e.pointers).sort().forEach(function(i) {
        t.push(e.pointers[i])
      }), t
    }, updatePointer: function(e, t) {
      return e == i.EVENT_END ? this.pointers = {} : (t.identifier = t.pointerId, this.pointers[t.pointerId] = t), Object.keys(this.pointers).length
    }, matchType: function(e, t) {
      if (!t.pointerType) return !1;
      var n = {};
      return n[i.POINTER_MOUSE] = t.pointerType == t.MSPOINTER_TYPE_MOUSE || t.pointerType == i.POINTER_MOUSE, n[i.POINTER_TOUCH] = t.pointerType == t.MSPOINTER_TYPE_TOUCH || t.pointerType == i.POINTER_TOUCH, n[i.POINTER_PEN] = t.pointerType == t.MSPOINTER_TYPE_PEN || t.pointerType == i.POINTER_PEN, n[e]
    }, getEvents: function() {
      return ["pointerdown MSPointerDown", "pointermove MSPointerMove", "pointerup pointercancel MSPointerUp MSPointerCancel"]
    }, reset: function() {
      this.pointers = {}
    }
  }, i.utils = {
    extend: function(e, i, n) {
      for (var a in i) e[a] !== t && n || (e[a] = i[a]);
      return e
    }, hasParent: function(e, t) {
      for (; e;) {
        if (e == t) return !0;
        e = e.parentNode
      }
      return !1
    }, getCenter: function(e) {
      for (var t = [], i = [], n = 0, a = e.length; n < a; n++) t.push(e[n].pageX), i.push(e[n].pageY);
      return {
        pageX: (Math.min.apply(Math, t) + Math.max.apply(Math, t)) / 2,
        pageY: (Math.min.apply(Math, i) + Math.max.apply(Math, i)) / 2
      }
    }, getVelocity: function(e, t, i) {
      return {x: Math.abs(t / e) || 0, y: Math.abs(i / e) || 0}
    }, getAngle: function(e, t) {
      var i = t.pageY - e.pageY, n = t.pageX - e.pageX;
      return 180 * Math.atan2(i, n) / Math.PI
    }, getDirection: function(e, t) {
      var n = Math.abs(e.pageX - t.pageX);
      return Math.abs(e.pageY - t.pageY) <= n ? 0 < e.pageX - t.pageX ? i.DIRECTION_LEFT : i.DIRECTION_RIGHT : 0 < e.pageY - t.pageY ? i.DIRECTION_UP : i.DIRECTION_DOWN
    }, getDistance: function(e, t) {
      var i = t.pageX - e.pageX, n = t.pageY - e.pageY;
      return Math.sqrt(i * i + n * n)
    }, getScale: function(e, t) {
      return 2 <= e.length && 2 <= t.length ? this.getDistance(t[0], t[1]) / this.getDistance(e[0], e[1]) : 1
    }, getRotation: function(e, t) {
      return 2 <= e.length && 2 <= t.length ? this.getAngle(t[1], t[0]) - this.getAngle(e[1], e[0]) : 0
    }, isVertical: function(e) {
      return e == i.DIRECTION_UP || e == i.DIRECTION_DOWN
    }, stopDefaultBrowserBehavior: function(e, t) {
      var i, n = ["webkit", "khtml", "moz", "ms", "o", ""];
      if (t && e.style) {
        for (var a = 0; a < n.length; a++) for (var r in t) t.hasOwnProperty(r) && (i = r, n[a] && (i = n[a] + i.substring(0, 1).toUpperCase() + i.substring(1)), e.style[i] = t[r]);
        "none" == t.userSelect && (e.onselectstart = function() {
          return !1
        })
      }
    }
  }, i.detection = {
    gestures: [], current: null, previous: null, stopped: !1, startDetect: function(e, t) {
      this.current || (this.stopped = !1, this.current = {
        inst: e,
        startEvent: i.utils.extend({}, t),
        lastEvent: !1,
        name: ""
      }, this.detect(t))
    }, detect: function(e) {
      if (this.current && !this.stopped) {
        e = this.extendEventData(e);
        for (var t = this.current.inst.options, n = 0, a = this.gestures.length; n < a; n++) {
          var r = this.gestures[n];
          if (!this.stopped && !1 !== t[r.name] && !1 === r.handler.call(r, e, this.current.inst)) {
            this.stopDetect();
            break
          }
        }
        return this.current && (this.current.lastEvent = e), e.eventType == i.EVENT_END && !e.touches.length - 1 && this.stopDetect(), e
      }
    }, stopDetect: function() {
      this.previous = i.utils.extend({}, this.current), this.current = null, this.stopped = !0
    }, extendEventData: function(e) {
      var t = this.current.startEvent;
      if (t && (e.touches.length != t.touches.length || e.touches === t.touches)) {
        t.touches = [];
        for (var n = 0, a = e.touches.length; n < a; n++) t.touches.push(i.utils.extend({}, e.touches[n]))
      }
      var r = e.timeStamp - t.timeStamp, o = e.center.pageX - t.center.pageX,
          s = e.center.pageY - t.center.pageY, l = i.utils.getVelocity(r, o, s);
      return i.utils.extend(e, {
        deltaTime: r,
        deltaX: o,
        deltaY: s,
        velocityX: l.x,
        velocityY: l.y,
        distance: i.utils.getDistance(t.center, e.center),
        angle: i.utils.getAngle(t.center, e.center),
        direction: i.utils.getDirection(t.center, e.center),
        scale: i.utils.getScale(t.touches, e.touches),
        rotation: i.utils.getRotation(t.touches, e.touches),
        startEvent: t
      }), e
    }, register: function(e) {
      var n = e.defaults || {};
      return n[e.name] === t && (n[e.name] = !0), i.utils.extend(i.defaults, n, !0), e.index = e.index || 1e3, this.gestures.push(e), this.gestures.sort(function(e, t) {
        return e.index < t.index ? -1 : e.index > t.index ? 1 : 0
      }), this.gestures
    }
  }, i.gestures = i.gestures || {}, i.gestures.Hold = {
    name: "hold",
    index: 10,
    defaults: {hold_timeout: 500, hold_threshold: 1},
    timer: null,
    handler: function(e, t) {
      switch (e.eventType) {
        case i.EVENT_START:
          clearTimeout(this.timer), i.detection.current.name = this.name, this.timer = setTimeout(function() {
            "hold" == i.detection.current.name && t.trigger("hold", e)
          }, t.options.hold_timeout);
          break;
        case i.EVENT_MOVE:
          e.distance > t.options.hold_threshold && clearTimeout(this.timer);
          break;
        case i.EVENT_END:
          clearTimeout(this.timer)
      }
    }
  }, i.gestures.Tap = {
    name: "tap",
    index: 100,
    defaults: {
      tap_max_touchtime: 250,
      tap_max_distance: 10,
      tap_always: !0,
      doubletap_distance: 20,
      doubletap_interval: 300
    },
    handler: function(e, t) {
      if (e.eventType == i.EVENT_END) {
        var n = i.detection.previous, a = !1;
        if (e.deltaTime > t.options.tap_max_touchtime || e.distance > t.options.tap_max_distance) return;
        n && "tap" == n.name && e.timeStamp - n.lastEvent.timeStamp < t.options.doubletap_interval && e.distance < t.options.doubletap_distance && (t.trigger("doubletap", e), a = !0), (!a || t.options.tap_always) && (i.detection.current.name = "tap", t.trigger(i.detection.current.name, e))
      }
    }
  }, i.gestures.Swipe = {
    name: "swipe",
    index: 40,
    defaults: {swipe_max_touches: 1, swipe_velocity: .7},
    handler: function(e, t) {
      if (e.eventType == i.EVENT_END) {
        if (0 < t.options.swipe_max_touches && e.touches.length > t.options.swipe_max_touches) return;
        (e.velocityX > t.options.swipe_velocity || e.velocityY > t.options.swipe_velocity) && (t.trigger(this.name, e), t.trigger(this.name + e.direction, e))
      }
    }
  }, i.gestures.Drag = {
    name: "drag",
    index: 50,
    defaults: {
      drag_min_distance: 10,
      drag_max_touches: 1,
      drag_block_horizontal: !1,
      drag_block_vertical: !1,
      drag_lock_to_axis: !1,
      drag_lock_min_distance: 25
    },
    triggered: !1,
    handler: function(e, n) {
      if (i.detection.current.name != this.name && this.triggered) return n.trigger(this.name + "end", e), this.triggered = !1, t;
      if (!(0 < n.options.drag_max_touches && e.touches.length > n.options.drag_max_touches)) switch (e.eventType) {
        case i.EVENT_START:
          this.triggered = !1;
          break;
        case i.EVENT_MOVE:
          if (e.distance < n.options.drag_min_distance && i.detection.current.name != this.name) return;
          i.detection.current.name = this.name, (i.detection.current.lastEvent.drag_locked_to_axis || n.options.drag_lock_to_axis && n.options.drag_lock_min_distance <= e.distance) && (e.drag_locked_to_axis = !0);
          var a = i.detection.current.lastEvent.direction;
          e.drag_locked_to_axis && a !== e.direction && (e.direction = i.utils.isVertical(a) ? e.deltaY < 0 ? i.DIRECTION_UP : i.DIRECTION_DOWN : e.deltaX < 0 ? i.DIRECTION_LEFT : i.DIRECTION_RIGHT), this.triggered || (n.trigger(this.name + "start", e), this.triggered = !0), n.trigger(this.name, e), n.trigger(this.name + e.direction, e), (n.options.drag_block_vertical && i.utils.isVertical(e.direction) || n.options.drag_block_horizontal && !i.utils.isVertical(e.direction)) && e.preventDefault();
          break;
        case i.EVENT_END:
          this.triggered && n.trigger(this.name + "end", e), this.triggered = !1
      }
    }
  }, i.gestures.Transform = {
    name: "transform",
    index: 45,
    defaults: {transform_min_scale: .01, transform_min_rotation: 1, transform_always_block: !1},
    triggered: !1,
    handler: function(e, n) {
      if (i.detection.current.name != this.name && this.triggered) return n.trigger(this.name + "end", e), this.triggered = !1, t;
      if (!(e.touches.length < 2)) switch (n.options.transform_always_block && e.preventDefault(), e.eventType) {
        case i.EVENT_START:
          this.triggered = !1;
          break;
        case i.EVENT_MOVE:
          var a = Math.abs(1 - e.scale), r = Math.abs(e.rotation);
          if (n.options.transform_min_scale > a && n.options.transform_min_rotation > r) return;
          i.detection.current.name = this.name, this.triggered || (n.trigger(this.name + "start", e), this.triggered = !0), n.trigger(this.name, e), r > n.options.transform_min_rotation && n.trigger("rotate", e), a > n.options.transform_min_scale && (n.trigger("pinch", e), n.trigger("pinch" + (e.scale < 1 ? "in" : "out"), e));
          break;
        case i.EVENT_END:
          this.triggered && n.trigger(this.name + "end", e), this.triggered = !1
      }
    }
  }, i.gestures.Touch = {
    name: "touch",
    index: -1 / 0,
    defaults: {prevent_default: !1, prevent_mouseevents: !1},
    handler: function(e, n) {
      return n.options.prevent_mouseevents && e.pointerType == i.POINTER_MOUSE ? e.stopDetect() : (n.options.prevent_default && e.preventDefault(), e.eventType == i.EVENT_START && n.trigger(this.name, e)), t
    }
  }, i.gestures.Release = {
    name: "release", index: 1 / 0, handler: function(e, t) {
      e.eventType == i.EVENT_END && t.trigger(this.name, e)
    }
  }, "object" == typeof module && "object" == typeof module.exports ? module.exports = i : (e.Hammer = i, "function" == typeof e.define && e.define.amd && e.define("hammer", [], function() {
    return i
  }))
}(this), function(e, t, i) {
  e.fn.jScrollPane = function(n) {
    return n = e.extend({}, e.fn.jScrollPane.defaults, n), e.each(["arrowButtonSpeed", "trackClickSpeed", "keyboardSpeed"], function() {
      n[this] = n[this] || n.speed
    }), this.each(function() {
      var a = e(this), r = a.data("jsp");
      r ? r.reinitialise(n) : (e("script", a).filter('[type="text/javascript"],:not([type])').remove(), r = new function(n, a) {
        var r, o, s, l, c, u, d, p, h, m, f, y, w, g, v, b, j, Q, T, x, _, k, E, P, C, O, L, S, M,
            I, N, z, D, H, A = this, B = !0, R = !0, Y = !1, V = !1, X = n.clone(!1, !1).empty(),
            W = e.fn.mwheelIntent ? "mwheelIntent.jsp" : "mousewheel.jsp";

        function F(a) {
          var x, B, R, Y, V, X, ce, ue, de, pe, he, me, fe, ye, we = !1, ge = !1;
          if (r = a, o === i) V = n.scrollTop(), X = n.scrollLeft(), n.css({
            overflow: "hidden",
            padding: 0
          }), s = n.innerWidth() + D, l = n.innerHeight(), n.width(s), o = e('<div class="jspPane" />').css("padding", z).append(n.children()), c = e('<div class="jspContainer" />').css({
            width: s + "px",
            height: l + "px"
          }).append(o).appendTo(n); else {
            if (n.css("width", ""), we = r.stickToBottom && 20 < (ue = d - l) && ue - se() < 10, ge = r.stickToRight && 20 < (ce = u - s) && ce - oe() < 10, (Y = n.innerWidth() + D != s || n.outerHeight() != l) && (s = n.innerWidth() + D, l = n.innerHeight(), c.css({
              width: s + "px",
              height: l + "px"
            })), !Y && H == u && o.outerHeight() == d) return void n.width(s);
            H = u, o.css("width", ""), n.width(s), c.find(">.jspVerticalBar,>.jspHorizontalBar").remove().end()
          }
          o.css("overflow", "auto"), u = a.contentWidth ? a.contentWidth : o[0].scrollWidth, d = o[0].scrollHeight, o.css("overflow", ""), m = 1 < (h = d / l), (f = 1 < (p = u / s)) || m ? (n.addClass("jspScrollable"), (x = r.maintainPosition && (g || j)) && (B = oe(), R = se()), m && (c.append(e('<div class="jspVerticalBar" />').append(e('<div class="jspCap jspCapTop" />'), e('<div class="jspTrack" />').append(e('<div class="jspDrag" />').append(e('<div class="jspDragTop" />'), e('<div class="jspDragBottom" />'))), e('<div class="jspCap jspCapBottom" />'))), Q = c.find(">.jspVerticalBar"), T = Q.find(">.jspTrack"), y = T.find(">.jspDrag"), r.showArrows && (E = e('<a class="jspArrow jspArrowUp" />').on("mousedown.jsp", G(0, -1)).on("click.jsp", le), P = e('<a class="jspArrow jspArrowDown" />').on("mousedown.jsp", G(0, 1)).on("click.jsp", le), r.arrowScrollOnHover && (E.on("mouseover.jsp", G(0, -1, E)), P.on("mouseover.jsp", G(0, 1, P))), $(T, r.verticalArrowPositions, E, P)), _ = l, c.find(">.jspVerticalBar>.jspCap:visible,>.jspVerticalBar>.jspArrow").each(function() {
            _ -= e(this).outerHeight()
          }), y.on('hover', function() {
            y.addClass("jspHover")
          }, function() {
            y.removeClass("jspHover")
          }).on("mousedown.jsp", function(t) {
            e("html").on("dragstart.jsp selectstart.jsp", le), y.addClass("jspActive");
            var i = t.pageY - y.position().top;
            return e("html").on("mousemove.jsp", function(e) {
              J(e.pageY - i, !1)
            }).on("mouseup.jsp mouseleave.jsp", Z), !1
          }), U()), f && (c.append(e('<div class="jspHorizontalBar" />').append(e('<div class="jspCap jspCapLeft" />'), e('<div class="jspTrack" />').append(e('<div class="jspDrag" />').append(e('<div class="jspDragLeft" />'), e('<div class="jspDragRight" />'))), e('<div class="jspCap jspCapRight" />'))), C = c.find(">.jspHorizontalBar"), O = C.find(">.jspTrack"), v = O.find(">.jspDrag"), r.showArrows && (M = e('<a class="jspArrow jspArrowLeft" />').on("mousedown.jsp", G(-1, 0)).on("click.jsp", le), I = e('<a class="jspArrow jspArrowRight" />').on("mousedown.jsp", G(1, 0)).on("click.jsp", le), r.arrowScrollOnHover && (M.on("mouseover.jsp", G(-1, 0, M)), I.on("mouseover.jsp", G(1, 0, I))), $(O, r.horizontalArrowPositions, M, I)), v.on('hover', function() {
            v.addClass("jspHover")
          }, function() {
            v.removeClass("jspHover")
          }).on("mousedown.jsp", function(t) {
            e("html").on("dragstart.jsp selectstart.jsp", le), v.addClass("jspActive");
            var i = t.pageX - v.position().left;
            return e("html").on("mousemove.jsp", function(e) {
              te(e.pageX - i, !1)
            }).on("mouseup.jsp mouseleave.jsp", Z), !1
          }), L = c.innerWidth(), q()), function() {
            if (f && m) {
              var t = O.outerHeight(), i = T.outerWidth();
              _ -= t, e(C).find(">.jspCap:visible,>.jspArrow").each(function() {
                L += e(this).outerWidth()
              }), L -= i, l -= i, s -= t, O.parent().append(e('<div class="jspCorner" />').css("width", t + "px")), U(), q()
            }
            f && o.width(c.outerWidth() - D + "px"), d = o.outerHeight(), h = d / l, f && ((S = Math.ceil(1 / p * L)) > r.horizontalDragMaxWidth ? S = r.horizontalDragMaxWidth : S < r.horizontalDragMinWidth && (S = r.horizontalDragMinWidth), v.width(S + "px"), b = L - S, ie(j)), m && ((k = Math.ceil(1 / h * _)) > r.verticalDragMaxHeight ? k = r.verticalDragMaxHeight : k < r.verticalDragMinHeight && (k = r.verticalDragMinHeight), y.height(k + "px"), w = _ - k, ee(g))
          }(), x && (ae(ge ? u - s : B, !1), ne(we ? d - l : R, !1)), o.find(":input,a").unbind("focus.jsp").on("focus.jsp", function(e) {
            re(e.target, !1)
          }), c.unbind(W).on(W, function(e, t, i, n) {
            var a = j, o = g;
            return A.scrollBy(i * r.mouseWheelSpeed, -n * r.mouseWheelSpeed, !1), a == j && o == g
          }), ye = !1, c.unbind("touchstart.jsp touchmove.jsp touchend.jsp click.jsp-touchclick").on("touchstart.jsp", function(e) {
            var t = e.originalEvent.touches[0];
            de = oe(), pe = se(), he = t.pageX, me = t.pageY, ye = !(fe = !1)
          }).on("touchmove.jsp", function(e) {
            if (ye) {
              var t = e.originalEvent.touches[0], i = j, n = g;
              return A.scrollTo(de + he - t.pageX, pe + me - t.pageY), fe = fe || 5 < Math.abs(he - t.pageX) || 5 < Math.abs(me - t.pageY), i == j && n == g
            }
          }).on("touchend.jsp", function(e) {
            ye = !1
          }).on("click.jsp-touchclick", function(e) {
            if (fe) return fe = !1
          }), r.enableKeyboardNavigation && function() {
            var t, i, a = [];

            function s() {
              var e = j, n = g;
              switch (t) {
                case 40:
                  A.scrollByY(r.keyboardSpeed, !1);
                  break;
                case 38:
                  A.scrollByY(-r.keyboardSpeed, !1);
                  break;
                case 34:
                case 32:
                  A.scrollByY(l * r.scrollPagePercent, !1);
                  break;
                case 33:
                  A.scrollByY(-l * r.scrollPagePercent, !1);
                  break;
                case 39:
                  A.scrollByX(r.keyboardSpeed, !1);
                  break;
                case 37:
                  A.scrollByX(-r.keyboardSpeed, !1)
              }
              return i = e != j || n != g
            }

            f && a.push(C[0]), m && a.push(Q[0]), o.on('focus', function() {
              n.focus()
            }), n.attr("tabindex", 0).unbind("keydown.jsp keypress.jsp").on("keydown.jsp", function(n) {
              if (n.target === this || a.length && e(n.target).closest(a).length) {
                var r = j, o = g;
                switch (n.keyCode) {
                  case 40:
                  case 38:
                  case 34:
                  case 32:
                  case 33:
                  case 39:
                  case 37:
                    t = n.keyCode, s();
                    break;
                  case 35:
                    ne(d - l), t = null;
                    break;
                  case 36:
                    ne(0), t = null
                }
                return !(i = n.keyCode == t && r != j || o != g)
              }
            }).on("keypress.jsp", function(e) {
              return e.keyCode == t && s(), !i
            }), r.hideFocus ? (n.css("outline", "none"), "hideFocus" in c[0] && n.attr("hideFocus", !0)) : (n.css("outline", ""), "hideFocus" in c[0] && n.attr("hideFocus", !1))
          }(), r.clickOnTrack && (K(), m && T.on("mousedown.jsp", function(t) {
            if (t.originalTarget === i || t.originalTarget == t.currentTarget) {
              var n, a = e(this), o = a.offset(), s = t.pageY - o.top - g, c = !0,
                  u = function() {
                    var e = a.offset(), i = t.pageY - e.top - k / 2,
                        o = l * r.scrollPagePercent, h = w * o / (d - l);
                    if (s < 0) i < g - h ? A.scrollByY(-o) : J(i); else {
                      if (!(0 < s)) return void p();
                      g + h < i ? A.scrollByY(o) : J(i)
                    }
                    n = setTimeout(u, c ? r.initialDelay : r.trackClickRepeatFreq), c = !1
                  }, p = function() {
                    n && clearTimeout(n), n = null, e(document).unbind("mouseup.jsp", p)
                  };
              return u(), e(document).on("mouseup.jsp", p), !1
            }
          }), f && O.on("mousedown.jsp", function(t) {
            if (t.originalTarget === i || t.originalTarget == t.currentTarget) {
              var n, a = e(this), o = a.offset(), l = t.pageX - o.left - j, c = !0,
                  d = function() {
                    var e = a.offset(), i = t.pageX - e.left - S / 2,
                        o = s * r.scrollPagePercent, h = b * o / (u - s);
                    if (l < 0) i < j - h ? A.scrollByX(-o) : te(i); else {
                      if (!(0 < l)) return void p();
                      j + h < i ? A.scrollByX(o) : te(i)
                    }
                    n = setTimeout(d, c ? r.initialDelay : r.trackClickRepeatFreq), c = !1
                  }, p = function() {
                    n && clearTimeout(n), n = null, e(document).unbind("mouseup.jsp", p)
                  };
              return d(), e(document).on("mouseup.jsp", p), !1
            }
          })), function() {
            if (location.hash && 1 < location.hash.length) {
              var t, i, n = escape(location.hash.substr(1));
              try {
                t = e("#" + n + ', a[name="' + n + '"]')
              } catch (t) {
                return
              }
              t.length && o.find(n) && (0 === c.scrollTop() ? i = setInterval(function() {
                0 < c.scrollTop() && (re(t, !0), e(document).scrollTop(c.position().top), clearInterval(i))
              }, 50) : (re(t, !0), e(document).scrollTop(c.position().top)))
            }
          }(), r.hijackInternalLinks && (e(document.body).data("jspHijack") || (e(document.body).data("jspHijack", !0), e(document.body).delegate("a[href*=#]", "click", function(i) {
            var n, a, r, o, s, l = this.href.substr(0, this.href.indexOf("#")),
                c = location.href;
            if (-1 !== location.href.indexOf("#") && (c = location.href.substr(0, location.href.indexOf("#"))), l === c) {
              n = escape(this.href.substr(this.href.indexOf("#") + 1));
              try {
                a = e("#" + n + ', a[name="' + n + '"]')
              } catch (i) {
                return
              }
              a.length && ((r = a.closest(".jspScrollable")).data("jsp").scrollToElement(a, !0), r[0].scrollIntoView && (o = e(t).scrollTop(), ((s = a.offset().top) < o || s > o + e(t).height()) && r[0].scrollIntoView()), i.preventDefault())
            }
          })))) : (n.removeClass("jspScrollable"), o.css({
            top: 0,
            width: c.width() - D
          }), c.unbind(W), o.find(":input,a").unbind("focus.jsp"), n.attr("tabindex", "-1").removeAttr("tabindex").unbind("keydown.jsp keypress.jsp"), K()), r.autoReinitialise && !N ? N = setInterval(function() {
            F(r)
          }, r.autoReinitialiseDelay) : !r.autoReinitialise && N && clearInterval(N), V && n.scrollTop(0) && ne(V, !1), X && n.scrollLeft(0) && ae(X, !1), n.trigger("jsp-initialised", [f || m])
        }

        function U() {
          T.height(_ + "px"), g = 0, x = r.verticalGutter + T.outerWidth(), o.width(s - x - D);
          try {
            0 === Q.position().left && o.css("margin-left", x + "px")
          } catch (e) {
          }
        }

        function q() {
          c.find(">.jspHorizontalBar>.jspCap:visible,>.jspHorizontalBar>.jspArrow").each(function() {
            L -= e(this).outerWidth()
          }), O.width(L + "px"), j = 0
        }

        function $(e, t, i, n) {
          var a, r = "before", o = "after";
          "os" == t && (t = /Mac/.test(navigator.platform) ? "after" : "split"), t == r ? o = t : t == o && (r = t, a = i, i = n, n = a), e[r](i)[o](n)
        }

        function G(t, i, n) {
          return function() {
            return function(t, i, n, a) {
              n = e(n).addClass("jspActive");
              var o, s, l = !0, c = function() {
                0 !== t && A.scrollByX(t * r.arrowButtonSpeed), 0 !== i && A.scrollByY(i * r.arrowButtonSpeed), s = setTimeout(c, l ? r.initialDelay : r.arrowRepeatFreq), l = !1
              };
              c(), o = a ? "mouseout.jsp" : "mouseup.jsp", (a = a || e("html")).on(o, function() {
                n.removeClass("jspActive"), s && clearTimeout(s), s = null, a.unbind(o)
              })
            }(t, i, this, n), this.trigger('blur'), !1
          }
        }

        function K() {
          O && O.unbind("mousedown.jsp"), T && T.unbind("mousedown.jsp")
        }

        function Z() {
          e("html").unbind("dragstart.jsp selectstart.jsp mousemove.jsp mouseup.jsp mouseleave.jsp"), y && y.removeClass("jspActive"), v && v.removeClass("jspActive")
        }

        function J(e, t) {
          m && (e < 0 ? e = 0 : w < e && (e = w), t === i && (t = r.animateScroll), t ? A.animate(y, "top", e, ee) : (y.css("top", e), ee(e)))
        }

        function ee(e) {
          e === i && (e = y.position().top), c.scrollTop(0);
          var t, a, s = 0 === (g = e), u = g == w, p = -e / w * (d - l);
          B == s && Y == u || (B = s, Y = u, n.trigger("jsp-arrow-change", [B, Y, R, V])), t = s, a = u, r.showArrows && (E[t ? "addClass" : "removeClass"]("jspDisabled"), P[a ? "addClass" : "removeClass"]("jspDisabled")), o.css("top", p), n.trigger("jsp-scroll-y", [-p, s, u]).trigger("scroll")
        }

        function te(e, t) {
          f && (e < 0 ? e = 0 : b < e && (e = b), t === i && (t = r.animateScroll), t ? A.animate(v, "left", e, ie) : (v.css("left", e), ie(e)))
        }

        function ie(e) {
          e === i && (e = v.position().left), c.scrollTop(0);
          var t, a, l = 0 === (j = e), d = j == b, p = -e / b * (u - s);
          R == l && V == d || (R = l, V = d, n.trigger("jsp-arrow-change", [B, Y, R, V])), t = l, a = d, r.showArrows && (M[t ? "addClass" : "removeClass"]("jspDisabled"), I[a ? "addClass" : "removeClass"]("jspDisabled")), o.css("left", p), n.trigger("jsp-scroll-x", [-p, l, d]).trigger("scroll")
        }

        function ne(e, t) {
          J(e / (d - l) * w, t)
        }

        function ae(e, t) {
          te(e / (u - s) * b, t)
        }

        function re(t, i, n) {
          var a, o, u, d, p, h, m, f, y, w = 0, g = 0;
          try {
            a = e(t)
          } catch (t) {
            return
          }
          for (o = a.outerHeight(), u = a.outerWidth(), c.scrollTop(0), c.scrollLeft(0); !a.is(".jspPane");) if (w += a.position().top, g += a.position().left, a = a.offsetParent(), /^body|html$/i.test(a[0].nodeName)) return;
          h = (d = se()) + l, w < d || i ? f = w - r.verticalGutter : h < w + o && (f = w - l + o + r.verticalGutter), f && ne(f, n), m = (p = oe()) + s, g < p || i ? y = g - r.horizontalGutter : m < g + u && (y = g - s + u + r.horizontalGutter), y && ae(y, n)
        }

        function oe() {
          return -o.position().left
        }

        function se() {
          return -o.position().top
        }

        function le() {
          return !1
        }

        z = n.css("paddingTop") + " " + n.css("paddingRight") + " " + n.css("paddingBottom") + " " + n.css("paddingLeft"), D = (parseInt(n.css("paddingLeft"), 10) || 0) + (parseInt(n.css("paddingRight"), 10) || 0), e.extend(A, {
          reinitialise: function(t) {
            F(t = e.extend({}, r, t))
          }, scrollToElement: function(e, t, i) {
            re(e, t, i)
          }, scrollTo: function(e, t, i) {
            ae(e, i), ne(t, i)
          }, scrollToX: function(e, t) {
            ae(e, t)
          }, scrollToY: function(e, t) {
            ne(e, t)
          }, scrollToPercentX: function(e, t) {
            ae(e * (u - s), t)
          }, scrollToPercentY: function(e, t) {
            ne(e * (d - l), t)
          }, scrollBy: function(e, t, i) {
            A.scrollByX(e, i), A.scrollByY(t, i)
          }, scrollByX: function(e, t) {
            te((oe() + Math[e < 0 ? "floor" : "ceil"](e)) / (u - s) * b, t)
          }, scrollByY: function(e, t) {
            J((se() + Math[e < 0 ? "floor" : "ceil"](e)) / (d - l) * w, t)
          }, positionDragX: function(e, t) {
            te(e, t)
          }, positionDragY: function(e, t) {
            J(e, t)
          }, animate: function(e, t, i, n) {
            var a = {};
            a[t] = i, e.animate(a, {
              duration: r.animateDuration,
              easing: r.animateEase,
              queue: !1,
              step: n
            })
          }, getContentPositionX: function() {
            return oe()
          }, getContentPositionY: function() {
            return se()
          }, getContentWidth: function() {
            return u
          }, getContentHeight: function() {
            return d
          }, getPercentScrolledX: function() {
            return oe() / (u - s)
          }, getPercentScrolledY: function() {
            return se() / (d - l)
          }, getIsScrollableH: function() {
            return f
          }, getIsScrollableV: function() {
            return m
          }, getContentPane: function() {
            return o
          }, scrollToBottom: function(e) {
            J(w, e)
          }, hijackInternalLinks: e.noop, destroy: function() {
            var e, t;
            e = se(), t = oe(), n.removeClass("jspScrollable").unbind(".jsp"), n.replaceWith(X.append(o.children())), X.scrollTop(e), X.scrollLeft(t), N && clearInterval(N)
          }
        }), F(a)
      }(a, n), a.data("jsp", r))
    })
  }, e.fn.jScrollPane.defaults = {
    showArrows: !1,
    maintainPosition: !0,
    stickToBottom: !1,
    stickToRight: !1,
    clickOnTrack: !0,
    autoReinitialise: !1,
    autoReinitialiseDelay: 500,
    verticalDragMinHeight: 0,
    verticalDragMaxHeight: 99999,
    horizontalDragMinWidth: 0,
    horizontalDragMaxWidth: 99999,
    contentWidth: i,
    animateScroll: !1,
    animateDuration: 300,
    animateEase: "linear",
    hijackInternalLinks: !1,
    verticalGutter: 4,
    horizontalGutter: 4,
    mouseWheelSpeed: 3,
    arrowButtonSpeed: 0,
    arrowRepeatFreq: 50,
    arrowScrollOnHover: !1,
    trackClickSpeed: 0,
    trackClickRepeatFreq: 70,
    verticalArrowPositions: "split",
    horizontalArrowPositions: "split",
    enableKeyboardNavigation: !0,
    hideFocus: !1,
    keyboardSpeed: 0,
    initialDelay: 300,
    speed: 30,
    scrollPagePercent: .8
  }
}(jQuery, this), jQuery(document).ready(function() {
  (/MSIE 10/i.test(navigator.userAgent) || /MSIE 9/i.test(navigator.userAgent) || /rv:11.0/i.test(navigator.userAgent) || /Edge\/\d./i.test(navigator.userAgent)) && jQuery(".orchestration-table .checkmark-descr").attr("style", "top:68%!important"), is_mobile() && (jQuery(".page-id-10039 #maincontent").css("margin-top", "-15px"), jQuery(".page-id-10203 #maincontent").css("margin-top", "-15px"), jQuery(".page-id-10274 #maincontent").css("margin-top", "-15px"), jQuery(".page-id-9816 #maincontent").css("margin-top", "-15px"), jQuery(".page-id-9575 #maincontent").css("margin-top", "-15px"), jQuery(".page-id-9523 #maincontent").css("margin-top", "-15px"), jQuery(".page-id-9493 #maincontent").css("margin-top", "-15px"), jQuery(".page-id-9544 #maincontent").css("margin-top", "-15px"), jQuery(".page-id-9598 #maincontent").css("margin-top", "-15px")), jQuery(".wpcf7-list-item-label").on("click", function() {
    jQuery(this).prev('input[type="checkbox"]').trigger("click")
  }), is_mobile() && jQuery("li#menu-item-6947 ul.sub-menu,li#menu-item-7695 ul.sub-menu").css({"margin-left": "0"}), 0 == is_mobile() && screen.availWidth < 1380 ? (jQuery("#menu-item-11932 a").append('<img class="ubermenu-image ubermenu-image-size-full" src="https://web.archive.org/web/20190202220907/https://www.altoroslabs.com/wp-content/uploads/2014/06/AltorosLogo_42х42.png" width="22" height="22" alt="AltorosLogo_mini1">'), jQuery("#menu-item-7312 a").append('<img class="ubermenu-image ubermenu-image-size-full" src="https://web.archive.org/web/20190202220907/https://www.altoroslabs.com/wp-content/uploads/2014/06/AltorosLogo_42х42.png" width="22" height="22" alt="AltorosLogo_mini1">'), jQuery("#menu-item-8747 a").append('<img class="ubermenu-image ubermenu-image-size-full" src="https://web.archive.org/web/20190202220907/https://www.altoroslabs.com/wp-content/uploads/2014/06/AltorosLogo_42х42.png" width="22" height="22" alt="AltorosLogo_mini1">')) : (jQuery("#menu-item-11932 a").append('<img class="ubermenu-image ubermenu-image-size-full" src="https://web.archive.org/web/20190202220907/https://www.altoros.com/wp-content/uploads/2015/06/AltorosLogo_mini1.png" width="140" height="22" alt="AltorosLogo_mini1">'), jQuery("#menu-item-7312 a").append('<img class="ubermenu-image ubermenu-image-size-full" src="https://web.archive.org/web/20190202220907/https://www.altoros.com/wp-content/uploads/2015/06/AltorosLogo_mini1.png" width="140" height="22" alt="AltorosLogo_mini1">'), jQuery("#menu-item-8747 a").append('<img class="ubermenu-image ubermenu-image-size-full" src="https://web.archive.org/web/20190202220907/https://www.altoros.com/wp-content/uploads/2015/06/AltorosLogo_mini1.png" width="140" height="22" alt="AltorosLogo_mini1">')), jQuery("menu > div").first().attr("id", "navigation"), jQuery("#navigation li a").each(function() {
    var e = jQuery(this);
    0 == e.find(".menubutton").length && e.html('<div class="menubutton">' + e.html() + "</div>")
  }), jQuery("body").hasClass("menuontop") && jQuery("#navigation").css({visibility: "visible"}), jQuery("#menu-footerlogo").length && (jQuery("#navigation").html(jQuery("#navigation").html() + jQuery("#menu-footerlogo").html()), jQuery("#menu-footerlogo").remove()), jQuery.support.transition || (jQuery.fn.transition = jQuery.fn.animate)

  if (0 < jQuery(".cinematic").length) {
    setMainContentMargin();
    initBackgroundSlider()
  } else {
    jQuery("#maincontent").css({display: "block"});
    jQuery("#footer").css({display: "block"});
    jQuery("#subfooter").css({display: "block"});
    jQuery("body").addClass("withoutgradientheader")
  }

  initMenuFunctions(), initMediaWall(), initShowbizSimple(), initAccordions(), jQuery(window).on('scroll', function() {
    jQuery("body").data("topos", jQuery(window).scrollTop())
  }), initInputFields(), initBlogOverview(), jQuery(".fitvideo").fitVids(), jQuery(window).scrollTop() < jQuery(window).height() && (is_mobile() || jQuery("body").hasClass("withoutmoduleanimations") || isIE(8) || initModuleAnims()), TweenLite.to(jQuery("#maincontent"), .3, {
    autoAlpha: 1,
    delay: .5
  }), jQuery(".portfolio-mediacontainer,#showbiz-teaser-2").each(function() {
    var e = jQuery(this), t = e.data("autoplay"), i = e.data("autoplaydelay");
    null == t && (t = "disabled"), null == i && (i = 5e3), e.punchBox({
      items: ".punchbox",
      navigation: {container: "insidemedia", position: "dettached", autoplay: t, autoplaydelay: i},
      metaInfo: {
        showMeta: !0,
        orderMarkup: "%n / %m",
        metaMarkup: '<div class="pb-metawrapper"><div class="pb-title">%title%</div><div class="pb-metadata">%metadata%</div><div class="pb-order">%ordermarkup%</div></div>'
      },
      callbacks: {
        ready: function(e, t) {
        }, beforeAnim: function(e, t) {
        }, afterAnim: function(e, t) {
        }
      }
    })
  }), jQuery("body").punchBox({
    items: ".singlepunchbox",
    navigation: {
      container: "insidemedia",
      position: "dettached",
      autoplay: "disabled",
      autoplaydelay: 0
    },
    metaInfo: {
      showMeta: !0,
      orderMarkup: "%n / %m",
      metaMarkup: '<div class="pb-metawrapper"><div class="pb-title">%title%</div><div class="pb-metadata">%metadata%</div><div class="pb-order">%ordermarkup%</div></div>'
    },
    callbacks: {
      ready: function(e, t) {
      }, beforeAnim: function(e, t) {
      }, afterAnim: function(e, t) {
      }
    }
  }), jQuery(".fbuilder_content_wrapper").each(function() {
    var e = jQuery(this).find("p").last();
    0 == e.text().length && e.remove()
  }), mapgyver(), jQuery('input[name="email"]').attr("maxlength", 254)
}), function(e) {
  "use strict";
  e.fn.fitVids = function(t) {
    var i = {customSelector: null};
    if (!document.getElementById("fit-vids-style")) {
      var n = document.createElement("div"),
          a = document.getElementsByTagName("base")[0] || document.getElementsByTagName("script")[0];
      n.className = "fit-vids-style", n.id = "fit-vids-style", n.style.display = "none", n.innerHTML = "&shy;<style>                 .fluid-width-video-wrapper {                   width: 100%;                                position: relative;                         padding: 0;                              }                                                                                       .fluid-width-video-wrapper iframe,          .fluid-width-video-wrapper object,          .fluid-width-video-wrapper embed {             position: absolute;                         top: 0;                                     left: 0;                                    width: 100%;                                height: 100%;                            }                                         </style>", a.parentNode.insertBefore(n, a)
    }
    return t && e.extend(i, t), this.each(function() {
      var t = ["iframe[src*='player.vimeo.com']", "iframe[src*='youtube.com']", "iframe[src*='youtube-nocookie.com']", "iframe[src*='kickstarter.com'][src*='video.html']", "object", "embed"];
      i.customSelector && t.push(i.customSelector);
      var n = e(this).find(t.join(","));
      (n = n.not("object object")).each(function() {
        var t = e(this);
        if (!("embed" === this.tagName.toLowerCase() && t.parent("object").length || t.parent(".fluid-width-video-wrapper").length)) {
          var i = ("object" === this.tagName.toLowerCase() || t.attr("height") && !isNaN(parseInt(t.attr("height"), 10)) ? parseInt(t.attr("height"), 10) : t.height()) / (isNaN(parseInt(t.attr("width"), 10)) ? t.width() : parseInt(t.attr("width"), 10));
          if (!t.attr("id")) {
            var n = "fitvid" + Math.floor(999999 * Math.random());
            t.attr("id", n)
          }
          t.wrap('<div class="fluid-width-video-wrapper"></div>').parent(".fluid-width-video-wrapper").css("padding-top", 100 * i + "%"), t.removeAttr("height").removeAttr("width")
        }
      })
    })
  }
}(jQuery), function(e) {
  "function" == typeof define && define.amd ? define(["jquery"], e) : "object" == typeof exports ? module.exports = e : e(jQuery)
}(function(e) {
  var t, i, n = ["wheel", "mousewheel", "DOMMouseScroll", "MozMousePixelScroll"],
      a = "onwheel" in document || 9 <= document.documentMode ? ["wheel"] : ["mousewheel", "DomMouseScroll", "MozMousePixelScroll"];
  if (e.event.fixHooks) for (var r = n.length; r;) e.event.fixHooks[n[--r]] = e.event.mouseHooks;

  function o(n) {
    var a, r, o, s = n || window.event, l = [].slice.call(arguments, 1), c = 0, u = 0, d = 0;
    return (n = e.event.fix(s)).type = "mousewheel", s.wheelDelta && (c = s.wheelDelta), s.detail && (c = -1 * s.detail), s.deltaY && (c = d = -1 * s.deltaY), s.deltaX && (c = -1 * (u = s.deltaX)), void 0 !== s.wheelDeltaY && (d = s.wheelDeltaY), void 0 !== s.wheelDeltaX && (u = -1 * s.wheelDeltaX), a = Math.abs(c), (!t || a < t) && (t = a), r = Math.max(Math.abs(d), Math.abs(u)), (!i || r < i) && (i = r), o = 0 < c ? "floor" : "ceil", c = Math[o](c / t), u = Math[o](u / i), d = Math[o](d / i), l.unshift(n, c, u, d), (e.event.dispatch || e.event.handle).apply(this, l)
  }

  e.event.special.mousewheel = {
    setup: function() {
      if (this.addEventListener) for (var e = a.length; e;) this.addEventListener(a[--e], o, !1); else this.onmousewheel = o
    }, teardown: function() {
      if (this.removeEventListener) for (var e = a.length; e;) this.removeEventListener(a[--e], o, !1); else this.onmousewheel = null
    }
  }, e.fn.extend({
    mousewheel: function(e) {
      return e ? this.on("mousewheel", e) : this.trigger("mousewheel")
    }, unmousewheel: function(e) {
      return this.unbind("mousewheel", e)
    }
  })
}), jQuery(document).ready(function() {
  jQuery("body").hasClass("page-id-12251") || jQuery(".wpcf7-form").on("click", function() {
    var e = jQuery(this).find('input[name="first_name"]').val();
    jQuery(this).find('input[name="first_name"]').val(jQuery.trim(e));
    var t = jQuery(this).find('input[name="last_name"]').val();
    jQuery(this).find('input[name="last_name"]').val(jQuery.trim(t));
    var i = jQuery(this).find('input[name="phone"]').val();
    jQuery(this).find('input[name="phone"]').val(jQuery.trim(i))
  })
});
