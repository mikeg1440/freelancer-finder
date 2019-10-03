

class JobFinder::Scraper

  attr_accessor :doc, :base_url

  def initialize(url = "https://www.freelancer.com/jobs/")
    @base_url = url
    @doc = open_from_url
    scrape_data(@doc)
    self
  end

  def open_from_url
    Nokogiri::HTML(open(@base_url))
  end

  def scrape_data(document)

    listings = document.css(".JobSearchCard-item")

    listings.each do |listing|

      info = {}

      info[:title] = listing.css(".JobSearchCard-primary-heading a").text.strip
      info[:time_left] = listing.css(".JobSearchCard-primary-heading-days").text
      info[:short_description] = listing.css(".JobSearchCard-primary-description").text.strip

      info[:tags] = listing.css(".JobSearchCard-primary-tags").text.split("\n").map {|tag| tag.strip }  # remove blank entries at some point
      price_string = listing.css(".JobSearchCard-primary-price").text.strip
      info[:price] = price_string.match(/\$\d+/)
      info[:url] = listing.css(".JobSearchCard-primary-heading-link")[0]['href']

      # next create the job instances from the data we just scraped

      JobFinder::Job.new(info)

    end

  end

  def scrape_details

    binding.pry

  end


end
