require 'json'
require 'net/http'
require 'uri'

PAGERDUTY_EVENTS_URL = 'https://events.pagerduty.com/v2/enqueue'

def lambda_handler(event:, context:)
  routing_key = ENV.fetch('PAGERDUTY_ROUTING_KEY', '')

  if routing_key.empty?
    puts 'PagerDuty routing key not configured — skipping alert'
    return
  end

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
