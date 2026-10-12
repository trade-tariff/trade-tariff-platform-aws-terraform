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

  it "keeps the default Notify endpoint when no override is set" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("GOVUK_NOTIFY_API_URL").and_return(nil)

    lambda_handler(event:, context: nil)

    expect(Notifications::Client).to have_received(:new).with("test-key", nil)
  end

  it "uses the configured local Notify endpoint" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("GOVUK_NOTIFY_API_URL").and_return("http://identity-inbox:8080")

    lambda_handler(event:, context: nil)

    expect(Notifications::Client).to have_received(:new).with("test-key", "http://identity-inbox:8080")
  end

  it "accepts localhost as a local Notify endpoint" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("GOVUK_NOTIFY_API_URL").and_return("http://localhost:8080")

    lambda_handler(event:, context: nil)

    expect(Notifications::Client).to have_received(:new).with("test-key", "http://localhost:8080")
  end

  [
    "https://attacker.example.com",
    "http://identity-inbox.attacker.example",
    "http://16909060:8080",
    "http://[2001:db8::1]:8080",
    "not a url",
  ].each do |override|
    it "ignores a Notify endpoint that is not a local inbox: #{override}" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("GOVUK_NOTIFY_API_URL").and_return(override)

      lambda_handler(event:, context: nil)

      expect(Notifications::Client).to have_received(:new).with("test-key", nil)
    end
  end

  context "with the actual locked Notify client" do
    let(:http) { instance_double(Net::HTTP) }
    let(:http_response) { instance_double(Net::HTTPCreated, body: '{"id":"fixture-notification"}') }

    before do
      allow(Notifications::Client).to receive(:new).and_call_original
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("GOVUK_NOTIFY_API_KEY").and_return(
        "local-00000000-0000-0000-0000-000000000000-00000000-0000-0000-0000-000000000001",
      )
      # Intercept the transport: these tests must never send a network request.
      allow(Net::HTTP).to receive(:start).and_yield(http)
      allow(http).to receive(:request).and_return(http_response)
    end

    it "sends to the original production endpoint when the override is absent" do
      allow(ENV).to receive(:[]).with("GOVUK_NOTIFY_API_URL").and_return(nil)
      lambda_handler(event:, context: nil)
      expect(Net::HTTP).to have_received(:start).with("api.notifications.service.gov.uk", 443, :ENV, use_ssl: true)
    end

    it "sends to the original production endpoint when the override is not a local inbox" do
      allow(ENV).to receive(:[]).with("GOVUK_NOTIFY_API_URL").and_return("https://attacker.example.com")
      lambda_handler(event:, context: nil)
      expect(Net::HTTP).to have_received(:start).with("api.notifications.service.gov.uk", 443, :ENV, use_ssl: true)
    end

    it "sends only to the inbox when overridden" do
      allow(ENV).to receive(:[]).with("GOVUK_NOTIFY_API_URL").and_return("http://identity-inbox:8080")
      result = lambda_handler(event:, context: nil)
      expect(Net::HTTP).to have_received(:start).with("identity-inbox", 8080, :ENV, use_ssl: false)
      expect(http).to have_received(:request) do |request|
        expect(request.path).to eq("/v2/notifications/email")
        expect(JSON.parse(request.body).dig("personalisation", "auth_code")).to eq(generated_code(result))
      end
    end
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
