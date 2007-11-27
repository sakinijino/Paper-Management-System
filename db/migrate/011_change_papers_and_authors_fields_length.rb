class ChangePapersAndAuthorsFieldsLength < ActiveRecord::Migration
  def self.up
    change_column :papers, :title, :string, :limit=>1024, :null=>false
    change_column :papers, :source, :string, :limit=>1024, :null=>false
    change_column :papers, :attachment, :string, :limit=>1024
    change_column :papers, :abstract, :text, :null=>false
    change_column :authors, :name, :string, :null=>false
  end

  def self.down
    change_column :papers, :title, :string
    change_column :papers, :source, :string
    change_column :papers, :attachment, :string
    change_column :papers, :abstract, :text
    change_column :authors, :name, :string
  end
end
