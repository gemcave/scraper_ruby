require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper
	url = "https://hh.kz/search/vacancy?area=159&st=searchVacancy&text=react"
	unparsed_page = HTTParty.get(url)
	parsed_page = Nokogiri::HTML(unparsed_page)

	jobs = Array.new
	job_listings = parsed_page.css('div.vacancy-serp-item') # 20 jobs per page
	page = 1
	
	per_page = job_listings.count
	total = parsed_page.css('h1.header').text.split(/[[:space:]]/)[0].to_i
	last_page = (total.to_f / per_page.to_f).round
	
	while	page <= last_page
		if page > 1
			pagination_url = "https://hh.kz/search/vacancy?area=159&st=searchVacancy&text=react&page=#{page-1}"
		else
			pagination_url = "https://hh.kz/search/vacancy?area=159&st=searchVacancy&text=react"
		end

		puts pagination_url
		puts "Page: #{page}\n"
		pagination_unparsed_page = HTTParty.get(pagination_url)
		pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
		pagination_job_listings = pagination_parsed_page.css('div.vacancy-serp-item') # 20 jobs per page

		pagination_job_listings.each do |job_listing|
			job = {
				title: job_listing.css('a.HH-LinkModifier').text,
				company: job_listing.css('a.HH-AnonymousIndexAnalytics-Recommended-Company').text,			
			}	
			jobs << job
			puts "Added #{job[:title]}"
			puts ""
		end
		page += 1
	end
	# byebug
	# p jobs
end

scraper