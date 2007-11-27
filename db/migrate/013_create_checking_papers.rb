class CreateCheckingPapers < ActiveRecord::Migration
  def self.up
    create_table :checking_papers do |t|
      t.column :title, :string, :limit=>1024, :null=>false
      t.column :abstract, :text, :null=>false
      t.column :publish_time, :date
      t.column :identifier, :string
      t.column :source, :string, :limit=>1024, :null=>false
      t.column :attachment, :string, :limit=>1024    
    end
  end

  def self.down
    drop_table :checking_papers
  end
end
