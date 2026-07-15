require_relative "../lambda_function"

RSpec.describe "lambda_handler" do
  def event_with_session(session)
    { "request" => { "session" => session }, "response" => {} }
  end

  def response_of(session)
    lambda_handler(event: event_with_session(session), context: nil)["response"]
  end

  context "when the session is empty (first attempt)" do
    it "issues a custom challenge" do
      expect(response_of([])).to eq(
        "challengeName" => "CUSTOM_CHALLENGE",
        "issueTokens" => false,
        "failAuthentication" => false,
      )
    end
  end

  context "when the most recent attempt was correct" do
    it "issues tokens" do
      session = [{ "challengeName" => "CUSTOM_CHALLENGE", "challengeResult" => true }]

      expect(response_of(session)).to eq(
        "issueTokens" => true,
        "failAuthentication" => false,
      )
    end
  end

  context "when there has been 1 wrong attempt" do
    it "re-issues the challenge so the user can retry" do
      session = [{ "challengeName" => "CUSTOM_CHALLENGE", "challengeResult" => false }]

      expect(response_of(session)).to eq(
        "challengeName" => "CUSTOM_CHALLENGE",
        "issueTokens" => false,
        "failAuthentication" => false,
      )
    end
  end

  context "when there have been 2 wrong attempts" do
    it "re-issues the challenge so the user can retry" do
      session = [
        { "challengeName" => "CUSTOM_CHALLENGE", "challengeResult" => false },
        { "challengeName" => "CUSTOM_CHALLENGE", "challengeResult" => false },
      ]

      expect(response_of(session)).to eq(
        "challengeName" => "CUSTOM_CHALLENGE",
        "issueTokens" => false,
        "failAuthentication" => false,
      )
    end
  end

  context "when there have been 3 wrong attempts" do
    it "fails authentication, forcing the user to request a fresh code" do
      session = [
        { "challengeName" => "CUSTOM_CHALLENGE", "challengeResult" => false },
        { "challengeName" => "CUSTOM_CHALLENGE", "challengeResult" => false },
        { "challengeName" => "CUSTOM_CHALLENGE", "challengeResult" => false },
      ]

      expect(response_of(session)).to eq(
        "issueTokens" => false,
        "failAuthentication" => true,
      )
    end
  end
end
