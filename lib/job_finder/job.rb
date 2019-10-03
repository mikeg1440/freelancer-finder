

class JobFinder::Job

  attr_accessor :title, :time_left, :short_description, :tags, :price, :url

  @@all = []

  def initialize(info)
    info.each {|key, value| self.send("#{key}=", value) }
    save
    self
  end

  def print_info

    print "Job Title: "
    print "#{self.title}\n".green
    print "\tPrice: "
    print "#{self.price}\n".green
    print "\tTime Left: "
    print "#{self.time_left}\n".green
    print "\tTags: "
    print "#{self.tags.join(',')}\n".green
    print "Description: \n"
    print "#{self.short_description}\n\n".green

  end


  def self.all
    @@all
  end

  def save
    @@all << self
  end

end
