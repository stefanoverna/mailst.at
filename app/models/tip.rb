class Tip < ActiveRecord::Base
  attr_accessible :description, :title, :citation

  def self.random
    Tip.offset(rand(Tip.count)).first
  end
end
