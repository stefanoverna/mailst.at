require 'rspec'
require 'tzinfo'
require 'active_support/all'
require 'timecop'
require 'ostruct'
require_relative '../../app/services/reports_sender'

describe ReportsSender do

  describe "#report_sending_time" do

    it "should return a today time" do
      Timecop.freeze("2012-10-21T07:00:00+00:00".to_datetime) do
        mailbox = OpenStruct.new(timezone: 'Europe/Rome', report_time_hour: 10)
        report_time = ReportsSender.report_sending_time(mailbox)
        report_time.should == "2012-10-21T10:00:00+02:00".to_datetime
      end
    end

    it "should return a tomorrow day time" do
      Timecop.freeze("2012-10-21T08:01:00+00:00".to_datetime) do
        mailbox = OpenStruct.new(timezone: 'Europe/Rome', report_time_hour: 10)
        report_time = ReportsSender.report_sending_time(mailbox)
        report_time.should == "2012-10-22T10:00:00+02:00".to_datetime
      end
    end

  end

end

