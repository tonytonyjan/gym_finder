# frozen_string_literal: true

module GymFinder
  class TimeTable
    class TimeSlot
      attr_accessor :time, :court, :price, :status, :qpid

      def initialize(**params)
        params.each do |key, value|
          send("#{key}=", value)
        end
      end

      def ==(other_time_slot)
        %i[time court price status qpid].each do |name|
          return false unless send(name) == other_time_slot.send(name)
        end
        true
      end
    end
    attr_accessor :time_slots

    def available_time_slots
      time_slots.select { |time_slot| time_slot.status == 'available' }
    end
  end
end
