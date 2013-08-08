#!/usr/bin/env ruby
#
# Script to format Markdown as html
#
require 'cgi'
require 'redcarpet'

q = CGI.new

q.out 'text/html' do
    text = File.open(q.path_translated,"r", &:read)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render text
end

# vim: sts=4 sw=4 ts=8
