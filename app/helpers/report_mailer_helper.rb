module ReportMailerHelper

  def table_image(asset, bgc = 0xffffffff)
    image = ChunkyPNG::Image.from_file(Rails.root.join("app/assets/images", asset))

    image_lines = []
    image.height.times do |y|
      current_line = []
      x = 0
      while x < image.width
        w = 1
        color = image[x, y]
        x += 1
        while x < image.width && image[x, y] == color
          x += 1
          w += 1
        end
        color = ChunkyPNG::Color.compose(color, bgc)
        if color == bgc
          current_line << [w, false]
        else
          color = ChunkyPNG::Color.to_hex(color, false)
          current_line << [w, color]
        end
      end
      prev_line = image_lines.last
      if prev_line && current_line == prev_line.last
        prev_line[0] += 1
      else
        image_lines << [1, current_line]
      end
    end

    buffer = ""
    image_lines.each do |line|
      buffer << "<tr height=#{line.first}>"
        line.last.each do |cell|
          buffer << "<td width=#{cell.first} colspan=#{cell.first}"
          if cell.last
            buffer << " bgcolor=#{cell.last}"
          end
          buffer << "></td>"
        end
      buffer << "</tr>"
    end
    "<table cellspacing=0 cellpadding=0 style='width:#{image.width}px'>#{buffer}</table>".html_safe
  end

  def greet(mailbox)
    name = mailbox.user.first_name
    last_at = mailbox.last_report_sent_at
    zone = ActiveSupport::TimeZone[@mailbox.timezone]
    local = zone.utc_to_local(last_at.utc)
    message = case
    when local.hour < 12
    "Good morning"
    when local.hour > 12 && local.hour < 17
    "Good afternoon"
    else
    "Good evening"
    end
    "#{message}, #{name}!"
  end

  def report_sent_time(mailbox)
    last_at = mailbox.last_report_sent_at
    zone = ActiveSupport::TimeZone[@mailbox.timezone]
    I18n.l(zone.utc_to_local(last_at.utc), format: "%H:%M")
  end

end

