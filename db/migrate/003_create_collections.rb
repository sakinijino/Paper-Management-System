class CreateCollections < ActiveRecord::Migration
  def self.up
    create_table :collections do |t|
      t.column :user_id, :integer
      t.column :paper_id, :integer
      t.column :tag_id, :integer
      t.column :status, :string
    end
  end

  def self.down
    drop_table :collections
  end
  
end