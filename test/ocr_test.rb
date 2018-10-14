# frozen_string_literal: true

require 'minitest/autorun'
require 'gym_finder/ocr'

module GymFinder
  class OcrTest < MiniTest::Test
    def setup
      @ocr = Ocr.new
    end

    def test_resolve
      assert_equal "13062", @ocr.resolve(image(13062))
      assert_equal "21244", @ocr.resolve(image(21244))
      assert_equal "23590", @ocr.resolve(image(23590))
    end

    private

    def image(name)
      IO.read("#{__dir__}/fixtures/#{name}.gif", mode: 'rb')
    end
  end
end
