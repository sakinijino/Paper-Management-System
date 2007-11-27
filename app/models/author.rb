class Author < ActiveRecord::Base
  validates_uniqueness_of   :name
  validates_presence_of :name
  validates_length_of       :name,    :within => 1..200
  has_and_belongs_to_many :papers
  
  def Author.clear_redundances
    authors = Author.find_by_sql("SELECT a.id FROM authors as a left join authors_papers as ap on a.id = ap.author_id where paper_id is NULL;")
    authors.each{|a| Author.find(a.id).destroy}
  end
end
