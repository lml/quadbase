/*
**
** Part of StackOverflow Answer 
**  http://stackoverflow.com/questions/536676/how-to-draw-a-line-between-draggable-and-droppable
**
** Created and Maintained by Bruno Alexandre (balexandre.com) 
**
** Last Edit by Author: 29 September 2011
**
** Modified for use in Quadbase
**
*/

var isDialogOpen = false,
	myLines = [],
	svg = null;
	
// icons
var ico_userNormal  = 'icons/user-48x48.png',
    ico_userChecked = 'icons/check-user-48x48.png';

$(document).ready(function () {

    // Mapping dialog box			
    $("#dialogMappingResult").dialog({
        autoOpen: false,
        modal: true,
        overlay: {
            backgroundColor: '#000',
            opacity: 0.5
        },
        buttons: {
            Close: function () {
                $(this).dialog('close');
            }
        }
    });

    // Reset mappings dialog box
    $("#dialog").dialog({
        autoOpen: false,
        modal: true,
        overlay: {
            backgroundColor: '#000',
            opacity: 0.5
        },
        buttons: {
            Close: function () {
                $(this).dialog('close');
            },
            'Reset mapping': function () {

                // change class and image back to default
                $("div .droppable")
						.removeClass("ui-state-highlight")
						.find("img")
						.removeAttr("src")
						.attr("src", ico_userNormal);

                // enable the droppable area	
                $("div .droppable").droppable("enable");

                // change class and image back to default
                $("div .draggable")
						.removeClass("ui-state-highlight")
						.find("img")
						.removeAttr("src")
						.attr("src", ico_userNormal);
                // change icon back to default
                $("div .draggable")
						.find(".ui-icon-locked")
						.removeClass("ui-icon-locked")
						.addClass("ui-icon-shuffle");

                // reset the draggable value
                $("div .draggable")
						.find("input:hidden")
						.each(function () {
						    $(this).val(
								$(this).val().split("_")[0]
							);
						});

                // enable the draggable area	
                $("div .draggable").draggable("enable");

                // reset the mapping dialog
                $("#dialogMappingResult")
						.find("ul")
						.empty()
						.append("<li>No mapping was done yet</li>");

                $(this).dialog("close");

                // clear lines
                svgClear();
            }
        }
    });

    // all draggable elements
    $("div .draggable").draggable({
        revert: true,
        containment: '#container',
        helper: 'clone',
        start: function(event, ui) { $(this).css('visibility', 'hidden'); },
        stop: function(event, ui) { $(this).css('visibility', ''); }
    });

    // all droppable elements
    $("div .droppable").droppable({
        hoverClass: "ui-state-hover",
        helper: "clone",
        cursor: "move",
        drop: function (event, ui) {
            // change class and image
            $(this)
				      .addClass("ui-state-highlight")
				      .find("img")
				      .removeAttr("src")
				      .attr("src", ico_userChecked);

            // disable it so it can't be used anymore		
            $(this).droppable("disable");
            
            // change the icon
            $(this)
				      .find(".ui-icon-shuffle")
				      .removeClass("ui-icon-shuffle")
				      .addClass("ui-icon-locked");

            // change class and image of the source element		
            $(ui.draggable)
				      .addClass("ui-state-highlight")
				      .find("img")
				      .removeAttr("src")
				      .attr("src", ico_userChecked);

            // change the icon of the source element				
            $(ui.draggable)
				      .find(".ui-icon-shuffle")
				      .removeClass("ui-icon-shuffle")
				      .addClass("ui-icon-locked");

            var regexp = /question_match_items_attributes_(\d+)_match_id/
            var sourceId = $(ui.draggable).find(".match_item_match_id").attr('id').match(regexp)[1];
            var targetId = $(this).find(".match_item_match_id").attr('id').match(regexp)[1];
        
            // change the input element to contain the mapping target and source
             $(this)
				      .find(".match_item_match_id")
				      .val(sourceId);
             $(ui.draggable)
				      .find(".match_item_match_id")
				      .val(targetId);

            // disable it so it can"t be used anymore	
            $(ui.draggable).draggable("disable");

            svgDrawLine($(this), $(ui.draggable));
        }
    });

    svg = Raphael("svg_div", "100%", "100%");

});

function svgClear() {
    svg.clear();
}

function svgDrawLine(eTarget, eSource) {

    // wait 1 sec before drawing the lines, so we can get the position of the draggable
    setTimeout(function () {

        var $source = eSource;
        var $target = eTarget;

        // origin -> ending ... from left to right
        // 10 + 10 (padding left + padding right) + 2 + 2 (border left + border right)
        var originX = 0;
        var originY = $source.position().top + $source.height()/2;

        
        var endingX = 57;
        var endingY = $target.position().top + $target.height()/2;

        var space = 15;
        var color = colours[random(9)];

        // draw lines
        // http://raphaeljs.com/reference.html#path			
        var a = "M" + originX + " " + originY + " L" + (originX + space) + " " + originY; // beginning
        var b = "M" + (originX + space) + " " + originY + " L" + (endingX - space) + " " + endingY; // diagonal line
        var c = "M" + (endingX - space) + " " + endingY + " L" + endingX + " " + endingY; // ending
        var all = a + " " + b + " " + c;

        /*
        // log (to show in FF (with FireBug), Chrome and Safari)			
        console.log("New Line ----------------------------");
        console.log("originX: " + originX + " | originY: " + originY + " | endingX: " + endingX + " | endingY: " + endingY + " | space: " + space + " | color: " + color );				
        console.log(all); 
        */

        // write line
        myLines[myLines.length] = svg
										.path(all)
										.attr({
										    "stroke": color,
										    "stroke-width": 2,
										    "stroke-dasharray": "--."
										});

    }, 1000);

}

function random(range) {
    return Math.floor(Math.random() * range);
}

// random colors are not that random after all
var colours = ["purple", "red", "orange", "yellow", "lime", "green", "blue", "navy", "black"];
