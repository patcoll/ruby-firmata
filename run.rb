$:.unshift File.join(File.dirname(__FILE__), 'lib')
Dir[File.join(File.dirname(__FILE__), 'samples', '*')].each { |sample| require sample }

require "rubygems"
require "arduino"

arduino = Arduino.new(Dir["/dev/tty.usbserial*"][0], 57600)
arduino.run(Button)
