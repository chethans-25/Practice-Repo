`ifndef CLOCK_VIP_SCOREBOARD_SV
`define CLOCK_VIP_SCOREBOARD_SV

class clock_vip_scoreboard;

    mailbox #(clock_vip_txn) expected_mbx[NUM_CLOCKS];
    mailbox #(clock_vip_txn) observed_mbx[NUM_CLOCKS];

    mailbox #(bit) periods_done_mbx[NUM_CLOCKS];
    mailbox #(bit) stop_done_mbx[NUM_CLOCKS];
    mailbox #(bit) reset_done_mbx[NUM_CLOCKS];

    virtual clock_vip_if.MONITOR vif;

    int pass_count;
    int fail_count;

    int session_count;
    int start_pass_count;
    int stop_pass_count;
    int reset_pass_count;


    function new(
        mailbox #(clock_vip_txn) expected_mbx[NUM_CLOCKS],
        mailbox #(clock_vip_txn) observed_mbx[NUM_CLOCKS],
        mailbox #(bit)           periods_done_mbx[NUM_CLOCKS],
        mailbox #(bit)           stop_done_mbx[NUM_CLOCKS],
        mailbox #(bit)           reset_done_mbx[NUM_CLOCKS],
        virtual clock_vip_if.MONITOR vif
    );
        this.expected_mbx     = expected_mbx;
        this.observed_mbx     = observed_mbx;
        this.periods_done_mbx = periods_done_mbx;
        this.stop_done_mbx    = stop_done_mbx;
        this.reset_done_mbx   = reset_done_mbx;
        this.vif              = vif;

        this.pass_count       = 0;
        this.fail_count       = 0;
        this.session_count    = 0;
        this.start_pass_count = 0;
        this.stop_pass_count  = 0;
        this.reset_pass_count = 0;

        for (int i = 0; i < NUM_CLOCKS; i++) begin
            this.vif.dbg_check_pass_pulse[i]   = 1'b0;
            this.vif.dbg_check_fail_pulse[i]   = 1'b0;
        end
        this.vif.dbg_measured_period_ps_bus = '0;
    endfunction


    // Tolerance check: 1% relative, 0.05 ns minimum absolute
    function automatic bit within_tolerance(
        realtime measured,
        realtime expected
    );
        realtime tolerance;

        tolerance = expected * 0.01;
        if (tolerance < 0.05)
            tolerance = 0.05;

        return (measured >= expected - tolerance &&
                measured <= expected + tolerance);
    endfunction


    // Get observation with timeout to prevent deadlock
    task automatic get_observation_with_timeout(
        int unsigned         id,
        output bit           got_observation,
        output clock_vip_txn observation,
        input  time          timeout
    );
        process p_get, p_time;

        got_observation = 1'b0;
        observation     = null;

        fork
            begin
                p_get = process::self();
                observed_mbx[id].get(observation);
                got_observation = 1'b1;
            end
            begin
                p_time = process::self();
                #(timeout);
            end
        join_any

        if (p_get != null && p_get.status() != process::FINISHED) p_get.kill();
        if (p_time != null && p_time.status() != process::FINISHED) p_time.kill();
    endtask


    task automatic check_start(int unsigned id, clock_vip_txn expected_tx);
        clock_vip_txn observed_tx;
        bit           got_observation;
        bit           all_passed;
        bit           period_ok;
        bit           freq_ok;
        time          deadline;
        time          remaining_timeout;
        int unsigned  matched_period_count;
        int unsigned  stale_period_count;
        int unsigned  stale_terminal_count;

        session_count++;
        all_passed = 1'b1;

        $display("[%0t][SCB][C%0d] -- START CHECK S%-2d : freq=%0d MHz  periods=%0d --",
            $time, id, expected_tx.session_id,
            expected_tx.frequency_mhz,
            expected_tx.periods_to_check);

        // If periods_to_check is 0, skip (reset-interruption start)
        if (expected_tx.periods_to_check == 0) begin
            periods_done_mbx[id].put(1'b1);
            return;
        end

        matched_period_count = 0;
        stale_period_count   = 0;
        stale_terminal_count = 0;
        deadline = $time + time'(expected_tx.expected_period_ns * realtime'(expected_tx.periods_to_check + 4) + 200ns);

        while (matched_period_count < expected_tx.periods_to_check) begin
            remaining_timeout = (deadline > $time) ? (deadline - $time) : 0;
            if (remaining_timeout == 0) begin
                fail_count++;
                all_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    TIMEOUT : expected OBS_PERIOD", $time, id);
                break;
            end

            get_observation_with_timeout(id, got_observation, observed_tx, remaining_timeout);

            if (!got_observation) begin
                fail_count++;
                all_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    TIMEOUT : expected OBS_PERIOD", $time, id);
                break;
            end

            if (observed_tx.command != OBS_PERIOD) begin
                if ((observed_tx.command inside {OBS_STOP, OBS_RESET}) &&
                    (observed_tx.session_id < expected_tx.session_id)) begin
                    stale_terminal_count++;
                    continue;
                end
                fail_count++;
                all_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    MISMATCH: expected OBS_PERIOD, got %s",
                    $time, id, observed_tx.command_name());
                break;
            end

            if (observed_tx.session_id < expected_tx.session_id) begin
                stale_period_count++;
                continue;
            end
            if (observed_tx.session_id > expected_tx.session_id) begin
                fail_count++;
                all_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    MISMATCH: OBS_PERIOD session expected=S%0d got=S%0d",
                    $time, id, expected_tx.session_id, observed_tx.session_id);
                break;
            end

            matched_period_count++;
            period_ok = within_tolerance(
                observed_tx.measured_period_ns,
                expected_tx.expected_period_ns
            );
            freq_ok = within_tolerance(
                observed_tx.measured_frequency_mhz,
                expected_tx.expected_frequency_mhz
            );

            if (!period_ok) begin
                fail_count++;
                all_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    P%-2d FAIL : period  expected=%0.3f  measured=%0.3f ns",
                    $time, id, observed_tx.transaction_id,
                    expected_tx.expected_period_ns,
                    observed_tx.measured_period_ns);
            end

            if (!freq_ok) begin
                fail_count++;
                all_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    P%-2d FAIL : freq    expected=%0.3f  measured=%0.3f MHz",
                    $time, id, observed_tx.transaction_id,
                    expected_tx.expected_frequency_mhz,
                    observed_tx.measured_frequency_mhz);
            end

            if (period_ok && freq_ok) begin
                $display("[%0t][SCB][C%0d]    P%-2d PASS : period=%0.3f ns  freq=%0.3f MHz",
                    $time, id, observed_tx.transaction_id,
                    observed_tx.measured_period_ns,
                    observed_tx.measured_frequency_mhz);
            end

            // Waveform: record what was measured and pulse a pass/fail
            // strobe right at this point in time, so the wave viewer
            // shows the verdict lined up with the dut_clk edge that
            // produced it -- no need to cross-reference the log.
            vif.dbg_measured_period_ps_bus[id*`DBG_PERIOD_W +: `DBG_PERIOD_W] =
                int'(observed_tx.measured_period_ns * 1000.0);
            if (period_ok && freq_ok) begin
                vif.dbg_check_pass_pulse[id] = 1'b1;
                #1ns;
                vif.dbg_check_pass_pulse[id] = 1'b0;
            end
            else begin
                vif.dbg_check_fail_pulse[id] = 1'b1;
                #1ns;
                vif.dbg_check_fail_pulse[id] = 1'b0;
            end
        end

        if (stale_period_count != 0 || stale_terminal_count != 0) begin
            $display("[%0t][SCB][C%0d]    (drained stale before START: OBS_PERIOD=%0d OBS_STOP/OBS_RESET=%0d)",
                $time, id, stale_period_count, stale_terminal_count);
        end

        if (all_passed) begin
            pass_count++;
            start_pass_count++;
            $display("[%0t][SCB][C%0d]    PASS START S%0d", $time, id, expected_tx.session_id);
        end
        else begin
            $display("[%0t][SCB][C%0d]    FAIL START S%0d", $time, id, expected_tx.session_id);
        end

        periods_done_mbx[id].put(1'b1);
    endtask


    task automatic check_stop(int unsigned id, clock_vip_txn expected_tx);
        clock_vip_txn observed_tx;
        bit           got_observation;
        bit           stop_passed;
        int unsigned  stale_period_count;
        int unsigned  stale_stop_count;
        time          deadline;
        time          remaining_timeout;

        stop_passed = 1'b1;
        stale_period_count = 0;
        stale_stop_count   = 0;
        deadline = $time + 500ns;

        $display("[%0t][SCB][C%0d] -- STOP CHECK S%-2d --", $time, id, expected_tx.session_id);

        // At stop boundary, one or more final OBS_PERIOD events can already be queued.
        // Drain them until OBS_STOP is observed, bounded by total timeout.
        forever begin
            remaining_timeout = (deadline > $time) ? (deadline - $time) : 0;
            if (remaining_timeout == 0) begin
                fail_count++;
                stop_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    TIMEOUT : expected OBS_STOP", $time, id);
                break;
            end

            get_observation_with_timeout(id, got_observation, observed_tx, remaining_timeout);

            if (!got_observation) begin
                fail_count++;
                stop_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    TIMEOUT : expected OBS_STOP", $time, id);
                break;
            end

            if (observed_tx.command == OBS_PERIOD) begin
                stale_period_count++;
                continue;
            end

            if (observed_tx.command == OBS_STOP &&
                observed_tx.session_id != expected_tx.session_id) begin
                stale_stop_count++;
                continue;
            end

            if (observed_tx.command != OBS_STOP) begin
                fail_count++;
                stop_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    MISMATCH: expected OBS_STOP, got %s",
                    $time, id, observed_tx.command_name());
                break;
            end

            $display("[%0t][SCB][C%0d]    OBS_STOP received", $time, id);
            break;
        end

        if (stale_period_count != 0 || stale_stop_count != 0) begin
            $display("[%0t][SCB][C%0d]    (drained stale before STOP: OBS_PERIOD=%0d OBS_STOP(other session)=%0d)",
                $time, id, stale_period_count, stale_stop_count);
        end

        // Quiet-window check: verify clock is inactive after stop
        #20ns;

        if (!vif.clock_active[id] && !vif.dut_clk[id]) begin
            $display("[%0t][SCB][C%0d]    QUIET PASS : dut_clk=0  clock_active=0", $time, id);
        end
        else begin
            fail_count++;
            stop_passed = 1'b0;
            $display("[%0t][SCB][C%0d]    QUIET FAIL : clock still active after stop", $time, id);
        end

        if (stop_passed) begin
            pass_count++;
            stop_pass_count++;
            $display("[%0t][SCB][C%0d]    PASS STOP S%0d", $time, id, expected_tx.session_id);
            vif.dbg_check_pass_pulse[id] = 1'b1; #1ns; vif.dbg_check_pass_pulse[id] = 1'b0;
        end
        else begin
            $display("[%0t][SCB][C%0d]    FAIL STOP S%0d", $time, id, expected_tx.session_id);
            vif.dbg_check_fail_pulse[id] = 1'b1; #1ns; vif.dbg_check_fail_pulse[id] = 1'b0;
        end

        stop_done_mbx[id].put(1'b1);
    endtask


    task automatic check_reset(int unsigned id, clock_vip_txn expected_tx);
        clock_vip_txn observed_tx;
        bit           got_observation;
        bit           reset_passed;
        int unsigned  stale_period_count;
        int unsigned  stale_stop_count;
        time          deadline;
        time          remaining_timeout;

        reset_passed = 1'b1;
        stale_period_count = 0;
        stale_stop_count   = 0;
        deadline = $time + 500ns;

        $display("[%0t][SCB][C%0d] -- RESET CHECK S%-2d --", $time, id, expected_tx.session_id);

        // During reset interruption, active clocks can enqueue OBS_PERIOD/OBS_STOP
        // just before OBS_RESET due to scheduling order. Drain stale observations
        // until OBS_RESET is seen, bounded by a hard timeout.
        forever begin
            remaining_timeout = (deadline > $time) ? (deadline - $time) : 0;
            if (remaining_timeout == 0) begin
                fail_count++;
                reset_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    TIMEOUT : expected OBS_RESET", $time, id);
                break;
            end

            get_observation_with_timeout(id, got_observation, observed_tx, remaining_timeout);

            if (!got_observation) begin
                fail_count++;
                reset_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    TIMEOUT : expected OBS_RESET", $time, id);
                break;
            end

            if (observed_tx.command == OBS_PERIOD) begin
                stale_period_count++;
                continue;
            end

            if (observed_tx.command == OBS_STOP) begin
                stale_stop_count++;
                continue;
            end

            if (observed_tx.command != OBS_RESET) begin
                fail_count++;
                reset_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    MISMATCH: expected OBS_RESET, got %s",
                    $time, id, observed_tx.command_name());
                break;
            end

            if (observed_tx.session_id != expected_tx.session_id) begin
                fail_count++;
                reset_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    MISMATCH: OBS_RESET session expected=S%0d got=S%0d",
                    $time, id, expected_tx.session_id, observed_tx.session_id);
                break;
            end

            if (observed_tx.observed_reset_n    ||
                observed_tx.observed_dut_clk    ||
                observed_tx.observed_clock_active) begin
                fail_count++;
                reset_passed = 1'b0;
                $display("[%0t][SCB][C%0d]    RESET STATE FAIL : reset_n=%0b  dut_clk=%0b  clock_active=%0b",
                    $time, id,
                    observed_tx.observed_reset_n,
                    observed_tx.observed_dut_clk,
                    observed_tx.observed_clock_active);
                break;
            end

            $display("[%0t][SCB][C%0d]    RESET STATE PASS : reset_n=0  dut_clk=0  clock_active=0", $time, id);
            break;
        end

        if (stale_period_count != 0 || stale_stop_count != 0) begin
            $display("[%0t][SCB][C%0d]    (drained stale before RESET: OBS_PERIOD=%0d OBS_STOP=%0d)",
                $time, id, stale_period_count, stale_stop_count);
        end

        if (reset_passed) begin
            pass_count++;
            reset_pass_count++;
            $display("[%0t][SCB][C%0d]    PASS RESET S%0d", $time, id, expected_tx.session_id);
            vif.dbg_check_pass_pulse[id] = 1'b1; #1ns; vif.dbg_check_pass_pulse[id] = 1'b0;
        end
        else begin
            $display("[%0t][SCB][C%0d]    FAIL RESET S%0d", $time, id, expected_tx.session_id);
            vif.dbg_check_fail_pulse[id] = 1'b1; #1ns; vif.dbg_check_fail_pulse[id] = 1'b0;
        end

        reset_done_mbx[id].put(1'b1);
    endtask


    task automatic check_clock(int unsigned id);
        clock_vip_txn expected_tx;

        forever begin
            expected_mbx[id].get(expected_tx);

            case (expected_tx.command)
                CMD_START: check_start(id, expected_tx);
                CMD_STOP:  check_stop(id, expected_tx);
                CMD_RESET: check_reset(id, expected_tx);

                CMD_END: begin
                    $display("[%0t][SCB][C%0d] CMD_END : command stream complete", $time, id);
                    break;
                end

                default: begin
                    $warning("[%0t][SCB][C%0d] UNKNOWN : %s", $time, id, expected_tx.command_name());
                end
            endcase
        end
    endtask

    task run();
        for (int i = 0; i < NUM_CLOCKS; i++) begin
            automatic int id = i;
            fork
                check_clock(id);
            join_none
        end
        
        // Wait for all clocks to finish checking
        wait fork;

        $display("[%0t][SCB] DONE", $time);
    endtask


    function void report();

        $display("");
        $display("================================================================");
        $display("||              CLOCK VIP SCOREBOARD REPORT                   ||");
        $display("================================================================");
        $display("|| Sessions checked   : %-4d                                  ||", session_count);
        $display("|| START  checks pass : %-4d                                  ||", start_pass_count);
        $display("|| STOP   checks pass : %-4d                                  ||", stop_pass_count);
        $display("|| RESET  checks pass : %-4d                                  ||", reset_pass_count);
        $display("|| Total passed       : %-4d                                  ||", pass_count);
        $display("|| Total failed       : %-4d                                  ||", fail_count);
        $display("================================================================");

        if (fail_count == 0)
          $display("|| FINAL RESULT       : PASS                                   ||");
        else
          $display("|| FINAL RESULT       : FAIL                                   ||");

        $display("================================================================");

    endfunction

endclass

`endif