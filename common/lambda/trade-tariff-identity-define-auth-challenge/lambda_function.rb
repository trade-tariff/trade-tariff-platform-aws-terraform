def lambda_handler(event:, context:)
    session = event.dig('request', 'session') || []

    if session.empty?
      event['response'] = {
        'challengeName' => 'CUSTOM_CHALLENGE',
        'issueTokens' => false,
        'failAuthentication' => false
      }
    elsif session.last['challengeResult']
      event['response'] = {
        'issueTokens' => true,
        'failAuthentication' => false
      }
    else
      event['response'] = {
        'issueTokens' => false,
        'failAuthentication' => true
      }
    end

    event
  end
