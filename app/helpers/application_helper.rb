module ApplicationHelper

  def t(name, options = {})
    I18n.t(name).html_safe
  end

  def form_error_messages(form, resource)
    if resource.errors.present?
      content_tag :div, {:class => "form_errors" } do
        content_tag(:p, form.error_notification) +
        content_tag(:ul, resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join.html_safe)
      end
    else
      ""
    end
  end

  def quote(sentence)
    "\"#{sentence.gsub('.','')}\""
  end

  def overdue_l(count)
    if count == 100
      "+100"
    else
      count
    end
  end
end
