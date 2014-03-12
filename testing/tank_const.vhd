library IEEE;
use IEEE.std_logic_1164.all;
--Additional standard or custom libraries go here
package tank_const is
constant T_SIZE : integer := 10;
constant C_LENGTH : integer := 5;
constant C_WIDTH : integer := 2;
constant BULLET_TRAVEL : integer := 10; --must be <= T_SIZE

--Other constants, types, subroutines, components go here
end package tank_const;
package body tank_const is
--Subroutine declarations go here
-- you will not have any need for it now, this package is only for defining -
-- some useful constants
end package body tank_const;