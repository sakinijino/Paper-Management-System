class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.column :user_id, :integer
      t.column :paper_id, :integer
      t.column :content, :text
      t.column :publish_time, :datetime
      t.column :is_private, :boolean
    end
  end

  def self.down
    drop_table :notes
  end
end
