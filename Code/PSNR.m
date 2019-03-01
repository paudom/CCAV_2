%% -- PSNR CALCULATION  -- %%
function [PSNR_EZW,PSNR_ZTE] = PSNR(Original,EZW,ZTE)

	%% -- DEFINITION OF VARIABLES -- %%
	Original = uint8(Original);
	EZW = uint8(EZW);
	ZTE = uint8(ZTE);

	%% -- CALCULATION OF PSNR -- %%
	PSNR_EZW = psnr(EZW,Original);
	PSNR_ZTE = psnr(ZTE,Original);

end
