

class FreelancerFinder::Scraper

  attr_accessor :doc, :base_url

  def initialize(url = "https://www.freelancer.com/jobs/")
    @base_url = url
    scrape_data_from_url(url)
    self
  end

  def scrape_data_from_url(url)
    doc = open_from_url(url)
    scrape_data(doc)
  end

  def open_from_url(url)
    Nokogiri::HTML(open(url))
  end

  # scrapes the initial info from the main listing pages
  def scrape_data(document)

    listings = document.css(".JobSearchCard-item")

    listings.each do |listing|

      info = {}

      info[:title] = scrape_title(listing)
      info[:time_left] = scrape_time_left(listing)
      info[:short_description] = scrape_short_description(listing)
      info[:base_url] = scrape_listing_url(listing)
      info[:base_url] = @base_url.match(/http(s)*:\/\/(www\.)*([a-zA-Z0-9\-])+(\.\w+){1,2}/)[0]
      info[:url] = scrape_listing_url(listing)
      info[:tags] = scrape_tags(listing)

      bid_info = scrape_bid_info(listing)

      info.merge!(bid_info)


      FreelancerFinder::Job.new(info) unless FreelancerFinder::Job.all.detect {|job| job.url == info[:url]}      # next create a job instance from the data we just scraped unless it exists already


    end

  end

  def scrape_title(listing)
    listing.css(".JobSearchCard-primary-heading a").text.strip
  end

  def scrape_time_left(listing)
    listing.css(".JobSearchCard-primary-heading-days").text
  end

  def scrape_short_description(listing)
    listing.css(".JobSearchCard-primary-description").text.strip
  end

  def scrape_tags(listing)
    info = {}
    info[:tags] = listing.css(".JobSearchCard-primary-tags").text.split("\n").map {|tag| tag.strip unless tag.strip.empty? }

    info[:tags] = info[:tags].compact
    info[:tags]
  end

  def scrape_bid_info(listing)
    price_string = listing.css(".JobSearchCard-primary-price").text.strip
    price_match = price_string.scan(/[\$€₹]\d+/)

    info = {}

    # this if then else statement filters the text depending on the type of data
    if price_string.include?("Avg") && price_match.count > 1        # if the string contains Avg and has more than 1 number group then we have a Ave Bid range
      # price_match = price_string.gsub("\n","").scan(/(\$\d+).+(Avg Bid)/)
      info[:avg_bid] = price_match.join(" - ")
    elsif price_string.include?("-") && price_string.include?("hr")   # if the string includes a dash("-") and also includes the chars "hr" then we have a range for hourly rate
      info[:budget] = "#{price_match.join(' - ')} / hr"
      info[:budget_range] = info[:budget].scan(/\d+/)
    elsif price_string.include?("hr") && price_match.count == 1       # if string includes chars "hr" and only one number then its a single hourly rate
      info[:avg_bid] = "#{price_match[0]} / hr"
    elsif price_string.include?("-")                                  # if the string only includes a dash and no "Avg" then it is a budget range
      info[:budget_range] = price_string.split(" - ")
    else
      info[:avg_bid] = price_string.match(/[\$€₹]\d+/)[0] if price_string.match(/[\$€₹]\d+/)      # if also else are false then it should just be a single Avg bid number to store
    end

    info
  end

  def scrape_listing_url(listing)
    listing.css(".JobSearchCard-primary-heading-link")[0]['href']
  end

  # this method scrapes the details from the individual listing pages after user chooses what listing they want to view
  def scrape_details(job_listing)

    listing_doc = open_from_url(job_listing.full_url)

    scrape_budget(listing_doc, job_listing)

    scrape_description(listing_doc, job_listing)

    scrape_bids(listing_doc, job_listing)

  end

  private

  def scrape_budget(listing_doc, job_listing)
    if listing_doc.css(".PageProjectViewLogout-header-byLine").text.match(/[\$€₹][\d]+ ?- ?[\$€₹]?\d+.*/)
      job_listing.budget = listing_doc.css(".PageProjectViewLogout-header-byLine").text.match(/[\$€₹][\d]+ ?- ?[\$€₹]?\d+.*/)[0]
      job_listing.budget_range = job_listing.budget.scan(/\d+/)
    end

  end

  def scrape_description(listing_doc, job_listing)
    if listing_doc.css(".Card-body").class == nil
      job_listing.description = listing_doc.css(".Card-body")[0].text.split.join(" ")
    end

  end

  def scrape_bids(listing_doc, job_listing)

    job_listing.bid_summary = listing_doc.css(".Card-heading").first.text.strip

    if listing_doc.css(".Card-header").class == nil
      job_listing.bid_summary = listing_doc.css(".Card-header").first.text.strip
      job_listing.bids = listing_doc.css(".Card-header").text.split("\n")[3].strip
    end

    job_listing.bids = job_listing.bid_summary.match(/^\d+/)
    job_listing.avg_bid = job_listing.bid_summary.match(/[\$€₹]\d+/)

  end

end
