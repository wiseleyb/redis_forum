# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_redis_forum_session',
  :secret      => 'dae694f1418e0eab1bb67bf637c68d16240f05f4719dd4cd09e08cf112a362257a18b225aae90e1e693d089f3d492cb6a3c25032d5b0f35d1f72520772291767'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
