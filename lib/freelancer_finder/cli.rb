

class FreelancerFinder::CLI

  attr_accessor :scraper, :last_results, :username, :screen_size, :last_scraped_page, :prompt


  # this method starts the program by getting the user by current username then scraping the first page and showing the menu
  def call

    get_environment       # gets and sets some environmental variables that we will need
    greet_user
    scrape_jobs           # scrapes the 50 most recent job listings to start off

    ret_value = ""

    until ret_value == "exit" || ret_value == "00"        # loop program until return value is one of the exit commands
      ret_value = run                                # store run methods return value in ret_value so we can check it for exit commands
    end

    farewell_message
  end

  # this is the main program flow method, each user 'turn' will complete this method and return it to the 'call' method until it returns a exit command
  def run
    job = handle_input(show_menu)

    # job = handle_input(get_menu_choice)     # here we the menu choice and handle the choice together and return value will be the selected job or exit command

    # if job is a valid job instance then show details and offer to open in browser
    if job.class == FreelancerFinder::Job
      show_job_details(job)
      open_in_browser?(job)
    end
    # selected_job
    job
  end

  # gets and sets some initializing variables and environment varaibles
  def get_environment
    @last_scraped_page = 0
    @username = ENV['USER']
    @screen_size = `tput cols`.strip.to_i    # gets the terminal output of `tput cols` and converts to int and stores as screen_size
    @prompt = TTY::Prompt.new
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

    if (rand 2) == 1        # should switch between true and false to randomly print one of the banners everytime
      puts banner_1.blue
    else
      puts banner_2.blue
    end
    print "\n\t[*] Hello #{@username}! [*]\t\n".blue
  end


  # create scraper instance and scrape the all the jobs on the first page
  def scrape_jobs
    @scraper = FreelancerFinder::Scraper.new
    @scraper.scrape_recent_jobs.each do |job_hash|
      FreelancerFinder::Job.new(job_hash) unless FreelancerFinder::Job.all.detect {|job| job.path == job_hash[:path]}      # next create a job instance from the data we just scraped unless it exists already
    end
  end


  # shows user the menu options with a short description
  def show_menu
    clear_screen

    puts "[+] #{FreelancerFinder::Job.all.count} Jobs Scraped [+]".magenta
    puts "_____________________________________________________________"
    return @prompt.select("Please Select a Menu Option: ") do |menu|
      menu.choice "show recent"
      menu.choice "scrape more"
      menu.choice "search"
      menu.choice "search by pay"
      if @last_results
        menu.choice "results"
      end
      menu.choice "exit"
    end

  end


  # takes the users menu choice as a argument and calls the corresponding method, then sends array of jobs to display_jobs method
  def handle_input(choice)

    case choice
    when "0", "00", "exit"
      return choice
    when "1", "show recent"
      jobs = show_recent_jobs
    when "2", "scrape more"
      scrape_more_pages
      jobs = ""
    when "3", "search"
      jobs = find_jobs_by_term
    when "4", "search by pay"
      jobs = find_jobs_by_pay
    when "5", "results"
      jobs = show_last_results
    else
      puts "Invalid command!"
      puts "Please Enter a Valid Menu Choice!"
    end

    display_jobs(jobs) if jobs.class == Array
  end


  # prompts user for a job job entry choice from the index numbers listed for each job
  def get_menu_choice

    valid_cmds = [      # array of valid commands we will accept
      "exit",
      "0", "00",
      "1","2","3","4","5",
      "show recent",
      "scrape more",
      "search",
      "search by pay",
      "results"
    ]

    response = ""
    until valid_cmds.include?(response)
      print "Please Enter a Command or Number: ".blue
      response = gets.chomp.downcase
    end

    clear_screen
    response
  end


  # takes a array of job job objects as a argument and displays each title and averge bid or budget range along with a number so the user can choose it
  def display_jobs(jobs)

    clear_screen

    @last_results = jobs

    choices = []
    choices << {name: 'Return to Menu'.colorize(:magenta), value: 'menu'}
    choices << {name: 'Exit'.colorize(:red), value: 'exit'}

    choices += jobs.map.with_index(1) {|job, idx|  {name: "#{job.job_summary}".colorize(:light_blue), value: idx} }
    jobSelection = prompt.select("Select a job posting (use the left and right arrows to navigate pages)\n#{'_'*(@screen_size-1)} ".colorize(:white), choices, per_page: 35)

    if jobSelection == "exit"
      farewell_message
      exit
    elsif jobSelection == "menu"
      job = "menu"
    else
      job = jobs.find.with_index {|job, idx| jobSelection == idx }
    end


    return job
  end

  # return the previous results or "0" if no results
  def show_last_results
    @last_results ||= "0"
  end


  # show user message when we don't find any jobs
  def print_no_results_message
    puts "No jobs found!!".red
    puts "Press enter to return to Menu".magenta
    gets
    clear_screen
  end


  # takes a job instance as a argument then instructs the scraper object to scrape the details
  def show_job_details(job)
    @scraper.scrape_details(job)
    job.print_info
    job
  end


  # this method asks user how many jobs they want to view then returns that number of jobs
  def show_recent_jobs

    max_jobs = ""

    # until max_jobs.to_i.between?(1, FreelancerFinder::Job.all.count)
    #   puts "#{FreelancerFinder::Job.all.count} Total Listings to Choose From!".magenta
    #   print "How many jobs would you like to see?: ".blue
    #   max_jobs = gets.chomp.downcase
    # end

    puts "#{FreelancerFinder::Job.all.count} Total Listings to Choose From!".magenta
    max_jobs = @prompt.slider('How many jobs would you like to see?', max: FreelancerFinder::Job.all.count, step: 10)

    max_jobs = max_jobs.to_i - 1

    jobs = []

    FreelancerFinder::Job.all.each.with_index do |job, index|
      jobs << job
      break if index >= max_jobs
    end

    jobs
  end


  # this method asks user how many pages they want to scrape then sends the the page urls to a scraper instance which scrapes and creates job instances
  def scrape_more_pages

    pages_to_scrape = 0

    clear_screen
    clear_screen

    # loop untl we get a valid number of pages to scrape
    until pages_to_scrape != 0
      print "\nHow many pages would you like to scrape?: ".blue
      pages_to_scrape = gets.chomp.to_i
    end

    ending_page = last_scraped_page + pages_to_scrape    # calculate our last page number
    @last_scraped_page += 1

    puts "\n"
    (@last_scraped_page..ending_page).each.with_index(1) do |page, index|
      progress_bar(index.to_f / pages_to_scrape)
      @scraper.scrape_data_from_url("#{@scraper.base_url}#{page}").each do |job_hash|
        FreelancerFinder::Job.new(job_hash) unless FreelancerFinder::Job.all.detect {|job| job.path == job_hash[:path]}      # next create a job instance from the data we just scraped unless it exists already
      end
    end

    puts "\nSuccesfully Scraped #{pages_to_scrape} Pages!".magenta

    @last_scraped_page = ending_page

    FreelancerFinder::Job.all
  end


  # prompts user for a search term then returns all the jobs that have that term in their title, description or tags
  def find_jobs_by_term

    print "\nEnter a search term to filter jobs by: ".blue
    search_term = gets.strip

    jobs = FreelancerFinder::Job.all.find_all do |job|
      job.title.include?("#{search_term}") || job.short_description.include?("#{search_term}") || !!job.tags.detect {|tag| tag.include?("#{search_term}")}
    end

    jobs
  end


  # this method prompts user for a min and max pay range then returns all the jobs that fall within that range
  def find_jobs_by_pay

    min_pay = 0
    max_pay = 0
    puts "View all job jobs in a certain pay range"

    until min_pay > 0 && max_pay > 0 && max_pay >= min_pay                     # until loop for input validation
      print "Enter the low end of pay range: ".blue
      min_pay = gets.chomp.to_i
      print "Enter the high end of the pay range: ".blue
      max_pay  = gets.chomp.to_i
    end

    jobs = FreelancerFinder::Job.find_jobs_in_pay_range(min_pay, max_pay)

    puts "[*] Found #{jobs.count} jobs with pay between #{min_pay} and #{max_pay} [*]".magenta

    jobs
  end


  # takes a argument of a ratio, then dislays a progress bar with that percent of the bar filled with '#'
  def progress_bar(progress_ratio)
    max = @screen_size * 0.8
    print "\r\t[#{progress_ratio.round(2)*100}%] ["
    print "#".magenta * (progress_ratio * max)
    print "] DONE!\n" if progress_ratio == 1
  end


  # takes a job object as a argument and asks the user if they want to open the job up in their browser
  def open_in_browser?(job)
    puts "\nURL: #{job.full_url}"
    # print "Open job page in browser?(yes/no): ".blue
    # response = gets.chomp.downcase

    response = @prompt.yes?("Open job page in browser?")

    if response == "y" || response == "yes"
      system("xdg-open #{job.full_url}")
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
