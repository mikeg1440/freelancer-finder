

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
      info[:base_url] = @base_url.match(/http(s)*:\/\/(www\.)*([a-zA-Z0-9\-])+(\.\w+){1,2}/)[0]
      info[:tags] = listing.css(".JobSearchCard-primary-tags").text.split("\n").map {|tag| tag.strip unless tag.strip.empty? }
      info[:tags] = info[:tags].compact
      price_string = listing.css(".JobSearchCard-primary-price").text.strip
      price_match = price_string.scan(/\$\d+/)

      if price_string.include?("Avg") && price_match.count > 1
        # price_match = price_string.gsub("\n","").scan(/(\$\d+).+(Avg Bid)/)
        info[:avg_bid] = price_match.join(" - ")
        binding.pry if info[:avg_bid].scan(/\d+/).count > 1
      elsif price_string.include?("-") && price_string.include?("hr")
        info[:budget] = "#{price_match.join(' - ')} / hr"
        info[:budget_range] = info[:budget].scan(/\d+/)
      elsif price_string.include?("hr") && price_match.count == 1
        info[:avg_bid] = "#{price_match[0]} / hr"
      elsif price_string.include?("-")
        info[:budget_range] = price_string.split(" - ")
      else
        info[:avg_bid] = price_string.match(/\$\d+/)[0] if price_string.match(/\$\d+/)
      end
      # info[:price] = price_string.match(/\$\d+/)
      info[:url] = listing.css(".JobSearchCard-primary-heading-link")[0]['href']

      # binding.pry if !info[:budget]

      # next create the job instances from the data we just scraped

      JobFinder::Job.new(info)

    end

  end

  def scrape_details(job_listing)

    doc = open_from_url(job_listing.full_url)

    binding.pry

    if doc.css(".PageProjectViewLogout-header-byLine").text.match(/\$[\d]+ ?- ?\$?\d+.*/)
      job_listing.budget = doc.css(".PageProjectViewLogout-header-byLine").text.match(/\$[\d]+ ?- ?\$?\d+.*/)[0]
      job_listing.budget_range = job_listing.budget.scan(/(\d+)/)
    end

    if doc.css(".Card-body").class == nil
      job_listing.description = doc.css(".Card-body")[0].text.split.join(" ")
    end

    if doc.css(".Card-header").class == nil
      job_listing.bids = doc.css(".Card-header").text.split("\n")[3].strip
    end

    binding.pry

  end


end
