

class FreelancerFinder::CLI

  attr_accessor :scraper, :last_listings, :username


  # this method starts the program by gretting the user by current username then scraping the first page and showing the menu
  def call

    @username = ENV['USER']
    ret_value = ""

    greet_user
    scrape_jobs

    # loop program until return value is falsey
    until ret_value == "exit" || ret_value == "00"
      ret_value = run         # store run methods return value in ret_value so we can check it for the loop
    end

    farewell_message

  end

  def run
    show_menu
    listing = handle_input(prompt_user)

    if listing.class == FreelancerFinder::Job
      show_job_details(listing)
      open_in_browser?(listing)
    end

    if !listing
      return true
    end

    # selected_job
    listing
  end

  def greet_user
    banner_1 = '''
    /$$$$$$$$                            /$$                                                  /$$$$$           /$$
   | $$_____/                           | $$                                                 |__  $$          | $$
   | $$     /$$$$$$   /$$$$$$   /$$$$$$ | $$  /$$$$$$  /$$$$$$$   /$$$$$$$  /$$$$$$             | $$  /$$$$$$ | $$$$$$$
   | $$$$$ /$$__  $$ /$$__  $$ /$$__  $$| $$ |____  $$| $$__  $$ /$$_____/ /$$__  $$            | $$ /$$__  $$| $$__  $$
   | $$__/| $$  \__/| $$$$$$$$| $$$$$$$$| $$  /$$$$$$$| $$  \ $$| $$      | $$$$$$$$       /$$  | $$| $$  \ $$| $$  \ $$
   | $$   | $$      | $$_____/| $$_____/| $$ /$$__  $$| $$  | $$| $$      | $$_____/      | $$  | $$| $$  | $$| $$  | $$
   | $$   | $$      |  $$$$$$$|  $$$$$$$| $$|  $$$$$$$| $$  | $$|  $$$$$$$|  $$$$$$$      |  $$$$$$/|  $$$$$$/| $$$$$$$/
   |__/   |__/       \_______/ \_______/|__/ \_______/|__/  |__/ \_______/ \_______/       \______/  \______/ |_______/



    /$$$$$$$$ /$$                 /$$
   | $$_____/|__/                | $$
   | $$       /$$ /$$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$
   | $$$$$   | $$| $$__  $$ /$$__  $$ /$$__  $$ /$$__  $$
   | $$__/   | $$| $$  \ $$| $$  | $$| $$$$$$$$| $$  \__/
   | $$      | $$| $$  | $$| $$  | $$| $$_____/| $$
   | $$      | $$| $$  | $$|  $$$$$$$|  $$$$$$$| $$
   |__/      |__/|__/  |__/ \_______/ \_______/|__/


                                                                                                                       '''
    banner_2 = '''
    ___________                   .__                                    ____.     ___.
    \_   _____/______  ____  ____ |  | _____    ____   ____  ____       |    | ____\_ |__
     |    __) \_  __ \/ __ \/ __ \|  | \__  \  /    \_/ ___\/ __ \      |    |/  _ \| __ \
     |     \   |  | \|  ___|  ___/|  |__/ __ \|   |  \  \__\  ___/  /\__|    (  <_> ) \_\ \
     \___  /   |__|   \___  >___  >____(____  /___|  /\___  >___  > \________|\____/|___  /
         \/               \/    \/          \/     \/     \/    \/                      \/
    ___________.__            .___
    \_   _____/|__| ____    __| _/___________
     |    __)  |  |/    \  / __ |/ __ \_  __ \
     |     \   |  |   |  \/ /_/ \  ___/|  | \/
     \___  /   |__|___|  /\____ |\___  >__|
         \/            \/      \/    \/
                                                                                                                       '''
    clear_screen

    if (rand 2) == 1
      puts banner_1.blue
    else
      puts banner_2.blue
    end
    print "\n\t[*] Hello #{@username}! [*]\t\n".blue
  end

  def scrape_jobs
    @scraper = FreelancerFinder::Scraper.new
  end

  def show_menu

    puts "[+] #{FreelancerFinder::Job.all.count} Listings Scraped [+]".magenta
    puts "_____________________________________________________________"
    puts " # |  COMMANDS    |           DESCRIPTION                   |"
    puts " 1 | show recent  |  Show most recent job listings(1st Page)|".green
    puts " 2 | scrape more  |  Scrape Additional Pages                |".green
    puts " 3 | find by term |  Find listing by search term            |".green
    puts " 4 | find by pay  |  Find listing by pay                    |".green
    puts "00 |     exit     |  Exit Program                           |".red
    puts "___|______________|_________________________________________|"

  end

  def handle_input(choice)


    case choice
    when "0", "00", "exit"
      return choice
    when "1", "show recent"
      listings = show_recent_listings
    when "2", "scrape more"
      scrape_more_pages
      listings = ""
    when "3", "find by term"
      listings = find_listings_by_term
    when "4", "find by pay"
      listings = find_listings_by_pay
    else
      puts "Invalid command!"
      puts "Please Enter a Valid Menu Choice!"
    end


    select_listing(listings) if listings.class == Array
  end

  # prompts user for a job listing entry choice from the index numbers listed
  def prompt_user

    valid_opts = [
      "exit",
      "0", "00",
      "1","2","3","4",
      "show recent",
      "scrape more",
      "find by term",
      "find by pay"
    ]

    response = ""
    # until response == "exit" || response == "00" || response.to_i.between?(1,4)
    until valid_opts.include?(response)
      print "Please Enter a Command or Number: ".blue
      response = gets.chomp.downcase
    end

    clear_screen

    response
  end


  # takes a array of job listing objects as a argument and displays each title and averge bid or budget range along with a number so the user can choose it
  def select_listing(listings)

    listings.each.with_index(1) do |job, index|
      print "#{index}. #{job.title} - ".green

      # this if statement prevents from displaying any blank values (some listings have one or the other value)
      if job.avg_bid
        print "#{job.avg_bid}\n".green
      elsif job.budget
        print "#{job.budget}\n".green
      elsif job.budget_range
        print "#{job.budget_range.join(" - ")}".green
      else
        print "\n"
      end
      print "\n"
    end

    puts "exit -> Exit Program".red
    puts "0 -> Return to menu".magenta

    get_user_selection(listings)
  end

  # takes in the listing objects array as a argument then prompts user for a valid listing choice between 1 and listings array size then returns the selected listing object
  def get_user_selection(listings)

    selected_listing = ""

    puts "[+] Displaying #{listings.count} Listings [+]".magenta

    # prompt user until a valid command is recieved
    until selected_listing.to_i.between?(1, listings.count) || selected_listing == "exit" || selected_listing == "0"
      print "Please select a job listings by number: ".blue
      selected_listing = gets.chomp.downcase
    end

    clear_screen

    return selected_listing if selected_listing == "0" || selected_listing == "exit" # return to main menu

    listings[selected_listing.to_i - 1]  # if user selected the exit command return nil otherwise return the selected listing
  end

  def show_job_details(job_listing)

    @scraper.scrape_details(job_listing)
    job_listing.print_info
    job_listing
  end

  def show_recent_listings

    max_listings = ""

    until max_listings.to_i.between?(1, FreelancerFinder::Job.all.count)
      puts "#{FreelancerFinder::Job.all.count} Total Listings to Choose From!".magenta
      print "How many listings would you like to see?: ".blue
      max_listings = gets.chomp.downcase
    end

    max_listings = max_listings.to_i - 1

    listings = []

    FreelancerFinder::Job.all.each.with_index do |job, index|
      listings << job
      break if index >= max_listings
    end

    listings
  end


  def scrape_more_pages

    pages_to_scrape = 0

    until pages_to_scrape != 0
      print "How many pages would you like to scrape?: ".blue
      pages_to_scrape = gets.chomp.to_i
    end

    base_url = "https://www.freelancer.com/jobs/"
    puts "\n"
    (1..pages_to_scrape).each do |page|
      progress_bar(1.0 / pages_to_scrape)
      FreelancerFinder::Scraper.new("#{base_url}#{page}")
    end

    puts "\nSuccesfully Scraped #{pages_to_scrape} Pages!".magenta

    FreelancerFinder::Job.all
  end

  def find_listings_by_term

    print "Enter a search term to filter jobs by: ".blue
    response = gets.strip

    # listings = FreelancerFinder::Job.all.find_all {|job| job.title.match(/"#{response}"/) || job.short_description.match(/"#{response}"/)}
    listings = FreelancerFinder::Job.all.find_all {|job| job.title.include?("#{response}") || job.short_description.include?("#{response}")}

    listings
  end

  def find_listings_by_pay

    min_pay = 0
    max_pay = 0
    puts "View all job listings in a certain pay range"

    until min_pay > 0 && max_pay > 0
      print "Enter the low end of pay range: ".blue
      min_pay = gets.chomp.to_i
      print "Enter the high end of the pay range: ".blue
      max_pay  = gets.chomp.to_i

    end

    listings = FreelancerFinder::Job.all.find_all do |job|

      if job.budget_range

        if job.budget_range.count > 1

          max_pay.between?(job.budget_range[0].gsub("$","").to_i, job.budget_range[1].gsub("$","").to_i)
          min_pay.between?(job.budget_range[0].gsub("$","").to_i, job.budget_range[1].gsub("$","").to_i)
        else
          job.budget_range.between?(min_pay, max_pay)
        end

      elsif job.avg_bid

        job.avg_bid.match(/\d+/)[0].to_i.between?(min_pay, max_pay)

      end
    end

    puts "[*] Found #{listings.count} with pay between #{min_pay} and #{max_pay} [*]".magenta

    listings
  end

  def progress_bar(progress_ratio)
    max = ENV['COLUMNS'].to_i
    binding.pry
    print "#".magenta * (progress_ratio * max)
  end

  def open_in_browser?(listing)
    puts "\nURL: #{listing.full_url}"
    print "Open listing page in browser?(yes/no): ".blue
    response = gets.chomp.downcase

    if response == "y" || response == "yes"
      system("xdg-open #{listing.full_url}")
    end
  end

  def farewell_message
    puts "Program Exiting...".red
    puts "Goodbye #{@username}!".blue
  end

  def clear_screen
    puts "\e[H\e[2J"
  end

end