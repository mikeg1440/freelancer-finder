require 'nokogiri'
require 'open-uri'
require_relative '../lib/freelancer_finder/job'
require_relative '../lib/freelancer_finder/scraper'

RSpec.describe FreelancerFinder::Job do

  scraper = FreelancerFinder::Scraper.new
  jobs_hash = scraper.scrape_recent_jobs
  job = FreelancerFinder::Job.new(jobs_hash.first)

  describe '#new' do
    context 'on initializing a new instance' do

      it 'takes in a hash of attributes and assigns them to new job instance' do
        expect(job.class == FreelancerFinder::Job)
      end

      it 'creates instance variable of title' do
        expect(job.title)
      end

      it 'creates instance variable of short_description' do
        expect(job.short_description)
      end

      it 'creates instance variable of host' do
        expect(job.host)
      end

      it 'creates instance variable of path' do
        expect(job.path)
      end

      it 'creates instance variable of tags' do
        expect(job.tags)
      end

      it 'creates instance variable with budget info' do
        expect(job.avg_bid || job.budget || job.budget_range)
      end

    end
  end
end
