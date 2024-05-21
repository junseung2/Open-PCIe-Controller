class pcie_dll_sequence extends uvm_sequence #(pcie_dll_transaction);

    `uvm_object_utils(pcie_dll_sequence)

    // Constructor: Initializes the sequence with a given name
    function new(string name = "pcie_dll_sequence");
        super.new(name);
    endfunction: new

    // Main task: Generates and sends a series of transactions
    virtual task body();
        pcie_dll_transaction txn;

        // Loop to create and send 5 transactions
        for (int i = 0; i < 5; i++) begin
            // Create a new transaction object
            txn = pcie_dll_transaction::type_id::create("txn", this);
            
            // Start the transaction
            start_item(txn);
            
            // Randomize the transaction fields and check for success
            if (!txn.randomize()) begin
                // Log an error if randomization fails
                `uvm_error(get_type_name(), "Randomization failed")
            end else begin
                // Log transaction details if randomization is successful
                `uvm_info(get_type_name(), $sformatf(
                    "Transaction %0d:\n  tlp_valid = %0d\n  tlp = %0h\n  tlp_ready = %0d\n  dllp = %0h\n  dllp_valid = %0d",
                    i, txn.tlp_valid, txn.tlp, txn.tlp_ready, txn.dllp, txn.dllp_valid), UVM_MEDIUM)
            end
            
            // Finish the transaction
            finish_item(txn);
        end
    endtask: body

endclass
