# gem install ruby-serialport if needed
require "serialport"

class Arduino
  # pin modes
  INPUT = 0
  OUTPUT = 1
  ANALOG = 2
  PWM = 3
  SERVO = 4
  SHIFT = 5
  I2C = 6

  LOW = 0
  HIGH = 1
  MAX_DATA_BYTES = 32
  
  DIGITAL_MESSAGE = 0x90 # send data for a digital port
  ANALOG_MESSAGE = 0xE0 # send data for an analog pin (or PWM)
  REPORT_ANALOG = 0xC0 # enable analog input by pin #
  REPORT_DIGITAL = 0xD0 # enable digital input by port
  SET_PIN_MODE = 0xF4 # set a pin to INPUT/OUTPUT/PWM/etc
  REPORT_VERSION = 0xF9 # report firmware version
  SYSTEM_RESET = 0xFF # reset from MIDI
  START_SYSEX = 0xF0 # start a MIDI SysEx message
  END_SYSEX = 0xF7 # end a MIDI SysEx message
  
  def initialize(device, baud=57600)
    @device = device
    @baud = baud
    @serial_port = SerialPort.new(device, baud, 8, 1, SerialPort::NONE)
    @wait_for_data = 0
    @execute_multi_byte_command = 0
    @multi_byte_channel = 0
    @stored_input_data = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ,0, 0, 0 ]
    @parsing_sysex = false
    @sysex_bytes_read = 0
    @digital_output_data = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
    @digital_input_data  = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
    @analog_input_data   = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
    @major_version = 0
    @minor_version = 0
    report
  end
  
  def to_s
    "Arduino <%s>" % @device
  end
  
  def run(klass)
    obj = klass.new(self)
    obj.setup
    begin
      while true do
        obj.draw
      end
    ensure
      @serial_port.close
    end
  end
  
  def pin_mode(pin, mode)
    write(SET_PIN_MODE)
    write(pin)
    write(mode)
  end
  
  # Reading from digital pin
  def digital_read(pin)
    (@digital_input_data[pin >> 3] >> (pin & 0x07)) & 0x01
  end
  
  # Writing to a digital pin
  def digital_write(pin, value)
    port_number = (pin >> 3) & 0x0F
    
    if value == 0
      @digital_output_data[port_number] &= ~(1 << (pin & 0x07))
    else
      @digital_output_data[port_number] |= (1 << (pin & 0x07))
    end
    
    write(DIGITAL_MESSAGE | port_number)
    write(@digital_output_data[port_number] & 0x7F)
    write(@digital_output_data[port_number] >> 7)
  end
  
  # Reading from analog pin
  def analog_read(pin)
    @analog_input_data[pin]
  end
  
  # Writing to a analog pin
  def analog_write(pin, value)
    pin_mode(pin, PWM)
    write(ANALOG_MESSAGE | (pin & 0x0F))
    write(value & 0x7F)
    write(value >> 7)
  end
  
  # Setting a minor and major version
  def set_version(major, minor)
    @major_version = major
    @minor_version = minor
  end
  
  # Waiting in seconds
  def delay(seconds)
    sleep(seconds)
  end
  
  private
  
  def write(value)
    @serial_port.write(value.to_i.chr)
  end
  
  # Reporting analog and digital pins
  def report
    (0..15).each do |i|
      write(REPORT_ANALOG | i)
      write(1)
    end
    
    (0..1).each do |i|
      write(REPORT_DIGITAL | i)
      write(1)
    end

    sleep 3
  end
end