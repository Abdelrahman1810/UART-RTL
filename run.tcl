vlib work

vlog {RTL/BaudGenerator/RxBaudGenerator.sv}
vlog {RTL/BaudGenerator/TxBaudGenerator.sv}
vlog {RTL/BaudGenerator/BaudRateGenerator.sv}

vlog {RTL/FIFO/register.sv}
vlog {RTL/FIFO/FIFO_CO.sv}
vlog {RTL/FIFO/FIFO.sv}

vlog {RTL/Rx/ReceiverSIPO.sv}
vlog {RTL/Rx/EvenParityCheck.sv}

vlog {RTL/Rx/RxUnit.sv}

vlog {RTL/Tx/TransmitterPISO.sv}
vlog {RTL/Tx/EvenParityCreat.sv}
vlog {RTL/Tx/TxUnit.sv}

vlog {RTL/UART.sv}

# vlog +define+BRD48 {uart_tb.sv}
vlog +define+BRD96 {testbench/uart_tb.sv}
# vlog +define+BRD57 {uart_tb.sv}
# vlog +define+BRD11 {uart_tb.sv}

vsim -voptargs=+acc work.uart_tb

add wave -position insertpoint  \
sim:/uart_tb/uart/Rx_clk \
sim:/uart_tb/uart/Tx_clk
add wave *

add wave -position insertpoint  \
sim:/uart_tb/in_rx/in

run -all
# quit -sim