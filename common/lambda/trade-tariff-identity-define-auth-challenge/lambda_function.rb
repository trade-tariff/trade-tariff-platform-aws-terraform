MAX_ATTEMPTS = 3

def lambda_handler(event:, context:)
  session = event.dig('request', 'session') || []
  failed_attempts = session.count { |attempt| attempt['challengeResult'] == false }

  event['response'] =
    if session.empty?
      { 'challengeName' => 'CUSTOM_CHALLENGE', 'issueTokens' => false, 'failAuthentication' => false }
    elsif session.last['challengeResult']
      { 'issueTokens' => true, 'failAuthentication' => false }
    elsif failed_attempts >= MAX_ATTEMPTS
      { 'issueTokens' => false, 'failAuthentication' => true }
    else
      { 'challengeName' => 'CUSTOM_CHALLENGE', 'issueTokens' => false, 'failAuthentication' => false }
    end

  event
end
