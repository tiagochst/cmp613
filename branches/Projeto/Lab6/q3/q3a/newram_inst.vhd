newram_inst : newram PORT MAP (
		address	 => address_sig,
		clken	 => clken_sig,
		clock	 => clock_sig,
		data	 => data_sig,
		wren	 => wren_sig,
		q	 => q_sig
	);
