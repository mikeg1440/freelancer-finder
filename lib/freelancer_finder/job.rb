

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
