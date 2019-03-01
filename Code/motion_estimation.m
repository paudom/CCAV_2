%% -- MOTION ESTIMATION -- %%
function [x,y,MSAD,SAD] = motion_estimation(ref_frame,curr_frame,N)

	%% -- VARIABLES -- %%
	[Height,Width] = size(ref_frame);
	x = int16(zeros(Height/N,Width/N));
	y = int16(zeros(Height/N,Width/N));
    SAD = zeros(Height/N,Width/N);
    MSAD = zeros(Height/N,Width/N);
    
	%% -- MIRRORING THE FRAMES -- %%
	r_frame = double(padarray(ref_frame,[N N],'replicate')); 
	c_frame = double(padarray(curr_frame,[N N],'replicate'));

	%% -- ESTIMATING THE MOTION VECTORS 8x8 AND CALCULATING MSAD -- %%
	for r = N:N:Height
		rblk = floor(r/N);
		for c = N:N:Width
			cblk = floor(c/N);
			D = 1.0e+10;
			for u = -N:N
				for v = -N:N
					difference = c_frame(r+1:r+N,c+1:c+N)-r_frame(r+u+1:r+u+N,c+v+1:c+v+N);
					SAD(rblk,cblk) = sum(abs(difference(:)))-100;
					if SAD(rblk,cblk) < D
						D = SAD(rblk,cblk);
						x(rblk,cblk) = v; y(rblk,cblk) = u;
					end
				end
            end
            MBlock = curr_frame((rblk-1)*N+1:rblk*N,(cblk-1)*N+1:cblk*N);
			Mean_MB = mean(mean(MBlock));
            MB = MBlock-Mean_MB;
			MSAD(rblk,cblk) = round(sum(abs(MB(:))));
		end
    end
        
    %% -- MOTION REGULAR COMPENSATION USING BLOCK MATCHING -- %%
% 	N2 = 2*N;
% 	comp_frame = double(zeros(Height,Width)); % reconstructed frame
% 	for r = 1:N:Height
% 		rblk = floor(r/N)+1;
% 		for c = 1:N:Width
% 			cblk = floor(c/N)+1;
% 			x1 = x(rblk,cblk); y1 = y(rblk,cblk);
% 			comp_frame(r:r+N-1,c:c+N-1) = r_frame(r+N+y1:r+y1+N2-1,c+N+x1:c+x1+N2-1);
% 		end
% 	end
end