class Tag < ActiveRecord::Base
  has_many :collections
  has_many :users, :through => :collections, :select => "distinct users.*"
  has_many :papers, :through => :collections, :select => "distinct papers.*"
  
  validates_uniqueness_of   :name
  validates_presence_of   :name  
  
  def <=>(another_tag)
    another_tag.collections.count <=> self.collections.count
  end
end
