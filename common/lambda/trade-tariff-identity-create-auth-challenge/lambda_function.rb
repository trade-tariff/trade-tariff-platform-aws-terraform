require 'securerandom'
require 'notifications/client'
require 'cgi'

def lambda_handler(event:, context:)
  url = ENV['URL']
  api_key = ENV['GOVUK_NOTIFY_API_KEY']
  notify = Notifications::Client.new(api_key)
  email = event.dig('request', 'userAttributes', 'email')
  consumer = 'myott'
  token = SecureRandom.hex(32)
  auth_link = "#{url}/passwordless/callback?email=#{CGI.escape(email)}&token=#{token}&consumer=#{consumer}"

  notify.send_email(
    email_address: email,
    template_id: 'efdb4ffb-2b88-4ccf-ad93-ee3ad6469cc2',
    email_reply_to_id: '61e19d5e-4fae-4b7e-aa2e-cd05a87f4cf8',
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
