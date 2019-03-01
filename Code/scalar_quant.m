function [Q_Block,I,b] = scalar_quant(Block)
    
    %% -- VARIABLES -- %%
	IQmin = min(min(Block));
	IQmax = max(max(Block));
	b = ceil(log2(IQmax-IQmin))+1;
	N = pow2(b);
	Q = (IQmax-IQmin)/N;
    I= [IQmin IQmax];

	%% -- QUANTIZATION PROCESS -- %%
	Q_Block = floor(abs(Block/Q)).*sign(Block);
end

