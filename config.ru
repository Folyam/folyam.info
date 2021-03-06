require 'bundler/setup'
require 'sinatra/base'
require 'rack/rewrite'
require 'rack-cache'

use Rack::Static,
  :urls => ["/assets", "/images", "/javascripts", "/stylesheets", "/media" ],
  :root => 'public',
  :cache_control => 'public, max-age=2592000'
use Rack::Deflater

# The project root directory
$root = ::File.dirname(__FILE__)

use Rack::Rewrite do
  r301 %r{^/[a-z]+/([0-9]{4})/([0-9]{2})/([0-9]{2})/(.*)$}, '/$1/$2/$3/$4'
end

class SinatraStaticServer < Sinatra::Base

  before do
    expires 3600, :public, :must_revalidate
  end

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  not_found do
    send_sinatra_file('404.html') {"Sorry, I cannot find #{request.path}"}
  end

  def send_sinatra_file(path, &missing_file_block)
    file_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i
    File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  end

end

run SinatraStaticServer
