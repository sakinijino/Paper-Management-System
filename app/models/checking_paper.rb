class CheckingPaper < ActiveRecord::Base
  
  has_and_belongs_to_many :authors
  file_column :attachment
  
  def author_list_with_comma
    (self.authors.map {|a| a.name}).join(", ")
  end  

end
