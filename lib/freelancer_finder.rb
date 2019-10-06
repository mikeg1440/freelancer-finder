require 'bundler'
require 'open-uri'

Bundler.require()

module FreelancerFinder

  require_relative "freelancer_finder/cli.rb"
  require_relative "freelancer_finder/job.rb"
  require_relative "freelancer_finder/scraper.rb"

end
