# PCIe Data Link Layer (TX) 
This code implements the transmission module (PCIE_DLL_TX) of the PCIe (Peripheral Component Interconnect Express) Data Link Layer. This module handles the interface between the Transaction Layer (TL) and the Physical Layer (PL), processes received Data Link Layer Protocol Packets (DLLP), and transmits Transaction Layer Packets (TLP).

<img width="1107" alt="image" src="https://github.com/junseung2/PCIe_Controller_with_UVM/assets/105153659/96aa6a6b-58cc-4d03-a20c-d5a877440ccf">

# Main Input and Output Signals
## Input Signals:
* clk: Clock signal
* rst_n: Reset signal (active low)
* tlp_valid_i: TLP valid signal from the Transaction Layer
* tlp_i: TLP data from the Transaction Layer
* tlp_ready_i: TLP ready signal from the Physical Layer
* dllp_in: Received DLLP packet
* dllp_valid_i: DLLP valid signal
* tlp_blocking_i: TLP blocking signal during retry

 ## Output Signals:
 * tlp_ready_o: TLP ready signal to the Transaction Layer
 * tlp_valid_o: TLP valid signal to the Physical Layer
 * tlp_o: TLP data to the Physical Layer
 
# Main Internal Logic
## Sequence Number (seq_num) and CRC Generation:
* seq_num is the sequence number assigned to the TLP packet.
* crc is the CRC32 value for error detection of the TLP data.
* The crc32_generator instance generates the CRC value for the TLP data.

## Retry Buffer:
* retry_buffer is a FIFO buffer used to store TLP packets for retry purposes. The depth of this buffer is 4096.
* wr_ptr and rd_ptr are the write and read pointers, respectively, indicating positions within the buffer.
* retry_empty and retry_full indicate whether the buffer is empty or full, respectively.

## State Update and TLP Transmission:
* The always_ff block updates the sequence number, pointers, and buffer status based on the clock or reset signal.
* The always_comb block contains logic for sequence number updates, retry buffer handling, DLLP processing, and TLP transmission.

## DLLP Processing:
* When dllp_valid_i is active, it processes dllp_in based on its value.
* For ACK (dllp_in.ack_or_nak == 8'h00), it updates the read pointer based on the acknowledged sequence number and reads data from the buffer to transmit the TLP.
* For NAK (dllp_in.ack_or_nak == 8'h10), it retransmits the TLP from the retry buffer corresponding to the sequence number.

## TLP Transmission:
* When a valid TLP is received from the Transaction Layer and the buffer is not full, it stores the TLP in the retry buffer and transmits it to the Physical Layer.
* It assigns the sequence number and CRC to the TLP, sets the tlp_o output, and activates the tlp_valid_o signal.

