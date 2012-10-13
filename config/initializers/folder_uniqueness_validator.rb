class FolderUniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "IMAP folder names must be unique" unless value.map(&:imap_name).uniq.size == value.size
  end
end
