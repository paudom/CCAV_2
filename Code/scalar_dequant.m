function [Block] = scalar_dequant(Q_Block,I,b)
    %% -- VARIABLES -- %%
    IQmin = I(1,1);
    IQmax = I(1,2);
    N = pow2(b);
	Q = (IQmax-IQmin)/N;

	%% -- DESQUANTIZE PROCESS-- %%
	Block = sign(Q_Block).*(abs(Q_Block)+(Q/2))*Q;
end
