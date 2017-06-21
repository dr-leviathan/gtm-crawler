require 'mechanize'

class GTM_Crawler
	def initialize()
		print "Enter the domain you'd like to crawl: "
		domain = gets.chomp
		@domain = domain.to_s
		@domaintld = @domain.match(/\.([a-z]+)$/i).captures[0]
		@base_url = "http://" + domain
		@agent = Mechanize.new
		@visited = Hash.new
	end

	def do_crawl
		crawl(@base_url)
		return @visited
	end

	def crawl(url)
		# request url, ignore errored pages
		begin
 			page = @agent.get(url)
		rescue Exception => e
			return
		end

		# add absolute path to visited
		@visited[url] = page.search('/html/head/script').text.strip.include? "gtm.start"

		# recursively crawl all
		page.links.each do |link|
			s = link.href.to_s || ""
			unless s.empty? || (s.include?("http") && !s.include?(@domain)) || (s =~ /mailto|javascript:/)
				if s.include?(@domain)
					 @base_url = s.match(/(.+#{@domaintld})/i).captures[0]
					 s = s.match(/#{@domaintld}(.+)/i).nil? ? @base_url + "/" : @base_url + s.match(/com(.+)/i).captures[0]
				else
					s = @base_url + s
				end
				if @visited[s].nil? then crawl(s) end
			end
		end
	end
end

crawler = GTM_Crawler.new()
results = crawler.do_crawl

puts ""
puts ""
puts "ALL OF THE BELOW URLS DO NOT HAVE GTM TRACKING CODES:"

results.each do |k, v|
	if v == false
		puts k
	end
end
