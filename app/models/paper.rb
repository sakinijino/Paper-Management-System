class Paper < ActiveRecord::Base
  has_many :collections
  has_many :users, :through => :collections, :select => "distinct users.*"
  has_many :tags, :through => :collections, :select => "distinct tags.*"
  has_many :notes
  has_and_belongs_to_many :authors
  
  file_column :attachment
  acts_as_ferret :fields => [:title, :abstract, :identifier, :author_list, :tag_list, :source],
                      :analyzer => 'Ferret::Analysis::StandardAnalyzer'
  
  def author_list
    (self.authors.map {|a| a.name}).join(" ")
  end
  
  def author_list_with_comma
    (self.authors.map {|a| a.name}).join(", ")
  end  
  
  def tag_list
    (self.tags.map {|a| a.name}).join(" ")
  end  
end
