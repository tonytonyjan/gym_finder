# frozen_string_literal: true

require 'nokogiri'
require 'date'
require 'gym_finder/time_table'
require 'gym_finder/calendar'
require 'gym_finder/reservation'

module GymFinder
  class Parser
    def parse_reservation(html)
      doc = Nokogiri::HTML(html)
      selector = 'img[onclick*="net_booking"]'
      Reservation.new.tap do |reservation|
        reservation.available_courts = doc.css(selector).map do |node|
          Reservation::Court.new.tap do |court|
            court.name = node['title']
            court.pt = node['onclick'][/PT=(\d+)/, 1]
          end
        end
      end
    end

    def parse_calendar(html)
      doc = Nokogiri::HTML(html)
      dates_selector = 'td[bgcolor="#87C675"]'
      Calendar.new.tap do |calendar|
        calendar.available_dates = doc.css(dates_selector).map do |node|
          Date.strptime(node.at_css('img')['onclick'][%r{\d{4}/\d{2}/\d{2}}], '%Y/%m/%d')
        end
      end
    end

    def parse_time_table(html)
      doc = Nokogiri::HTML(html)
      TimeTable.new.tap do |table|
        table.time_slots = doc.css('#ContentPlaceHolder1_Step2_data tr:not(:first-child)').map do |row|
          TimeTable::TimeSlot.new.tap do |time_slot|
            time_slot.time = row.at_css('td:first-child').text[/(\d+):\d+~\d+\d+/, 1].to_i
            time_slot.court = row.at_css('td:nth-child(2)').text
            time_slot.price = row.at_css('td:nth-child(3)').text.to_i
            img = row.at_css('td:last-child > img')
            img_src = img['src']
            case img_src
            when 'img/sche01.png'
              time_slot.status = 'available'
              time_slot.qpid = img['onclick'][/Step3Action\((\d+),\d+\)/, 1]
            when 'img/sche02.jpg'
              time_slot.status = 'reserved'
            else
              warn "unknown status: #{img_src}"
              'unknown'
            end
          end
        end
      end
    end
  end
end
