

class FreelancerFinder::CLI

  attr_accessor :scraper, :last_listings, :username, :screen_size, :last_scraped_page


  # this method starts the program by gretting the user by current username then scraping the first page and showing the menu
  def call

    get_environment
    greet_user
    scrape_jobs

    ret_value = ""
    # loop program until return value is falsey
    until ret_value == "exit" || ret_value == "00"
      ret_value = run         # store run methods return value in ret_value so we can check it for the loop
    end

    farewell_message

  end

  def run
    show_menu
    listing = handle_input(get_menu_choice)

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

  # gets and sets some initializing variables and environment varaibles
  def get_environment
    @last_scraped_page = 0
    @username = ENV['USER']
    @screen_size = `tput cols`.strip.to_i

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
    puts " # |  COMMANDS     |           DESCRIPTION                   |"
    puts " 1 | show recent   |  Show most recent job listings(1st Page)|".green
    puts " 2 | scrape more   |  Scrape Additional Pages of listings    |".green
    puts " 3 | search        |  Find listings by search term           |".green
    puts " 4 | search by pay |  Find listings by pay range             |".green
    puts "00 | exit          |  Exit Program                           |".red
    puts "___|_______________|_________________________________________|"

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
    when "3", "search"
      listings = find_listings_by_term
    when "4", "search by pay"
      listings = find_listings_by_pay
    else
      puts "Invalid command!"
      puts "Please Enter a Valid Menu Choice!"
    end


    display_listings(listings) if listings.class == Array
  end

  # prompts user for a job listing entry choice from the index numbers listed
  def get_menu_choice

    valid_opts = [
      "exit",
      "0", "00",
      "1","2","3","4",
      "show recent",
      "scrape more",
      "search",
      "search by pay"
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
  def display_listings(listings)

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

    puts "\n_______________________"
    puts "| exit -> Exit Program |".red
    puts "| 0 -> Return to menu  |"
    puts "|______________________|"
    get_user_selection(listings)
  end

  # takes in the listing objects array as a argument then prompts user for a valid listing choice between 1 and listings array size then returns the selected listing object
  def get_user_selection(listings)

    if listings.empty?
      puts "No listings found!!".red
      puts "Press enter to return to Menu".magenta
      gets
      clear_screen
      return "0"
    end

    selected_listing = ""

    puts "[+] Displaying #{listings.count} Listings [+]".magenta

    # prompt user until a valid command is recieved
    until selected_listing.to_i.between?(1, listings.count) || selected_listing == "exit" || selected_listing == "0"
      print "Please select a job listings by number: ".blue
      selected_listing = gets.chomp.downcase
    end

    clear_screen

    if selected_listing == "0" || selected_listing == "exit" # return to main menu and return the value of display_listings
      return selected_listing
    else
      listings[selected_listing.to_i - 1]  # if user selected the exit command return nil otherwise return the selected listing
    end

  end

  # takes a job instance as a argument then instructs the scraper object to scrape the details
  def show_job_details(job_listing)

    @scraper.scrape_details(job_listing)
    job_listing.print_info
    job_listing
  end

  # this method asks user how many listings they want to view then returns that number of listings
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

  # this method asks user how many pages they want to scrape then sends the the page urls to a scraper instance which scrapes and creates job instances
  def scrape_more_pages

    pages_to_scrape = 0

    clear_screen
    until pages_to_scrape != 0
      print "\nHow many pages would you like to scrape?: ".blue
      pages_to_scrape = gets.chomp.to_i
    end

    end_page = last_scraped_page + pages_to_scrape    # calculate our last page number
    @last_scraped_page += 1


    puts "\n"
    (@last_scraped_page..end_page).each.with_index(1) do |page, index|
      progress_bar(index.to_f / pages_to_scrape)
      @scraper.scrape_data_from_url("#{@scraper.base_url}#{page}")
    end

    puts "\nSuccesfully Scraped #{pages_to_scrape} Pages!".magenta

    @last_scraped_page = end_page

    FreelancerFinder::Job.all
  end

  # prompts user for a search term then returns all the listings that have that term in their title, description or tags
  def find_listings_by_term

    print "\nEnter a search term to filter jobs by: ".blue
    search_term = gets.strip

    listings = FreelancerFinder::Job.all.find_all do |job|
      job.title.include?("#{search_term}") || job.short_description.include?("#{search_term}") || !!job.tags.detect {|tag| tag.include?("#{search_term}")}
    end

    listings
  end

  # this method prompts user for a min and max pay range then returns all the listings that fall within that range
  def find_listings_by_pay

    min_pay = 0
    max_pay = 0
    puts "View all job listings in a certain pay range"

    until min_pay > 0 && max_pay > 0 && max_pay >= min_pay                     # until loop for input validation
      print "Enter the low end of pay range: ".blue
      min_pay = gets.chomp.to_i
      print "Enter the high end of the pay range: ".blue
      max_pay  = gets.chomp.to_i
    end

    listings = FreelancerFinder::Job.all.find_all do |job|

      if job.budget_range

        if job.budget_range.count > 1       # if we have a budget_range then check if the budget falls within our min and max pay
          budget_min = job.budget_range[0].match(/\d+/)[0].to_i
          budget_max = job.budget_range[1].match(/\d+/)[0].to_i
          max_pay.between?(budget_min, budget_max)
          min_pay.between?(budget_min, budget_max)
        else                                  # else check if the budget_range is between the min and max pay
          job.budget_range.between?(min_pay, max_pay)
        end
      end

      if job.avg_bid
        job.avg_bid.match(/\d+/)[0].to_i.between?(min_pay, max_pay)       # return listing if avg_bid is between min pay and max pay
      end

    end

    puts "[*] Found #{listings.count} jobs with pay between #{min_pay} and #{max_pay} [*]".magenta

    listings
  end

  # takes a argument of a ratio, then dislays a progress bar with that percent of the bar filled with '#'
  def progress_bar(progress_ratio)
    max = @screen_size * 0.8
    print "\r\t[#{progress_ratio.round(2)*100}%] ["
    print "#".magenta * (progress_ratio * max)
    print "] DONE!\n" if progress_ratio == 1
  end

  # takes a listing object as a argument and asks the user if they want to open the listing up in their browser
  def open_in_browser?(listing)
    puts "\nURL: #{listing.full_url}"
    print "Open listing page in browser?(yes/no): ".blue
    response = gets.chomp.downcase

    if response == "y" || response == "yes"
      system("xdg-open #{listing.full_url}")
    end
  end

  # final message to user
  def farewell_message
    puts "Program Exiting...".red
    puts "Goodbye #{@username}!".blue
  end

  def clear_screen
    puts "\e[H\e[2J"
  end

end
