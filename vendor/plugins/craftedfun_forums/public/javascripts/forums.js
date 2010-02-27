if( $('#topics_paginate_total_pages').text() ) {
  
  PostsPaginate = function(name_var) {
    this.init(name_var);
  }

  $.extend(PostsPaginate.prototype, {
    total_pages: 0,
    last_page_viewed: 0,
    current_page: 0,

    init: function( total_pages ) {
      this.total_pages = parseInt(total_pages); // b/c our first page is 0
      if ( this.total_pages < 0 ) {
        this.total_pages = 0;
      }      
      this.update_css();
    },

    next_page: function() {
      this.current_page ++;
      if ( this.current_page > this.total_pages )
        this.current_page = this.total_pages;

      this.update_css();
      scroll_to_top();
    },

    previous_page: function() {
      this.current_page --;
      if ( this.current_page < 0 )
        this.current_page = 0;

      this.update_css();
      scroll_to_top();
    },

    goto_page: function( page ) {
      this.current_page = page;

      if ( this.current_page > this.total_pages )
        this.current_page = this.total_pages;

      if ( this.current_page < 0 )
        this.current_page = 0;

      this.update_css();
      scroll_to_top();
    },

    goto_last_page: function( ) {
      this.current_page = this.total_pages;
      this.update_css();
      scroll_to_top();
    },

    goto_bottom_of_last_page: function( ) {
      this.current_page = this.total_pages;
      this.update_css();
      self.location.href = self.location.href + '#bottom';
    },
    
    update_css: function( ) {
      // First, reset the CSS
      if ( this.last_page_viewed == 0 )
        $('.pagination .previous_page').removeClass('disabled')

      if ( this.last_page_viewed == this.total_pages )
        $('.pagination .next_page').removeClass('disabled')
      
      $('.pagination .posts_page' + this.last_page_viewed ).removeClass('selected');
      $('#posts_page' + this.last_page_viewed).removeClass('show');
      
      // Now update the CSS
      if ( this.current_page == 0 )
        $('.pagination .previous_page').addClass('disabled')

      if ( this.current_page == this.total_pages )
        $('.pagination .next_page').addClass('disabled')

      $('.pagination .posts_page' + this.current_page ).addClass('selected');
      $('#posts_page' + this.current_page).addClass('show');
      
      this.last_page_viewed = this.current_page;

      return false;
    }
  });
  
  var posts_paginate = new PostsPaginate( $('#topics_paginate_total_pages').text() );
  //posts_paginate.next_page();
}

$(document).ready( function() {
  if ( $('#page_body').hasClass('topics') ) {
            
    
    
  } // hasClass
});

function submit_post_form( topic_id ) {
  disable_button( $('.submit_post_form_button') );

  var post_form =       $('#post_form_' + topic_id );
  if ( post_form.length == 0 )
    post_form =         $('#post_form');

  var textarea  =       $(post_form).find( 'textarea' );
  var text      =       $(post_form).find( 'input:text' );

  if( post_form && ! $(textarea).val() == '' && 
      ! ($(text).length > 0 && $(text).val() == '') ) {

    var url = $(post_form).attr( 'action' );
    var params = $(post_form).serialize();

    $.postJSON( url, params, function( data ) {
      if( data.post_html ) {
        posts_paginate.goto_bottom_of_last_page();
        
        $('#posts_' + topic_id ).append( data.post_html );
        $('.topic_preview_toggle_' + topic_id).addClass('you');

        if( data.post_count ) {
          $('.post_count').html( data.post_count );
        }
      }

      if( data.topic_html ) {
        $('#topics').prepend( data.topic_html );
      }

      update( data );

      $(post_form).find( 'textarea' ).val( '' );
      $(post_form).find( 'input:text' ).val( '' );
      enable_button( $('.submit_post_form_button') );
      $('.posts_container .timeago').timeago();
    } );
  }
  else {
    $(post_form).find( ".error_msg" ).show();
    enable_button( $('.submit_post_form_button') );
  }
}

function save_topic( topic_id ) {
  var post_form =       $('#save_topic_' + topic_id + '_title_form');
  var text      =       $(post_form).find( 'input:text' );

  if( post_form && ! ($(text).length > 0 && $(text).val() == '') ) {

    var url = $(post_form).attr( 'action' );
    var params = $(post_form).serialize();

    $.postJSON( url, params, function( data ) {
      $('#topic_' + topic_id + '_title').html( data.topic_title );
    });
  }
}

function merge_topic( lose_id, keep_id ) {
  $.post( "/topics/merge/" + lose_id + "?into_topic_id=" + keep_id, admin_controls_handler, "html" )
}

function move_topic( id, forum_id ) {
  $.post( "/topics/move/" + id + "?forum_id=" + forum_id, admin_controls_handler, "html" )
}

function lock_topic( id ) {
  $.post( "/topics/lock/" + id, admin_controls_handler, "html" );
}

function unlock_topic( id ) {
  $.post( "/topics/unlock/" + id, admin_controls_handler, "html" );
}

function stick_topic( id ) {
  $.post( "/topics/stick/" + id, admin_controls_handler, "html" );
}

function unstick_topic( id ) {
  $.post( "/topics/unstick/" + id, admin_controls_handler, "html" );
}

function unflag_topic( id ) {
  $.post( "/topics/unflag/" + id, public_controls_handler, "html" );
  $('.post_container').removeClass('flagged');
  $('.bottom_jump').removeClass('flagged');
}

function flag_topic( id ) {
  // This qtip destroy works, but it reports an error so just swallow the error
  try { $('.flag_control_explanation').qtip("destroy"); } catch( err ) { }
  $.post( "/topics/flag/" + id, public_controls_handler, "html" );
  $('.post_container').addClass('flagged');
  $('.bottom_jump').addClass('flagged');
}

function admin_controls_handler( html ) {
  $('.topic_admin_controls').replaceWith( html );
  update_buttons();
}

function public_controls_handler( html ) {
  $('.topic_public_controls').replaceWith( html );
  update_buttons();
}

