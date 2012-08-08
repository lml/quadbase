// Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
// License version 3 or later.  See the COPYRIGHT file for details.

jQuery.fn.exists = function(){return jQuery(this).length>0;}

jQuery.fn.closeOnClickOutside = function(){
  var dialogx = this;
  $('.ui-widget-overlay').live("click",function(){
    dialogx.dialog("close");
  });
}
