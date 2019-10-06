

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

  # scrapes the initial info from the main listing pages
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

      # this element changes depending on what kind of listing it is and weather or not it has been bid on yet
      price_string = listing.css(".JobSearchCard-primary-price").text.strip
      price_match = price_string.scan(/\$\d+/)

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
        info[:avg_bid] = price_string.match(/\$\d+/)[0] if price_string.match(/\$\d+/)      # if also else are false then it should just be a single Avg bid number to store
      end
      # info[:price] = price_string.match(/\$\d+/)
      info[:url] = listing.css(".JobSearchCard-primary-heading-link")[0]['href']


      JobFinder::Job.new(info)                # next create a job instance from the data we just scraped

    end

  end

  # this method scrapes the details from the individual listing pages after user chooses what listing they want to view
  def scrape_details(job_listing)

    job_doc = open_from_url(job_listing.full_url)

    if job_doc.css(".PageProjectViewLogout-header-byLine").text.match(/\$[\d]+ ?- ?\$?\d+.*/)
      job_listing.budget = job_doc.css(".PageProjectViewLogout-header-byLine").text.match(/\$[\d]+ ?- ?\$?\d+.*/)[0]
      job_listing.budget_range = job_listing.budget.scan(/(\d+)/)
    end

    if job_doc.css(".Card-body").class == nil
      job_listing.description = job_doc.css(".Card-body")[0].text.split.join(" ")
    end

    if job_doc.css(".Card-header").class == nil
      job_listing.bids = job_doc.css(".Card-header").text.split("\n")[3].strip
    end

  end


end
