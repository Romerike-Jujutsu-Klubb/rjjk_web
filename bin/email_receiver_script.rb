#!/usr/bin/env ruby

require_relative '../config/environment'
RawIncomingEmail.create content: $stdin.read

# content = $stdin.read
# mail = Mail.read_from_string(content)
# from = mail.from.first
# to = mail.to.first
#
# if mail.multipart?
#   part = mail.parts.select { |p| p.content_type =~ /text\/plain/ }.first rescue nil
#   unless part.nil?
#     message = part.body.decoded
#   end
# else
#   message = part.body.decoded
# end
# RawIncomingEmail.create(content: content) unless message.nil?
