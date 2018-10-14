require 'json'
require 'gym_finder/gym'

module GymFinder
  GYMS = JSON.parse(IO.read("#{__dir__}/gyms.json")).map! do |element|
    Gym.new.tap do |gym|
      gym.name = element['name']
      gym.homepage = element['homepage']
      gym.reservation = element['reservation']
    end
  end
end