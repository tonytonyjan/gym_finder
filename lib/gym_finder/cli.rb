# frozen_string_literal: true

require 'gym_finder/client'
require 'gym_finder/post_processor'
require 'set'

module GymFinder
  class Cli
    def initialize(
      gyms: [],
      courts: [],
      hours: [],
      weekend: false,
      weekday: false,
      only_available: true,
      username: ENV['GYM_FINDER_USERNAME'],
      password: ENV['GYM_FINDER_PASSWORD']
    )
      bind = binding
      local_variables.each do |variable|
        instance_variable_set(
          "@#{variable}",
          bind.local_variable_get(variable)
        )
      end
      validate!
      @client = Client.new(username: username, password: password)
      @gym_filter = lambda { |gym|
        gyms.empty? ? true : gyms.any? { |name| gym.name.include?(name) }
      }
      @court_filter = lambda { |court|
        courts.empty? ? true : courts.any? { |name| court.name.include?(name) }
      }
      @date_filter = lambda { |date|
        return true unless weekend ^ weekday
        return date.sunday? || date.saturday? if weekend
        return !date.sunday? && !date.sunday if weekday
      }
    end

    def perform
      results = @client.fetch(
        gym_filter: @gym_filter,
        court_filter: @court_filter,
        date_filter: @date_filter
      )
      results = PostProcessor.new(results).available.slots if @only_available
      results = PostProcessor.new(results).hour_list(hour_list).slots unless @hours.empty?
      results
    end

    private

    def validate!
      if @username.nil?
        warn 'env GYM_FINDER_USERNAME is not set'
        exit 1
      elsif @password.nil?
        warn 'env GYM_FINDER_PASSWORD is not set'
        exit 1
      end
    end

    def hour_list
      @hours
        .map { |time| time.split('-').map(&:to_i) }
        .map! { |a| a.length == 2 ? a.first.upto(a.last - 1).to_a : a }
    end
  end
end
