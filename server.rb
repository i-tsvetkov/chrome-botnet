require 'webrick'
require 'webrick/https'
require 'openssl'

cert = OpenSSL::X509::Certificate.new File.read 'cert.pem'
pkey = OpenSSL::PKey::RSA.new File.read 'pkey.pem'

server = WEBrick::HTTPServer.new(:Port => 8000,
                                 :SSLEnable => true,
                                 :SSLCertificate => cert,
                                 :SSLPrivateKey => pkey)

trap 'INT' do server.shutdown end

server.mount_proc '/js' do |req, res|
  res.status = 200
  res['Content-Type'] = 'application/javascript'
  res['Pragma'] = res['Cache-Control'] = 'no-cache'
  res.body = 'alert("botnet!");'
end

server.start

