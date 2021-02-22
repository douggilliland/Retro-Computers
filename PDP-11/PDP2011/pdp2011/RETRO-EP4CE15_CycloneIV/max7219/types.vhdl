-- synthesis library utils
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package machine_state_type is
    type machine_state_type IS(initialize, ready, execute, busy);
    function To_Std_Logic(L: BOOLEAN) return std_logic;
end package machine_state_type;

package body machine_state_type is
    function To_Std_Logic(L: BOOLEAN) return std_logic is
    begin
        if L then
            return('1');
        else
            return('0');
        end if;
    end function To_Std_Logic;
end package body;
