

class FreelancerFinder::Job

  attr_accessor :title, :time_left, :short_description, :description, :tags, :budget, :budget_range, :base_url, :url, :bids, :avg_bid, :bid_summary

  @@green = "\u001b[32m"
  @@white = "\u001b[37m"
  @@reset = "\u001b[0m"

  @@all = []

  def initialize(info)
    info.each {|key, value| self.send("#{key}=", value) }
    save
    self
  end


  def print_summary         # prints the summary info we get from the main listing page

    print "#{self.title} - ".green
    if self.avg_bid
      print "#{self.avg_bid}".green
    elsif self.budget
      print "#{self.budget}".green
    elsif self.budget_range
      print "#{self.budget_range.join(" - ")}".green
    # else
    #   print "\n"
    end
  end

  # takes a min and max for a range and finds all jobs that have pay or budget in that range
  def self.find_jobs_in_pay_range(min_pay, max_pay)
    jobs = self.all.find_all do |job|

      # if we have a budget range check if it falls with the pay reange we are looking for
      if job.budget_range

        if job.budget_range.count > 1       # if we have a budget_range then check if the budget falls within our min and max pay

          budget_min = job.budget_range[0].match(/\d+/)[0].to_i if job.budget_range[0].class == String
          budget_max = job.budget_range[1].match(/\d+/)[0].to_i if job.budget_range[1].class == String
          max_pay.between?(budget_min, budget_max)
          min_pay.between?(budget_min, budget_max)
        else                                  # else check if the budget_range is between the min and max pay
          job.budget_range.between?(min_pay, max_pay)
        end
      end

      # if we have a average bid then check if that is in our range
      if job.avg_bid
        if job.avg_bid.class.is_a? MatchData                          # if the avg_bid is a match for some reason get the matched text of the first match element

          job.avg_bid[0].match(/\d+/)[0].to_i.between?(min_pay, max_pay)    # return job if avg_bid is between min pay and max pay
        else
          job.avg_bid.match(/\d+/)[0].to_i.between?(min_pay, max_pay)       # return job if avg_bid is between min pay and max pay
        end
      end

    end

    jobs
  end

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

  # class method to return a array of all the tags present from all
  def self.tags
    tags = []
    @@all.map do |job|
      job.tags.each {|tag| tags << tag unless tags.include?(tag) }
    end
    tags
  end

  def self.all
    @@all
  end

  def save
    @@all << self
  end

end
