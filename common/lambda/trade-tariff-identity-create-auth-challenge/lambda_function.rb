require 'securerandom'
require 'notifications/client'
require 'cgi'

def lambda_handler(event:, context:)
  url = ENV['URL']
  api_key = ENV['GOVUK_NOTIFY_API_KEY']
  notify = Notifications::Client.new(api_key)
  email = event.dig('request', 'userAttributes', 'email')
  consumer = "myott"
  token = SecureRandom.hex(32)
  auth_link = "#{url}/passwordless/callback?email=#{CGI.escape(email)}&token=#{token}&consumer=#{consumer}"

  response = notify.send_email(
    email_address: email,
    template_id: "4efe28e9-faa1-47de-8bcb-0b0297e99b0b",
    personalisation: {
      auth_link: auth_link
    }
  )

  event['response'] = {
    'publicChallengeParameters' => {},
    'privateChallengeParameters' => { 'answer' => token },
    'challengeMetadata' => 'MAGIC_LINK'
  }

  event
end
