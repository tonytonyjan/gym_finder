# frozen_string_literal: true

require 'minitest/autorun'
require 'gym_finder/client'

module GymFinder
  class ClientTest < MiniTest::Test
    def setup
      @client = Client.new
    end

    def test_fetch
      p @client.fetch(gym_filter: ->(gym) { gym.name =~ /中山/ })
    end
  end
end
