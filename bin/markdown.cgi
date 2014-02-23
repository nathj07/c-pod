#!/usr/bin/env ruby
#
# Script to format Markdown as html
# Using https://github.com/markserbol/tocible
#
require 'cgi'
require 'erb'
require 'redcarpet'

cgi = CGI.new('html4')

cgi.out 'text/html' do
    cgi.html do
	cgi.head do
	    cgi.title('C-Pod') +
	    cgi.link(rel: "stylesheet", href: "/assets/cpod.css", type: "text/css") +
            cgi.link(rel: "stylesheet", href: "/assets/tocible.css", type: "text/css") +
            cgi.script(src: "http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js") +
            cgi.script(src: "/assets/jquery.tocible.js")
	end +
	cgi.body do
	    begin
		erb = ERB.new(File.open(cgi.path_translated,"r", &:read))
		text = erb.result(binding)
	    rescue Exception => e
		text = <<-ERROR
                    Error in parsing #{cgi.path_translated}

                    #{e.message} #{e.backtrace.shift}"
                ERROR
	    end
	    rtxt = Redcarpet::Render::HTML.new(:with_toc_data => true)
	    mdtxt = Redcarpet::Markdown.new(rtxt, :fenced_code_blocks => true)
	    out = <<-TOC
	    <div id="section_wrapper" >
                <article>
                #{mdtxt.render(text)}
                </article>
                <nav class="tocible" id="tocible" ></nav>
            </div>
            TOC
            out + cgi.script do
            <<-SCRIPT
                $(document).ready(function(e) {
                $('#section_wrapper').tocible({
                navigation:'#tocible',
                heading:'h2',
                subheading:'h3',
                offset: 10,
                title:'h1'
                });
                });
            SCRIPT
            end
	end
    end
end

# vim: sts=4 sw=4 ts=8
