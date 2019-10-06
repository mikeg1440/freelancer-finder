require 'bundler'
require 'open-uri'
require 'etc'

Bundler.require(:default, :developement)

module JobFinder

  require_relative "job_finder/cli.rb"
  require_relative "job_finder/job.rb"
  require_relative "job_finder/scraper.rb"


end
