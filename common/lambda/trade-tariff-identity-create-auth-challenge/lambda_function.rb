require 'securerandom'
require 'notifications/client'
require 'cgi'

def lambda_handler(event:, context:) # rubocop:disable Metrics/MethodLength
  url = ENV['URL']
  api_key = ENV['GOVUK_NOTIFY_API_KEY']
  notify = Notifications::Client.new(api_key)
  email = event.dig('request', 'userAttributes', 'email')
  token = SecureRandom.hex(32)
  auth_link = "#{url}/passwordless/callback?email=#{CGI.escape(email)}&token=#{token}"

  if url.include? 'dev'
    template_id = 'bdb7b23b-177a-4e79-91f4-ab89a4509eea'
    email_reply_to_id = 'e780283a-471f-42ae-a573-4364ef604fea'
  elsif url.include? 'staging'
    template_id = '8b61bb5d-3537-4151-ba89-82cd1c6d49cc'
    email_reply_to_id = 'ed4f4168-e8c5-4b80-94b9-050c86a40f0f'
  else
    template_id = 'efdb4ffb-2b88-4ccf-ad93-ee3ad6469cc2'
    email_reply_to_id = '61e19d5e-4fae-4b7e-aa2e-cd05a87f4cf8'
  end

  notify.send_email(
    email_address: email,
    template_id: template_id,
    email_reply_to_id: email_reply_to_id,
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
