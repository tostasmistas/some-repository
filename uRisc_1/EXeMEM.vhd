use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EXeMEM is
	port(
	-- input
	clk, rst 					: in std_logic;
	oper_A						: in std_logic_vector(15 downto 0);	-- operando A para a ALU (vem do OF)
	oper_B						: in std_logic_vector(15 downto 0) 	-- operando B para a ALU (vem do OF)
	out_mux_constantes  		: in std_logic_vector(15 downto 0) 	-- operando para carregamento de constantes	(vem do OF)	
	  
	ALU_OPER					: in std_logic_vector(4 downto 0);
	FLAGS_IN					: in std_logic_vector(3 downto 0);
			
	---PARA A FlagTest
	TRANS_OP					: in std_logic_vector(1 downto 0);
	TRANS_FI_COND_IN			: in std_logic_vector(3 downto 0);
	FLAGTEST_active_IN			: in std_logic;


	-- output
	out_mux_WB					: out std_logic_vector(15 downto 0); -- saída para o WB

	--Registo
	REG_WC            			: out std_logic_vector(15 downto 0)
	flagtest_rel_OUT			: out std_logic;						-- salto relativo
	flagtest_abs_OUT			: out std_logic							-- salto absoluto
	FLAGS_OUT					: out std_logic_vector(3 downto 0);
	FLAGTEST_cond_OUT			: out std_logic
		
	);
end EXeMEM;

architecture Behavioral of EXeMEM is

--------------------------------------------------------------------------
--------------------------- Aux Signals ----------------------------------
--------------------------------------------------------------------------
signal out_ALU				: std_logic_vector(15 downto 0) := (others => '0'); -- saída da ALU
signal aux_FLAGS			: std_logic_vector(3 downto 0) := (others => '0'); 	-- Z,N,C,O
signal aux_MSR_FLAGS		: std_logic_vector(3 downto 0) := (others => '0');
signal aux_flagtest_rel		: std_logic := '0';
signal aux_FLAGTEST			: std_logic := '0';


--------------------------------------------------------------------------
---------------------  Constantes   --------------------------------------
--------------------------------------------------------------------------
constant zeros				: std_logic_vector(3 downto 0) := (others => '0');

begin
---------------------------------------------------------------------------------------------
---------------------------------- MEMORIA --------------------------------------------------
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
----------------------------------- ALU -----------------------------------------------------
---------------------------------------------------------------------------------------------

-- a saida da ALU deve ser armazenada no sinal out_ALU

out_mux_WB <=	out_ALU				when inst_IN(14) = '0' else
				out_mux_constantes;

---------------------------------------------------------------------------------------------
---------------------------------- TESTE FLAGS ----------------------------------------------
---------------------------------------------------------------------------------------------
aux_FLAGMUX	 <= FLAGS_IN(0) when TRANS_FI_COND_IN="0101" else
					 FLAGS_IN(1) when TRANS_FI_COND_IN="0100" else
					 FLAGS_IN(2) when TRANS_FI_COND_IN="0110" else
					 FLAGS_IN(3) when TRANS_FI_COND_IN="0011" else
						 '1' 	 	 when TRANS_FI_COND_IN="0000" else
					 FLAGS_IN(0) or aux_FLAGS(1) when TRANS_FI_COND_IN="0111" else
					 '0';


aux_FLAGTEST <= aux_FLAGMUX xnor TRANS_OP(1);

aux_FLAGTEST_cond <= (TRANS_OP(1) and not(TRANS_OP(0))) or (aux_FLAGTEST and not(TRANS_OP(1))); 




---------------------------------------------------------------------------------------------
----------------------------------- REGISTO FLAGS -------------------------------------------
---------------------------------------------------------------------------------------------

process (clk, rst)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				aux_MSR_FLAGS <= zeros;
			else
				aux_MSR_FLAGS <= aux_FLAGS;
			end if;		
		end if;
end process;


FLAGS_OUT <= aux_MSR_FLAGS;

end Behavioral;

