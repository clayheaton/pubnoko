class Journal < ActiveRecord::Base
  attr_accessible :name, :description, :url, :short_name
  
  has_many :articles, :order => 'pubdate DESC'
  
  validates_uniqueness_of :name
  validates_presence_of :short_name
  validates_presence_of :name
  
  before_save :make_short_name
  
  def best_name
    if !self.short_name.nil? && self.short_name.length > 0
      return self.short_name
    else
      return self.name
    end
  end
  
  private
  
  # Makes sure that a new journal has a short name in case one isn't entered.
  def make_short_name
    if self.short_name.nil? || self.short_name.length == 0
      self.short_name = self.name
    end
  end
end
