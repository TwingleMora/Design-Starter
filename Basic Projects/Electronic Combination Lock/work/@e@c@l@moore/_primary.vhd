library verilog;
use verilog.vl_types.all;
entity ECLMoore is
    generic(
        IDLE            : integer := 0;
        S0              : integer := 1;
        S01             : integer := 2;
        S010            : integer := 3;
        S0101           : integer := 4;
        S01011          : integer := 5
    );
    port(
        but_0           : in     vl_logic;
        but_1           : in     vl_logic;
        RESET           : in     vl_logic;
        CLK             : in     vl_logic;
        UNLOCK          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of S0 : constant is 1;
    attribute mti_svvh_generic_type of S01 : constant is 1;
    attribute mti_svvh_generic_type of S010 : constant is 1;
    attribute mti_svvh_generic_type of S0101 : constant is 1;
    attribute mti_svvh_generic_type of S01011 : constant is 1;
end ECLMoore;
