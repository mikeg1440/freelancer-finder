

class JobFinder::CLI

  attr_accessor :scraper

  def call

    username = Etc.getlogin
    ret_value = ""

    greet_user(username)
    scrape_jobs

    # loop program until return value is falsey
    until !ret_value
      ret_value = run         # store run methods return value in ret_value so we can check it for the loop
      # clear_screen
    end

    farewell_message(username)

  end

  def run
    show_menu
    listing = handle_input(prompt_user)
    # binding.pry
    if listing
      # selected_job = select_listing(listing)
      show_job_details(listing)
      open_in_browser?(listing)
    elsif listing != nil
      puts "No Listings Found!"
    end


    # selected_job
    listing
  end

  def greet_user(username)
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
    print "\n\t[*] Hello #{username}! [*]\t\n".blue
  end

  def scrape_jobs
    @scraper = JobFinder::Scraper.new
  end

  def show_menu

    puts "1. Show most recent job listings".green
    puts "2. Show listings from multiple pages".green
    puts "3. Find listing by search term".green
    puts "4. Find listing by pay".green
    puts "0. Exit or type 'exit'".red

  end

  def handle_input(choice)
    # binding.pry

    case choice
    when "0", "exit", nil
      return nil
    when "1", "show recent"
      listings = show_recent_listings
    when "2", "show all"
      listings = show_all_listings
    when "3", "find by term"
      listings = find_listings_by_term
    when "4", "find by pay"
      listings = find_listings_by_pay
    else
      puts "Invalid command!"
      puts "Please Enter a Valid Menu Choice!"
    end

    select_listing(listings)
  end

  # prompts user for a job listing entry choice from the index numbers listed
  def prompt_user
    response = ""
    until response == "exit" || response == "0" || response.to_i.between?(1,4)
      print "Please Choose a Menu Option[0-4]: ".blue
      response = gets.chomp.downcase
    end

    clear_screen

    response == "0" ? nil : response
  end

  def select_listing(listings)

    listings.each.with_index(1) do |job, index|
      puts "#{index}. #{job.title} - #{job.price}".green
      puts ""
    end

    puts "00. Exit"

    get_user_selection(listings)
  end

  def get_user_selection(listings)

    selected_listing = ""

    until selected_listing.to_i.between?(1, listings.count) || selected_listing == "00"
      print "Please select a job listings by number: ".blue
      selected_listing = gets.chomp.downcase
    end

    clear_screen

    selected_listing != "00" ? listings[selected_listing.to_i - 1] : nil
  end

  def show_job_details(job_listing)

    @scraper.scrape_details(job_listing)
    job_listing.print_info
    job_listing
  end

  def show_recent_listings

    max_listings = ""

    until max_listings.to_i.between?(1, JobFinder::Job.all.count)
      puts "#{JobFinder::Job.all.count} Total Listings to Choose From!".magenta
      print "How many listings would you like to see?: ".blue
      max_listings = gets.chomp.downcase
    end

    max_listings = max_listings.to_i - 1

    # JobFinder::Job.all.each.with_index(1) do |job, index|
    #   puts "#{index}. #{job.title}".green
    #   puts "----------------------------------------------------------".magenta
    #   break if index >= num_listings
    # end

    listings = []

    JobFinder::Job.all.each.with_index do |job, index|
      listings << job
      break if index >= max_listings
    end

    listings
  end

  def show_all_listings
  end

  def find_listings_by_term

    print "Enter a search term to filter jobs by: ".blue
    response = gets.strip

    # listings = JobFinder::Job.all.find_all {|job| job.title.match(/"#{response}"/) || job.short_description.match(/"#{response}"/)}
    listings = JobFinder::Job.all.find_all {|job| job.title.include?("#{response}") || job.short_description.include?("#{response}")}

    binding.pry
    listings
  end

  def find_listings_by_pay

    pay = 0
    until pay > 0
      print "Show all listings with a pay of: "
      pay = gets.strip.to_i
    end

    listings = JobFinder::Job.all.find_all do |job|
      binding.pry
      if job.budget_range.count > 1
        pay.between?(job.budget_range[0], job.budget_range[1])
      else
        job.budget_range[0] == pay
      end
    end

    binding.pry
    listings
  end

  def open_in_browser?(listing)
    puts "URL: #{listing.full_url}"
    print "Open listing page in browser?(yes/no): "
    response = gets.chomp.downcase

    if response == "y" || response == "yes"
      system("xdg-open #{listing.full_url}")
    end

  end

  def farewell_message(username)
    puts "Program Exiting...".red
    puts "Goodbye #{username}!".blue
  end

  def clear_screen
    puts "\e[H\e[2J"
  end

end
