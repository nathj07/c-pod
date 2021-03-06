# Simple NAT-PMP client
# See: http://tools.ietf.org/html/rfc6886
#
require 'socket'

class NATPMP
  PMP_VERSION = 0
  DEFAULT_LIFETIME  = 7200
  DELAY_MSEC = 250
  MAX_WAIT_SEC = 64
  SERVER_PORT = 5351
  CLIENT_PORT = 5350

  OPCODE = { addr: 0, udp: 1, tcp: 2 }

  # Return codes
  #
  RETCODE = { success: 0,     # Success
	      unsupported: 1, # Unsupported Version
	      refused: 2,     # Not Authorized/Refused (e.g., box supports mapping, but user has turned feature off)
	      failed: 3,      # Network Failure (e.g., NAT box itself has not obtained a DHCP lease)
	      exhausted: 4,   # Out of resources (NAT box cannot create any more mappings at this time)
	      opnotsupp: 5    # Unsupported opcode
	    }

  # Determine the default gateway
  #
  def self.GW
    return @gw if @gw
    @gw = case RUBY_PLATFORM
    when /darwin/
      routes = `netstat -nrf inet`.split("\n").select{|l| l=~/^default/}
      raise "Can't find default route" unless routes.size > 0
      routes.first.split(/\s+/)[1]
    when /linux/
      routes = `ip route list match 0.0.0.0`.split("\n").select{|l| l =~ /^default/}
      raise "Can't find default route" unless routes.size > 0
      routes.first.split(/\s+/)[2]
    else
      raise "Platform not supported!"
    end
  end

  def self.verbose flag
    @verbose = flag
  end

  def self.verbose?
    return @verbose
  end

  def self.send msg
    sop = msg.unpack("xC").first
    sock = UDPSocket.open
    sock.connect(NATPMP.GW, SERVER_PORT)
    cb = sock.send(msg, 0)
    raise "Couldn't send!" unless cb == msg.size
    delay = DELAY_MSEC/1000.0
    begin
      sleep delay # to give time for the response to arrive!
      (reply, sendinfo) = sock.recvfrom_nonblock(16)
      sender = Addrinfo.new sendinfo
      raise "Being spoofed!" unless sender.ip_address == NATPMP.GW
      (ver,op,res) = reply.unpack("CCn")
      raise "Invalid version #{ver}" unless ver == PMP_VERSION
      raise "Invalid reply opcode #{op}" unless op == 128 + sop
      raise "Request failed (code #{RETCODE.key(res)})" unless res == RETCODE[:success]
      return reply
    rescue IO::WaitReadable
      if delay < MAX_WAIT_SEC
	puts "Retrying after #{delay}..." if NATPMP.verbose?
        delay *= 2
	retry
      end
      raise "Waited too long, got no response"
    rescue Errno::ECONNREFUSED
      raise "Remote NATPMP server not found"
    end
  end

  # Return the externally facing IPv4 address
  #
  def self.addr
    reply = self.send [0, OPCODE[:addr]].pack("CC")
    sssoe = reply.unpack("x4N").first
    addr = reply.unpack("x8CCCC")
    return addr.join('.')
  end

  attr_reader :priv, :pub, :mapped, :maxlife, :life, :type

  def initialize priv, pub, maxlife, type
    @priv = priv
    @pub = pub
    @maxlife = maxlife
    @type = type
    @renew = nil # Renewal thread

    # These are filled in when a request is made
    #
    @life = 0
    @mapped = 0
  end

  # See section 3.3
  def request!
    rsp = NATPMP.send [0, OPCODE[@type], 0, @priv, @pub, @maxlife||DEFAULT_LIFETIME].pack("CCnnnN")
    (sssoe, priv, @mapped, @life) = rsp.unpack("x4NnnN")
    raise "Port mismatch: requested #{@priv} received #{priv}" if @priv != priv
    STDERR.puts "Mapped (at #{sssoe}) #{inspect}" if NATPMP.verbose?
    schedule_renew! if @maxlife.nil?
  end

  # See section 3.4
  def revoke!
    @renew.exit if @renew
    rsp = NATPMP.send [0, OPCODE[@type], 0, @priv, 0, 0].pack("CCnnnN")
    STDERR.puts "Revoked #{inspect}" if NATPMP.verbose?
  end

  def inspect
    "#{NATPMP.GW}:#{@mapped}->#{@type}:#{@priv} (#{@life} sec)"
  end

  def self.map priv, pub, maxlife = DEFAULT_LIFETIME, type = :tcp, &block

    map = NATPMP.new(priv, pub, block_given? ? nil: maxlife, type)
    map.request!
    if block_given?
      begin
	yield map
      ensure
	map.revoke!
        map = nil
      end
    end
    return map

  end

  private

  # As per section 3.3 re-issue the request using the actual mapped port
  def schedule_renew!
    Thread.abort_on_exception = true
    # As per section 3.3 re-issue the request using the actual mapped port
    @renew = Thread.new @life do |life|
      wait_time = life/2
      STDERR.puts "Renewal in #{wait_time} seconds" if NATPMP.verbose?
      sleep wait_time
      rsp = NATPMP.send [0, OPCODE[@type], 0, @priv, @mapped, @life].pack("CCnnnN")
      (sssoe, priv, @mapped, @life) = rsp.unpack("x4NnnN")
      STDERR.puts "Renewed (at #{sssoe}) #{inspect}" if NATPMP.verbose?
      schedule_renew!
    end
  end

end
