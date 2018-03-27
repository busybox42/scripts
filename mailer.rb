#!/usr/bin/ruby

require 'mail'
require 'net/smtp'
require 'optparse'
require 'parallel'
require 'logger'

# Default options
user = nil
host = '127.0.0.1'
port = 25
text = 'message.txt'
html = 'message.html'
list =  nil
frm  = 'postmaster@evil-admin.com'
frnm = frm.split("@")[0]
helo = frm.split("@")[1]
sbj  = 'This Is A Test'
thrd = 1
tls  = false
usr  = nil
pass = nil
rdm  = nil
auth = 'login'
log  = '/tmp/mailer.log'
head = Array.new
att  = Array.new

# Arguements
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: mailer.rb [options]"
  opts.separator ""
  opts.on("-t", "--to user@domain.tld", "Email address to send to.", String) { |val| user = val }
  opts.on("-l", "--list list.txt", "List of Email address to send to.", String) { |val| list = val }
  opts.on("-f", "--from user@domain.tld", "Email address to send as. Default: #{frm}", String) { |val| frm = val }
  opts.on("-n", "--name 'Name'", "Sender's name  Default: '#{frnm}'", String) { |val| frnm = val }
  opts.on("-s", "--subject 'Subject Text'", "Subject header of the email. Default: '#{sbj}'", String) { |val| sbj = val }
  opts.on("-x", "--text message.txt", "Text message to send. Default: #{text}", String) { |val| text = val }
  opts.on("-w", "--html message.html", "HTML message to send. Default: #{html}", String) { |val| html = val }
  opts.on("-H", "--host smtp.hostname.tld", "SMTP host to send. Default: #{host}", String) { |val| host = val }
  opts.on("-p", "--port smtp port", "SMTP port to connect to. Default: #{port}", Integer) { |val| port = val }
  opts.on("-A", "--auth (plain|login)", "SMTP authentication type. Default: #{auth}", String) { |val| pass = val }
  opts.on("-T", "--threads #", "Number of parallel threads. Default: #{thrd}", Integer) { |val| thrd = val }
  opts.on("-g", "--log file.log", "Write to log a file. Default: #{log}", String) { |val| log = val }
  opts.on("-U", "--user username", "SMTP auth username", String) { |val| usr = val }
  opts.on("-P", "--pass username", "SMTP auth password", String) { |val| pass = val }
  opts.on("-o", "--helo host.domain.tld", "HELO string, ussually a hostname", String) { |val| helo = val }
  opts.on("-d", "--header X-Header1 Value", "Comma seperated additional headers", Array) { |val| head = val } 
  opts.on("-a", "--attach /path/to/file1.ext", "Comma seperated attachments", Array) { |val| att = val } 
  opts.on("-r", "--random /path/to/messages", "Directory of random html and text messages.  This is typically used to load test a mail system.", String) { |val| rdm = val }
  opts.on("-L", "--tls", "Enable STARTTLS.") do
    tls = true
  end
  opts.on("-h", "--help", "Usage options.") do
    puts opts
    exit
  end
  begin opts.parse! ARGV
  rescue => e
      puts e
      puts opts
      exit
  end
  opts.parse!
end

# Logger
begin
  logger = Logger.new(STDOUT)
  logger = Logger.new(log)
  logger.level = Logger::INFO
  #logger.level = Logger::DEBUG
rescue => e
  puts "Error: #{e.message}"
  exit
end

# Catch ctrl-c
trap "SIGINT" do
  puts "\nUser Exited Early!"
  exit 130
end

# Host defaults to send
if usr == nil && pass == nil
  Mail.defaults do
    delivery_method :smtp, {
      :address              => host,
      :port                 => port,
      :domain               => helo,
      :enable_starttls_auto => tls
    }
  end
  logger.debug("Mail Defaults: SMTP Host - #{host} SMTP Port - #{port} TLS Enabled - #{tls}")
else
  if usr == nil
    puts "Password set without a username."
    logger.debug("Password set without a username.")
    exit
  end
  if pass == nil
    puts "Username set without a passord."
    logger.debug("Username set without a passord.")
    exit
  end
  Mail.defaults do
    delivery_method :smtp, {
      :address              => host,
      :port                 => port,
      :user_name            => usr,
      :password             => pass,
      :authentication       => auth,
      :domain               => helo,
      :enable_starttls_auto => tls
    }
  end
  logger.debug("Mail Defaults: SMTP Host - #{host} SMTP Port - #{port} Auth User - #{usr} Password - #{pass} Auth Type - #{auth} TLS Enabled - #{tls}")
end

# Message files
begin
  if rdm == nil
    msgstr  = File.read(text)
    msghtml = File.read(html)
  else
    puts "Random message directory: #{rdm}"
    logger.info("Random message directory: #{rdm}")
    tf = Dir["#{rdm}/*.txt"]
    hf = Dir["#{rdm}/*.html"]
    tf.concat hf
    files = tf + hf
    if files.empty?
      puts "No files found to send."
      logger.error("No files found to send.")
      exit
    end
  end
  rescue => e
    puts "Error: #{e.message}"
    logger.error("#{e.message.chomp}")
    logger.debug("Text File: #{text.chomp} HTML File: #{html.chomp}")
    exit
end

# Set from name if not set
if frnm == nil
  frnm = frm[/[^@]+/]
  logger.debug("From name left empty. Using localpart '#{frnm.chomp}' instead.")
end

# Create Array of recipients
rcpt = Array.new
if list != nil
  rcpt = IO.readlines(list)
  logger.debug("Reading in list file #{list.chomp} into recipient array.")
end
if user != nil
  rcpt << user
  logger.debug("Adding user #{user.chomp} into recipient array.")
end
if rcpt.empty?
  puts "No recpients defined!"
  logger.error("No recpients defined!")
  exit
end

# Setup threading
puts "Begin processing send queue."
logger.info("Begin processing send queue.")
Parallel.each(rcpt, in_threads: thrd) do |user|
  time = Time.new
  localpart = user[/[^@]+/]
  lprcpt = "#{localpart.chomp} <#{user.chomp}>"
  lpfrm = "#{frnm.chomp} <#{frm.chomp}>"
  logger.debug("Beginning SMTP send from '#{lpfrm}' to '#{lprcpt.chomp}' with subject '#{sbj.chomp}'.")
  # Are we sending random emails?
  if rdm != nil
    mess = files.sample.split('.')[0]
    # I don't know how I want to handle random message subjects yet.
    msgstr = ""
    msghtml = ""
    t = ""
    if File.exists?("#{mess}.html")
      t = File.open("#{mess}.html").grep(/title/)
    end
    if !t.empty?
      sbj = t.to_s.gsub(/^.+?(<[^>]*>)|(<[^>]*>).+?$/, '')
    else
      s = mess.to_s.gsub('_', ' ')
      sbj = s.to_s.gsub(/.*\//, '')
    end
    if File.exists?("#{mess}.txt")
      msgstr = File.read("#{mess}.txt")
    end
    if File.exists?("#{mess}.html")
      msghtml = File.read("#{mess}.html")
    end
  end
  # Send email.
  begin
    mail = Mail.deliver do
      to      lprcpt
      from    lpfrm
      subject sbj
      date    time.inspect
      header['X-Mailer'] = 'Evil Mailer'
      if !head.empty?
        head.each do |hd|
          header["#{hd.split[0]}"] = "#{hd.split[1]}"
        end
      end
      if !msgstr.empty?
        text_part do
          body msgstr
        end
      end
      if !msghtml.empty?
        html_part do
          content_type 'text/html; charset=UTF-8'
          body msghtml
        end
      end
      if !att.empty?
        att.each do |a|
          add_file "#{a}"
        end
      end
    end
    rescue => e
      puts "Unable send from #{frm.chomp} to #{user.chomp} - Error: \"#{e.message.chomp}\""
      logger.error("Unable send from #{frm.chomp} to #{user.chomp} - Error: \"#{e.message.chomp}\"")
    else
      puts "Message sent from #{frm.chomp} to #{user.chomp} - Subject: \"#{sbj.chomp}\""
      logger.info("Message sent from #{frm.chomp} to #{user.chomp} - Subject: \"#{sbj.chomp}\"")
  end
end

# End
puts "Send queue finished."
logger.info("Send queue finished.")
