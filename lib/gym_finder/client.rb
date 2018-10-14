# frozen_string_literal: true

require 'eventmachine'
require 'eventmachine'
require 'em-http-request'
require 'json'
require 'uri'
require 'gym_finder/gyms'
require 'gym_finder/parser'
require 'gym_finder/ocr'
require 'time'

module GymFinder
  class Client
    class Error < RuntimeError; end
    class CaptchaError < Error; end
    class Conn
      attr_accessor :cookie
      def initialize
        @conn = EventMachine::HttpRequest.new('https://scr.cyc.org.tw/')
        @pending = 0
        @processed = 0
      end

      def request(method, **params)
        client = @conn.send(method, keepalive: true, head: { 'cookie' => @cookie }, **params)
        @pending += 1
        client.callback do
          @processed += 1
          yield client
          print "\t#{(@processed.to_f / @pending * 100).round}%\r" if STDOUT.tty?
          @done.call if @pending == @processed && @done
        end
      end

      def post(**params, &block)
        request(:post, **params, &block)
      end

      def get(**params, &block)
        request(:get, **params, &block)
      end

      def done(&block)
        @done = block
      end
    end

    class Slot
      attr_accessor :gym, :court, :date, :time_slot, :client
      def initialize(gym:, court:, date:, time_slot:, client:)
        @gym = gym
        @court = court
        @date = date
        @time_slot = time_slot
        @client = client
      end

      def to_json(*args)
        {
          gym: @gym.name,
          type: @court.name,
          court: @time_slot.court,
          price: @time_slot.price,
          status: @time_slot.status,
          time: Time.new(@date.year, @date.month, @date.day, @time_slot.time).iso8601,
          gym_homepage: @gym.homepage,
          reservation_link: "https://#{@client.req.host}#{@client.req.path}?module=net_booking&files=booking_place&StepFlag=25&QPid=#{@time_slot.qpid}&QTime=#{@time_slot.time}&PT=#{@court.pt}&D=#{@date.strftime('%Y/%m/%d')}"
        }.to_json(*args)
      end
    end

    def initialize(
      username: ENV['GYM_FINDER_USERNAME'],
      password: ENV['GYM_FINDER_PASSWORD'],
      retry_captcha: 3
    )
      @parser = Parser.new
      @username = username
      @password = password
      @retry_captcha = retry_captcha
    end

    def fetch(*params)
      captcha_error_count = 0
      begin
        _fetch(*params)
      rescue CaptchaError => error
        captcha_error_count += 1
        raise error if captcha_error_count == @retry_captcha
        retry
      end
    end

    private

    def _fetch(
      gym_filter: ->(_gym) { true },
      court_filter: ->(_court) { true },
      date_filter: ->(_date) { true }
    )
      captcha_error_count = 0
      result = []
      EM.run do
        conn = Conn.new
        conn.done { EM.stop }
        conn.get(path: '/NewCaptcha.aspx') do |client|
          ocr = Ocr.new
          captcha_text = ocr.resolve(client.response)
          conn.cookie = client.response_header['SET_COOKIE'][/ASP\.NET_SessionId=\w+/]
          conn.post(
            path: '/tp03.aspx',
            query: 'module=login_page&files=login',
            body: {
              loginid: @username,
              loginpw: @password,
              Captcha_text: captcha_text
            }
          ) do |client|
            raise CaptchaError if client.response.include?('驗證碼錯誤')
            GYMS.select(&gym_filter).each do |gym|
              uri = URI(gym.reservation)
              conn.get(path: uri.path) do |client|
                @parser.parse_reservation(client.response).available_courts.select(&court_filter).each do |court|
                  query = "module=net_booking&files=booking_place&PT=#{court.pt}"
                  conn.get(path: client.req.path, query: query) do |client_calendar|
                    @parser.parse_calendar(client_calendar.response).available_dates.select(&date_filter).each do |date|
                      1.upto(3).each do |i|
                        query = "module=net_booking&files=booking_place&StepFlag=2&PT=#{court.pt}&D=#{date.strftime('%Y/%m/%d')}&D2=#{i}"
                        conn.get(path: client_calendar.req.path, query: query) do |client_time_table|
                          result.concat(
                            @parser
                              .parse_time_table(client_time_table.response)
                              .time_slots
                              .map do |time_slot|
                              Slot.new(
                                gym: gym,
                                court: court,
                                date: date,
                                time_slot: time_slot,
                                client: client_time_table
                              )
                            end
                          )
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      result
    end
  end
end
