class CreatePapers < ActiveRecord::Migration
  def self.up
    create_table :papers do |t|
      t.column :title, :string
      t.column :abstract, :text
      t.column :publish_time, :date
      t.column :identifier, :string
      t.column :source, :string
      t.column :attachment, :string
    end
  end

  def self.down
    drop_table :papers
  end
end
