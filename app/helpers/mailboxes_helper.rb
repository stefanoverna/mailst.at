module MailboxesHelper

  class TimeZone < Struct.new(:title, :id)
  end

  def timezones_collection
    time_zones_by_utc_offset = {}
    TZInfo::Timezone.all_country_zones.each do |time_zone|
      time_zones_by_utc_offset[time_zone.current_period.utc_offset] ||= []
      time_zones_by_utc_offset[time_zone.current_period.utc_offset] << time_zone
    end

    # sort time_zones_sorted_by_utc_offset
    time_zones_sorted_by_utc_offset = []
    Hash[time_zones_by_utc_offset.sort].each_pair do |offset, time_zones|
      offset = sprintf("%+d", offset / 3600)
      time_zones.each do |time_zone|
        timezone = TimeZone.new(
          "#{time_zone.friendly_identifier} (UTC/GMT #{offset})",
          time_zone.identifier
        )
        time_zones_sorted_by_utc_offset << timezone
      end
    end

    time_zones_sorted_by_utc_offset
  end

end
