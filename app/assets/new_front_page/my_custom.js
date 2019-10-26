function formRedirect(urlRedirect) {
    if (supportsHistoryAPI = !!(window.history && history.pushState)) {
        url = location.href
        history.pushState({page: url}, document.title, url);
    }
    location.replace(urlRedirect);
}

function revslider_showDoubleJqueryError(sliderID) {
    var errorMessage = "Revolution Slider Error: You have some jquery.js library include that comes after the revolution files js include.";
    errorMessage += "<br> This includes make eliminates the revolution slider libraries, and make it not work.";
    errorMessage += "<br><br> To fix it you can:<br>&nbsp;&nbsp;&nbsp; 1. In the Slider Settings -> Troubleshooting set option:  <strong><b>Put JS Includes To Body</b></strong> option to true.";
    errorMessage += "<br>&nbsp;&nbsp;&nbsp; 2. Find the double jquery.js include and remove it.";
    errorMessage = "<span style='font-size:16px;color:#BC0C06;'>" + errorMessage + "</span>"
    jQuery(sliderID).show().html(errorMessage);
}

function wrap_button() {
    jQuery(".form-submit input[type=submit]").each(function () {
        jQuery(this).wrap("<div class=\"glassbtn\">");
    });
    jQuery(".wpcf7 input[type=submit]").each(function () {
        jQuery(this).wrap("<div class=\"glassbtn\">");
    });
}

function step_2_forms() {
    jQuery.ajax({
        type: "POST",
        url: location.href,
        data: {action: 'step_2'}
    })
        .done(function (response) {
            if (response) {
                message = jQuery('.wpcf7-response-output').html()
                jQuery("form.wpcf7-form").closest('.wpcf7').replaceWith(response);
                jQuery('div.wpcf7 > form').wpcf7InitForm();
                jQuery(document).scrollTop(jQuery("form.wpcf7-form").closest('.wpcf7').offset().top - 300);
                wrap_button();
                jQuery('.wpcf7-response-output').html(message).addClass('wpcf7-mail-sent-ok').show();
                jQuery('#platform-other-text').hide();
                jQuery('#platform-other').find('input').change(function () {
                    if (this.checked) {
                        jQuery('#platform-other-text').show();
                    } else {
                        jQuery('#platform-other-text').hide();
                    }
                })
            }
        });
    return false;
}

function step_1_forms() {
    jQuery.ajax({
        type: "POST",
        url: location.href,
        data: {action: 'step_1'}
    })
        .done(function (response) {
            if (response) {
                message = jQuery('.wpcf7-response-output').html()
                jQuery("form.wpcf7-form").closest('.wpcf7').replaceWith(response);
                jQuery('div.wpcf7 > form').wpcf7InitForm();
                wrap_button();
                jQuery('.wpcf7-response-output').html(message).addClass('wpcf7-mail-sent-ok').show()
                jQuery(document).scrollTop(jQuery("form.wpcf7-form").closest('.wpcf7').offset().top - 300);
            }
        });
    return false;
}

function ga_send_event(type) {
    var action, category;
    if (type) {
        switch (type) {
            case 1:
                action = 'CF Cheat Sheet';
                category = 'Visuals Download';
                break;
            case 2:
                action = 'BOSH Cheat Sheet';
                category = 'Visuals Download';
                break;
            case 3:
                action = 'Pattern and Anti-Patterns';
                category = 'Visuals Download';
                break;
            case 4:
                action = 'How to Create CF Manifest';
                category = 'Visuals Download';
                break;
            case 5:
                action = 'TensorFlow Cheat Sheet';
                category = 'Visuals Download';
                break;
            case 'contact_form_paas':
                action = 'PaaS';
                category = 'Contact form';
                break;
            case 'contact_form_cf_cli':
                action = 'CF CLI';
                category = 'Contact form';
                break;
            case 'contact_form_cf_trainings':
                action = 'CF Trainings';
                category = 'Contact form';
                break;
            case 'contact_form_cf_upgrade':
                action = 'CF Upgrade';
                category = 'Contact form';
                break;
            case 'contact_form_cf_support':
                action = 'CF Support';
                category = 'Contact form';
                break;
        }
        ga('send', 'event', category, action, action);
        console.log('action = ' + action);
    }
    return false;
}

jQuery(window).on("pageshow", function (event) {
    if (event.originalEvent.persisted) {
        jQuery('html, body').animate({
            scrollTop: jQuery("body").offset().top
        }, 10);
        window.location.reload();
    }
});

jQuery(document).ready(function () {
    jQuery('.wpcf7 input, .wpcf7 textarea').on('focusin', function () {
        jQuery(this).removeClass('wpcf7-not-valid');
    });
    jQuery('.wpcf7 .hs_persona').on('focusin', function () {
        jQuery(this).find('.select2-selection').removeClass('wpcf7-not-valid');
    });
    jQuery('html, body').animate({
        scrollTop: jQuery("body").offset().top
    }, 10);
    if ('scrollRestoration' in history) {
        history.scrollRestoration = 'manual';
    }

    jQuery(".wpcf7-textarea").focusout(function () {
        var str = jQuery(this).val();
        if ((jQuery.trim(str)).length == 0) {
            jQuery(this).val(jQuery.trim(str));
        }
    });

    var first_name = jQuery('input[name="first_name"]');
    first_name.attr('maxlength', '50');
    var last_name = jQuery('input[name="last_name"]');
    last_name.attr('maxlength', '50');
    var phone = jQuery('input[name="phone"]');
    phone.attr('maxlength', '50');
    var text_area = jQuery('textarea.wpcf7-form-control');
    text_area.attr('maxlength', '1800');

    var cf_img = jQuery("#cf_download").closest('div'),
        cf_button = jQuery("#cf_download").closest('div').next('div'),
        cc_img = jQuery("#cc_download").closest('div'),
        cc_button = jQuery("#cc_download").closest('div').next('div'),
        pa_img = jQuery("#pa_download").closest('div'),
        pa_button = jQuery("#pa_download").closest('div').next('div'),
        hc_img = jQuery("#hc_download").closest('div'),
        hc_button = jQuery("#hc_download").closest('div').next('div'),
        tf_img = jQuery("#tf_download").closest('div'),
        tf_button = jQuery("#tf_download").closest('div').next('div');

    cf_img.click(function () {
        ga_send_event(1);
    });
    cf_button.click(function () {
        ga_send_event(1);
    });
    cc_img.click(function () {
        ga_send_event(2);
    });
    cc_button.click(function () {
        ga_send_event(2);
    });
    pa_img.click(function () {
        ga_send_event(3);
    });
    pa_button.click(function () {
        ga_send_event(3);
    });
    hc_img.click(function () {
        ga_send_event(4);
    });
    hc_button.click(function () {
        ga_send_event(4);
    });
    tf_img.click(function () {
        ga_send_event(5);
    });
    tf_button.click(function () {
        ga_send_event(5);
    });

    jQuery("a.ancLinks").click(function () {
        elementClick = jQuery(this).attr("href");
        destination = jQuery(elementClick).offset().top;
        jQuery('html, body').animate({scrollTop: destination}, 1100);
        return false;
    });


    jQuery('.thesidebar .widget .sub-menu .current_page_item').parent().css({display: 'block'});

    if (jQuery('#allcontent').attr('touch-action')) {
        jQuery('#allcontent').removeAttr('touch-action')
    }

    jQuery('.formWP').css({position: "relative"});
    var my_tooltip = jQuery("#tooltip");

    jQuery(".wpcf7-form-control").mouseover(function () {
        if (jQuery(this).hasClass('wpcf7-not-valid')) {
            var text = jQuery(this).parent('.wpcf7-form-control-wrap').find('.wpcf7-not-valid-tip').text();
            my_tooltip.text(text).css({
                opacity: 0.8,
                display: "none", position: "absolute", width: "180px"
            }).fadeIn(400);
        }
    }).mousemove(function (kmouse) {
        if (jQuery('#formWP').hasClass('formWP')) {
            var offset = jQuery('.formWP').offset();
            my_tooltip.css({
                left: kmouse.pageX - offset.left + 15,
                top: kmouse.pageY - offset.top + 15
            });
        }
    }).mouseout(function () {
        if (jQuery(this).hasClass('wpcf7-not-valid')) {
            my_tooltip.fadeOut(0);
        }
    });

    jQuery('.management_team').click(function () {
        id = jQuery(this).attr('id');
        if (!id)
            text = jQuery(this).text();
        else
            text = 'contact ' + id;
        jQuery('#brief_project').val('I want to ' + text)
    });

    jQuery('.request_eference').click(function () {
        id = jQuery(this).attr('id');
        if (!id)
            text = jQuery(this).text();
        else
            text = 'request a reference from ' + id;
        jQuery('#brief_project').val('I\'d like to ' + text)
    });
    if (window.location.hostname.indexOf('altoros.no') + 1) {
        jQuery('.request_eference').click(function () {
            id = jQuery(this).attr('id');
            if (!id)
                text = jQuery(this).text();
            else
                text = id;
            jQuery('#brief_project').val('Jeg ønsker referanse fra ' + text)
        });
    }

    /*Remove not valid class*/
    jQuery(".formWP .wpcf7-not-valid").focus(function () {
        jQuery(this).removeClass("wpcf7-not-valid");
    });
    jQuery('#platform-other-text').hide();
    jQuery('#platform-other').find('input').change(function () {
        if (this.checked) {
            jQuery('#platform-other-text').show();
        } else {
            jQuery('#platform-other-text').hide();
        }
    });

    jQuery(".wpcf7-form-control").each(function () {
        if (typeof jQuery(this).attr('name') != 'undefined') {
            var value = cookie(jQuery(this).attr('name'));
            if (value) {
                jQuery(this).val(JSON.parse(value).replace('+', ' '));
            }
        }
    });

    function cookie(name, value, options) {
        if (typeof value != 'undefined') {
            options = options || {};
            if (value === null) {
                value = '';
                options.expires = -1;
            }
            var expires = '';
            if (options.expires && (typeof options.expires == 'number' || options.expires.toUTCString)) {
                var date;
                if (typeof options.expires == 'number') {
                    date = new Date();
                    date.setTime(date.getTime() + (options.expires * 24 * 60 * 60 * 1000));
                } else {
                    date = options.expires;
                }
                expires = '; expires=' + date.toUTCString();
            }
            var path = options.path ? '; path=' + (options.path) : '';
            var domain = options.domain ? '; domain=' + (options.domain) : '';
            var secure = options.secure ? '; secure' : '';
            document.cookie = [name, '=', encodeURIComponent(value), expires, path, domain, secure].join('');
        } else {
            var cookieValue = null;
            if (document.cookie && document.cookie != '') {
                var cookies = document.cookie.split(';');
                for (var i = 0; i < cookies.length; i++) {
                    var cookie = (cookies[i]).trim();
                    if (cookie.substring(0, name.length + 1) == (name + '=')) {
                        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                        break;
                    }
                }
            }
            return cookieValue;
        }
    }

    if (isMobile.any()) {
        jQuery('body').addClass('isMobile-version');
    }

    if (isMobile.any()) {
        jQuery('#menu-main-menu').find('ul.sub-menu').each(function () {
            jQuery(this).closest('li').append('<div class="hassubmenu-arr"></div>');
            if (!jQuery(this).prevAll('a').attr('href')) {
                jQuery(this).prevAll('a').addClass('empty-link');
            }
        });
        jQuery('#menu-main-menu .empty-link').on('click', function () {
            jQuery(this).closest('li').toggleClass('menuopen');
            jQuery(this).closest('li').find('.sub-menu:first').toggle(300);
        });
        jQuery('#menu-main-menu .hassubmenu-arr').on('click', function () {
            jQuery(this).closest('li').toggleClass('menuopen');
            jQuery(this).closest('li').find('.sub-menu:first').toggle(300);
        });

        jQuery('.links_container-wrap').hide();
        jQuery('.s-header-nav').hide();

        jQuery('.s-header-cf-enabl').addClass("header-no-padding");
        jQuery('.s-header-replat').addClass("header-no-padding");
        jQuery('.s-header-cont-del').addClass("header-no-padding");
        jQuery('.s-header-cf-support').addClass("header-no-padding");

        jQuery('.art-int').css("margin-top", "-25px");
        jQuery('.bc-solution').css("margin-top", "-25px");
        jQuery('.kub-enabl').css("margin-top", "-25px");
        jQuery('.s-header-cf-support').css("margin-top", "-25px");
    }

    jQuery('.searchsubmittericon').on('click', function () {
        var len = jQuery(this).parent().find('input').val().length;
        if (len >= 3) {
            jQuery(this).closest('form').submit();
        } else {
            alert("Search term must be at least 3 characters in length");
        }
    });
    jQuery("#searchform input").keypress(function (event) {
        if (event.which == 13) {
            event.preventDefault();
            if (location.hostname === 'www.altoros.com') {
                var value = encodeURIComponent(jQuery(this).val());
                jQuery(this).val(value);
            }
            var len = jQuery(this).val().length;
            if (len >= 3) {
                jQuery(this).closest('form').submit();
                jQuery(this).val('');
            } else {
                alert("Search term must be at least 3 characters in length");
            }
        }
    });

    jQuery(document).ready(function () {
        var cookie = window.location.search.split('&')[0].replace("?p=", "");
        jQuery('input.p').val(cookie);

        var str = decodeURIComponent(window.location.search);
        var ar = str.split('&');
        var newStr = '';
        for (var i = 0; i < ar.length; i++) {
            if (ar[i].search(/utm_term/i) >= 0) {
                newStr = ar[i];
                newStr = newStr.replace('utm_term=', "");
                jQuery('input.utm_term').val(newStr);
                //console.log(jQuery('input.utm_term').val());
            }
        }
    });
});

//Handling of sending a form containing an invitation to Slack
jQuery('#slack-form-join').submit(function () {
    var email = jQuery('.s-contact-join-field input').val();
    if (!validate_slack_email()) {
        jQuery('.s-cotact-join-input').css({
            'border': '1px solid red',
            'background': 'url(https://www.altoros.com/wp-content/uploads/2018/03/err.svg) 95% 50% no-repeat'
        });
        jQuery('#slack-form-join-msg').text("Please type valid email!");
        jQuery('#slack-form-join-msg').css({'color': 'red', 'position': 'absolute', 'bottom': '-22px'});
    } else {
        submitJoinSlack(email);
        jQuery('.s-contact-join-field input').val('');
        jQuery('.s-cotact-join-input').css({
            'border': '1px solid #e0e0e0',
            'background': 'url(https://www.altoros.com/wp-content/uploads/2018/03/required.svg) 95% 50% no-repeat'
        });
        jQuery('#slack-form-join-msg').text('Thanks for your interest in joining our Slack community. Your invite is on the way!');
        jQuery('#slack-form-join-msg').css({
            'color': 'green',
            'position': 'absolute',
            'bottom': '-38px',
            'line-height': '18px'
        });
        if (jQuery(window).width() < 333) {
            jQuery('#slack-form-join-msg').css({
                'color': 'green',
                'position': 'absolute',
                'bottom': '-55px',
                'line-height': '18px'
            });
        }
    }
    return false;
});

//Processing submit Join-button
function submitJoinSlack(email) {
    //Initialization for Slack
    var webhook = 'https://web.archive.org/web/20190202220855/https://hooks.slack.com/services/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'; // Webhook URL for Slack
    var text = 'A new request has been received from the ' + email + ' to join your channel!'; // Text to post for Slack
    //Initialization for Hubspot
    var formGuid = '24eb2998-3013-45b0-b29e-be473ca313ef';
    var portalId = '2950617';
    var fields = {};
    fields["email"] = email;
    sendToSlack(webhook, text);
    sendToHubspot(fields, portalId, formGuid);
}

//Sending msg to Slack
function sendToSlack(webhook, text) {
    jQuery.ajax({
        data: 'payload=' + JSON.stringify({
            "text": text
        }),
        dataType: 'json',
        processData: false,
        type: 'POST',
        url: webhook
    });
}

//Sending email to Hubspot
function sendToHubspot(aArray, portalId, formGuid) {
    var submittedAt = new Date();
    var skipValidation = false;
    var context = {};
    var fields = [];

    for (var key in aArray) {
        if (aArray.hasOwnProperty(key)) {
            fields.push({"name": key, "value": aArray[key]});
        }
    }
    context['pageUri'] = window.location.href;
    context['pageName'] = document.title;


    var url = 'https://web.archive.org/web/20190202220855/https://api.hsforms.com/submissions/v3/integration/submit/' + portalId + '/' + formGuid; // Webhook URL
    jQuery.ajax({
        data: JSON.stringify({
            "submittedAt": submittedAt.getTime(),
            "fields": fields,
            "context": context,
            "skipValidation": skipValidation,
        }),
        contentType: 'application/json',
        dataType: 'json',
        type: 'POST',
        url: url,
        error: function (e) {
            console.log(e);
        }
    });
}

jQuery('#slick-link').on('click touchend', function (e) {
    e.preventDefault();
    jQuery('.s-contact-join').toggleClass('show-contact-join');
});

jQuery('.slack.contact-link').on('click touchend', function (e) {
    e.preventDefault();
    jQuery('.s-contact-join').toggleClass('show-contact-join');
});

jQuery('.engineer-slack').on('click touchend', function (e) {
    e.preventDefault();
    jQuery('.s-contact-join').toggleClass('show-contact-join');
});

jQuery("#slick-link").removeClass("show-contact-join")

jQuery("#slick-link").click(function (e) {
    if (jQuery("#slick-link").hasClass("show-contact-join")) {
        jQuery("#slick-link").stop(true);
        jQuery("#slick-link").removeClass("show-contact-join");
        e.preventDefault();
        e.stopPropagation();
        console.log("slick");
    } else {
        if (jQuery(window).width() > 1200) {
            jQuery('html,body').animate({
                    scrollTop: jQuery(".s-contact-join").offset().top - 80
                },
                'slow');
        } else if (jQuery(window).width() < 1200 && jQuery(window).width() > 768) {
            jQuery('html,body').animate({
                    scrollTop: jQuery(".s-contact-join").offset().top - 80
                },
                'slow');
        } else {
            jQuery('html,body').animate({
                    scrollTop: jQuery(".s-contact-join").offset().top - 120
                },
                'slow');
        }
        jQuery(this).addClass("show-contact-join");
        e.preventDefault();
        e.stopPropagation();
    }
});

jQuery(".slack.contact-link").click(function (e) {
    if (jQuery("#slick-link").hasClass("show-contact-join")) {
        jQuery("#slick-link").stop(true);
        jQuery("#slick-link").removeClass("show-contact-join");
        e.preventDefault();
        e.stopPropagation();
    } else {
        if (jQuery(window).width() > 1200) {
            jQuery('html,body').animate({
                    scrollTop: jQuery(".s-contact-join").offset().top - 80
                },
                'slow');
        } else if (jQuery(window).width() < 1200 && jQuery(window).width() > 768) {
            jQuery('html,body').animate({
                    scrollTop: jQuery(".s-contact-join").offset().top - 80
                },
                'slow');
        } else {
            jQuery('html,body').animate({
                    scrollTop: jQuery(".s-contact-join").offset().top - 120
                },
                'slow');
        }
        jQuery(this).addClass("show-contact-join");
        e.preventDefault();
        e.stopPropagation();
    }
});

jQuery(".engineer-slack").click(function (e) {
    if (jQuery("#slick-link").hasClass("show-contact-join")) {
        jQuery("#slick-link").stop(true);
        jQuery("#slick-link").removeClass("show-contact-join");
        e.preventDefault();
        e.stopPropagation();
    } else {
        if (jQuery(window).width() > 1200) {
            jQuery('html,body').animate({
                    scrollTop: jQuery(".s-contact-join").offset().top - 80
                },
                'slow');
        } else if (jQuery(window).width() < 1200 && jQuery(window).width() > 768) {
            jQuery('html,body').animate({
                    scrollTop: jQuery(".s-contact-join").offset().top - 80
                },
                'slow');
        } else {
            jQuery('html,body').animate({
                    scrollTop: jQuery(".s-contact-join").offset().top - 120
                },
                'slow');
        }
        jQuery(this).addClass("show-contact-join");
        e.preventDefault();
        e.stopPropagation();
    }
});

jQuery('.s-contact-join .input-form').on('focus', function () {
    jQuery(this).next('.plaseholder-text').css({
        "font-size": "11px",
        "top": "8px",
        "color": "#1ea2a1"
    })
});

jQuery('.s-contact-join .input-form').on('focusout', function () {
    if (jQuery(this).val() === '') {
        jQuery(this).next('.plaseholder-text').css({
            "font-size": "14px",
            "top": "14px",
            "color": "#333333"
        })
    }
});

function validate_slack_email() {
    var email = '#slack-form-join .s-cotact-join-input';
    var reg = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    var address = jQuery(email).val();
    if (reg.test(address) == false || address === "") {
        return false;
    } else
        return true;
}

jQuery(document).ready(function () {
    var source, medium, term, content, campaign, session_count, pageview_count;

    function get_campaign_info() {
        var utma = get_utm_value(document.cookie, '__utma=', ';');
        var utmb = get_utm_value(document.cookie, '__utmb=', ';');
        var utmc = get_utm_value(document.cookie, '__utmc=', ';');
        var utmz = get_utm_value(document.cookie, '__utmz=', ';');

        source = get_utm_value(utmz, 'utmcsr=', '|');
        medium = get_utm_value(utmz, 'utmcmd=', '|');
        term = get_utm_value(utmz, 'utmctr=', '|');
        content = get_utm_value(utmz, 'utmcct=', '|');
        campaign = get_utm_value(utmz, 'utmccn=', '|');


        session_count = get_session_count(utma);
        pageview_count = get_pageview_count(utmb, utmc);
    }

    function get_utm_value(l, n, s) {
        if (!l || l == "" || !n || n == "" || !s || s == "") return "-";
        var i, j, k, utm = "-";
        i = l.indexOf(n);
        k = n.indexOf("=") + 1;

        if (i > -1) {
            j = l.indexOf(s, i);
            if (j < 0) {
                j = l.length;
            }
            utm = l.substring((i + k), j);
        }
        return utm;
    }

//This function extracts the "Count of Sessions" value from the _utma cookie
    function get_session_count(str) {
        var i, vc = '-';
        if (str != '-') {
            i = str.lastIndexOf(".");
            i++;
            vc = str.substring(i);
        }
        return vc;
    }

//This function extracts the "Count of Pageviews" value from the _utmb cookie
    function get_pageview_count(utmb, utmc) {
        var i, j, pc = '-';
        if (utmb != '-' && utmc != '-') {
            utmc = utmc + '.';

            i = utmc.length;
            j = utmb.indexOf(".", i);
            pc = utmb.substring(i, j);
        }
        return pc;
    }

    get_campaign_info();

    function loadJSON(callback) {

        var xobj = new XMLHttpRequest();
        xobj.overrideMimeType("application/json");
        xobj.open('GET', '../../../sheets_api/data.json', true);
        xobj.onreadystatechange = function () {
            if (xobj.readyState == 4 && xobj.status == "200") {
                callback(xobj.responseText);
            }
        }
        xobj.send(null);

    }

    jQuery(document).ready(function () {
        if (jQuery('form div').is(".hidden")) {

            jQuery('form div').find('.hidden:first').append('<input type="hidden" name="p" value="">' +
                '<input type="hidden" name="client_id" value="">' +
                '<input type="hidden" name="campaign_source" value="">' +
                '<input type="hidden" name="campaign_channel" value="">' +
                '<input type="hidden" name="campaign_name" value="">' +
                '<input type="hidden" name="search_queries" value="">' +
                '<input type="hidden" name="session_count" value="">' +
                '<input type="hidden" name="keyword_match_type" value="keyword">' +
                '<input type="hidden" name="utm_term" value="">' +
                '<input type="hidden" name="device" value="">');
        } else {

            jQuery('div.formWP').append('<input type="hidden" name="p" value="">' +
                '<input type="hidden" name="client_id" value="">' +
                '<input type="hidden" name="campaign_source" value="">' +
                '<input type="hidden" name="campaign_channel" value="">' +
                '<input type="hidden" name="campaign_name" value="">' +
                '<input type="hidden" name="search_queries" value="">' +
                '<input type="hidden" name="session_count" value="">' +
                '<input type="hidden" name="keyword_match_type" value="keyword">' +
                '<input type="hidden" name="utm_term" value="">' +
                '<input type="hidden" name="device" value="">');
        }

        jQuery('input[name="url_page"]').val(jQuery('input[name="url_page"]').val() + window.location.search);

        var cookie = window.location.search.split('&')[0].replace("?p=", "");
        jQuery('input[name="p"]').val(cookie);
        jQuery('input[name="session_count"]').val(session_count);
        jQuery('input[name="keyword_match_type"]').val('keyword');

        var str = decodeURIComponent(window.location.href);
        var ar = str.split(/&|#|\//);
        var newStr = '';
        var newStrCampaign = '';
        var newStrMedium = '';
        var newStrSource = '';

        for (var i = 0; i < ar.length; i++) {
            if (ar[i].search(/utm_term/i) >= 0) {
                newStr = ar[i];
                newStr = newStr.replace('utm_term=', "");
                jQuery('input[name="utm_term"]').val(newStr);
                jQuery('input[name="search_queries"]').val(newStr);
            }

            if (ar[i].search(/utm_campaign/i) >= 0) {
                newStrCampaign = ar[i];
                newStrCampaign = newStrCampaign.replace('utm_campaign=', "");

                loadJSON(function (response) {
                        var jsonresponse = JSON.parse(response);

                        for (var key in jsonresponse) {
                            if (newStrCampaign == jsonresponse[key].campaign_id) {
                                newStrCampaign = jsonresponse[key].campaign_name;
                                jQuery('input[name="campaign_name"]').val(newStrCampaign);
                            } else {
                                jQuery('input[name="campaign_name"]').val(newStrCampaign);
                            }
                        }
                    }
                );
            }

            if (ar[i].search(/utm_medium/i) >= 0) {
                newStrMedium = ar[i];
                newStrMedium = newStrMedium.replace('utm_medium=', "");
                jQuery('input[name="campaign_channel"]').val(newStrMedium);
            }

            if (ar[i].search(/utm_source/i) >= 0) {
                newStrSource = ar[i];
                newStrSource = newStrSource.replace('utm_source=', "");
                jQuery('input[name="campaign_source"]').val(newStrSource);
                //console.log($('input[name="campaign_source"]').val());
            }

            if (ar[i].search(/device/i) >= 0) {
                newStrSource = ar[i];
                newStrSource = newStrSource.replace('device=', "");
                jQuery('input[name="device"]').val(newStrSource);
            }
        }

        //https://trello.com/c/jpQS1jYY
        jQuery('.wpcf7-form input[type="checkbox"]').attr('checked', false);

    });

    jQuery(document).change(function () {
        if (typeof ga.getAll === "function") {
            jQuery('input[name="client_id"]').val(ga.getAll()[0].get('clientId'));
        }
    });
});

// https://trello.com/c/r5EvRq3G/
////aliaksei.kalesnikau@altoros.com
jQuery(function () {

    var pathname = window.window.location.href,
        parts = pathname.split("#");

    if (parts[1] == "specials") {

        jQuery('html, body').animate({
            scrollTop: jQuery("#specials").offset().top - 100
        }, 800);
    }
});

// https://trello.com/c/r5EvRq3G/
////aliaksei.kalesnikau@altoros.com

jQuery(function () {
    jQuery('.description-days-table').each(function () {
        var dayTitle = jQuery(this).find('.table-striped').prev('p');
        dayTitle.addClass('training-toggle-btn');
        jQuery(this).find('.training-toggle-btn').next().wrap('<div class="trainings-table-wrapper">');

        var dayLength = jQuery(this).find('.training-toggle-btn').length;
        for (var i = 0, y = 1; i < dayLength; i++, y++) {
            // jQuery(this).find('.training-toggle-btn').eq(i).next().addClass('training-day-' + y);
            jQuery(this).find('.training-toggle-btn').eq(i).next().attr('id', 'training-day-' + y);
            jQuery(this).find('.training-toggle-btn').eq(i).attr('data-target', '#training-day-' + y);
        }

        dayTitle.attr('data-toggle', 'collapse');
        jQuery(this).html(jQuery('.description-days-table').html().replace(/&nbsp;/gi, ''));
        dayTitle.addClass('collapsed');
        jQuery(this).find('.trainings-table-wrapper').addClass('collapse');

    });
    jQuery('.trainings-table-wrapper').first().addClass('in collapse');
    jQuery('body.postid-19935 .trainings-table-wrapper').addClass('in collapse'); //https://trello.com/c/f2u5kTvW/

    var placeholder = jQuery('#brief_project').parent().siblings('.plaseholder-text');
    if (placeholder.length) {
        jQuery('#brief_project').on("change keyup paste", function () {
            if (document.getElementById("brief_project").clientHeight < document.getElementById("brief_project").scrollHeight) {
                placeholder.hide();
            } else {
                placeholder.show();
            }
        });
    }
});
