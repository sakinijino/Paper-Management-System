class Tag < ActiveRecord::Base
  has_many :collections
  has_many :users, :through => :collections, :select => "distinct users.*"
  has_many :papers, :through => :collections, :select => "distinct papers.*"
  
  validates_uniqueness_of   :name
  validates_presence_of   :name  
  validates_length_of       :name,    :within => 1..50
  
  def <=>(another_tag)
    another_tag.collections.count <=> self.collections.count
  end
  
  def Tag.clear_redundances
    tags = Tag.find_by_sql("SELECT t.id FROM tags as t left join collections as c on t.id = c.tag_id where c.id is NULL;")
    tags.each{|t| Tag.find(t.id).destroy}
  end
end
