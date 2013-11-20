#!/usr/bin/env ruby
#
# Script to format Markdown as html
#
require 'cgi'
require 'erb'
require 'redcarpet'

cgi = CGI.new('html4')

cgi.out 'text/html' do
    cgi.html do
	cgi.head do
#	    cgi.title 'C-Pod'
	    cgi.link(rel: "stylesheet", href: "/css/cpod.css", type: "text/css")
	end +
	cgi.body do
	    begin
		erb = ERB.new(File.open(cgi.path_translated,"r", &:read))
		text = erb.result(binding)
	    rescue Exception => e
		text = "Error in parsing #{cgi.path_translated}\n\n    #{e.message} #{e.backtrace.shift}"
	    end
	    rtoc = Redcarpet::Render::HTML_TOC.new()
	    mdtoc = Redcarpet::Markdown.new(rtoc)
	    rtxt = Redcarpet::Render::HTML.new(:with_toc_data => true)
	    mdtxt = Redcarpet::Markdown.new(rtxt, :fenced_code_blocks => true)
	    mdtoc.render(text)+ mdtxt.render(text)
	end
    end
end

# vim: sts=4 sw=4 ts=8
