class Tag < ActiveRecord::Base
  has_many :collections
  has_many :users, :through => :collections, :select => "distinct users.*"
  has_many :papers, :through => :collections, :select => "distinct papers.*"
  
  def <=>(another_tag)
    another_tag.collections.count <=> self.collections.count
  end
end
