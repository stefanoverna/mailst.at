object @mailbox
attribute :email
attribute :"credentials_valid?" => :credentials_valid
attribute :"credentials_verified?" => :credentials_verified
node :folders_from_partial do |mailbox|
  if mailbox.credentials_valid?
    j(render "folders_form", mailbox: mailbox)
  end
end
