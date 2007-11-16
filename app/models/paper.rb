class Paper < ActiveRecord::Base
  has_many :collections
  has_many :users, :through => :collections, :select => "distinct users.*"
  has_many :tags, :through => :collections, :select => "distinct tags.*"
  has_many :notes
  has_and_belongs_to_many :authors
  
  file_column :attachment
  acts_as_ferret :fields => [:title, :abstract, :identifier, :author_list]
  
  def author_list
    (self.authors.map {|a| a.name}).join(" ")
  end
end
