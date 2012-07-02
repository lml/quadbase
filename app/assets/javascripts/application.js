// Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
// License version 3 or later.  See the COPYRIGHT file for details.
//
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require quadbase
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery-ui-1.8.12.custom.min
//= require jquery_extensions



function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(elem_to_append_to, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association + "|tid|rid", "g");
  $(elem_to_append_to).append(content.replace(regexp, new_id));
}

// Use this method when you want to do an AJAX "DELETE", which 
// rails/jquery likes to achieve as a POST with an extra field
// passed in.
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
