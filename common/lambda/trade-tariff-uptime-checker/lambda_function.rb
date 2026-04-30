require 'json'
require 'net/http'
require 'uri'
require 'aws-sdk-cloudwatch'

CLOUDWATCH_NAMESPACE = 'TradeTariff/Uptime'

def lambda_handler(event:, context:)
  endpoints = JSON.parse(ENV.fetch('MONITORED_URLS'))
  cloudwatch = Aws::CloudWatch::Client.new

  endpoints.each do |endpoint|
    name = endpoint.fetch('name')
    url  = endpoint.fetch('url')

    available, response_time_ms = probe(url)

    cloudwatch.put_metric_data(
      namespace: CLOUDWATCH_NAMESPACE,
      metric_data: [
        {
          metric_name: 'Availability',
          dimensions: [{ name: 'Endpoint', value: name }],
          value: available ? 1.0 : 0.0,
          unit: 'Count'
        },
        {
          metric_name: 'ResponseTime',
          dimensions: [{ name: 'Endpoint', value: name }],
          value: response_time_ms.to_f,
          unit: 'Milliseconds'
        }
      ]
    )

    puts "#{name}: available=#{available} response_time=#{response_time_ms}ms"
  end
end

def probe(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl     = uri.scheme == 'https'
  http.open_timeout = 10
  http.read_timeout = 15

  started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  response   = http.get(uri.request_uri)
  elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round

  available = response.code.to_i < 500
  [available, elapsed_ms]
rescue => e
  elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round
  puts "Probe failed for #{url}: #{e.class} #{e.message}"
  [false, elapsed_ms]
end
