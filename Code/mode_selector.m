%% -- SELECTING INTRA OR INTER MODE -- %%
function [x,y] = mode_selector(MSAD,SAD8,SAD16,x8,x16,y8,y16)

	%% -- INITIALIZATION OF VARIABLES -- %%
	[X,Y] = size(SAD8);
	x = double(zeros(X,Y));
	y = double(zeros(X,Y));
	Thresh = 400;

	%% -- COMPARATION BETWEEN MSAD AND SAD16 -- %%
	D = abs(MSAD-SAD16);
    [Height,Width] = size(D);
	Mode = zeros(size(D));

	%% -- SELECTING MODE -- %%
	Mode(D>Thresh) = 1;
    for rows = 1:Height
		for cols = 1:Width
			if(Mode(rows,cols)==0) %INTER MODE
				if(SAD16(rows,cols) < min(min(SAD8(2*rows-1:2*rows,2*cols-1:2*cols)))) %MOTION VECTORS 16X16 ARE SELECTED
					x(2*rows-1:2*rows,2*cols-1:2*cols) = [x16(rows,cols) x16(rows,cols);x16(rows,cols) x16(rows,cols)];
					y(2*rows-1:2*rows,2*cols-1:2*cols) = [y16(rows,cols) y16(rows,cols);y16(rows,cols) y16(rows,cols)];
                else %MOTION VECTORS 8X8 ARE SELECTED
					x(2*rows-1:2*rows,2*cols-1:2*cols) = x8(2*rows-1:2*rows,2*cols-1:2*cols);
					y(2*rows-1:2*rows,2*cols-1:2*cols) = y8(2*rows-1:2*rows,2*cols-1:2*cols);
				end
            else %INTRA MODE NO MOTION VECTORS ARE SELECTED
				x(2*rows-1:2*rows,2*cols-1:2*cols) = zeros(2);
				y(2*rows-1:2*rows,2*cols-1:2*cols) = zeros(2);
			end
        end
    end
end