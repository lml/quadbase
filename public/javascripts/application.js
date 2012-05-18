// Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
// License version 3 or later.  See the COPYRIGHT file for details.

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Useful debugging code:
//  window.alert("Your message here");

function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function partial_fields(link) {
   
   $(link).parent().hide();
   $(link).parent().next(".partialtext").show();

}

function rightwrong_fields(link) {
   
   $(link).parent().hide();
   $(link).parent().prev(".hidethis").show();

}

function add_fields(elem_to_append_to, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(elem_to_append_to).append(content.replace(regexp, new_id));
}

// Use this method when you want to do an AJAX "DELETE", which 
// rails/jquery likes to achieve as a POST with an extra field
// passed in.  See "handleMethod(link)" in rails.js for the 
// prototype for this method.
function delete_as_post(action, serializedArray) {
   serializedArray.push({name: "_method", value: "delete"}); 
   return $.post(action, serializedArray);
}

function put_as_post(action, serializedArray) {
   serializedArray.push({name: "_method", value: "put"}); 
   return $.post(action, serializedArray);
}

// Adds a 'notice' message to the page
function add_notice(message) {
   add_attention_message(message, "notice");
}

// Adds an 'alert' message to the page
function add_alert(message) {
   add_attention_message(message, "alert");
}

// Adds an attention message to the page of the given type
function add_attention_message(message, type) {
   $('#attention').append('<div id="' + type + '" class="' + type + '">' + message + '</div>');
}

(function($) {
    $.extend({
        getGo: function(url, params) {
            document.location = url + '?' + $.param(params);
        },
        postGo: function(url, params) {
            var $form = $("<form>")
                .attr("method", "post")
                .attr("action", url);
            $.each(params, function(name, value) {
                $("<input type='hidden'>")
                    .attr("name", name)
                    .attr("value", value)
                    .appendTo($form);
            });
            $form.appendTo("body");
            $form.submit();
        },
        putGo: function(url, params) {
              params.push({name: "_method", value: "put"}); 
              var $form = $("<form>")
                  .attr("method", "post")
                  .attr("action", url);
              $.each(params, function(index, param) {
                  $("<input type='hidden'/>")
                      .attr("name", param['name'])
                      .attr("value", param['value'])
                      .appendTo($form);
              });
              $form.appendTo("body");
              $form.submit();
          }
    });
});

function show_none_row_if_needed(table_id) {
  if ($('#' + table_id + ' tr').length == 2) {
    $('#' + table_id + '_none_row').show();
  }
}

function refresh_buttons() {
   $('input:submit').button();
   $('.button').button();
   $(".show_button").button({icons: {primary: "ui-icon-search"}, text: false });
   $(".edit_button").button({icons: {primary: "ui-icon-pencil"}, text: false });
   $(".trash_button").button({icons: {primary: "ui-icon-trash"}, text: false });   
}

function refresh_datetime_pickers() {
   $(".date_time_picker").datetimepicker({
     timeFormat: 'h:mm TT',
     stepMinute: 5, 
     ampm:true, 
     hour:9, 
     minute:0});
}
