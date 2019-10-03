

class JobFinder::CLI

  attr_accessor :scraper

  def call

    username = Etc.getlogin

    greet_user(username)
    scrape_jobs
    show_menu
    listings = handle_input(prompt_user)
    if listings
      selected_job = select_listing(listings)
      show_job_details(selected_job)
    else
      puts "No Listings Found!"
    end

    farewell_message(username)

  end

  def run

  end 

  def greet_user(username)
    banner_1 = '''
    /$$$$$$$$                            /$$
   | $$_____/                           | $$
   | $$     /$$$$$$   /$$$$$$   /$$$$$$ | $$  /$$$$$$  /$$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$
   | $$$$$ /$$__  $$ /$$__  $$ /$$__  $$| $$ |____  $$| $$__  $$ /$$_____/ /$$__  $$ /$$__  $$
   | $$__/| $$  \__/| $$$$$$$$| $$$$$$$$| $$  /$$$$$$$| $$  \ $$| $$      | $$$$$$$$| $$  \__/
   | $$   | $$      | $$_____/| $$_____/| $$ /$$__  $$| $$  | $$| $$      | $$_____/| $$
   | $$   | $$      |  $$$$$$$|  $$$$$$$| $$|  $$$$$$$| $$  | $$|  $$$$$$$|  $$$$$$$| $$
   |__/   |__/       \_______/ \_______/|__/ \_______/|__/  |__/ \_______/ \_______/|__/



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
   ____            __
  / _________ ___ / ___ ____ _______ ____
 / _// __/ -_/ -_/ / _ `/ _ / __/ -_/ __/
/_/_/_/_ \__/\__/_/\_,_/_//_\__/\__/_/
  / __(____ ___/ ___ ____
 / _// / _ / _  / -_/ __/
/_/ /_/_//_\_,_/\__/_/
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

    case choice
    when "0", "exit"
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

    listings
  end

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

    listings[selected_listing.to_i - 1]
  end

  def show_job_details(job_listing)

    @scraper.scrape_details(job_listing)
    job_listing.print_info

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
  end

  def find_listings_by_pay
  end

  def farewell_message(username)
    puts "Program Exiting...".red
    puts "Goodbye #{username}!".blue
  end

  def clear_screen
    puts "\e[H\e[2J"
  end

end
