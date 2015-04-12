//NewSpring Ooyala Player
$(document).ready(function(){
  $('a.ooyala-embed').click(function(event){
      if(event.preventDefault) event.preventDefault();
      else event.returnValue = false;

      var error = $("<div>Please enable Javascript to watch this video</div>");

      if ($(this).attr('data-embed')) {
			  var code = $(this).attr('data-embed');
		  } else {
			  var code = $($(this).parent().find("input")).val();
		  }

      if($.browser.msie){
        var video = document.getElementById("video");
        video.setAttribute("rel", code);
      }else{		
        $("#video").attr('data-embed', code);
      }

      if($.type(OO) == 'object'){
        OO.ready(function(){
          var videoPlayer = OO.Player.create('ooyalaplayer', code, {
            autoplay: true,
            onCreate: function(player){
                window.mb = player.mb;
            }
          });
          
          window.mb.subscribe(OO.EVENTS.PLAYED, 'Video', function(eventName){
              $("#tranny").trigger('click');	            
          });

          window.mb.subscribe(OO.EVENTS.ERROR, 'Video', function(error){
              $("#tranny").trigger('click');
              _gaq.push(['_trackEvent', 'Error', error , 'Ooyala','',true]);   
          });

          $("#video").fadeIn('fast');
    		  $('#tranny').fadeIn('fast');

          $('#tranny').click(function() {
            $('#tranny').fadeOut('fast').delay(150);
            $("#video").fadeOut('fast');
            videoPlayer.destroy('ooyalaplayer');
            return false;
          });
  
          $(document).bind('keyup', function(event) {
            if (event.keyCode == 27) {
              $("#tranny").trigger('click');	
            }
            return false;
          });
        });
      }else{
        $("#video").append(error);
        _gaq.push(['_trackEvent', 'Error', 'OO Object Not Available!', 'Ooyala','',true]);   
      }
  return false;
  });

  $(".sermon-embed").each(function(){
      if ($(this).attr('data-embed')) {
			  var code = $(this).attr('data-embed');
		  } else {
			  var code = $($(this).parent().find("input")).val();
		  }

      if($.browser.msie){
        var video = document.getElementById("video");
        video.setAttribute("rel", code);
      }else{		
        $("#video").attr('data-embed', code);
      }
      
      if($.type(OO) == 'object'){
          OO.ready(function(){
            var videoPlayer = OO.Player.create('ooyalaplayer', code, {
              autoplay: false,
              onCreate: function(player){
                  window.mb = player.mb;
              }
            });

            window.mb.subscribe(OO.EVENTS.ERROR, 'Video Error', function(error){
              _gaq.push(['_trackEvent', 'Error', error , 'Ooyala','',true]);   
            });

          });
        }else{
        $("#video").append(error);
        _gaq.push(['_trackEvent', 'Error', 'OO Object Not Available!', 'Ooyala','',true]);   
        }

  });

  if ( (window.location.hash != '') && (!Modernizr.touch) ) {
		var hash = window.location.hash;
		$(hash + " a").trigger('click');
	}
});


