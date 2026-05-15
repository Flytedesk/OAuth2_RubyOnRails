# README

This app is mainly used to show logic how to implement OAuth 2 in Ruby on Rails.

* Ruby version:<br>
The sample is tested on Ruby 2.4.2

* System dependencies:<br>
The rails version is 5.1.4

* Configuration and run<br>
  1. Install Ruby, Bundler, and gems:
     ```
     ❯ rbenv install
     ❯ gem install bundler -v 1.15.4
     ❯ bundle install
     ```
  2. Set up and run ngrok:
      1. Install:
         ```
         ❯ brew install --cask ngrok
         ```
      2. Sign up for an account: https://dashboard.ngrok.com/signup
      3. Copy your Authtoken: https://dashboard.ngrok.com/get-started/your-authtoken
      4. Add your Authtoken:
         ```
         ❯ ngrok config add-authtoken <your_authtoken>
         ```
      5. Run:
         ```
         ❯ ngrok http 3000
         ```
  3. Update your OAuth 2 configuration value at config/config.yml file.<br>
     ```
     OAuth2:
       client_id: <your_intuit_app_client_id>
       client_secret: <your_intuit_app_client_secret>
     ```
     ```
     Settings:
       host_uri: https://<your_ngrok_dev_domain>/
       redirect_uri: https://<your_ngrok_dev_domain>/token/new
     ```
  4. Update your Redirect URIs in your app. <br>
  5. Put the whole directory to your server, and run "rails server" <br>
  6. open a browser and go to the rail server host.
