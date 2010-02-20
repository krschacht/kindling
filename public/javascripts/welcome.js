function welcome_require_session() {
  FB.Connect.requireSession( function() { 
    window.top.location.href = '/play';   
  } );
  return false;
}
