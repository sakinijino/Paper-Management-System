class CheckingPaper < ActiveRecord::Base
  
  has_and_belongs_to_many :authors
  file_column :attachment

end
