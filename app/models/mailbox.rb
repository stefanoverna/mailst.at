class Mailbox < ActiveRecord::Base
  attr_accessible :email, :encryption, :host, :password, :port, :user_id, :username
end
