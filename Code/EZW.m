%% -- EZW ENCODING -- %%
function [Im_EZW,Im_Dif] = EZW(Im_WQ,Limit)

	%% -- THRESHOLDS -- %%
	Init_Thresh = 2^(floor(log2(max(max(Im_WQ))))); 
	T = [Init_Thresh];
	i=2;
	while(1)
		T(i) = T(i-1)/2;
		if(T(i)==1)
			break;
		end
		i = i+1;
	end

	%% -- INITIALIZING -- %%
	[Height,Width] = size(Im_WQ);
	Sig = zeros(Height,Width);
	Val = zeros(Height,Width);
	Im_EZW = zeros(Height,Width);

	%% -- ENCODING -- %%
	i=1;
	while(T(i)>=Limit)
		for rows = 1:Height
			for cols = 1:Width
				% -- DOMINANT PASS -- %
				if(Sig(rows,cols)==0)
					if(abs(Im_WQ(rows,cols))>=T(i))
						Val(rows,cols)=Im_WQ(rows,cols);
						if(Im_WQ(rows,cols)>0)
							Im_EZW(rows,cols) = 1.5*T(i);
						else
							Im_EZW(rows,cols) = -1.5*T(i);
						end
						Sig(rows,cols) = 1;
					end
				end
				% -- SUBORDINATE PASS -- %
				if(Sig(rows,cols)==1)
					if((Im_WQ(rows,cols)-Im_EZW(rows,cols))>=0)
						Im_EZW(rows,cols) = Im_EZW(rows,cols)+T(i)/4;
					else
						Im_EZW(rows,cols) = Im_EZW(rows,cols)-T(i)/4;
					end
				end
			end
		end
		i = i+1;
        if(i>length(T))
            break;
        end
    end
	Im_Dif = Val-Im_EZW;
end