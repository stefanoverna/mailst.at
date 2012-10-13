class Article < ActiveRecord::Base
  attr_accessible :description, :posted_at, :title
end
