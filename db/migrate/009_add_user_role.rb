class AddUserRole < ActiveRecord::Migration
 
  def self.up
    add_column :users, :role, :string
    User.update_all("role = 'Common User'")    
  end

  def self.down
    remove_column :users, :role    
  end

end
