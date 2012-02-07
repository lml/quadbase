# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

Paperclip.options[:command_path] = DEV_SETTINGS[:paperclip_command_path].nil? ? 
                                   "/usr/bin/" :
                                   DEV_SETTINGS[:paperclip_command_path]
