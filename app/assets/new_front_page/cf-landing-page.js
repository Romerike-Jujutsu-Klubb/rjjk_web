/**
 * Created by aliaksei.siamionau on 10/10/2017.
 */
jQuery(document).ready(function () {
    jQuery(function () {
        jQuery('select').select2({
            minimumResultsForSearch: -1,
            containerCssClass: "wpcf7-form-control"
        });
    });

    jQuery('#inlineContactLinkPopup').magnificPopup({
        delegate: 'a',
        callbacks: {
            beforeOpen: function() {
                this.st.mainClass = this.st.el.attr('data-effect');
            },
            open: function() {
                // window.location.href = window.location.href + "#viewContactPopup";
                window.location.hash = 'viewContactPopup';
            },
            close: function() {
                window.location.hash = '';
            }
        },
        midClick: true // allow opening popup on middle mouse click. Always set it to true if you don't provide alternative source.
    });
    jQuery('.custom-form').scrollSpy();
    jQuery('#footer').scrollSpy();
    jQuery('.form-show-popup').scrollSpy();
    jQuery('.custom-form').on('scrollSpy:enter', function() {
        jQuery('#inlineContactLinkPopup').hide();
    });
    jQuery('.form-show-popup').on('scrollSpy:enter', function() {
        jQuery('#inlineContactLinkPopup').hide();
    });
    var pgOffset = pageYOffset;
    var up = false;
    jQuery(window).scroll(function() {
        pageYOffset < pgOffset ? up = true : up = false;
            jQuery('.custom-form').on('scrollSpy:exit', function() {
                if (up) {
                    jQuery('#inlineContactLinkPopup').show();
                }
            });
            jQuery('.form-show-popup').on('scrollSpy:exit', function() {
                if (up) {
                    jQuery('#inlineContactLinkPopup').show();
                }
            });
        pgOffset = pageYOffset;
    });
    jQuery('#footer').on('scrollSpy:enter', function() {
        jQuery('#inlineContactLinkPopup').hide();
    });

    jQuery('.animate-link').on('click', function(e) {
        e.preventDefault();
        var pathId = jQuery(this).attr('href');
        jQuery("html, body").animate({ scrollTop: jQuery(pathId).offset().top - 80 }, 1000);
    });




    if (is_mobile()) {
        if (jQuery('.no-offset-top').length > 0) {
            jQuery('.page').css('margin-top', '0px');
            jQuery('#maincontent').css('margin-top', '0px');
            jQuery('#allcontent').css('margin-top', '-15px');
        } else if (jQuery('.single_blurredbg_holder').length > 0 && jQuery('div.page').length > 0) {
            jQuery('div.page').css('margin-top', jQuery('.single_blurredbg_holder').height() + 2 * jQuery('.single_blurredbg_holder').offset().top + 'px');
        }
    }
});
/*
     FILE ARCHIVED ON 22:08:37 Feb 02, 2019 AND RETRIEVED FROM THE
     INTERNET ARCHIVE ON 19:17:17 Mar 11, 2019.
     JAVASCRIPT APPENDED BY WAYBACK MACHINE, COPYRIGHT INTERNET ARCHIVE.

     ALL OTHER CONTENT MAY ALSO BE PROTECTED BY COPYRIGHT (17 U.S.C.
     SECTION 108(a)(3)).
*/
/*
playback timings (ms):
  LoadShardBlock: 62.297 (3)
  esindex: 0.012
  captures_list: 81.495
  CDXLines.iter: 13.44 (3)
  PetaboxLoader3.datanode: 63.716 (4)
  exclusion.robots: 0.437
  exclusion.robots.policy: 0.415
  RedisCDXSource: 1.585
  PetaboxLoader3.resolve: 41.063
  load_resource: 57.523
*/