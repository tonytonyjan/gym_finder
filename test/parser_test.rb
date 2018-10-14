# frozen_string_literal: true

require 'minitest/autorun'
require 'gym_finder/parser'
require 'gym_finder/time_table'

module GymFinder
  class ParserTest < MiniTest::Test
    FIXTURES = %w[calendar reservation time_table].each_with_object({}) do |name, obj|
      obj[name] = IO.read("#{__dir__}/fixtures/#{name}.html")
    end

    def setup
      @parser = Parser.new
    end

    def test_parse_reservation
      reservation = @parser.parse_reservation(FIXTURES['reservation'])
      assert_equal %w[羽球 桌球 籃球 撞球 壁球].sort!, reservation.available_courts.map(&:name).sort!
      assert_equal %w[1 2 3 4 8], reservation.available_courts.map(&:pt)
    end

    def test_parse_calendar
      calendar = @parser.parse_calendar(FIXTURES['calendar'])
      require 'date'
      expected = [
        [10, 22],
        [10, 23],
        [10, 24],
        [10, 25],
        [10, 26],
        [10, 28],
        [10, 29],
        [10, 30],
        [10, 31],
        [11, 1],
        [11, 2]
      ].map! { |m, d| Date.new(2018, m, d) }
      assert_equal expected, calendar.available_dates
    end

    def test_parse_time_table
      time_table = @parser.parse_time_table(FIXTURES['time_table'])
      time_slots = time_table.time_slots
      assert_equal time_slots.first, TimeTable::TimeSlot.new(
        time: 12,
        court: '羽5',
        price: 300,
        status: 'available',
        qpid: '1089'
      )
      assert_equal time_slots.last, TimeTable::TimeSlot.new(
        time: 17,
        court: '羽10',
        price: 300,
        status: 'reserved'
      )
      assert_equal time_slots[5], TimeTable::TimeSlot.new(
        time: 12,
        court: '羽10',
        price: 300,
        status: 'reserved'
      )
    end
  end
end
