require 'nokogiri'
require 'open-uri'
require 'pry-moves'
require_relative '../lib/freelancer_finder/scraper'
require_relative '../lib/freelancer_finder/job'


RSpec.describe FreelancerFinder::Scraper do

  # scraper = FreelancerFinder::Scraper.new
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

  describe '#scrape_recent_jobs' do
    # scraper = FreelancerFinder::Scraper.new('spec/fixtures/freelancer_page_1.html')
    # jobs_hash = scraper.scrape_recent_jobs
    it 'scrapes the newest 50 job listings on the first page' do
      expect(jobs_hash.count == 50)
    end

    it 'returns a array of hashes' do
      expect(jobs_hash.class == Array && jobs_hash.all?{ |elem| elem.class == Hash })
    end

    it 'each hash has a title key' do
      expect(!jobs_hash.first[:title].empty?)
    end

    it 'each hash has a short_description key' do
      expect(!jobs_hash.first[:short_description].empty?)
    end

    it 'each hash has a path key' do
      expect(!jobs_hash.first[:path].empty?)
    end

    it 'each hash has a tags key' do
      expect(!jobs_hash.first[:tags].empty?)
    end

  end
end
