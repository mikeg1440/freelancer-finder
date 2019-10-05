

class JobFinder::Job

  attr_accessor :title, :time_left, :short_description, :description, :tags, :price, :budget, :budget_range, :base_url, :url, :bids, :avg_bid

  @@all = []

  def initialize(info)
    info.each {|key, value| self.send("#{key}=", value) }
    save
    self
  end

  def print_info

    puts "\e[H\e[2J" # clear terminal screen

    print "Job Title: "
    print "#{self.title}\n".green

    if self.budget
      print "\tBudget: "
      print "#{self.budget}\n".green
    end

    if self.avg_bid
      print "\tAverage Bid: "
      print "#{self.avg_bid}\n".green
    end

    print "\tTime Left: "
    print "#{self.time_left}\n".green
    print "\tTags: "
    print "#{self.tags.join(',')}\n".green
    if self.bids
      print "\n\tBids: "
      print "#{self.bids}\n".green
    end
    print "\tDescription: \n"
    if self.description == nil
      # print "#{self.short_description}\n\n".green     # put a .each_line block here and add \t\t to space it out properly
      desc = self.short_description
    else
      # print "#{self.description}\n\n".green
      desc = self.description
    end

    desc.each_line {|line| print "\t\t#{line}\n".green}

  end

  def full_url
    @base_url+@url
  end


  def self.all
    @@all
  end

  def save
    @@all << self
  end

end
