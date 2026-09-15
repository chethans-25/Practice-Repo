`ifndef CLOCK_VIP_GENERATOR_SV
`define CLOCK_VIP_GENERATOR_SV

class clock_vip_generator;

    mailbox #(clock_vip_txn) command_mbx;
    mailbox #(clock_vip_txn) expected_mbx[NUM_CLOCKS];

    mailbox #(bit) periods_done_mbx[NUM_CLOCKS];
    mailbox #(bit) stop_done_mbx[NUM_CLOCKS];
    mailbox #(bit) reset_done_mbx[NUM_CLOCKS];

    virtual clock_vip_if.GEN vif;

    int unsigned active_session_id[NUM_CLOCKS];

    // ==================================================================
    // EDIT THESE to change what frequency each clock runs at.
    // clock_freqs_group1[i] / clock_freqs_group4[i] = frequency (MHz)
    // for clock id `i` in that concurrent test group. Array size MUST
    // equal NUM_CLOCKS -- if you change NUM_CLOCKS in
    // clock_vip_defines.svh, add/remove one entry here to match.
    // Values are otherwise arbitrary: any nonzero MHz works.
    // ==================================================================
    int unsigned clock_freqs_group1[NUM_CLOCKS] = '{5, 33, 50, 10};
    int unsigned clock_freqs_group4[NUM_CLOCKS] = '{3, 11, 17, 25};

    task automatic drain_period_done_mailbox(int unsigned clock_id);
        bit stale_done;
        while (periods_done_mbx[clock_id].try_get(stale_done)) begin
        end
    endtask

    function new(
        mailbox #(clock_vip_txn) command_mbx,
        mailbox #(clock_vip_txn) expected_mbx[NUM_CLOCKS],
        mailbox #(bit)           periods_done_mbx[NUM_CLOCKS],
        mailbox #(bit)           stop_done_mbx[NUM_CLOCKS],
        mailbox #(bit)           reset_done_mbx[NUM_CLOCKS],
        virtual clock_vip_if.GEN vif
    );
        this.command_mbx      = command_mbx;
        this.expected_mbx     = expected_mbx;
        this.periods_done_mbx = periods_done_mbx;
        this.stop_done_mbx    = stop_done_mbx;
        this.reset_done_mbx   = reset_done_mbx;
        this.vif              = vif;
        for (int i = 0; i < NUM_CLOCKS; i++) begin
            this.active_session_id[i]      = 0;
            this.vif.dbg_session_active[i] = 1'b0;
        end
        this.vif.dbg_session_id_bus         = '0;
        this.vif.dbg_expected_period_ps_bus = '0;
        this.vif.dbg_test_group = $unit::TG_NONE;
    endfunction


    task automatic send_start(
        int unsigned clock_id,
        int unsigned frequency_mhz,
        int unsigned periods_to_check
    );
        clock_vip_txn cmd_tx, exp_tx;
        realtime      expected_period_ns;
        int unsigned  session_id;
        bit           done;

        if (frequency_mhz == 0) begin
            $display("[%0t][GEN][C%0d] ERROR : frequency cannot be zero", $time, clock_id);
            return;
        end

        // Clear stale completion tokens left by no-wait START sequences.
        drain_period_done_mailbox(clock_id);

        active_session_id[clock_id]++;
        session_id = active_session_id[clock_id];
        expected_period_ns = 1000.0 / realtime'(frequency_mhz);
        active_session_id[clock_id] = session_id;

        cmd_tx = new(CMD_START);
        cmd_tx.clock_id       = clock_id;
        cmd_tx.session_id     = session_id;
        cmd_tx.frequency_mhz  = frequency_mhz;

        exp_tx = new(CMD_START);
        exp_tx.clock_id                = clock_id;
        exp_tx.session_id              = session_id;
        exp_tx.frequency_mhz           = frequency_mhz;
        exp_tx.periods_to_check        = periods_to_check;
        exp_tx.expected_period_ns      = expected_period_ns;
        exp_tx.expected_frequency_mhz  = frequency_mhz;

        command_mbx.put(cmd_tx);
        expected_mbx[clock_id].put(exp_tx);

        // Waveform: mark this clock's lane as "session open" with its
        // id and the period a passing OBS_PERIOD must match. These are
        // packed-bus slice writes (not array-element writes) so they
        // actually appear in the VCD dump -- see clock_vip_if.sv.
        vif.dbg_session_id_bus[clock_id*`DBG_ID_W +: `DBG_ID_W] = session_id[`DBG_ID_W-1:0];
        vif.dbg_expected_period_ps_bus[clock_id*`DBG_PERIOD_W +: `DBG_PERIOD_W] =
            int'(expected_period_ns * 1000.0);
        vif.dbg_session_active[clock_id] = 1'b1;

        $display("[%0t][GEN][C%0d] START S%-2d    : freq=%0d MHz  periods=%0d  expected_period=%0.3f ns",
            $time, clock_id, session_id, frequency_mhz, periods_to_check, expected_period_ns);

        // Synchronize: wait until scoreboard finishes period checks for this clock
        periods_done_mbx[clock_id].get(done);

        $display("[%0t][GEN][C%0d] PERIODS DONE S%0d", $time, clock_id, session_id);
    endtask


    task automatic send_stop(int unsigned clock_id);
        clock_vip_txn cmd_tx, exp_tx;
        bit           done;

        cmd_tx = new(CMD_STOP);
        cmd_tx.clock_id   = clock_id;
        cmd_tx.session_id = active_session_id[clock_id];

        exp_tx = new(CMD_STOP);
        exp_tx.clock_id   = clock_id;
        exp_tx.session_id = active_session_id[clock_id];

        command_mbx.put(cmd_tx);
        expected_mbx[clock_id].put(exp_tx);

        $display("[%0t][GEN][C%0d] STOP  S%-2d", $time, clock_id, active_session_id[clock_id]);

        // Synchronize: wait until scoreboard finishes stop+quiet checks for this clock
        stop_done_mbx[clock_id].get(done);

        // Waveform: session is now closed on this clock's lane.
        vif.dbg_session_active[clock_id] = 1'b0;
    endtask


    task automatic send_start_without_wait(
        int unsigned clock_id,
        int unsigned frequency_mhz
    );
        clock_vip_txn cmd_tx, exp_tx;
        realtime      expected_period_ns;
        int unsigned  session_id;

        if (frequency_mhz == 0) begin
            $display("[%0t][GEN][C%0d] ERROR : frequency cannot be zero", $time, clock_id);
            return;
        end

        active_session_id[clock_id]++;
        session_id = active_session_id[clock_id];
        expected_period_ns = 1000.0 / realtime'(frequency_mhz);
        active_session_id[clock_id] = session_id;

        cmd_tx = new(CMD_START);
        cmd_tx.clock_id       = clock_id;
        cmd_tx.session_id     = session_id;
        cmd_tx.frequency_mhz  = frequency_mhz;

        exp_tx = new(CMD_START);
        exp_tx.clock_id                = clock_id;
        exp_tx.session_id              = session_id;
        exp_tx.frequency_mhz           = frequency_mhz;
        exp_tx.periods_to_check        = 0;          // No period checks for reset test
        exp_tx.expected_period_ns      = expected_period_ns;
        exp_tx.expected_frequency_mhz  = frequency_mhz;

        command_mbx.put(cmd_tx);
        expected_mbx[clock_id].put(exp_tx);

        vif.dbg_session_id_bus[clock_id*`DBG_ID_W +: `DBG_ID_W] = session_id[`DBG_ID_W-1:0];
        vif.dbg_expected_period_ps_bus[clock_id*`DBG_PERIOD_W +: `DBG_PERIOD_W] =
            int'(expected_period_ns * 1000.0);
        vif.dbg_session_active[clock_id]      = 1'b1;

        $display("[%0t][GEN][C%0d] START S%-2d    : freq=%0d MHz  (reset-interruption test, no period wait)",
            $time, clock_id, session_id, frequency_mhz);
    endtask


    // Start every clock in `ids` concurrently and wait for all of them
    // to finish their period checks. Replaces a hand-written fork with
    // exactly 4 named branches -- this scales to any NUM_CLOCKS.
    task automatic send_start_all(
        int unsigned ids[],
        int unsigned freqs[],
        int unsigned periods[]
    );
        foreach (ids[idx]) begin
            automatic int unsigned id     = ids[idx];
            automatic int unsigned freq   = freqs[idx];
            automatic int unsigned period = periods[idx];
            fork
                send_start(id, freq, period);
            join_none
        end
        wait fork;
    endtask


    // Stop every clock in `ids` concurrently and wait for all stop
    // checks to complete.
    task automatic send_stop_all(int unsigned ids[]);
        foreach (ids[idx]) begin
            automatic int unsigned id = ids[idx];
            fork
                send_stop(id);
            join_none
        end
        wait fork;
    endtask


    // One driver-level CMD_RESET affects every clock, started or not, so
    // every clock needs a matching expected OBS_RESET queued. Replaces
    // the hand-written fork with 4 named branches (clock_id 0..3) --
    // this scales to any NUM_CLOCKS.
    task automatic broadcast_reset(int unsigned ids[]);
        clock_vip_txn cmd_tx;

        cmd_tx = new(CMD_RESET);
        command_mbx.put(cmd_tx);

        foreach (ids[idx]) begin
            automatic int unsigned id = ids[idx];
            fork
                begin
                    bit done_val;
                    clock_vip_txn exp_tx = new(CMD_RESET);
                    exp_tx.clock_id   = id;
                    exp_tx.session_id = active_session_id[id];
                    expected_mbx[id].put(exp_tx);
                    reset_done_mbx[id].get(done_val);
                    vif.dbg_session_active[id] = 1'b0;
                end
            join_none
        end
        wait fork;
    endtask


    task automatic send_reset(int unsigned clock_id);
        clock_vip_txn cmd_tx, exp_tx;
        bit           done;

        cmd_tx = new(CMD_RESET);
        cmd_tx.clock_id   = clock_id;
        cmd_tx.session_id = active_session_id[clock_id];

        exp_tx = new(CMD_RESET);
        exp_tx.clock_id   = clock_id;
        exp_tx.session_id = active_session_id[clock_id];

        command_mbx.put(cmd_tx);
        expected_mbx[clock_id].put(exp_tx);

        $display("[%0t][GEN][C%0d] RESET S%-2d", $time, clock_id, active_session_id[clock_id]);

        // Synchronize: wait until scoreboard finishes reset check for this clock
        reset_done_mbx[clock_id].get(done);
    endtask


    task automatic run();
        clock_vip_txn  end_tx;
        int unsigned   sweep_freqs[6] = '{1, 2, 7, 17, 25, 50};
        int unsigned   all_ids[NUM_CLOCKS];
        int unsigned   start_freqs[NUM_CLOCKS];
        int unsigned   start_periods[NUM_CLOCKS];
        int unsigned   rapid_id;

        for (int i = 0; i < NUM_CLOCKS; i++) begin
            all_ids[i] = i;
        end

        $display("");
        $display("================================================================");
        $display("||            CLOCK VIP TEST SEQUENCE STARTING                ||");
        $display("================================================================");
        $display("");

        $display("---- Test Group 1: Concurrent Normal Start/Stop Sessions ----");
        vif.dbg_test_group = $unit::TG_CONCURRENT_NORMAL;

        // Concurrent start/stop of every clock -- scales to NUM_CLOCKS.
        // Frequencies come straight from clock_freqs_group1[] -- edit
        // that array above to change what each clock runs at.
        for (int i = 0; i < NUM_CLOCKS; i++) begin
            start_freqs[i]   = clock_freqs_group1[i];
            start_periods[i] = 3 + (i % 3);
        end
        send_start_all(all_ids, start_freqs, start_periods);
        send_stop_all(all_ids);

        // Restart clock 0 to verify it runs independently
        send_start(0, 10, 3);
        send_stop(0);

        $display("");
        $display("---- Test Group 2: Reset Interruption ----");
        vif.dbg_test_group = $unit::TG_RESET_INTERRUPT;

        // Start up to two clocks but don't wait for completion
        if (NUM_CLOCKS >= 1) send_start_without_wait(0, 5);
        if (NUM_CLOCKS >= 2) send_start_without_wait(1, 25);

        #30ns;

        // One driver-level CMD_RESET affects every clock (started or
        // not), so every clock -- not just a hardcoded first few --
        // needs a matching expected OBS_RESET check.
        broadcast_reset(all_ids);

        $display("");
        $display("---- Test Group 3: Sequential Frequency Sweep on C0 ----");
        vif.dbg_test_group = $unit::TG_SEQUENTIAL_SWEEP;
        foreach (sweep_freqs[idx]) begin
            send_start(0, sweep_freqs[idx], 2);
            send_stop(0);
        end

        $display("");
        $display("---- Test Group 4: Concurrent Mixed Frequencies ----");
        vif.dbg_test_group = $unit::TG_CONCURRENT_MIXED;
        // Frequencies come straight from clock_freqs_group4[] -- edit
        // that array above to change what each clock runs at.
        for (int i = 0; i < NUM_CLOCKS; i++) begin
            start_freqs[i] = clock_freqs_group4[i];
        end
        send_start_all(all_ids, start_freqs, start_periods);
        send_stop_all(all_ids);

        $display("");
        $display("---- Test Group 5: Rapid Restart/Stop Pattern ----");
        vif.dbg_test_group = $unit::TG_RAPID_RESTART;
        rapid_id = NUM_CLOCKS - 1;
        send_start_without_wait(rapid_id, 50);
        #25ns;
        send_stop(rapid_id);
        send_start(rapid_id, 5, 2);
        send_stop(rapid_id);

        $display("");
        $display("---- All Test Sequences Complete ----");
        vif.dbg_test_group = $unit::TG_NONE;

        // Send end transaction to all components
        end_tx = new(CMD_END);
        command_mbx.put(end_tx.clone());
        for (int i = 0; i < NUM_CLOCKS; i++) begin
            expected_mbx[i].put(end_tx.clone());
        end

        $display("[%0t][GEN] DONE", $time);
    endtask

endclass

`endif