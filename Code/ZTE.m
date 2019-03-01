%% -- ZTE ENCODING-DECODING -- %%
function [Im_ZTE,Im_Dif] = ZTE(Im_WQ,Limit)

	%% -- BLOCKS -- %%
	LL3 = Im_WQ(1:36,1:44); 
	HL3 = Im_WQ(1:36,45:88); HL2 = Im_WQ(1:72,89:176); HL1 = Im_WQ(1:144,177:352);
	LH3 = Im_WQ(37:72,1:44); LH2 = Im_WQ(73:144,1:88); LH1 = Im_WQ(145:288,1:176);
	HH3 = Im_WQ(37:72,45:88); HH2 = Im_WQ(73:144,89:176); HH1 = Im_WQ(145:288,177:352); 
	N=8; N2=2; N3=4;

	%% -- INITIALIZING -- %%
	[Height,Width] = size(Im_WQ);
	Dom = zeros(Height,Width);
	Sig = zeros(Height,Width);
	Val = zeros(Height,Width);
	Im_Proc = zeros(Height,Width);
	I = zeros(10,2); Bits = zeros(10,1);

	%% -- OPTIMIZED QUANTIZATION -- %%
	[LL3Q,I(1,:),Bits(1)] = scalar_quant(LL3);
	[HL3Q,I(2,:),Bits(2)] = scalar_quant(HL3); [HL2Q,I(5,:),Bits(5)] = scalar_quant(HL2); [HL1Q,I(8,:),Bits(8)] = scalar_quant(HL1);
	[LH3Q,I(3,:),Bits(3)] = scalar_quant(LH3); [LH2Q,I(6,:),Bits(6)] = scalar_quant(LH2); [LH1Q,I(9,:),Bits(9)] = scalar_quant(LH1);
	[HH3Q,I(4,:),Bits(4)] = scalar_quant(HH3); [HH2Q,I(7,:),Bits(7)] = scalar_quant(HH2); [HH1Q,I(10,:),Bits(10)] = scalar_quant(HH1);

	%% -- GROUP OF FAMILY WAVELETS -- %%
	for rows = 1:36
		for cols = 1:44
			Lev3 = [LL3Q(rows,cols) HL3Q(rows,cols);LH3Q(rows,cols) HH3Q(rows,cols)];
			Lev2 = [Lev3 HL2Q(N2*rows-1:N2*rows, N2*cols-1:N2*cols); LH2Q(N2*rows-1:N2*rows, N2*cols-1:N2*cols) HH2Q(N2*rows-1:N2*rows, N2*cols-1:N2*cols)];
			Dom(N*rows-7:N*rows,N*cols-7:N*cols) = [Lev2 HL1Q(N3*rows-3:N3*rows, N3*cols-3:N3*cols); LH1Q(N3*rows-3:N3*rows, N3*cols-3:N3*cols) HH1Q(N3*rows-3:N3*rows, N3*cols-3:N3*cols)];
		end
    end
    
	%% -- THRESHOLDS -- %%
	Init_Thresh = 2^(floor(log2(max(max(Dom))))); 
	T = [Init_Thresh];
	i=2;
	while(1)
		T(i) = T(i-1)/2;
		if(T(i)==1)
			break;
		end
		i = i+1;
	end

	%% -- ENCODING -- %%
	i=1;
	while(T(i)>=Limit)
		for rows = 1:Height
			for cols = 1:Width
				% -- DOMINANT PASS -- %
				if(Sig(rows,cols)==0)
					if(abs(Dom(rows,cols))>=T(i))
						Val(rows,cols)=Dom(rows,cols);
						if(Dom(rows,cols)>0)
							Im_Proc(rows,cols) = 1.5*T(i);
						else
							Im_Proc(rows,cols) = -1.5*T(i);
						end
						Sig(rows,cols) = 1;
					end
				end
				% -- SUBORDINATE PASS -- %
				if(Sig(rows,cols)==1)
					if((Dom(rows,cols)-Im_Proc(rows,cols))>=0)
						Im_Proc(rows,cols) = Im_Proc(rows,cols)+T(i)/4;
					else
						Im_Proc(rows,cols) = Im_Proc(rows,cols)-T(i)/4;
					end
				end
			end
		end
		i = i+1;
        if(i>length(T))
            break;
        end
    end
	Im_Dif = Val-Im_Proc;

	%% -- DEBLOCKING -- %%
	LL3D = zeros(36,44); HL3D = zeros(36,44); HL2D = zeros(72,88); HL1D = zeros(144,176);
	LH3D = zeros(36,44); LH2D = zeros(72,88); LH1D = zeros(144,176);
	HH3D = zeros(36,44); HH2D = zeros(72,88); HH1D = zeros(144,176);

	for rows = N:N:Height
		rblk = floor(rows/N);
		for cols = N:N:Width
			cblk = floor(cols/N);
			LL3D(rblk,cblk)=Im_Proc(rows-N+1,cols-N+1); 
            HL3D(rblk,cblk)=Im_Proc(rows-N+1,cols-N+2); 
            LH3D(rblk,cblk)=Im_Proc(rows-N+2,cols-N+1); 
            HH3D(rblk,cblk)=Im_Proc(rows-N+2,cols-N+2);
			HL2D(N2*rblk-1:N2*rblk,N2*cblk-1:N2*cblk)=Im_Proc(rows-N+1:rows-N+2,cols-N+3:cols-N+4);
            LH2D(N2*rblk-1:N2*rblk,N2*cblk-1:N2*cblk)=Im_Proc(rows-N+3:rows-N+4,cols-N+1:cols-N+2); 
			HH2D(N2*rblk-1:N2*rblk,N2*cblk-1:N2*cblk)=Im_Proc(rows-N+3:rows-N+4,cols-N+3:cols-N+4);
            HL1D(N3*rblk-3:N3*rblk,N3*cblk-3:N3*cblk)=Im_Proc(rows-N+1:rows-N+4,cols-N+5:cols);
			LH1D(N3*rblk-3:N3*rblk,N3*cblk-3:N3*cblk)=Im_Proc(rows-N+5:rows,cols-N+1:cols-N+4); 
            HH1D(N3*rblk-3:N3*rblk,N3*cblk-3:N3*cblk)=Im_Proc(rows-N+5:rows,cols-N+5:cols);
		end
	end

	%% -- DEQUANTIZE -- %%
	LL3D = scalar_dequant(LL3D,I(1,:),Bits(1));
	HL3D = scalar_dequant(HL3D,I(2,:),Bits(2)); HL2D = scalar_dequant(HL2D,I(5,:),Bits(5)); HL1D = scalar_dequant(HL1D,I(8,:),Bits(8)); 
	LH3D = scalar_dequant(LH3D,I(3,:),Bits(3)); LH2D = scalar_dequant(LH2D,I(6,:),Bits(6)); LH1D = scalar_dequant(LH1D,I(9,:),Bits(9));
	HH3D = scalar_dequant(HH3D,I(4,:),Bits(4)); HH2D = scalar_dequant(HH2D,I(7,:),Bits(7)); HH1D = scalar_dequant(HH1D,I(10,:),Bits(10));

	%% -- CONSTRUCTING FINAL ZTE IMAGE -- %%
	Lev3D = [LL3D HL3D;LH3D HH3D];
	Lev2D = [Lev3D HL2D;LH2D HH2D];
	Im_ZTE = [Lev2D HL1D;LH1D HH1D];
end