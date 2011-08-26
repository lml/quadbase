# Copyright (c) 2011 Rice University.  All rights reserved.

Paperclip.options[:command_path] = DEV_SETTINGS[:paperclip_command_path].nil? ? 
                                   "/usr/bin/" :
                                   DEV_SETTINGS[:paperclip_command_path]
