class CreateAuthorsPapers < ActiveRecord::Migration
  def self.up
    create_table :authors_papers, :id => false do |t|
      t.column :author_id, :integer
      t.column :paper_id, :integer
    end
  end

  def self.down
    drop_table :authors_papers
  end
  
end
