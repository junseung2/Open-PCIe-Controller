module ltssm (
    input logic clk,
    input logic reset,
    
    input logic electrical_idle,
    input logic timeout,
    input logic receiver_detected,
    input logic enter_compliance,
    input logic ts1_received,
    input logic ts2_received,
    input logic linkwidth_negotiated,
    input logic lanenum_negotiated,
    input logic fts_sent,
    input logic speed_change,
    input logic link_width_change,
    input logic redo_equalization,
    input logic link_error,
    input logic bit_lock,
    input logic symbol_lock,
    input logic block_lock,
    input logic eq_phase_0,
    input logic eq_phase_1,
    input logic eq_phase_2,
    input logic eq_phase_3,
    input logic directed,
    input logic idle_exit,
    input logic skp_received,
    input logic directed_event,
    input logic signal_received,
    input logic beacon_detected,

    output logic [10:0] state
);

    // Define states
    typedef enum logic [10:0] {
        DETECT_QUIET,            // Initial quiet state waiting for electrical idle to end
        DETECT_ACTIVE,           // Active detection of receiver
        POLLING_ACTIVE,          // Active polling to establish link parameters
        POLLING_COMPLIANCE,      // Compliance mode during polling
        POLLING_CONFIGURATION,   // Configuration mode during polling
        CONFIG_LINKWIDTH_START,  // Start link width configuration
        CONFIG_LINKWIDTH_ACCEPT, // Accept link width configuration
        CONFIG_LANENUM_WAIT,     // Wait for lane number negotiation
        CONFIG_LANENUM_ACCEPT,   // Accept lane number negotiation
        CONFIG_COMPLETE,         // Complete configuration
        CONFIG_IDLE,             // Idle configuration state before active
        L0_ACTIVE,               // Active data transmission state
        TX_L0S_ENTRY,            // Transmitter entering L0s state (low power)
        TX_L0S_IDLE,             // Transmitter in L0s idle state
        TX_L0S_FTS,              // Transmitter sending Fast Training Sequences (FTS)
        RX_L0S_ENTRY,            // Receiver entering L0s state
        RX_L0S_IDLE,             // Receiver in L0s idle state
        RX_L0S_FTS,              // Receiver sending FTS
        L1_ENTRY,                // Entry into L1 state (low power)
        L1_IDLE,                 // Idle in L1 state
        L2_IDLE,                 // Idle in L2 state (lowest power)
        L2_TRANSMIT_WAKE,        // Transmit wake-up in L2 state
        HOT_RESET,               // Hot reset state
        DISABLED,                // Disabled state
        LOOPBACK_ENTRY,          // Entry into loopback state
        LOOPBACK_ACTIVE,         // Active loopback state
        LOOPBACK_EXIT,           // Exit from loopback state
        RECOVERY_RCVRLOCK,       // Recovery: receiver lock
        RECOVERY_RCVRCFG,        // Recovery: receiver configuration
        RECOVERY_EQUALIZATION_PHASE_0, // Recovery: equalization phase 0
        RECOVERY_EQUALIZATION_PHASE_1, // Recovery: equalization phase 1
        RECOVERY_EQUALIZATION_PHASE_2, // Recovery: equalization phase 2
        RECOVERY_EQUALIZATION_PHASE_3, // Recovery: equalization phase 3
        RECOVERY_SPEED,          // Recovery: speed change
        RECOVERY_IDLE            // Recovery: idle state
    } ltssm_state_t;

    // State registers
    ltssm_state_t current_state, next_state;

    // Output logic
    always_comb begin
        next_state = current_state; // Default to staying in the current state

        case (current_state)
            // Detect state: initial detection of the receiver
            DETECT_QUIET: begin
                if (!electrical_idle || timeout)
                    next_state = DETECT_ACTIVE; // Transition to DETECT_ACTIVE if electrical idle ends or timeout
            end

            DETECT_ACTIVE: begin
                if (receiver_detected)
                    next_state = POLLING_ACTIVE; // Transition to POLLING_ACTIVE if receiver is detected
                else
                    next_state = DETECT_QUIET; // Return to DETECT_QUIET if no receiver is detected
            end

            // Polling state: establish link width and speed
            POLLING_ACTIVE: begin
                if (enter_compliance)
                    next_state = POLLING_COMPLIANCE; // Enter compliance mode if compliance bit is set
                else if (ts1_received && ts2_received)
                    next_state = POLLING_CONFIGURATION; // Transition to POLLING_CONFIGURATION if TS1 and TS2 are received
                else if (timeout)
                    next_state = DETECT_QUIET; // Return to DETECT_QUIET on timeout
            end

            POLLING_COMPLIANCE: begin
                if (!enter_compliance)
                    next_state = POLLING_ACTIVE; // Return to POLLING_ACTIVE if compliance bit is cleared
            end

            POLLING_CONFIGURATION: begin
                if (timeout)
                    next_state = DETECT_QUIET; // Return to DETECT_QUIET on timeout
                else if (ts2_received)
                    next_state = CONFIG_LINKWIDTH_START; // Transition to CONFIG_LINKWIDTH_START if TS2 is received
            end

            // Configuration state: configure link parameters
            CONFIG_LINKWIDTH_START: begin
                if (linkwidth_negotiated)
                    next_state = CONFIG_LINKWIDTH_ACCEPT; // Transition to CONFIG_LINKWIDTH_ACCEPT if link width is negotiated
                else if (timeout)
                    next_state = DETECT_QUIET; // Return to DETECT_QUIET on timeout
            end

            CONFIG_LINKWIDTH_ACCEPT: begin
                next_state = CONFIG_LANENUM_WAIT; // Proceed to lane number negotiation
            end

            CONFIG_LANENUM_WAIT: begin
                if (lanenum_negotiated)
                    next_state = CONFIG_LANENUM_ACCEPT; // Transition to CONFIG_LANENUM_ACCEPT if lane number is negotiated
                else if (timeout)
                    next_state = DETECT_QUIET; // Return to DETECT_QUIET on timeout
            end

            CONFIG_LANENUM_ACCEPT: begin
                next_state = CONFIG_COMPLETE; // Complete configuration
            end

            CONFIG_COMPLETE: begin
                if (timeout)
                    next_state = DETECT_QUIET; // Return to DETECT_QUIET on timeout
                else
                    next_state = CONFIG_IDLE; // Move to idle configuration state
            end

            CONFIG_IDLE: begin
                next_state = L0_ACTIVE; // Transition to L0 Active state
            end

            // L0 state: active data transmission
            L0_ACTIVE: begin
                if (speed_change || link_width_change || redo_equalization || link_error)
                    next_state = RECOVERY_RCVRLOCK; // Go to recovery if there's a speed change, link width change, re-equalization, or link error
                else if (electrical_idle)
                    next_state = TX_L0S_ENTRY; // Enter L0s state if electrical idle is detected
            end

            // L0s state: low power state
            TX_L0S_ENTRY: begin
                if (timeout)
                    next_state = TX_L0S_IDLE; // Transition to TX_L0S_IDLE on timeout
            end

            TX_L0S_IDLE: begin
                if (directed)
                    next_state = TX_L0S_FTS; // Send Fast Training Sequences if directed
                else if (idle_exit)
                    next_state = L0_ACTIVE; // Return to L0_ACTIVE on idle exit
            end

            TX_L0S_FTS: begin
                if (fts_sent)
                    next_state = L0_ACTIVE; // Return to L0_ACTIVE after FTS is sent
            end

            RX_L0S_ENTRY: begin
                if (timeout)
                    next_state = RX_L0S_IDLE; // Transition to RX_L0S_IDLE on timeout
            end

            RX_L0S_IDLE: begin
                if (idle_exit)
                    next_state = L0_ACTIVE; // Return to L0_ACTIVE on idle exit
                else if (timeout)
                    next_state = RECOVERY_RCVRLOCK; // Go to recovery on timeout
            end

            RX_L0S_FTS: begin
                if (fts_sent || skp_received)
                    next_state = L0_ACTIVE; // Return to L0_ACTIVE after FTS is sent or SKP is received
            end

            // L1 state: low power state with more power saving than L0s
            L1_ENTRY: begin
                if (timeout)
                    next_state = L1_IDLE; // Transition to L1_IDLE on timeout
            end

            L1_IDLE: begin
                if (idle_exit)
                    next_state = RECOVERY_RCVRLOCK; // Go to recovery on idle exit
            end

            // L2 state: lowest power state
            L2_IDLE: begin
                if (directed_event || beacon_detected)
                    next_state = L2_TRANSMIT_WAKE; // Transmit wake-up if directed event or beacon is detected
                else if (idle_exit)
                    next_state = DETECT; // Return to DETECT on idle exit
            end

            L2_TRANSMIT_WAKE: begin
                if (idle_exit)
                    next_state = DETECT; // Return to DETECT on idle exit
                else
                    next_state = L2_IDLE; // Return to L2_IDLE
            end

            // Hot Reset state: reset the link
            HOT_RESET: begin
                if (timeout || (ts1_received && ts2_received))
                    next_state = DETECT; // Return to DETECT on timeout or after receiving TS1 and TS2
                else if (directed)
                    next_state = RECOVERY_RCVRLOCK; // Go to recovery if directed
            end

            // Disabled state: link is disabled
            DISABLED: begin
                if (directed || !electrical_idle || timeout)
                    next_state = DETECT; // Return to DETECT if directed, electrical idle ends, or timeout
            end

            // Loopback state: loopback testing
            LOOPBACK_ENTRY: begin
                next_state = LOOPBACK_ACTIVE; // Transition to active loopback state
            end

            LOOPBACK_ACTIVE: begin
                if (timeout || directed)
                    next_state = LOOPBACK_EXIT; // Exit loopback if directed or on timeout
            end

            LOOPBACK_EXIT: begin
                if (timeout)
                    next_state = DETECT; // Return to DETECT on timeout
            end

            // Recovery state: recover the link
            RECOVERY_RCVRLOCK: begin
                if (bit_lock && symbol_lock && block_lock)
                    next_state = RECOVERY_RCVRCFG; // Go to receiver configuration if all locks are acquired
                else if (timeout)
                    next_state = DETECT; // Return to DETECT on timeout
            end

            RECOVERY_RCVRCFG: begin
                if (link_width_change || redo_equalization)
                    next_state = RECOVERY_EQUALIZATION_PHASE_0; // Start equalization if link width change or re-equalization needed
                else
                    next_state = RECOVERY_SPEED; // Otherwise, proceed to speed recovery
            end

            RECOVERY_EQUALIZATION_PHASE_0: begin
                if (eq_phase_1)
                    next_state = RECOVERY_EQUALIZATION_PHASE_1; // Proceed to next equalization phase
                else if (timeout)
                    next_state = DETECT; // Return to DETECT on timeout
            end

            RECOVERY_EQUALIZATION_PHASE_1: begin
                if (eq_phase_2)
                    next_state = RECOVERY_EQUALIZATION_PHASE_2; // Proceed to next equalization phase
                else if (timeout)
                    next_state = DETECT; // Return to DETECT on timeout
            end

            RECOVERY_EQUALIZATION_PHASE_2: begin
                if (eq_phase_3)
                    next_state = RECOVERY_EQUALIZATION_PHASE_3; // Proceed to final equalization phase
                else if (timeout)
                    next_state = DETECT; // Return to DETECT on timeout
            end

            RECOVERY_EQUALIZATION_PHASE_3: begin
                next_state = RECOVERY_IDLE; // Go to recovery idle after final phase
            end

            RECOVERY_SPEED: begin
                if (timeout)
                    next_state = DETECT; // Return to DETECT on timeout
                else
                    next_state = RECOVERY_IDLE; // Proceed to recovery idle
            end

            RECOVERY_IDLE: begin
                next_state = L0_ACTIVE; // Return to active data transmission
            end

            default: begin
                next_state = DETECT_QUIET; // Default state is DETECT_QUIET
            end
        endcase
    end


    // State transition logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= DETECT_QUIET; // Initialize to DETECT_QUIET on reset
        end else begin
            current_state <= next_state; // Transition to next state
        end
    end

    // Output the current state for monitoring/debugging
    assign state = current_state;


endmodule
