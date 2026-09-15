`ifndef CLOCK_VIP_DRIVER_SV
`define CLOCK_VIP_DRIVER_SV

class clock_vip_driver;

    mailbox #(clock_vip_txn) command_mbx;
    semaphore                clk_sem;
    virtual clock_vip_if.DRIVER vif;

    bit          reset_released;
    bit          clock_running [NUM_CLOCKS];
    realtime     half_period_ns [NUM_CLOCKS];

    int unsigned active_session_id [NUM_CLOCKS];
    event        stop_clock_event [NUM_CLOCKS];


    function new(
        mailbox #(clock_vip_txn)    command_mbx,
        semaphore                   clk_sem,
        virtual clock_vip_if.DRIVER vif
    );
        this.command_mbx       = command_mbx;
        this.clk_sem           = clk_sem;
        this.vif               = vif;
        this.reset_released    = 1'b0;
        for (int i = 0; i < NUM_CLOCKS; i++) begin
            this.clock_running[i]     = 1'b0;
            this.half_period_ns[i]    = 500.0;
            this.active_session_id[i] = 0;
        end
    endfunction


    // Set interface to a known idle state
    task automatic drive_idle();
        clk_sem.get(1);

        reset_released  = 1'b0;
        vif.drv_cb.reset_n <= 1'b0;

        for (int i = 0; i < NUM_CLOCKS; i++) begin
            clock_running[i] = 1'b0;
            vif.drv_cb.start[i]         <= 1'b0;
            vif.drv_cb.stop[i]          <= 1'b0;
            vif.drv_cb.frequency_mhz[i] <= 32'd1;

            vif.dut_clk[i]      = 1'b0;
            vif.clock_active[i] = 1'b0;

            -> stop_clock_event[i];
        end

        clk_sem.put(1);

        $display("[%0t][DRV] IDLE  : reset_n=0  dut_clk=0  clock_active=0", $time);
    endtask


    // Assert reset, hold for 2 tb_clk cycles, then release
    task automatic drive_reset();
        clk_sem.get(1);

        reset_released  = 1'b0;
        vif.drv_cb.reset_n <= 1'b0;

        for (int i = 0; i < NUM_CLOCKS; i++) begin
            clock_running[i] = 1'b0;
            vif.drv_cb.start[i]   <= 1'b0;
            vif.drv_cb.stop[i]    <= 1'b0;

            vif.dut_clk[i]      = 1'b0;
            vif.clock_active[i] = 1'b0;

            -> stop_clock_event[i];
        end

        clk_sem.put(1);

        $display("[%0t][DRV] RESET ASSERT  : reset_n=0  dut_clk=0  clock_active=0", $time);

        // Hold reset for at least 2 tb_clk clocking events
        repeat (2)
            @(vif.drv_cb);

        clk_sem.get(1);
        vif.drv_cb.reset_n <= 1'b1;
        reset_released       = 1'b1;
        clk_sem.put(1);

        $display("[%0t][DRV] RESET RELEASE : reset_n=1", $time);
    endtask


    task automatic generate_clock(int unsigned id);
        bit running_now;
        bit reset_now;

        forever begin

            // Generic wait: race the half-period timer against an early
            // stop/reset for THIS clock's id. This one block replaces what
            // used to be a case(id) with a separately-named fork per clock
            // (0..3 only) -- that hardcoded the VIP to exactly 4 clocks.
            // disable fork here only kills processes spawned by this
            // generate_clock(id) invocation (each clock runs as its own
            // process, same pattern already used in the monitor), so
            // concurrently running clocks of other ids are unaffected.
            fork
                begin #(half_period_ns[id]); end
                begin @stop_clock_event[id]; end
            join_any
            disable fork;

            clk_sem.get(1);
            running_now = clock_running[id];
            reset_now   = reset_released;

            if (running_now && reset_now)
                vif.dut_clk[id] = ~vif.dut_clk[id];

            clk_sem.put(1);

            if (!running_now || !reset_now)
                break;
        end
    endtask


    task automatic start_clock(clock_vip_txn tx);
        int unsigned id = tx.clock_id;
        bit already_running;
        bit reset_now;

        clk_sem.get(1);
        already_running = clock_running[id];
        reset_now       = reset_released;

        if (!already_running && reset_now && tx.frequency_mhz != 0) begin
            active_session_id[id] = tx.session_id;
            half_period_ns[id]    = 500.0 / realtime'(tx.frequency_mhz);

            vif.drv_cb.frequency_mhz[id] <= tx.frequency_mhz;
            vif.drv_cb.start[id]         <= 1'b1;
            vif.drv_cb.stop[id]          <= 1'b0;

            vif.dut_clk[id]      = 1'b0;
            vif.clock_active[id] = 1'b1;
            clock_running[id]    = 1'b1;
        end
        clk_sem.put(1);

        // Error / ignore cases
        if (tx.frequency_mhz == 0) begin
            $display("[%0t][DRV][C%0d] START ERROR   : frequency cannot be zero", $time, id);
            return;
        end
        if (!reset_now) begin
            $display("[%0t][DRV][C%0d] START IGNORED : reset is active", $time, id);
            return;
        end
        if (already_running) begin
            $display("[%0t][DRV][C%0d] START IGNORED : clock already running", $time, id);
            return;
        end

        $display("[%0t][DRV][C%0d] START S%-2d     : freq=%0d MHz  half_period=%0.3f ns",
            $time, id, tx.session_id, tx.frequency_mhz, half_period_ns[id]);

        // Pulse start for one tb_clk cycle
        @(vif.drv_cb);
        clk_sem.get(1);
        vif.drv_cb.start[id] <= 1'b0;
        clk_sem.put(1);

        // Launch clock generation in the same background thread
        generate_clock(id);
    endtask


    task automatic stop_clock(clock_vip_txn tx);
        int unsigned id = tx.clock_id;
        
        clk_sem.get(1);

        vif.drv_cb.start[id] <= 1'b0;
        vif.drv_cb.stop[id]  <= 1'b1;

        clock_running[id]    = 1'b0;
        vif.dut_clk[id]      = 1'b0;
        vif.clock_active[id] = 1'b0;

        -> stop_clock_event[id];

        clk_sem.put(1);

        $display("[%0t][DRV][C%0d] STOP  S%-2d     : dut_clk=0  clock_active=0", $time, id, active_session_id[id]);

        // Hold stop for one tb_clk cycle then deassert
        @(vif.drv_cb);
        clk_sem.get(1);
        vif.drv_cb.stop[id] <= 1'b0;
        clk_sem.put(1);
    endtask


    task run();
        clock_vip_txn tx;

        drive_idle();
        drive_reset();

        forever begin
            command_mbx.get(tx);

            case (tx.command)

                CMD_START: begin
                    automatic clock_vip_txn local_tx = tx;
                    fork
                        start_clock(local_tx);
                    join_none
                end

                CMD_STOP: begin
                    automatic clock_vip_txn local_tx = tx;
                    fork
                        stop_clock(local_tx);
                    join_none
                end

                CMD_RESET: begin
                    $display("[%0t][DRV] CMD_RESET", $time);
                    drive_reset();
                end

                CMD_END: begin
                    $display("[%0t][DRV] CMD_END   : command stream complete", $time);
                    break;
                end

                default: begin
                    $warning("[%0t][DRV] UNKNOWN   : command=%s", $time, tx.command_name());
                end
            endcase
        end

        drive_idle();
        $display("[%0t][DRV] DONE", $time);
    endtask

endclass

`endif