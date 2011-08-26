# Copyright (c) 2011 Rice University.  All rights reserved.

# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Quadbase::Application
