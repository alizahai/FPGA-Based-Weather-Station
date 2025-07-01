# FPGA Weather Station with DHT11 Sensor

A comprehensive weather monitoring system implemented on Xilinx Spartan-6 FPGA (Nexys 3 board) using Verilog HDL. This project interfaces with a DHT11 temperature and humidity sensor and displays real-time measurements on a 7-segment display.

## 🌟 Features

- **Real-time Monitoring**: Continuous temperature and humidity readings from DHT11 sensor
- **Dual Display Mode**: Alternates between temperature (°C) and humidity (Hr) display every few seconds
- **7-Segment Display**: Clear numerical readout with custom characters for units
- **Visual Feedback**: LED indicator shows data transfer activity
- **Robust Communication**: State machine-based DHT11 protocol implementation with error handling
- **Modular Design**: Clean, reusable code architecture

## 📋 Specifications

- **Target Platform**: Xilinx Spartan-6 FPGA (Nexys 3 Board)
- **Clock Frequency**: 100 MHz input clock
- **Sensor**: DHT11 Temperature & Humidity Sensor
- **Display**: 4-digit 7-segment display
- **Communication**: Single-wire bidirectional protocol
- **Update Rate**: Approximately every 500ms

## 🔧 Hardware Setup

### Required Components
- Xilinx Nexys 3 FPGA Development Board
- DHT11 Temperature & Humidity Sensor
- Connecting wires
- Breadboard (optional)

### Pin Connections
```
DHT11 Sensor:
- VCC  → 3.3V power supply
- GND  → Ground
- DATA → FPGA I/O pin (configurable via constraints file)

FPGA Outputs:
- 7-segment display (built-in on Nexys 3)
- LED indicator for data transfer status
```

## 🏗️ Architecture Overview

The project consists of five main modules:

### 1. `weather_station_top` (Top Module)
- **Purpose**: System integration and control
- **Functions**: 
  - Coordinates all subsystems
  - Manages display switching logic
  - Handles data flow between modules

### 2. `DHT11` (Sensor Interface)
- **Purpose**: DHT11 sensor communication
- **Functions**:
  - Implements DHT11 single-wire protocol
  - State machine for reliable data acquisition
  - Error detection and timeout handling
  - Generates 1MHz clock for precise timing

### 3. `binarytoBCD` (Data Conversion)
- **Purpose**: Binary to BCD conversion
- **Functions**:
  - Converts 8-bit binary sensor data to BCD format
  - Separates hundreds, tens, and units digits
  - Implements double-dabble algorithm

### 4. `BCDto7segment` (Display Decoder)
- **Purpose**: BCD to 7-segment encoding
- **Functions**:
  - Maps BCD digits to 7-segment patterns
  - Supports hexadecimal characters (A-F)
  - Handles special characters and blank display

### 5. `sevenSegDisplay` (Display Controller)
- **Purpose**: 7-segment display multiplexing
- **Functions**:
  - Time-division multiplexing for 4-digit display
  - Refresh rate management
  - Individual digit control

## 🔄 DHT11 Communication Protocol

The DHT11 module implements a complete state machine for reliable sensor communication:

### Communication States
1. **IDLE**: Initial state, line pulled high
2. **START_LOW**: MCU pulls line low for 20ms
3. **START_HIGH**: MCU releases line for 40µs
4. **WAIT_RESPONSE**: Wait for DHT11 response (80µs low)
5. **WAIT_RESPONSE_HIGH**: Wait for DHT11 ready signal (80µs high)
6. **WAIT_BIT_LOW**: Wait for bit start (50µs low)
7. **WAIT_BIT_HIGH**: Wait for bit data (variable high)
8. **MEASURE_BIT**: Measure pulse width to determine bit value
9. **PROCESS_DATA**: Extract temperature and humidity values
10. **DELAY**: 500ms delay before next reading

### Data Format
- **40 bits total**: 8-bit humidity + 8-bit humidity decimal + 8-bit temperature + 8-bit temperature decimal + 8-bit checksum
- **Bit encoding**: 
  - '0' = 50µs low + 26-28µs high
  - '1' = 50µs low + 70µs high

## 📊 Display Format

The system alternates between two display modes:

### Temperature Mode
```
XX°C
```
- Shows temperature in Celsius
- Custom degree symbol (°) 
- 'C' character for Celsius

### Humidity Mode
```
XXHr
```
- Shows relative humidity percentage
- 'H' character for humidity
- 'r' character for relative

## 🚀 Getting Started

### Prerequisites
- Xilinx ISE or Vivado Design Suite
- Nexys 3 FPGA Board
- DHT11 Sensor Module

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/fpga-weather-station.git
   cd fpga-weather-station
   ```

2. **Open in Xilinx ISE**
   - Create new project targeting Spartan-6 XC6SLX16
   - Add all Verilog source files
   - Set `weather_station_top` as top module

3. **Configure Constraints**
   - Create UCF file with pin assignments
   - Map `dht11_io` to appropriate I/O pin
   - Configure 7-segment display and LED pins

4. **Synthesize and Implement**
   - Run synthesis
   - Run implementation
   - Generate programming file (.bit)

5. **Program FPGA**
   - Connect Nexys 3 board
   - Program with generated bitstream
   - Connect DHT11 sensor

## 📁 File Structure

```
fpga-weather-station/
├── src/
│   ├── weather_station_top.v      # Top-level module
│   ├── DHT11.v                    # DHT11 sensor interface
│   ├── binarytoBCD.v              # Binary to BCD converter
│   ├── BCDto7segment.v            # BCD to 7-segment decoder
│   └── sevenSegDisplay.v          # Display multiplexer
├── constraints/
│   └── top.ucf                    # Pin constraint file
├── docs/
│   └── block_diagram.png          # System architecture
│   └── Hardware_demonstration.mp4 # Prototype Demo
└── LICENSE                        # LICENSE file
└── README.md                      # This file
```

## 🔍 Troubleshooting

### Common Issues

**No Display Output**
- Check power connections
- Verify pin constraints match hardware
- Ensure clock is properly distributed

**Incorrect Readings**
- Verify DHT11 wiring
- Check timing constraints
- Ensure stable power supply (DHT11 is sensitive to power quality)

**Display Flickering**
- Adjust display refresh rate
- Check for timing violations
- Verify multiplexing logic

### Debug Features
- LED indicator shows communication activity
- Error states set sensor values to 0xFF for identification
- Timeout mechanisms prevent system lockup

## 🎯 Future Enhancements

- [ ] Add temperature unit conversion (Fahrenheit)
- [ ] Add wireless connectivity (WiFi/Bluetooth)
- [ ] Include additional sensors (pressure, light)
- [ ] Add LCD display support

## 📈 Performance Metrics

- **Update Rate**: ~2 Hz (500ms intervals)
- **Accuracy**: ±2°C temperature, ±5% humidity (DHT11 specifications)
- **Response Time**: <1 second for display update
- **Resource Utilization**: 
  - Logic Cells: ~150 (minimal footprint)
  - Memory: No external memory required
  - Clock Domains: Single 100MHz domain

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for:
- Bug fixes
- Feature enhancements
- Documentation improvements
- Performance optimizations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📌 Acknowledgments

- Developed as part of FPGA Hackathon, Fourth Semester
- DHT11 datasheet and protocol specifications
- Xilinx documentation and examples
- FPGA development community resources

## 📞 Contact

For questions or collaboration opportunities, please reach out through GitHub issues or contact [alizahayder786@example.com].

---

**Note**: This project demonstrates practical FPGA development skills including state machine design, sensor interfacing, display control, and modular programming practices. It serves as an excellent foundation for more complex embedded systems projects.
