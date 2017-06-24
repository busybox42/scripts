#!/usr/bin/ruby
require 'rubygems'
require 'optparse'
require 'net/smtp'
require 'net/pop'
require 'net/imap'

# Lets make some options yo!
options = {}

OptionParser.new do |opts|
    opts.banner = "Usage: mail_service_tester.rb [options]"

    opts.on("-f", "--from [ADDRESS]", "Specify from address") { |v| options[:source_from] = v}
    opts.on("-t", "--to [ADDRESS]", "Specify to address") { |v| options[:source_to] = v}
    opts.on("-h", "--host [ADDRESS]", "Specify host address") { |v| options[:source_host] = v}
    opts.on("-a", "--auth [USER NAME]", "Specify username to authenticate as.") { |v| options[:source_user] = v}
    opts.on("-p", "--pass [PASSWORD]", "Specify password to authenticate with.") { |v| options[:source_pass] = v}
    opts.on("-c", "--check [pop|smtp|imap|all]", "Specify type of mail test.") { |v| options[:source_check] = v}
    opts.on("-S", "--security [ssl|tls]", "Specify type of mail test.") { |v| options[:source_security] = v}

end.parse!

# Make some variables.
from=options[:source_from]
to=options[:source_to]
check=options[:source_check]
security=options[:source_security]

# Message Contents
msgstr = <<END_OF_MESSAGE
From: #{from}
To: #{to}
Subject: Test

This is a test message.
END_OF_MESSAGE

# Let's run a check!
puts "#{check} running!"
if check == "smtp"
    puts "Sending email!"
    puts "--------------"
    if !options[:source_user]
        Net::SMTP.start(options[:source_host], 25) do |smtp|
            if security == "tls"
                smtp.enable_starttls
            elsif security == "ssl"
                smtp.enable_ssl
            end
            smtp.send_message msgstr, options[:source_from], options[:source_to]
        end
    else
        Net::SMTP.start(options[:source_host], 25, 'Synacor Test Script',
                       options[:source_user], options[:source_pass], :login) do |smtp|
            if security == "tls"
                smtp.enable_starttls
            elsif security == "ssl"
                smtp.enable_ssl
            end
            smtp.send_message msgstr, options[:source_from], options[:source_to]
        end
    end
elsif check == "pop"
    puts "Checking POP3"
    puts "-------------"
    Net::POP3.start(options[:source_host], 110,
                    options[:source_user], options[:source_pass]) do |pop|
        if pop.mails.empty?
            puts 'No mail.'
        else
            i = 0
            pop.each_mail do |m|
                i += 1
            end
            puts "#{pop.mails.size} message in inbox."
        end
    end
elsif check == "imap" 
    puts "Checking IMAP"
    puts "-------------"
    imap = Net::IMAP.new(options[:source_host])
    imap.authenticate('LOGIN', options[:source_user], options[:source_pass])
    imap.examine('INBOX')
    imap.search(["RECENT"]).each do |message_id|
        envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
        puts "#{envelope.from[0].mailbox}@#{envelope.from[0].host}: \t#{envelope.subject}"
    end
elsif check == "all"
    puts "Sending email!"
    puts "--------------"
    if !options[:source_user]
        Net::SMTP.start(options[:source_host], 25) do |smtp|
            smtp.send_message msgstr, options[:source_from], options[:source_to]
        end
    else
        Net::SMTP.start(options[:source_host], 587, 'Synacor Test Script',
                       options[:source_user], options[:source_pass], :login) do |smtp|
            smtp.send_message msgstr, options[:source_from], options[:source_to]
        end
    end
    sleep 2
    puts""
    puts "Checking POP3"
    puts "-------------"
    Net::POP3.start(options[:source_host], 110,
                    options[:source_user], options[:source_pass]) do |pop|
        if pop.mails.empty?
            puts 'No mail.'
        else
            i = 0
            pop.each_mail do |m|
                i += 1
            end
            puts "#{pop.mails.size} message in inbox."
        end
    end
    puts ""
    puts "Checking IMAP"
    puts "-------------"
    imap = Net::IMAP.new(options[:source_host])
    imap.authenticate('LOGIN', options[:source_user], options[:source_pass])
    imap.examine('INBOX')
    imap.search(["RECENT"]).each do |message_id|
        envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
        puts "#{envelope.from[0].mailbox}@#{envelope.from[0].host}: \t#{envelope.subject}"
    end
else
    puts "Please specify a check to run."    
end
