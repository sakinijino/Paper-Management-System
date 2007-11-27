class CreateAuthorsCheckingPapers < ActiveRecord::Migration
  def self.up
    create_table :authors_checking_papers, :id => false do |t|
      t.column :author_id, :integer
      t.column :checking_paper_id, :integer
    end    
  end

  def self.down
    drop_table :authors_checking_papers    
  end
end
