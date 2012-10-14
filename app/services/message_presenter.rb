class MessagePresenter < Struct.new(:message)
  def from
    address = Mail::Address.new(message[:from])
    address.display_name || address.address
  end
end
