def lambda_handler(event:, context:)
  expected_token = event.dig('request', 'privateChallengeParameters', 'answer')
  user_token = event.dig('request', 'challengeAnswer')

  event['response'] = {
    'answerCorrect' => user_token == expected_token
  }

  event
end
