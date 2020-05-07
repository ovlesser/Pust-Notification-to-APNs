  #
  # push.rb

  # Created by Ovlesser Xie on 06 May 2020.
  # Copyright All rights reserved.

  # This script is to send a push notification request to APNs with Auth Token
  #
  # References:
  # https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_token-based_connection_to_apns
  # https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html#//apple_ref/doc/uid/TP40008194-CH11-SW1
  # https://shashikantjagtap.net/wwdc18-a-basic-guide-to-app-store-connect-api/
  # https://gist.github.com/greencoder/16d1f8d7b0fed5b49cf64312ce2b72cc



require "base64"
require "jwt"
 
DEVELOPMENT_SERVER = "https://api.sandbox.push.apple.com:443" # for debug build
PRODUCTION_SERVER = "https://api.push.apple.com:443" # for production and beta build?

ISSUER_ID = "79JA83N72Y" # team id
KEY_ID = "W63FF2S49Z" # https://developer.apple.com/account/resources/authkeys/list

build = "Beta" # Alpha / Beta

if build == "Alpha"
  APNS_TOPIC = "au.com.ninemsn.jump-in-Alpha"
  DEVICE_TOKEN = "06e01c740888a3a24c6df8003f1f55b38dff70f0a3cec559c2206bce537365df" # for au.com.ninemsn.jump-in-Alpha, might change periodically
  APNS_SERVER = DEVELOPMENT_SERVER

elsif build == "Beta"
  APNS_TOPIC =  "au.com.ninemsn.jump-in-Beta"
  DEVICE_TOKEN = "3bb30da7af208778ba9264bd0a361be0f64b29b7c361be8a81fddb105390c255" # for au.com.ninemsn.jump-in-Beta, might change periodically
  APNS_SERVER = PRODUCTION_SERVER

end
 
private_key = OpenSSL::PKey.read(File.read("./AuthKey_#{KEY_ID}.p8")) # private key generated when creating new key
 
token = JWT.encode(
   {
 
    iss: ISSUER_ID,
    iat: Time.now.to_i - 20 * 60 # had better 20 minutes PRIOR to now
   },
   private_key,
   "ES256",
   header_fields={
     kid: KEY_ID }
 )

# puts "AuthToken: #{token}"

# category, gameID and deepURL are custom data, need to be parsed in the app
payload = '\'{
  "aps" : {
    "alert" : {
      "title" : "This is the push title",
      "subtitle" : "This is the subtitle",
      "body" : "this the push body"
    },
    "category" : "GAME_INVITATION"
  },
  "gameID" : "12345678",
  "deepURL": "ninenow://www.9now.com.au?ocid=tpushI-9now-test--200121&mktg_scr=tpushI-9nowpush"
}\''

curl = 'curl -v \
     -d %s \
     -H "apns-topic: %s" \
     -H "authorization: bearer %s" \
     --http2 \
     %s/3/device/%s' %[payload, APNS_TOPIC, token, APNS_SERVER, DEVICE_TOKEN]

# curl = 'curl -v \
#      -d %s \
#      -H "apns-topic: au.com.ninemsn.jump-in-Alpha" \
#      --http2 \
#      --cert ./beta-Certificates.p12 \
#      %s/3/device/%s' %[payload, Development_server, DEVICE_TOKEN]

# puts curl

system curl
