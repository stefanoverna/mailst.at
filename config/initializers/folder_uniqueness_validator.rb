class FolderUniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "cannot refer to the same IMAP folder" unless value.map(&:imap_name).uniq.size == value.size
  end
end
