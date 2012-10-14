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
    result = {}
    begin
      @imap_client.examine(folder_name)
      result[:messages_count] = @imap_client.status(folder_name, ["UNSEEN", "MESSAGES"])["MESSAGES"]

      if result[:messages_count] > 0
        range = 1 .. [result[:messages_count], options[:max_search]].min

        oldest_mails = @imap_client.fetch(range, "BODY[HEADER.FIELDS (From To Subject Date Sender)]").map do |header|
            Mail.read_from_string(header.attr.values.first)
        end.select do |mail|
            mail.date.utc < older_than_time.utc
        end

        result[:old_messages_count] = oldest_mails.count
        result[:old_messages] = oldest_mails.take(options[:max_fetch])
      else
        result[:old_messages_count] = 0
        result[:old_messages] = []
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

  def disconnect
    @imap_client.disconnect if connected?
  end

end
