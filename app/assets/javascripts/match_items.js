/**
  * Based on Draggable-Line-to-Droppable
  *  https://github.com/balexandre/Draggable-Line-to-Droppable
  *
  * Part of StackOverflow Answer 
  *  http://stackoverflow.com/questions/536676/how-to-draw-a-line-between-draggable-and-droppable
  *
  * Created and Maintained by Bruno Alexandre (balexandre.com) 
  * Modified for use in Quadbase
  *
  * Last Edit by Author: 29 September 2011
  */

var svg = null,
    colors = ['purple', 'red', 'orange', 'yellow', 'lime', 'green', 'blue', 'navy', 'black'];

$(document).ready(function () {
  svg = Raphael('svg_div', '100%', '100%');
});

function randInt(range) {
  return Math.floor(Math.random() * range);
}

function svgDrawLine(eTarget, eSource) {
    // wait 1 sec before drawing the lines, so we can get the position of the draggable
    setTimeout(function () {
        // origin -> ending ... from left to right
        // 10 + 10 (padding left + padding right) + 2 + 2 (border left + border right)
        var originX = 0;
        var originY = eSource.position().top + eSource.height()/2;

        
        var endingX = 57;
        var endingY = eTarget.position().top + eTarget.height()/2;

        var space = 15;
        var color = colors[randInt(9)];

        // draw lines
        // http://raphaeljs.com/reference.html#path			
        var a = 'M' + originX + ' ' + originY + ' L' + (originX + space) + ' ' + originY; // beginning
        var b = 'M' + (originX + space) + ' ' + originY + ' L' + (endingX - space) + ' ' + endingY; // diagonal line
        var c = 'M' + (endingX - space) + ' ' + endingY + ' L' + endingX + ' ' + endingY; // ending
        var all = a + ' ' + b + ' ' + c;

        /*
        // log (shown in FF (with FireBug), Chrome and Safari)			
        console.log('New Line ----------------------------');
        console.log('originX: ' + originX + ' | originY: ' + originY + ' | endingX: ' + endingX + ' | endingY: ' + endingY + ' | space: ' + space + ' | color: ' + color );				
        console.log(all); 
        */

        // write line
        svg.path(all)
				   .attr({
					   'stroke': color,
					   'stroke-width': 2,
					   'stroke-dasharray': '--.'
				});
    }, 1000);
}

function clearMatchings() {
  $('div .draggable')
    .removeClass('ui-state-highlight')
    .draggable('enable')
    .find('.ui-icon-locked')
	  .removeClass('ui-icon-locked')
		.addClass('ui-icon-shuffle');
		
	$('div .droppable')
    .removeClass('ui-state-highlight')
    .droppable('enable')
    .find('.ui-icon-locked')
	  .removeClass('ui-icon-locked')
		.addClass('ui-icon-shuffle');
	
  $('.match_item_match_id').val('');
  return svg.clear();
}

function updateColumnFields() {
  $('#match_left_column .match_item')
    .addClass('draggable')
    .find('.match_item_right_column_field')
    .val('f');
  $('#match_right_column .match_item')
    .addClass('droppable')
    .find('.match_item_right_column_field')
    .val('t')
    .parent()
      .find('.ui-icon-arrow-4')
      .hide();
    
  // all draggable elements
  $('div .draggable').draggable({
      containment: '#container',
      helper: 'clone',
      start: function(event, ui) { $(this).css('visibility', 'hidden'); },
      stop: function(event, ui) { $(this).css('visibility', ''); }
  });

  // all droppable elements
  $('div .droppable').droppable({
      hoverClass: 'ui-state-hover',
      helper: 'clone',
      cursor: 'move',
      drop: function (event, ui) {
          // change class, disable and change icon
          $(this)
			      .addClass('ui-state-highlight')
			      .droppable('disable')
			      .find('.ui-icon-shuffle')
			      .removeClass('ui-icon-shuffle')
			      .addClass('ui-icon-locked');
			    $(ui.draggable)
			      .addClass('ui-state-highlight')
			      .draggable('disable')
			      .find('.ui-icon-shuffle')
			      .removeClass('ui-icon-shuffle')
			      .addClass('ui-icon-locked');

          var regexp = /question_match_items_attributes_(new_)?(\d+)_match_id/
          var sourceId = $(ui.draggable).find('.match_item_match_id').attr('id').match(regexp)[2];
          var targetId = $(this).find('.match_item_match_id').attr('id').match(regexp)[2];
      
          // change the input element to contain the mapping target and source
           $(this).find('.match_item_match_id')
			            .val(sourceId);
           $(ui.draggable).find('.match_item_match_id')
			            .val(targetId);
			    
          svgDrawLine($(this), $(ui.draggable));
      }
  });
}
