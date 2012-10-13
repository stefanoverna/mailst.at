require 'net/imap'
require 'mail'

class ImapMailbox
  attr_reader :params

  def initialize(params = {})
    @params = params.symbolize_keys!

    [:email, :host, :port, :encryption, :username, :password].each do |param|
      raise ArgumentError, "#{param} is required" unless @params.include? param
    end

    @params[:port] = @params[:port].to_i if @params[:port].is_a? String
    @params[:encryption].downcase! if @params[:encryption].is_a? String

    @params[:encryption] = case @params[:encryption]
                           when false, nil, '', 'none'
                             false
                           else
                             true
                           end
  end

  def credentials_valid?
    @imap_client = Net::IMAP.new(params[:host], params[:port], params[:encryption], nil, false)
    @imap_client.login(params[:username], params[:password])
    true
  rescue
    false
  end

  def folders
    return [] unless @imap_client

    @imap_client.list("", "*").select do |folder|
      !folder.attr.include? :Noselect
    end.map(&:name)
  end
end
