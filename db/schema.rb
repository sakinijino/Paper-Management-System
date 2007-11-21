# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 10) do

  create_table "authors", :force => true do |t|
    t.column "name", :string
  end

  create_table "authors_checking_papers", :id => false, :force => true do |t|
    t.column "author_id",         :integer
    t.column "checking_paper_id", :integer
  end

  create_table "authors_papers", :id => false, :force => true do |t|
    t.column "author_id", :integer
    t.column "paper_id",  :integer
  end

  create_table "checking_papers", :force => true do |t|
    t.column "title",        :string
    t.column "abstract",     :text
    t.column "publish_time", :date
    t.column "identifier",   :string
    t.column "source",       :string
    t.column "attachment",   :string
  end

  create_table "collections", :force => true do |t|
    t.column "user_id",  :integer
    t.column "paper_id", :integer
    t.column "tag_id",   :integer
    t.column "status",   :string
  end

  create_table "notes", :force => true do |t|
    t.column "user_id",      :integer
    t.column "paper_id",     :integer
    t.column "content",      :text
    t.column "publish_time", :datetime
    t.column "is_private",   :boolean
  end

  create_table "papers", :force => true do |t|
    t.column "title",        :string
    t.column "abstract",     :text
    t.column "publish_time", :date
    t.column "identifier",   :string
    t.column "source",       :string
    t.column "attachment",   :string
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tags", :force => true do |t|
    t.column "name", :string
  end

  create_table "users", :force => true do |t|
    t.column "login",                     :string
    t.column "email",                     :string
    t.column "crypted_password",          :string,   :limit => 40
    t.column "salt",                      :string,   :limit => 40
    t.column "created_at",                :datetime
    t.column "updated_at",                :datetime
    t.column "remember_token",            :string
    t.column "remember_token_expires_at", :datetime
    t.column "realname",                  :string
    t.column "role",                      :string
  end

end
