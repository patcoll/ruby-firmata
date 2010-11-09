class Button
  def initialize(arduino)
    @arduino = arduino
    @brightness = 0
    @fade_amount = 5
  end
  
  def setup
    @arduino.pin_mode(2, Arduino::INPUT)
    @arduino.pin_mode(9, Arduino::OUTPUT)
  end
  
  def draw
    @arduino.parse
    # p @arduino.digital_input_data
    # p @arduino.digital_read(2)
    # @arduino.delay(1)
    # p "button" if @arduino.digital_read(2)
    @arduino.analog_write(9, @brightness)
    @brightness += @fade_amount
    if @brightness == 0 or @brightness == 255
      @fade_amount = -@fade_amount
    end
    @arduino.delay(0.03)
  end
end
