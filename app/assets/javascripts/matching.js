// Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
// License version 3 or later.  See the COPYRIGHT file for details.
//
//= require jquery_nested_form
//= require dragdropline
//= require raphael-min

function update_column_fields() {
  $('#match_left_column .match_item').addClass('draggable')
    .find('.match_item_right_column_field').val('f');
  $('#match_right_column .match_item').addClass('droppable')
    .find('.match_item_right_column_field').val('t')
    .parent().find('.ui-icon-arrow-4').hide();
}
