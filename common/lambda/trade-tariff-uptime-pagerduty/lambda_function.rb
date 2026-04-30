require 'json'
require 'net/http'
require 'uri'
require 'aws-sdk-secretsmanager'

PAGERDUTY_EVENTS_URL = 'https://events.pagerduty.com/v2/enqueue'

def lambda_handler(event:, context:)
  routing_key = fetch_routing_key

  event['Records'].each do |record|
    message    = JSON.parse(record.dig('Sns', 'Message'))
    alarm_name = message['AlarmName']
    new_state  = message['NewStateValue']  # "ALARM" or "OK"

    event_action = new_state == 'ALARM' ? 'trigger' : 'resolve'

    payload = {
      routing_key:  routing_key,
      event_action: event_action,
      dedup_key:    alarm_name,
      payload: {
        summary:  message['AlarmDescription'] || alarm_name,
        source:   alarm_name,
        severity: 'critical',
        custom_details: {
          alarm_name: alarm_name,
          state:      new_state,
          reason:     message['NewStateReason']
        }
      }
    }

    post_to_pagerduty(payload)
  end
end

def fetch_routing_key
  secret_arn = ENV.fetch('PAGERDUTY_SECRET_ARN')
  client     = Aws::SecretsManager::Client.new
  secret     = client.get_secret_value(secret_id: secret_arn)
  JSON.parse(secret.secret_string).fetch('routing_key')
end

def post_to_pagerduty(payload)
  uri      = URI.parse(PAGERDUTY_EVENTS_URL)
  http     = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl      = true
  http.open_timeout = 10
  http.read_timeout = 10

  request      = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  request.body = payload.to_json

  response = http.request(request)
  puts "PagerDuty response: #{response.code} #{response.body}"

  raise "PagerDuty API error: #{response.code}" unless response.code.to_i < 300
end
