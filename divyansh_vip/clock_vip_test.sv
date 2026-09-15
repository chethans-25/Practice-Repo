`ifndef CLOCK_VIP_TEST_SV
`define CLOCK_VIP_TEST_SV

class clock_vip_test;

    clock_vip_environment env;

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
    endfunction


    task automatic run();
        env = new(drv_vif, mon_vif, gen_vif);
        env.run();
    endtask

endclass

`endif