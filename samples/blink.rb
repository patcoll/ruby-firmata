class Blink
  def initialize(arduino)
    @arduino = arduino
  end
  
  def setup
    @arduino.pin_mode(9, Arduino::OUTPUT)
  end
  
  def draw
    @arduino.digital_write(9, Arduino::HIGH)
    @arduino.delay(1)
    @arduino.digital_write(9, Arduino::LOW)
    @arduino.delay(1)
  end
end
