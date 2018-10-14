# frozen_string_literal: true

module GymFinder
  class Reservation
    class Court
      attr_accessor :name, :pt
    end
    attr_accessor :available_courts
  end
end
