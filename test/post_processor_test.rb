# frozen_string_literal: true

require 'minitest/autorun'
require 'gym_finder/post_processor'
require 'gym_finder/client'
require 'gym_finder/time_table'

module GymFinder
  class PostProcessorTest < MiniTest::Test
    def test_available
      slots = [
        new_slot(gym: 'foo', time_slot: { status: 'reserved' }),
        new_slot(gym: 'bar', time_slot: { status: 'available' }),
        new_slot(gym: 'buz', time_slot: { status: 'available' })
      ]
      assert_equal %w[bar buz], PostProcessor.new(slots).available.slots.map(&:gym).sort
    end

    def test_hour_list
      slots = [
        new_slot(gym: 'foo', date: Date.new(2018, 11, 23), time_slot: { time: 11 }),
        new_slot(gym: 'foo', date: Date.new(2018, 11, 23), time_slot: { time: 10 }),
        new_slot(gym: 'foo', date: Date.new(2018, 11, 23), time_slot: { time: 12 }),
        new_slot(gym: 'foo', date: Date.new(2018, 11, 23), time_slot: { time: 13 }),
        new_slot(gym: 'foo', date: Date.new(2018, 11, 23), time_slot: { time: 14 }),
        new_slot(gym: 'foo', date: Date.new(2018, 11, 23), time_slot: { time: 15 }),
        new_slot(gym: 'bar', date: Date.new(2018, 11, 23), time_slot: { time: 10 }),
        new_slot(gym: 'bar', date: Date.new(2018, 11, 23), time_slot: { time: 15 })
      ]
      expected = [['foo', 11], ['foo', 10], ['foo', 15], ['bar', 15]].sort!
      assert_equal expected, PostProcessor.new(slots).hour_list([[10, 11], [15]]).slots.map { |slot| [slot.gym, slot.time_slot.time] }.sort!
    end

    private

    def new_slot(**params)
      time_slot_params = params.delete(:time_slot)
      base = {
        gym: 'foo',
        court: 'bar',
        date: Date.today,
        time_slot: TimeTable::TimeSlot.new(**time_slot_params),
        client: nil
      }
      Client::Slot.new(**base, **params)
    end
  end
end
