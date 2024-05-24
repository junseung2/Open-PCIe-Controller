class pcie_dll_sequence extends uvm_sequence #(pcie_dll_transaction);

    `uvm_object_utils(pcie_dll_sequence)

    // Constructor: Initializes the sequence with a given name
    function new(string name = "pcie_dll_sequence");
        super.new(name);
    endfunction: new

    // Main task: Generates and sends a series of transactions
    virtual task body();
        pcie_dll_transaction txn;
        int seq_num;

         #(10);


        // Get seq_num from configuration database
        if (!uvm_config_db#(int)::get(null, "env", "seq_num", seq_num)) begin
            `uvm_error("SEQ_NUM_NOT_FOUND", "seq_num not found in configuration database");
        end

        // Loop to create and send 5 transactions
        for (int i = 0; i < 10; i++) begin
            // Create a new transaction object
            txn = pcie_dll_transaction::type_id::create("txn");
            
            // Start the transaction
            start_item(txn);
            
            // Randomize the transaction fields and check for success
            if (!txn.randomize()) begin
                // Log an error if randomization fails
                `uvm_error(get_type_name(), "Randomization failed")
            end else begin
                // Log transaction details if randomization is successful
                `uvm_info(get_type_name(), $sformatf(
                    "Transaction %0d:\n  tlp_valid_i = %0d\n  tlp_i = %0h\n  tlp_ready_i = %0d\n",
                    i, txn.tlp_valid_i, txn.tlp_i, txn.tlp_ready_i), UVM_MEDIUM)
            end
            
            // Finish the transaction
            finish_item(txn);
        end
    endtask: body

endclass
