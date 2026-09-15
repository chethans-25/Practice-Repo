`ifndef CLOCK_VIP_MONITOR_SV
`define CLOCK_VIP_MONITOR_SV

class clock_vip_monitor;

    mailbox #(clock_vip_txn) observed_mbx[NUM_CLOCKS];
    virtual clock_vip_if.MONITOR vif;

    bit          stop_requested;
    event        stop_event;

    function new(
        mailbox #(clock_vip_txn)     observed_mbx[NUM_CLOCKS],
        virtual clock_vip_if.MONITOR vif
    );
        this.observed_mbx       = observed_mbx;
        this.vif                = vif;
        this.stop_requested     = 1'b0;
    endfunction


    function void request_stop();
        stop_requested = 1'b1;
        -> stop_event;
        $display("[%0t][MON] SHUTDOWN REQUESTED", $time);
    endfunction


    // Capture reset-state values and send OBS_RESET
    task automatic send_reset_observation(int unsigned id, int unsigned session_id);
        clock_vip_txn reset_tx;

        reset_tx = new(OBS_RESET);
        reset_tx.clock_id            = id;
        reset_tx.session_id          = session_id;
        reset_tx.observed_reset_n    = vif.reset_n;
        reset_tx.observed_dut_clk    = vif.dut_clk[id];
        reset_tx.observed_clock_active = vif.clock_active[id];

        observed_mbx[id].put(reset_tx);

        $display("[%0t][MON][C%0d] OBS_RESET S%-2d : reset_n=%0b  dut_clk=%0b  clock_active=%0b",
            $time, id, session_id,
            reset_tx.observed_reset_n,
            reset_tx.observed_dut_clk,
            reset_tx.observed_clock_active);
    endtask

    task automatic monitor_clock(int unsigned id);
        realtime previous_edge;
        realtime current_edge;
        realtime measured_period;
        realtime measured_frequency;

        bit first_edge;
        bit session_active;
        int unsigned current_session_id = 0;
        int unsigned period_count = 0;

        forever begin

            if (stop_requested)
                break;

            first_edge     = 1'b0;
            session_active = 1'b0;

            // ---- Wait for a new clock session to begin ----
            fork : wait_for_session

                begin : wait_for_start_cmd
                    @(posedge vif.start[id]);

                    current_session_id++;
                    period_count = 0;

                    previous_edge  = 0.0;
                    first_edge     = 1'b0;
                    session_active = 1'b1;

                    $display("[%0t][MON][C%0d] SESSION START S%0d", $time, id, current_session_id);
                end

                begin : wait_for_clock_active_rise
                    @(posedge vif.clock_active[id]);

                    current_session_id++;
                    period_count = 0;

                    previous_edge  = 0.0;
                    first_edge     = 1'b0;
                    session_active = 1'b1;

                    $display("[%0t][MON][C%0d] SESSION START S%0d", $time, id, current_session_id);
                end

                begin : wait_for_first_edge
                    @(posedge vif.dut_clk[id]);

                    current_session_id++;
                    period_count = 0;

                    previous_edge  = $realtime;
                    first_edge     = 1'b1;
                    session_active = 1'b1;

                    $display("[%0t][MON][C%0d] SESSION START S%0d", $time, id, current_session_id);
                end

                begin : wait_for_reset
                    @(negedge vif.reset_n);
                    send_reset_observation(id, current_session_id);
                end

                begin : wait_for_monitor_stop
                    @stop_event;
                end

            join_any
            disable fork;

            if (stop_requested)
                break;

            if (!session_active)
                continue;

            // ---- Measure periods until session ends ----
            while (session_active && !stop_requested && vif.clock_active[id]) begin

                fork : measure_or_stop

                    begin : edge_measurement
                        clock_vip_txn period_tx;

                        @(posedge vif.dut_clk[id]);
                        current_edge = $realtime;

                        if (first_edge) begin
                            measured_period    = current_edge - previous_edge;
                            measured_frequency = 1000.0 / measured_period;

                            period_count++;

                            period_tx = new(OBS_PERIOD);
                            period_tx.clock_id            = id;
                            period_tx.session_id          = current_session_id;
                            period_tx.transaction_id      = period_count;
                            period_tx.measured_period_ns  = measured_period;
                            period_tx.measured_frequency_mhz = measured_frequency;

                            observed_mbx[id].put(period_tx);

                            $display("[%0t][MON][C%0d] OBS_PERIOD S%-2d P%-2d : period=%0.3f ns  freq=%0.3f MHz",
                                $time, id, current_session_id, period_count,
                                measured_period, measured_frequency);
                        end

                        previous_edge = current_edge;
                        first_edge    = 1'b1;
                    end

                    begin : stop_observation
                        clock_vip_txn stop_tx;

                        fork : stop_wait
                            begin : wait_for_stop_cmd
                                @(posedge vif.stop[id]);
                            end
                            begin : wait_for_clock_inactive
                                @(negedge vif.clock_active[id]);
                            end
                        join_any
                        disable fork;

                        // Only send OBS_STOP if this is a normal stop (not reset)
                        if (vif.reset_n) begin
                            stop_tx = new(OBS_STOP);
                            stop_tx.clock_id       = id;
                            stop_tx.session_id     = current_session_id;
                            stop_tx.transaction_id = period_count + 1;

                            observed_mbx[id].put(stop_tx);

                            $display("[%0t][MON][C%0d] OBS_STOP  S%-2d     : periods_measured=%0d",
                                $time, id, current_session_id, period_count);
                        end

                        session_active = 1'b0;
                    end

                    begin : reset_observation
                        @(negedge vif.reset_n);
                        send_reset_observation(id, current_session_id);
                        session_active = 1'b0;
                    end

                join_any
                disable fork;

            end

            $display("[%0t][MON][C%0d] SESSION END   S%0d", $time, id, current_session_id);

        end
    endtask

    task run();
        wait (vif.reset_n === 1'b1);
        $display("[%0t][MON] READY : reset released, monitor active", $time);

        for (int i = 0; i < NUM_CLOCKS; i++) begin
            automatic int id = i;
            fork
                monitor_clock(id);
            join_none
        end
        
        wait (stop_requested);
        $display("[%0t][MON] DONE", $time);
    endtask

endclass

`endif