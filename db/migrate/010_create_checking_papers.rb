class CreateCheckingPapers < ActiveRecord::Migration
  def self.up
    create_table :checking_papers do |t|
      t.column :title, :string
      t.column :abstract, :text
      t.column :publish_time, :date
      t.column :identifier, :string
      t.column :source, :string
      t.column :attachment, :string      
    end
  end

  def self.down
    drop_table :checking_papers
  end
end
