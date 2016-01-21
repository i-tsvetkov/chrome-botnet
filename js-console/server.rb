require 'webrick'
require 'webrick/https'
require 'openssl'
require 'uri'

cert = OpenSSL::X509::Certificate.new File.read 'cert.pem'
pkey = OpenSSL::PKey::RSA.new File.read 'pkey.pem'

server = WEBrick::HTTPServer.new(:Port => 8000,
                                 :SSLEnable => true,
                                 :SSLCertificate => cert,
                                 :SSLPrivateKey => pkey,
                                 :AccessLog => [],
                                 :Logger => WEBrick::Log.new('/dev/null'))

trap 'INT' do server.shutdown end

$jscode = ''
$result_shown = true

def read_cmd
  return sleep 0.1 unless $result_shown
  print ' js > '
  $jscode = readline
  $result_shown = false
end

server.mount_proc '/js' do |req, res|
  res.status = 200
  res['Content-Type'] = 'application/javascript'
  res['Pragma'] = res['Cache-Control'] = 'no-cache'
  res.body = $jscode
end

server.mount_proc '/result' do |req, res|
  $jscode = ''
  puts "->\s#{URI.unescape(req.query['r'])}"
  $result_shown = true
  res.status = 200
  res['Content-Type'] = 'application/javascript'
  res['Pragma'] = res['Cache-Control'] = 'no-cache'
  res.body = ''
end

Thread.new { server.start }

loop do
  read_cmd
end

