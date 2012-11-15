# Example Quadbase OAuth 2 Client

This app is an example of OAuth 2 client, based on the DoorKeeper [example client](https://github.com/applicake/doorkeeper-sinatra-client).

## Installation

Here are the steps for firing up this client app.

1. Run ````bundle install````.  This example directory has its own ````.rvmrc```` file for setting up an RVM gem dir, so running ````bundle```` will not interfere with your Quadbase gem dir.
2. Create a [new oauth app](http://localhost:3000/oauth/applications/new) in your development instance of Quadbase.
3. Create an ````env.rb```` file in the top-level ````oauth-client```` directory that has the following contents, where the ````OAUTH2_CLIENT_ID```` and ````OAUTH2_CLIENT_SECRET```` have the appropriate values from the result of the prior step.

        # Change these hashes to match what your local version of Quadbase gives you
        ENV['OAUTH2_CLIENT_ID']           = "40348dc38..."
        ENV['OAUTH2_CLIENT_SECRET']       = "69d7e8493..."
        ENV['OAUTH2_CLIENT_REDIRECT_URI'] = "http://localhost:9292/callback"
4. Run ````rackup config.ru```` to start the server on port 9292.
