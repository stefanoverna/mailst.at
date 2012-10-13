require 'net/imap'
require 'mail'

class ImapMailbox
  attr_reader :params

  def initialize(params = {})
    @params = params.symbolize_keys!

    [:host, :port, :encryption, :username, :password].each do |param|
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

  def connected?
    return @imap_client.present?
  end

  def folder_mail_summary(folder_name, older_than_time)
    return {} unless connected?
    older_than_time = older_than_time.utc

    begin
      result = {}

      @imap_client.examine(folder_name)
      result[:messages] = imap.status(folder.name, ["MESSAGES"])["MESSAGES"]

      email_ids = @imap_client.search("ALL").take 100
      result[:old] = email_ids.select do |email_id|
        email = @imap_client.fetch(email_id, "BODY[HEADER.FIELDS (Date)]")
        email_time = Time.parse(email.first.attr.values.first).utc
        email_time < older_than_time
      end.count

      result
    rescue
      {}
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
    return [] unless connected?

    begin
      @imap_client.list("", "*").select do |folder|
        !folder.attr.include? :Noselect
      end.map(&:name)
    rescue
      []
    end
  end

end
