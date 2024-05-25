class pcie_tl_sequence extends uvm_sequence #(pcie_tl_transaction);

    `uvm_object_utils(pcie_tl_sequence)

    // Constructor: Initializes the sequence with a given name
    function new(string name = "pcie_tl_sequence");
        super.new(name);
    endfunction: new

    // Main task: Generates and sends a series of transactions
    virtual task body();
        pcie_tl_transaction txn;
        #(10);

        // Small delay before starting the sequence

        // Loop to create and send transactions
        for (int i = 0; i < 10; i++) begin
            // Create a new transaction object
            txn = pcie_tl_transaction::type_id::create("txn");
            
            // Start the transaction
            start_item(txn);
            
            // Randomize the transaction fields and check for success
            if (!txn.randomize()) begin
                // Log an error if randomization fails
                `uvm_error(get_type_name(), "Randomization failed")
            end else begin
                // Log transaction details if randomization is successful
                `uvm_info(get_type_name(), $sformatf(
                    "Transaction %0d:\n  fc_valid = %0d\n  tlp_valid = %0d\n tlp = %0h\n rready = %0d",
                    i, txn.fc_valid, txn.tlp_valid, txn.tlp, txn.rready), UVM_MEDIUM)
            end
            
            // Finish the transaction
            finish_item(txn);
        end
    endtask: body

endclass
