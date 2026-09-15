`ifndef CLOCK_VIP_ENVIRONMENT_SV
`define CLOCK_VIP_ENVIRONMENT_SV

class clock_vip_environment;

    mailbox #(clock_vip_txn) command_mbx;
    mailbox #(clock_vip_txn) expected_mbx[NUM_CLOCKS];
    mailbox #(clock_vip_txn) observed_mbx[NUM_CLOCKS];

    mailbox #(bit) periods_done_mbx[NUM_CLOCKS];
    mailbox #(bit) stop_done_mbx[NUM_CLOCKS];
    mailbox #(bit) reset_done_mbx[NUM_CLOCKS];

    semaphore clk_sem;

    clock_vip_generator  gen;
    clock_vip_driver     drv;
    clock_vip_monitor    mon;
    clock_vip_scoreboard scb;

    virtual clock_vip_if.DRIVER  drv_vif;
    virtual clock_vip_if.MONITOR mon_vif;
    virtual clock_vip_if.GEN     gen_vif;


    function new(
        virtual clock_vip_if.DRIVER  drv_vif,
        virtual clock_vip_if.MONITOR mon_vif,
        virtual clock_vip_if.GEN     gen_vif
    );
        this.drv_vif = drv_vif;
        this.mon_vif = mon_vif;
        this.gen_vif = gen_vif;

        command_mbx  = new();
        clk_sem = new(1);

        for (int i = 0; i < NUM_CLOCKS; i++) begin
            expected_mbx[i]     = new();
            observed_mbx[i]     = new();
            periods_done_mbx[i] = new();
            stop_done_mbx[i]    = new();
            reset_done_mbx[i]   = new();
        end

        gen = new(command_mbx, expected_mbx,
                  periods_done_mbx, stop_done_mbx, reset_done_mbx,
                  gen_vif);

        drv = new(command_mbx, clk_sem, drv_vif);

        mon = new(observed_mbx, mon_vif);

        scb = new(expected_mbx, observed_mbx,
                  periods_done_mbx, stop_done_mbx, reset_done_mbx,
                  mon_vif);
    endfunction


    task run();

        fork
            mon.run();
        join_none

        fork
            gen.run();
            drv.run();
            scb.run();
        join

        mon.request_stop();
        wait fork;

        scb.report();

    endtask

endclass

`endif