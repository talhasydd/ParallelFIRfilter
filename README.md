# Parallel FIR Filter Implementation in VHDL

This project implements a parallel Finite Impulse Response (FIR) filter in VHDL. The filter is designed with configurable data width, coefficient width, and number of taps.

## Table of Contents
1. [Overview](#overview)
2. [Implementation Details](#implementation-details)
3. [Key Components](#key-components)
4. [Data Flow and Convolution](#data-flow-and-convolution)
5. [Output Calculation](#output-calculation)
6. [Testbench](#testbench)
7. [Impulse Response](#impulse-response)

## Overview

The FIR filter is implemented using a parallel architecture, which computes the filter output for each input sample in a single clock cycle. This design offers high throughput at the cost of increased hardware resources.

## Implementation Details

### Generic Parameters
- `data_width`: Width of input and output data (default: 16 bits)
- `coeff_width`: Width of filter coefficients (default: 16 bits)
- `TAPS`: Number of filter taps (default: 8)

### Port Definitions
- `clk`: System clock
- `reset`: Asynchronous reset
- `data_in`: Input data (data_width bits)
- `data_out`: Output data (data_width bits)
- `data_valid`: Input data valid signal
- `output_valid`: Output data valid signal

## Key Components

### Arrays and Signals
1. `coeff_array`: 
   - Type: Array of signed values
   - Size: TAPS x coeff_width bits
   - Purpose: Stores filter coefficients

2. `SR_array` (Shift Register):
   - Type: Array of signed values
   - Size: TAPS x data_width bits
   - Purpose: Stores recent input samples

3. `mult_array`:
   - Type: Array of signed values
   - Size: TAPS x (data_width + coeff_width) bits
   - Purpose: Stores multiplication results

4. `acc_result`:
   - Type: Signed
   - Width: data_width + coeff_width + TAPS + 1 bits
   - Purpose: Accumulates the sum of all multiplications

### Constants
- `acc_width`: Width of accumulator (data_width + coeff_width + TAPS)
- `output_shift`: Shift amount for output scaling (coeff_width + TAPS - 1)

## Data Flow and Convolution

1. Input Sampling:
   - New input data is shifted into the SR array on each valid input.

2. Parallel Multiplication:
   - Each element in SR is multiplied with its corresponding coefficient.

3. Accumulation:
   - All multiplication results are summed to produce the filter output.

4. Output Generation:
   - The accumulated result is scaled and truncated to produce the final output.

## Output Calculation

The output is calculated as follows:
1. Multiply each input sample with its corresponding coefficient.
2. Sum all products.
3. Scale the result by right-shifting: `output_shift = coeff_width + TAPS - 1`
4. Truncate to `data_width` bits.

Formula: `data_out = Σ(input[i] * coeff[i]) >> output_shift`

## Testbench

The testbench (`FIRfilterTB.vhd`) performs the following:

1. Generates a clock signal with a 10ns period.
2. Applies a reset signal for 40ns.
3. Introduces an impulse input (maximum 16-bit value: 32767).
4. Provides zero inputs for the remaining simulation time.
5. Monitors the filter's response to this impulse input.

## Impulse Response

The impulse response of the filter can be observed in the `data_out` signal:
- It will show scaled versions of the coefficients in sequence.
- Each output value represents: `(32767 * coefficient[i]) >> output_shift`
- This sequence demonstrates the filter's response characteristics.

The impulse response provides insight into the filter's frequency response and its behavior in the time domain.
