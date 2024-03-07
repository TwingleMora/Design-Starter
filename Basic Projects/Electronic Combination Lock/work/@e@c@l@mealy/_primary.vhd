library verilog;
use verilog.vl_types.all;
entity ECLMealy is
    port(
        CLK             : in     vl_logic;
        RESET           : in     vl_logic;
        but_0           : in     vl_logic;
        but_1           : in     vl_logic;
        UNLOCK          : out    vl_logic
    );
end ECLMealy;
