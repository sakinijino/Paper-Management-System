class CheckingPaper < ActiveRecord::Base
  
  has_and_belongs_to_many :authors
  file_column :attachment
  
  validates_uniqueness_of   :identifier, :allow_nil=>true
  validates_presence_of :title
  validates_length_of       :title,    :within => 0..1024
  validates_length_of       :source,    :within => 0..1024
  
  def author_list_with_comma
    (self.authors.map {|a| a.name}).join(", ")
  end
  
  def publish_time_f
    self.publish_time.strftime("%Y.%m")
  end

end
