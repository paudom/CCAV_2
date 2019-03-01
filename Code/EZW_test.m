%% -- EZW TEST -- %%
%              Matrix Symb 
%              '0' zero
%              '1' significant positive
%              '2' zerotree root
%              '3' isolated zero


%% -- CLEARING MATLAB -- %%
clear all
close all
clc

%% -- LOADING IMAGE -- %%
%IMAG = [30 30 49 10 7 13 12 7;31 23 14 13 3 4 6 1;15 14 3 12 5 7 3 9;9 7 14 8 4 2 3 2;5 9 1 47 4 6 2 2;3 0 3 2 3 2 0 4;2 3 6 4 3 6 3 6;5 11 5 6 0 3 4 4];
load IMAG;

%% -- BLOCKS -- %%
LL3 = IMAG(1,1);
% - HL FAMILY -%
HL3 = IMAG(1,2); HL2 = IMAG(1:2,3:4); HL1 = IMAG(1:4,5:8);
% - LH FAMILY - %
LH3 = IMAG(2,1); LH2 = IMAG(3:4,1:2); LH1 = IMAG(5:8,1:4);
% - HH FAMILY -%
HH3 = IMAG(2,2); HH2 = IMAG(3:4,3:4); HH1 = IMAG(5:8,5:8); 

%% -- INITIALIZING VARIABLES -- %%
Init_Thresh = 2^(floor(log2(max(max(IMAG))))); 
T = [Init_Thresh];
i=2;
while(1)
	T(i) = T(i-1)/2;
	if(T(i)==1)
		break;
	end
	i = i+1;
end
i=1;
[Height,Width] = size(IMAG);
Symb = zeros(Height,Width);
Coeff = zeros(Height,Width);
Rec_Value = zeros(Height,Width);
K=6;

%% -- IMPLEMENTED EWW -- %%
while(T(i)>=K)
    
    if(LL3>T(i))
        Symb(1,1) = 1;
        Coeff(1,1) = LL3;
        Rec_Value(1,1) = T(i)+(T(i)/2);
    else
        %FAMILY HL
        [Symb(1,1),Coef(1,1),Rec_Value(1,1)] = evaluation_2(Symb(1,1),Coeff(1,1), Rec_Value(1,1),T(i), LL3, HL3, HL2, HL1, 'Level_3');
        %FAMILY LH
        [Symb(1,1),Coef(1,1),Rec_Value(1,1)] = evaluation_2(Symb(1,1),Coeff(1,1), Rec_Value(1,1),T(i), LL3, LH3, LH2, LH1, 'Level_3');
        %FAMILY HH
        [Symb(1,1),Coef(1,1),Rec_Value(1,1)] = evaluation_2(Symb(1,1),Coeff(1,1), Rec_Value(1,1),T(i), LL3, HH3, HH2, HH1, 'Level_3');
    end
    
    %FAMILY HL
    if(HL3>T(i))
        Symb(1,2) = 1;
        Coeff(1,2) = HL3;
        Rec_Value(1,2) = T(i)+T(i)/2;
    else
        [Symb(1,2),Coeff(1,2),Rec_Value(1,2)] = evaluation_2(Symb(1,2),Coeff(1,2), Rec_Value(1,2),T(i), LL3, HL3, HL2, HL1,'Level_2');
    end
    
    for rows=1:2
        for cols=1:2
            if(HL2(rows,cols)>T(i))
                Symb(rows,2+cols) = 1;
                Coeff(rows,2+cols) = HL2(rows,cols);
                Rec_Value(rows,2+cols) = T(i)+T(i)/2;
            else
                [Symb(rows,2+cols),Coeff(rows,2+cols),Rec_Value(rows,2+cols)] = evaluation_2(Symb(rows,2+cols),Coeff(rows,2+cols),Rec_Value(rows,2+cols),T(i), LL3,HL3, HL2(rows,cols), HL1(2*rows-1:2*rows, 2*cols-1:2*cols),'Level_1');
            end   
        end 
    end

    for rows=1:4
        for cols=1:4
            if(HL1(rows,cols)>T(i))
                Symb(rows,4+cols) = 1;
                Coeff(rows,4+cols) = HL1(rows,cols);
                Rec_Value(rows,4+cols) = T(i)+T(i)/2;
            end
        end
    end

    %FAMILY LH
    if(LH3>T(i))
        Symb(2,1) = 1;
        Coeff(2,1) = LH3;
        Rec_Value(2,1) = T(i)+T(i)/2;
    else
        [Symb(2,1),Coeff(2,1),Rec_Value(1,2)] = evaluation_2(Symb(2,1),Coeff(2,1), Rec_Value(2,1),T(i), LL3, LH3, LH2, LH1,'Level_2');
    end
    
    for rows=1:2
        for cols=1:2
            if(LH2(rows,cols)>T(i))
                Symb(2+rows,cols) = 1;
                Coeff(2+rows,cols) = LH2(rows,cols);
                Rec_Value(rows,2+cols) = T(i)+T(i)/2;
            else
                [Symb(2+rows,cols),Coeff(rows,2+cols),Rec_Value(2+rows,cols)] = evaluation_2(Symb(2+rows,cols),Coeff(2+rows,cols),Rec_Value(2+rows,cols),T(i), LL3,LH3, LH2(rows,cols), LH1(2*rows-1:2*rows, 2*cols-1:2*cols),'Level_1');
            end   
        end 
    end

    for rows=1:4
        for cols=1:4
            if(LH1(rows,cols)>T(i))
                Symb(4+rows,cols) = 1;
                Coeff(4+rows,cols) = LH1(rows,cols);
                Rec_Value(4+rows,cols) = T(i)+T(i)/2;
            end
        end
    end

    %FAMILY HH
    if(HH3>T(i))
        Symb(2,2) = 1;
        Coeff(2,2) = HH3;
        Rec_Value(2,2) = T(i)+T(i)/2;
    else
        [Symb(2,2),Coeff(2,2),Rec_Value(2,2)] = evaluation_2(Symb(2,2),Coeff(2,2), Rec_Value(2,2),T(i), LL3, HH3, HH2, HH1,'Level_2');
    end
    
    for rows=1:2
        for cols=1:2
            if(HH2(rows,cols)>T(i))
                Symb(2+rows,2+cols) = 1;
                Coeff(2+rows,2+cols) = HH2(rows,cols);
                Rec_Value(2+rows,2+cols) = T(i)+T(i)/2;
            else
                [Symb(2+rows,2+cols),Coeff(2+rows,2+cols),Rec_Value(2+rows,2+cols)] = evaluation_2(Symb(2+rows,2+cols),Coeff(2+rows,2+cols),Rec_Value(2+rows,2+cols),T(i), LL3,HH3, HH2(rows,cols), HH1(2*rows-1:2*rows, 2*cols-1:2*cols),'Level_1');
            end   
        end 
    end

    for rows=1:4
        for cols=1:4
            if(HH1(rows,cols)>T(i))
                Symb(4+rows,4+cols) = 1;
                Coeff(4+rows,4+cols) = HH1(rows,cols);
                Rec_Value(4+rows,4+cols) = T(i)+T(i)/2;
            end
        end
    end
    
    i=i+1;

end
   