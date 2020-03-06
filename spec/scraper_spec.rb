require 'nokogiri'
require 'open-uri'
require 'pry-moves'
require_relative '../lib/freelancer_finder/scraper'
require_relative '../lib/freelancer_finder/job'
RSpec.describe FreelancerFinder::Scraper do
  scraper = FreelancerFinder::Scraper.new('spec/fixtures/freelancer.com_jobs')
  jobs_hash = scraper.scrape_recent_jobs

  describe '#new' do
    context 'on intialization' do
      it 'defaults url to "https://www.freelancer.com/jobs/" if no url argument passed' do
        new_scraper = FreelancerFinder::Scraper.new
        expect(new_scraper.base_url == 'https://www.freelancer.com/jobs/')
      end
    end
  end
end
