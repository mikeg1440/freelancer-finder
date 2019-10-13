

class FreelancerFinder::Job

  attr_accessor :title, :time_left, :short_description, :description, :tags
  attr_accessor :budget, :budget_range, :base_url, :url, :bids, :avg_bid, :bid_summary

  @@green = "\u001b[32m"
  @@white = "\u001b[37m"
  @@reset = "\u001b[0m"

  @@all = []

  def initialize(info)
    info.each {|key, value| self.send("#{key}=", value) }
    save
    self
  end


  # returns a summary string for the job instance
  def job_summary
    summary = "#{@@green}#{self.title} - "

    if self.avg_bid
      summary += "#{self.avg_bid}"
    elsif self.budget
      summary += "#{self.budget}"
    elsif self.budget_range
      summary += "#{self.budget_range.join(" - ")}"
    end
    summary
  end


  def print_summary         # prints the summary info we get from the main listing page
    print "#{self.title} - ".green
    if self.avg_bid
      print "#{self.avg_bid}".green
    elsif self.budget
      print "#{self.budget}".green
    elsif self.budget_range
      print "#{self.budget_range.join(" - ")}".green
    end
  end


  def job_in_range?( min, max)
    if self.budget_range

      if self.budget_range.count > 1       # if we have a budget_range then check if the budget falls within our min and max pay

        budget_min = self.budget_range[0].match(/\d+/)[0].to_i if self.budget_range[0].class == String
        budget_max = self.budget_range[1].match(/\d+/)[0].to_i if self.budget_range[1].class == String
        max.between?(budget_min, budget_max)
        min.between?(budget_min, budget_max)
      else                                  # else check if the budget_range is between the min and max pay
        self.budget_range.between?(min, max)
      end
    end
  end


  def job_avg_bid_in_range?(min, max)
    if self.avg_bid
      if self.avg_bid.class == MatchData                          # if the avg_bid is a match for some reason get the matched text of the first match element
        self.avg_bid[0].match(/\d+/)[0].to_i.between?(min, max)    # return self if avg_bid is between min pay and max pay
      elsif self.avg_bid.class == String
        self.avg_bid.match(/\d+/)[0].to_i.between?(min, max)       # return job if avg_bid is between min pay and max pay
      end
    end
  end


  # takes a min and max for a range and finds all jobs that have pay or budget in that range
  def self.find_jobs_in_pay_range(min_pay, max_pay)
    self.all.find_all do |job|
      job if job.job_in_range?(min_pay, max_pay)
      job if job.job_avg_bid_in_range?(min_pay, max_pay)
    end
  end


  # prints out the initial job info to terminal screen
  def print_info

    puts "\e[H\e[2J" # clear terminal screen

    # print the listing title
    print "#{@@white}Job Title: #{@@green}#{self.title}\n"


    # print the time left to bid
    print "\t#{@@white}Time Left: #{@@green}#{self.time_left}\n"

    # print the budget for the job if valid
    if self.budget
      print "\t#{@@white}Budget: #{@@green}#{self.budget}\n"
    end

    # print the tags associated with the listing
    print "\t#{@@white}Tags: #{@@green}#{self.tags.join(',')}\n"

    # print the number of bids if valid
    if self.bids
      print "\n\t#{@@white}Bids: #{@@green}#{self.bids}\n"
    end

    # print the average bid if valid
    if self.avg_bid
      print "\t#{@@white}Average Bid: #{@@green}#{self.avg_bid}\n"
    end

    # display the summary of bids at the momment
    print "\t#{@@white}Bid Summary: #{@@green}#{self.bid_summary}\n" if self.bid_summary

    # if we don't have the main description then print the short_description otherwise print the main description
    print "\t#{@@white}Description: \n#{@@green}"
    if self.description == nil
      # print "#{self.short_description}\n\n".green     # put a .each_line block here and add \t\t to space it out properly
      desc = self.short_description
    else
      # print "#{self.description}\n\n".green
      desc = self.description
    end

    # fix the formating issues by indenting each line with tabs twice
    desc.each_line {|line| print "\t\t#{@@green}#{line}\n"}

    print "#{@@reset}"
  end

  def full_url
    @base_url+@url
  end

# This method is not being used i guess
  # class method to return a array of all the tags present from all
  # def self.tags
  #   tags = []
  #   @@all.each do |job|
  #     job.tags.each {|tag| tags << tag unless tags.include?(tag) }
  #   end
  #   binding.pry
  #   tags
  # end

  def self.all
    @@all
  end

  def save
    @@all << self
  end

end
