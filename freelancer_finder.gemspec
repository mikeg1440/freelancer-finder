
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "freelancer_finder/version"

Gem::Specification.new do |spec|
  spec.name          = "freelancer_finder"
  spec.version       = FreelancerFinder::VERSION
  spec.authors       = ["Mike Gaudreau"]
  spec.email         = ["gaudreaum01@gmail.com"]

  spec.summary       = "This is a command line interface program that scrapes and displays job listings from Freelancer.com"
  spec.description   = "Freelancer.com is a freelance coding website where parties can post descriptions of jobs and a budget range then freelance coders can bid on the job.  This program scrapes the listings and displays them for the user allowing them to search by term, by pay range or just view the most recently posted listings."
  spec.homepage      = "https://www.github.com/mikeg1440/freelancer-finder"
  spec.license       = "MIT"

  # spec.executables   = "freelancer_finder"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = ": Set to 'http://mygemserver.com'"
  #
  #   spec.metadata["homepage_uri"] = spec.homepage
  #   spec.metadata["source_code_uri"] = "https://www.github.com/mikeg1440/freelancer-finder/"
  #   spec.metadata["changelog_uri"] = "https://www.github.com/mikeg1440/freelancer-finder/README.md"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|release|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "pry-moves", "~> 0.1.12"


  spec.add_dependency "nokogiri", "~> 1.10.4"
  spec.add_dependency "colorize", "~> 0.8.1"

end
