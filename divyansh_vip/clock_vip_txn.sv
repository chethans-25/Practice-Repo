`ifndef CLOCK_VIP_TXN_SV
`define CLOCK_VIP_TXN_SV

typedef enum int {
    CMD_START,
    CMD_STOP,
    CMD_RESET,
    CMD_END,
    OBS_PERIOD,
    OBS_STOP,
    OBS_RESET
} clock_cmd_e;


class clock_vip_txn;

    clock_cmd_e  command;

    int unsigned clock_id;
    int unsigned session_id;
    int unsigned transaction_id;

    int unsigned frequency_mhz;
    int unsigned periods_to_check;

    realtime     expected_period_ns;
    realtime     expected_frequency_mhz;

    realtime     measured_period_ns;
    realtime     measured_frequency_mhz;

    bit          observed_reset_n;
    bit          observed_dut_clk;
    bit          observed_clock_active;


    function new(clock_cmd_e command = CMD_START);
        this.command                 = command;
        this.clock_id                = 0;
        this.session_id              = 0;
        this.transaction_id          = 0;
        this.frequency_mhz           = 1;
        this.periods_to_check        = 3;
        this.expected_period_ns      = 0.0;
        this.expected_frequency_mhz  = 0.0;
        this.measured_period_ns      = 0.0;
        this.measured_frequency_mhz  = 0.0;
        this.observed_reset_n        = 1'b1;
        this.observed_dut_clk        = 1'b0;
        this.observed_clock_active   = 1'b0;
    endfunction


    function string command_name();
        return command.name();
    endfunction


    function clock_vip_txn clone();
        clock_vip_txn copy;
        copy = new(this.command);
        copy.clock_id                = this.clock_id;
        copy.session_id              = this.session_id;
        copy.transaction_id          = this.transaction_id;
        copy.frequency_mhz           = this.frequency_mhz;
        copy.periods_to_check        = this.periods_to_check;
        copy.expected_period_ns      = this.expected_period_ns;
        copy.expected_frequency_mhz  = this.expected_frequency_mhz;
        copy.measured_period_ns      = this.measured_period_ns;
        copy.measured_frequency_mhz  = this.measured_frequency_mhz;
        copy.observed_reset_n        = this.observed_reset_n;
        copy.observed_dut_clk        = this.observed_dut_clk;
        copy.observed_clock_active   = this.observed_clock_active;
        return copy;
    endfunction


    function string sprint();
        return $sformatf(
            "clock=%0d session=%0d txn=%0d cmd=%s freq=%0d MHz periods=%0d exp_period=%0.3f ns meas_period=%0.3f ns",
            clock_id,
            session_id,
            transaction_id,
            command_name(),
            frequency_mhz,
            periods_to_check,
            expected_period_ns,
            measured_period_ns
        );
    endfunction

endclass

`endif