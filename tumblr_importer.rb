#!/usr/bin/env ruby
require 'open-uri'
require 'json'
url = "http://folkwolf.tumblr.com/api/read/json"
json = JSON.parse(open(url).read[21...-2])
posts = json["posts"]

posts.each { |post| 
	type = post["type"]
	puts "#{type} #{post['slug']}"
	filedate = Date.parse(post['date-gmt']).to_s
	file = open("_posts/tumblr/#{post['date-gmt'][0..9]}-#{post['slug']}.html",'w')
	file.puts "---\nlayout: post"
	
	case type 
	when "regular"
		file.puts "title: #{post["regular-title"]}"
		file.puts "---"
		file.puts "#{post["regular-body"]}"
	when "link"
		file.puts "title: #{post["link-description"]}"
		file.puts "---"
		file.puts "<a href=\"#{post["link-url"]}\">#{post["link-text"]}</a>"
	when "quote"
		file.puts "title: #{post["quote-source"]}"
		file.puts "---"
		file.puts "#{post["quote-text"]}"
	when "photo"
		max_size = post.keys.map{ |k| k.gsub("photo-url-", "").to_i }.max
		url = post["photo-url"] || post["photo-url-#{max_size}"]
		file.puts "title: #{post["photo-caption"]}"
		file.puts "---"
		file.puts url
	when "video"
		file.puts "title: #{post["video-caption"]}"
		file.puts "---"
		file.puts "#{post["video-source"]}"
	when "audio"
		file.puts "title: #{post["audio-caption"]}"
		file.puts "---"
		file.puts "#{post["audio-player"]}"
	else 
		p post
	end
	file.close
}
