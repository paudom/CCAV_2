%% -- OVERLAPPING BLOCK -- %%
function [ pred_frame ] = OBMC(frame,x,y,H0,H1,H2,N)

	%% -- INITIALIZATION OF VARIABLES -- %%
	[Height,Width] = size(frame);
	pred_frame = double(zeros(Height,Width));
	pad_frame = double(padarray(frame,[N N],'replicate'));
	x1 = int16(padarray(x,[1 1]));
	y1 = int16(padarray(y,[1 1]));
	M = 2*N;

	%% -- OVERLAPPING PROCESS -- %%
	for rows = N:N:Height
		rblk = floor(rows/N);
		for cols = N:N:Width
			cblk = floor(cols/N);
			if(mod(rblk,2)==1) % UP
				if(mod(cblk,2)==1) % UP-LEFT
					q = pad_frame(rows+1+x1(rblk+1,cblk+1):rows+x1(rblk+1,cblk+1)+N,cols+1+y1(rblk+1,cblk+1):cols+y1(rblk+1,cblk+1)+N).*H0;
					r = pad_frame(rows+1+x1(rblk,cblk+1):rows+x1(rblk,cblk+1)+N,cols+1+y1(rblk,cblk+1):cols+y1(rblk,cblk+1)+N).*H1;
					s = pad_frame(rows+1+x1(rblk+1,cblk):rows+x1(rblk+1,cblk)+N,cols+1+y1(rblk+1,cblk):cols+y1(rblk+1,cblk)+N).*H2;
					UL = (q+r+s+4)/8;
                    pred_frame(rows-N+1:rows,cols-N+1:cols) = UL;
				else % UP-RIGHT
					q = pad_frame(rows+1+x1(rblk+1,cblk+1):rows+x1(rblk+1,cblk+1)+N,cols+1+y1(rblk+1,cblk+1):cols+y1(rblk+1,cblk+1)+N).*H0;
					r = pad_frame(rows+1+x1(rblk,cblk+1):rows+x1(rblk,cblk+1)+N,cols+1+y1(rblk,cblk+1):cols+y1(rblk,cblk+1)+N).*H1;
					s = pad_frame(rows+1+x1(rblk+1,cblk+2):rows+x1(rblk+1,cblk+2)+N,cols+1+y1(rblk+1,cblk+2):cols+y1(rblk+1,cblk+2)+N).*H2;
					UR = (q+r+s+4)/8;
                    pred_frame(rows-N+1:rows,cols-N+1:cols) = UR;
				end
			else % DOWN
				if(mod(cblk,2)==1) % DOWN-LEFT
					q = pad_frame(rows+1+x1(rblk+1,cblk+1):rows+x1(rblk+1,cblk+1)+N,cols+1+y1(rblk+1,cblk+1):cols+y1(rblk+1,cblk+1)+N).*H0;
					r = pad_frame(rows+1+x1(rblk+2,cblk+1):rows+x1(rblk+2,cblk+1)+N,cols+1+y1(rblk+2,cblk+1):cols+y1(rblk+2,cblk+1)+N).*H1;
					s = pad_frame(rows+1+x1(rblk+1,cblk):rows+x1(rblk+1,cblk)+N,cols+1+y1(rblk+1,cblk):cols+y1(rblk+1,cblk)+N).*H2;
					DL = (q+r+s+4)/8;
                    pred_frame(rows-N+1:rows,cols-N+1:cols) = DL;
				else % DOWN-RIGHT
					q = pad_frame(rows+1+x1(rblk+1,cblk+1):rows+x1(rblk+1,cblk+1)+N,cols+1+y1(rblk+1,cblk+1):cols+y1(rblk+1,cblk+1)+N).*H0;
					r = pad_frame(rows+1+x1(rblk+2,cblk+1):rows+x1(rblk+2,cblk+1)+N,cols+1+y1(rblk+2,cblk+1):cols+y1(rblk+2,cblk+1)+N).*H1;
					s = pad_frame(rows+1+x1(rblk+1,cblk+2):rows+x1(rblk+1,cblk+2)+N,cols+1+y1(rblk+1,cblk+2):cols+y1(rblk+1,cblk+2)+N).*H2;
					DR = (q+r+s+4)/8;
                    pred_frame(rows-N+1:rows,cols-N+1:cols) = DR;
				end
            end
        end
    end
end