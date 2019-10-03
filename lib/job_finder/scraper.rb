

class JobFinder::Scraper

  attr_accessor :doc, :base_url

  def initialize(url = "https://www.freelancer.com/jobs/")
    @base_url = url
    @doc = open_from_url(@base_url)
    scrape_data(@doc)
    self
  end

  def open_from_url(url)
    Nokogiri::HTML(open(url))
  end

  def scrape_data(document)

    listings = document.css(".JobSearchCard-item")

    listings.each do |listing|

      info = {}

      info[:title] = listing.css(".JobSearchCard-primary-heading a").text.strip
      info[:time_left] = listing.css(".JobSearchCard-primary-heading-days").text
      info[:short_description] = listing.css(".JobSearchCard-primary-description").text.strip

      info[:tags] = listing.css(".JobSearchCard-primary-tags").text.split("\n").map {|tag| tag.gsub(" ","") unless tag.empty? }
      info[:tags] = info[:tags].compact
      price_string = listing.css(".JobSearchCard-primary-price").text.strip
      info[:price] = price_string.match(/\$\d+/)
      info[:url] = listing.css(".JobSearchCard-primary-heading-link")[0]['href']

      # next create the job instances from the data we just scraped

      JobFinder::Job.new(info)

    end

  end

  def scrape_details(job_listing)

    new_url = @base_url[0..-7] + job_listing.url

    doc = open_from_url(new_url)

    job_listing.description = doc.css(".Card-body")[0].text.split.join(" ") unless doc.css(".Card-body").class == nil

    job_listing.bids = doc.css(".Card-header").text.split("\n")[3].strip unless doc.css(".Card-header").class == nil

    binding.pry

  end


end
