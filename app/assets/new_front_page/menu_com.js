jQuery(document).ready(function() {

    // USE THE STRICT MODE IN THE CUSTOM CODE
    "use strict";
    jQuery('#navigation #menu-item-15458').attr('tabindex', 1);
    jQuery('#navigation #menu-item-2232').attr('tabindex', 2);
    jQuery('#navigation #menu-item-86').attr('tabindex', 3);
    jQuery('#navigation #menu-item-1725').attr('tabindex', 4);
    jQuery('#navigation #menu-item-7303').attr('tabindex', 5);
    jQuery('#navigation #menu-item-1723').attr('tabindex', 6);
    jQuery('#navigation #menu-item-1366').attr('tabindex', 7);
    jQuery('#Form_Search').attr('tabindex', 8);
    if(is_mobile()){
        // add padding for submenu of mobile version
        jQuery('menu #navigation ul .hassubmenu .sub-menu > .hassubmenu > .sub-menu') .css('margin-left','0px');
    } else{
        //narrow serchform for ie with resolution 1024px
        if( window.screen.availWidth < 1025 ){
            jQuery('#searchform > div') .addClass('searchform-ie-1024');
            jQuery('.single_blurredbg').css('display','none');
        }
    }
    if(is_mobile()==false) {
        if (document.documentElement.clientWidth < 1024) {
            jQuery('#searchform-wrp #searchform').css('right', '-25px');
            jQuery('#searchform-wrp #searchform > div').css('width', '100px');
            jQuery('.single_blurredbg').css('width', '100px');
        }
    }
});


/*
     FILE ARCHIVED ON 22:08:37 Feb 02, 2019 AND RETRIEVED FROM THE
     INTERNET ARCHIVE ON 18:43:41 Mar 11, 2019.
     JAVASCRIPT APPENDED BY WAYBACK MACHINE, COPYRIGHT INTERNET ARCHIVE.

     ALL OTHER CONTENT MAY ALSO BE PROTECTED BY COPYRIGHT (17 U.S.C.
     SECTION 108(a)(3)).
*/
/*
playback timings (ms):
  LoadShardBlock: 1509.819 (3)
  esindex: 0.01
  captures_list: 1525.808
  CDXLines.iter: 10.926 (3)
  PetaboxLoader3.datanode: 282.23 (4)
  exclusion.robots: 0.385
  exclusion.robots.policy: 0.37
  RedisCDXSource: 1.615
  PetaboxLoader3.resolve: 1346.308 (2)
  load_resource: 126.985
*/