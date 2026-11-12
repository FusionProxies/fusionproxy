# Fusion Proxy residential proxies with Ruby Net::HTTP.
# export FUSION_USER=... FUSION_PASS=... [FUSION_COUNTRY=us]
require 'json'
require 'net/http'

user = ENV.fetch('FUSION_USER') { abort 'set FUSION_USER and FUSION_PASS' }
pass = ENV.fetch('FUSION_PASS') { abort 'set FUSION_USER and FUSION_PASS' }
country = ENV.fetch('FUSION_COUNTRY', 'us')

def exit_ip(proxy_user, pass)
  uri = URI('https://ipinfo.io/json')
  http = Net::HTTP.new(uri.host, uri.port, 'resi.fusionproxy.net', 12286, proxy_user, pass)
  http.use_ssl = true
  http.read_timeout = 30
  data = JSON.parse(http.get(uri.path).body)
  "#{data['ip']} (#{data['country']}, #{data['city']})"
end

# rotating: a new IP on every request
puts "rotating: #{exit_ip("#{user}-country-#{country}", pass)}"

# sticky: the same session ID keeps the same IP for 10 minutes
sticky = "#{user}-country-#{country}-sessid-#{rand(1_000_000..9_999_999)}-sessTime-600s"
puts "sticky:   #{exit_ip(sticky, pass)}"
puts "sticky:   #{exit_ip(sticky, pass)}"
