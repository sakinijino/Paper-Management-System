class Author < ActiveRecord::Base
  validates_uniqueness_of   :name
  validates_presence_of :name
  validates_length_of       :name,    :within => 1..250
  has_and_belongs_to_many :papers
end
