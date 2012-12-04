#!/usr/bin/env ruby
require 'open-uri'
require 'json'
require 'rubygems'
require 'nokogiri'
url = "http://folkwolf.tumblr.com/api/read/json?num=1&start=0"
posts_total = JSON.parse(open(url).read[21...-2])["posts-total"]
posts = []
posts.length
start_num = 0
url = "http://folkwolf.tumblr.com/api/read/json?num=50&start="
while start_num < posts_total.to_i
	puts "getting posts from #{start_num} to #{start_num + 50} out of #{posts_total}"
	posts.concat JSON.parse(open(url + start_num.to_s).read[21...-2])["posts"]
	start_num = start_num + 50
end
def sanitize(str)
	title = "title: \'#{Nokogiri::HTML(str).text.gsub("'","&#39;").gsub("\n"," ")}\'"
	if title == "title: ''"
		return "title: untitled"
	else
		return title
	end
end
posts.each { |post| 
	type = post["type"]
	if post['slug'] == '' 
		p post
	end
	puts "#{type} #{post['slug']}"
	filedate = Date.parse(post['date-gmt']).to_s
	if !File.exists?("_posts/#{post['date-gmt'][0..9]}-#{post['slug']}.html") 
		file = open("_posts/#{post['date-gmt'][0..9]}-#{post['slug']}.html",'w')
	else 
		puts "not rewriting #{post['date-gmt'][0..9]}-#{post['slug']}.html"
		next
	end
	file.puts "---\nlayout: post"
	
	case type 
	when "regular"
		file.puts sanitize(post["regular-title"])
		file.puts "---"
		file.puts "#{post["regular-body"]}"
		file.puts "<hr>imported from <a href=\"#{post["url"]}\">Tumblr</a>"
	when "link"
		file.puts sanitize(post["link-text"])
		file.puts "---"
		file.puts "#{post["link-description"]}"
		file.puts "<a href=\"#{post["link-url"]}\">#{post["link-text"]}</a>"
		file.puts "<hr>imported from <a href=\"#{post["url"]}\">Tumblr</a>"
	when "quote"
		file.puts sanitize(post["quote-source"])
		file.puts "---"
		file.puts "#{post["quote-text"]}"
		file.puts "<hr>imported from <a href=\"#{post["url"]}\">Tumblr</a>"
	when "photo"
		max_size = post.keys.map{ |k| k.gsub("photo-url-", "").to_i }.max
		url = post["photo-url"] || post["photo-url-#{max_size}"]
		file.puts sanitize(post["photo-caption"])
		file.puts "---"
		file.puts "<img src=\"#{url}\">"
		file.puts "#{post["photo-caption"]}"
		file.puts "<hr>imported from <a href=\"#{post["url"]}\">Tumblr</a>"
	when "video"
		file.puts sanitize(post["video-caption"])
		file.puts "---"
		file.puts "#{post["video-source"]}"
		file.puts "<hr>imported from <a href=\"#{post["url"]}\">Tumblr</a>"
	when "audio"
		file.puts sanitize(post["audio-caption"])
		file.puts "---"
		file.puts "#{post["audio-player"]}"
		file.puts "<hr>imported from <a href=\"#{post["url"]}\">Tumblr</a>"
	when "conversation"
		file.puts sanitize(post["conversation-title"])
		file.puts "---"
		content = "<section><dialog>\n"
          	post["conversation"].each do |line|
			content << "<dt>#{line['label']}</dt>\n<dd>#{line['phrase']}</dd>\n"
          	end
          	content << "</section></dialog>"
		file.puts content
		file.puts "<hr>imported from <a href=\"#{post["url"]}\">Tumblr</a>"
	else 
		p post
	end
	file.close
}
