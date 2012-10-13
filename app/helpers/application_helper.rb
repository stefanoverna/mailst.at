module ApplicationHelper
  def quote(sentence)
    "\"#{sentence.gsub('.','')}\""
  end
end
