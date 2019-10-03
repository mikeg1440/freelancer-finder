

class JobFinder::Scraper

  attr_accessor :doc, :base_url

  def initialize(url = "https://www.freelancer.com/jobs/")
    @doc = open_from_url
    @base_url = url
    scrape_data
  end

  def open_from_url
    Nokogiri::HTML(open(@base_url))
  end

  def scrape_data
    binding.pry
  end


end
