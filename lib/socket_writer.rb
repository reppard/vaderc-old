class Command
  attr_accessor :line, :socket, :payload
  CONFIG = YAML.load_file("commands.yaml")
  def initialize line, socket
    @line = line.chomp
    @socket = socket
    @payload = is_command? ? process_command : @line
  end

  def is_command?
    @line[0] == "/" && CONFIG.has_key?(stripped_cmd)
  end

  def process_command
    cmd_alias, *body = @line.split(' ')
    "#{CONFIG[stripped_cmd]['command']} #{body.join(' ')}"
  end

  def stripped_cmd
    @line.split(' ').first.gsub(/^\//,'').upcase
  end
end

class SocketWriter
  attr_reader :input_stream

  def initialize socket, window
    @socket = socket
    @window = window
    @input_stream = Thread.new{ read_from_client }
  end

  def read_from_client
    loop do
      line = @window.inputSpace.getstr
      msg = Command.new(line, @socket)
      @socket.sendmsg("#{msg.payload}\r\n",0)
      @window.inputSpace.clear
      @window.mainContent.refresh
    end
  end

end

