// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var facebook_api = null;

$(document).ready( function() {
                       // Just because the document is loaded doesn't mean the FB
                       // library has finished loading. Including all the usual onready()
                       // stuff inside this callback.


                       FB.init( api_key, xd_receiver );

                       FB.ensureInit(function() {
                                         facebook_api = FB.Facebook.apiClient;

                                         try {
                                             if( top.location.host == undefined ) {
                                                 throw( "error" );
                                             }
                                             //## Outside Facebook

                                             if( top.location.pathname == "/chat" ) {
                                                 //## Outside Facebook but inside our chat frame

                                             } else {
                                                 //## Outside Facebook not in any frames

                                             }

                                         } catch( err ) {
                                             //## Inside a Facebook iframe

                                             FB.CanvasClient.startTimerToSizeToContent();
                                             scroll_to_top();
                                         }

                                         check_cookie();
                                     }); // ensureInit
                   }); // ready

function check_cookie() {
    if( typeof session_cookie != "undefined" &&
        typeof session_id     != "undefined" ) {
            if( $.cookie( session_cookie ) != session_id ) {
                /*
                 if( $.browser.mozilla ) {
                 $('body').html( $('#third_party_cookies_disabled').html() );
                 }
                 else {
                 */
                fix_cookie_with_ajax( function() {
                                          if( $.cookie( session_cookie ) != session_id ) {
                                              fix_cookie_with_form();
                                          }
                                      } );
                /*
                 }
                 */
            }
        }
}

