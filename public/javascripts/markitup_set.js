// Copyright (c) 2011 Rice University.  All rights reserved.

mySettings = {	
//onShiftEnter:  	{keepDefault:false, replaceWith:'<br />\n'},
//onCtrlEnter:  	{keepDefault:false, openWith:'\n<p>', closeWith:'</p>'},
onTab:    		{keepDefault:false, replaceWith:'    '},
markupSet:  [ 	
	{name:'Bold', key:'B', openWith:'\!\!', closeWith:'\!\!' },
	{name:'Italic', key:'I', openWith:'\'\'', closeWith:'\'\''  },
	{name:'Picture', key:'P', replaceWith:function (markItUp) {
               open_add_image_dialog(markItUp);
               return false;
           }
   },
	{name:'Bullets', key:'Bl', openWith:'\n\*'},
	
	{name:'Number List', key:'N_L', openWith:'\n\#'},
	{name:'Math', key:'M', openWith:'\$', closeWith:'\$'}
]
}
