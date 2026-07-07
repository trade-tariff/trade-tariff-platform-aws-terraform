require "notifications/client"
require_relative "../lambda_function"

RSpec.describe "lambda_handler" do
  let(:notify) { instance_double(Notifications::Client, send_email: nil) }
  let(:email) { "test@example.com" }
  let(:event) do
    {
      "request" => { "userAttributes" => { "email" => email } },
      "response" => {},
    }
  end

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify)
    ENV["URL"] = "https://identity.dev.trade-tariff.service.gov.uk"
    ENV["GOVUK_NOTIFY_API_KEY"] = "test-key"
  end

  def generated_code(result)
    result["response"]["privateChallengeParameters"]["answer"]
  end

  it "generates a 6-digit numeric code as the challenge answer" do
    result = lambda_handler(event:, context: nil)

    expect(generated_code(result)).to match(/\A\d{6}\z/)
  end

  it "emails the code to the user via the auth_code personalisation" do
    result = lambda_handler(event:, context: nil)

    expect(notify).to have_received(:send_email).with(
      hash_including(email_address: email, personalisation: { auth_code: generated_code(result) }),
    )
  end

  it "does not include a link in the personalisation" do
    lambda_handler(event:, context: nil)

    expect(notify).to have_received(:send_email) do |args|
      expect(args[:personalisation]).not_to have_key(:auth_link)
    end
  end

  context "when retrying within an existing session (wrong code already submitted)" do
    let(:event) do
      {
        "request" => {
          "userAttributes" => { "email" => email },
          "session" => [
            { "challengeName" => "CUSTOM_CHALLENGE", "challengeResult" => false, "challengeMetadata" => "CODE-123456" },
          ],
        },
        "response" => {},
      }
    end

    it "reuses the code from the previous round instead of generating a new one" do
      result = lambda_handler(event:, context: nil)

      expect(generated_code(result)).to eq("123456")
    end

    it "does not send another email" do
      lambda_handler(event:, context: nil)

      expect(notify).not_to have_received(:send_email)
    end
  end
end
