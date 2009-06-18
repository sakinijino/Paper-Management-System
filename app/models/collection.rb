class Collection < ActiveRecord::Base
  belongs_to :user
  belongs_to :paper
  belongs_to :tag
end
