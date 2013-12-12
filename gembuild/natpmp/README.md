# Ruby Gem for NAT-PMP

This is a client implementation of [NAT-PMP](http://tools.ietf.org/html/rfc6886)

For a server implementation suitable for Linux see [Stallone](https://github.com/tedjp/stallone)

Upon request NAT-PMP can open either a UDP or TCP port on the gateway and bidirectionally relay traffic to a specific external server.

## Usage
The GEM includes a command-line utility as well as Ruby classes and can be used in several ways

### To open a mapping from the command line
To open a mapping on specific ports use:

    natpmp -p 1234

This command will hold the port open for the requested time, whereafter it _may_ be closed. To extend the mapping simply re-open it using the same port number.

### To run a command with a mapping
To run a command with specific port mappings:

    natpmp -p 1234 'echo using the mapping && sleep 5'

The mapping will be held open until the command completes. The command string may contain the tokens %H, %P, %h and %p which will be substituted for the remote (uppercase) and local (lowercase) host (h) and ports (p). The ports can be automatically assigned by the command.

### Example Ruby Code
To open a port and run code using it:
    
    require 'natpmp'
    NATPMP.map 633, 13033, 10, :tcp do |map|
      ... # the mapping will be renewed until this exits
    end

### Command Line Utility
The command line utility has the following options:

    usage: natpmp [options] [command]
    Open a port on a NAT-PMP gateway. Options:
        -t, --type TYPE                  Type: tcp, udp (default: tcp)
        -p, --port PORT                  Private port (default: auto)
            --ttl TIME                   TTL if no command (default 7200 sec)
        -P, --public PUBPORT             External port (default: auto)
        -v, --verbose                    Verbose
            --version                    Version
    In the command string the following substitutions will be made:
      %p the local port
      %h the local IP address
      %P the gateway port
      %H the gateway IP address
    (Use %% to avoid this)
    The mapping will be closed on completion of the command
        -?, --help                       Display this screen
