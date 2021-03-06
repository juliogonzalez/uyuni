require 'net/ssh'
require 'stringio'

def sshcmd(command, host: ENV['SERVER'], user: 'root', ignore_err: false)
  # Execute a command on the remote server
  # Not passing :password uses systems keys for auth
  out = StringIO.new
  err = StringIO.new
  Net::SSH.start(host, user, verify_host_key: :never) do |ssh|
    ssh.exec!(command) do |_chan, str, data|
      out << data if str == :stdout
      err << data if str == :stderr
    end
  end
  # smdba print this warning on stderr. Ignore it. It is not an error
  errstring = err.string.gsub('WARNING: Reserved space for the backup is smaller than available disk space. Adjusting.', '')
  errstring.chomp!

  if !errstring.empty? && !ignore_err
    raise "Execute command failed #{command}: #{err.string}"
  end

  { stdout: out.string, stderr: err.string }
end
