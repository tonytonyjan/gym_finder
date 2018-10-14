# frozen_string_literal: true

require 'set'

module GymFinder
  class PostProcessor
    attr_reader :slots
    def initialize(slots)
      @slots = slots
    end

    def available
      PostProcessor.new(@slots.select { |slot| slot.time_slot.status == 'available' })
    end

    def hour_list(list)
      results = []
      @slots.group_by { |slot| [slot.gym, slot.date] }.each do |_, slots|
        list.each do |hours|
          if Set.new(hours).subset?(Set.new(slots.map { |slot| slot.time_slot.time }))
            results.concat(slots.select { |slot| hours.include? slot.time_slot.time })
          end
        end
      end
      PostProcessor.new(results)
    end
  end
end
