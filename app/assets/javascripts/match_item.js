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

var show_svg = null;
var edit_svg = null;

function svgDrawLine(eTarget, eSource, edit) {
    var svg = null;
    if (edit)
      svg = edit_svg;
    else
      svg = show_svg;
    
    // origin -> ending ... from left to right
    // 10 + 10 (padding left + padding right) + 2 + 2 (border left + border right)
    var originX = 0;
    var originY = eSource.position().top + eSource.height()/2;

    
    var endingX = 57;
    var endingY = eTarget.position().top + eTarget.height()/2;

    var space = 15;
    var color = Raphael.getColor(1);

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
}

function disableDragDrop(element) {
  element.addClass('ui-state-highlight locked')
         .draggable('disable')
			   .droppable('disable')
			   .removeClass('ui-state-disabled');
}

function drawAllLines(edit) {
  if (edit) {
    $('#match_left_column .match_item').each(function() {
      var targetNumber = $(this).find('.match_item_match_number').val();
      if (targetNumber != '') {
        var targetElement = $('#question_match_items_attributes_' + targetNumber + '_right_column').parent();
        svgDrawLine(targetElement, $(this), true);
        disableDragDrop(targetElement);
        disableDragDrop($(this));
      }
    });
  }
  else {
    $('#quad-match_items_left_column .match_item_show').each(function() {
      var targetNumber = $(this).attr('data-match');
      if (targetNumber != '') {
        var targetElement = $('#match_item_' + targetNumber);
        svgDrawLine(targetElement, $(this), false);
      }
    });
  }
}

function loadSvg(edit) {
  if (edit)
    edit_svg = Raphael('edit_svg_div', '100%', '100%');
  else
    show_svg = Raphael('show_svg_div', '100%', '100%');
  drawAllLines(edit);
  if (edit)
    $('#match_column_container').css('visibility', 'visible');
}

function redrawEditLines() {
  edit_svg.clear();
  Raphael.getColor.reset();
  drawAllLines(true);
}

function removeMatching() {
  var thisField = $(this).parent().parent().find('.match_item_match_number')
  var matchNumber = thisField.val();
  thisField.val('');
  
  var otherField = $('#question_match_items_attributes_' + matchNumber + '_match_number')
  otherField.val('');
  otherField.parent().removeClass('ui-state-highlight locked')
                   .draggable('enable')
                   .droppable('enable');
  setTimeout(redrawEditLines, 1);
}

function clearMatchings() {
  if (confirm('Are you sure you wish to reset all matchings?')) {
    $('div .draggable')
      .removeClass('ui-state-highlight locked')
      .draggable('enable');
		
	  $('div .droppable')
      .removeClass('ui-state-highlight locked')
      .droppable('enable');
      
    $('.match_item_match_number').val('');
    edit_svg.clear();
    Raphael.getColor.reset();
  }
}

function updateMatchForm() {
  $('#match_left_column .match_item')
    .addClass('draggable')
    .find('.match_item_right_column_field')
    .val('f');
  $('#match_right_column .match_item')
    .addClass('droppable')
    .find('.match_item_right_column_field')
    .val('t');
    
  // all draggable elements
  $('div .draggable').draggable({
      appendTo: '#container',
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
          disableDragDrop($(this));
			    disableDragDrop($(ui.draggable));

          var regexp = /question_match_items_attributes_((new_)?\d+)_match_number/
          var sourceNumber = $(ui.draggable).find('.match_item_match_number').attr('id').match(regexp)[1];
          var targetNumber = $(this).find('.match_item_match_number').attr('id').match(regexp)[1];
      
          // change the input element to contain the mapping target and source
           $(this).find('.match_item_match_number')
			       .val(sourceNumber);
           $(ui.draggable).find('.match_item_match_number')
			       .val(targetNumber);
			    
          svgDrawLine($(this), $(ui.draggable), true);
      }
  });
  
  $('.match_item_remove_fields a').on('click', removeMatching);
}
