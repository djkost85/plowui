require 'simple_http'
require 'xmlrpc/client'

require_relative '../cookie_jar.rb'

# Provides access to an aria2c instance running with RPC enabled.
class Receiver::Aria < Receiver::Base

  # Accepted options are:
  # :user => the user name for authentication with the server
  # :password => the password for authentication with the server
  # :port => The port to connect to
  # :host => The host to connect to
  def initialize(opts = {})
    super("Aria2")
    default_opts = {
      :port => 6800,
      :host => "localhost"
    }
    opts = default_opts.merge(opts)
    @address = "#{opts[:host]}:#{opts[:port]}"
    @server = XMLRPC::Client.new(opts[:host], "/rpc", opts[:port],
        nil, nil, opts[:user], opts[:password])
    @cookie_jar = CookieJar.new
  end

  # Performs a version request to test if aria is online.
  def online?
    @server.call("aria2.getVersion")
    return true
  rescue
    return false
  end

  # Adds the given link to the server and starts it.
  # Will download to the given filename. If it is nil, downloads to
  # the default filename chosen by aria2.
  # If cookies is not nil, treats the given array of strings as cookie
  # definitons of the form name=value and sends them to aria2.
  #
  # C.f. http://sourceforge.net/apps/phpbb/aria2/viewtopic.php?f=2&t=63
  def handle(link, file_name = nil, cookies = nil)
    opts = {}

    if file_name
      opts.merge!('out' => file_name)
    end

    if cookies
      cookies = @cookie_jar.to_headers(cookies)
      cookies = "Cookie: " + cookies.join("; ")
      opts.merge!('header' => cookies)
    end

    @server.call("aria2.addUri", [link], opts)
    return true
  rescue Errno::ECONNREFUSED => e
    $log.error("could not connnect to aria2 at #{@address}")
    return false
  rescue XMLRPC::FaultException => e
    $log.error("error while communicating with aria2: #{e.faultString}")
    return false
  end

end

