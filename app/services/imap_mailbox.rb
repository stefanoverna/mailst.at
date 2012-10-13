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

  def folder_mail_summary(folder_name, older_than_time, options = {max_search: 100, max_fetch: 3})
    return {} unless connected?

    begin
      result = {messages_count: 0, old_messages_count: 0, old_mails: []}

      @imap_client.examine(folder_name)
      result[:messages_count] = @imap_client.status(folder_name, ["MESSAGES"])["MESSAGES"]

      email_ids = @imap_client.search("ALL")

      oldest_ids = email_ids.take(options[:max_search]).select do |email_id|
        header = @imap_client.fetch(email_id, "BODY[HEADER.FIELDS (From To Subject Date)]")
        mail = Mail.read_from_string(header.first.attr.values.first)
        mail.date.utc < older_than_time.utc
      end
      result[:old_messages_count] = oldest_ids.count

      result[:old_mails] = oldest_ids.take(options[:max_fetch]).map do |email_id|
        header = @imap_client.fetch(email_id, "BODY[HEADER.FIELDS (From To Subject Date)]")
        Mail.read_from_string(header.first.attr.values.first)
      end

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
