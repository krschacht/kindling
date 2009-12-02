# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_growing2_session',
  :secret      => '0342d7608dcad0571a36be0837b611e872359ca8a3ed1990d9e1b008ae0649a2b819c929d6c7530741f793076e0ca11cc3cbfa199162f7c19579509131a68311'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
