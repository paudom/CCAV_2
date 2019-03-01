%% -- DWT FUNCTION -- %%
function [I_W,S] = DWT(cA,Levels,W12name,W3name)

    %% -- USING WAVELET DESCOMPOSITION -- %%
    S = size(cA);
    C = [];
	for i = 1:Levels
		if(i~=3)
            [Lo_D,Hi_D] = wfilters(W12name,'d');
    		[cA,cH,cV,cD] = dwt2(cA,Lo_D,Hi_D,'mode','per'); % decomposition
    		C = [cH(:)' cV(:)' cD(:)' C];% store details
    		S = [size(cA);S]; % store size
        else
            [Lo_D,Hi_D] = wfilters(W3name,'d');
    		[cA,cH,cV,cD] = dwt2(cA,Lo_D,Hi_D,'mode','per'); % decomposition
    		C = [cH(:)' cV(:)' cD(:)' C];% store details
    		S = [size(cA);S]; % store size
    	end
    end
    C = [cA(:)' C];
    S = [size(cA);S];

    %% -- ADDING A NEW DIMENSION TO REORGANIZE THE RESULTING IMAGE -- %%
    S(:,3) = S(:,1).*S(:,2); L = length(S);

    I_W = zeros(S(L,1),S(L,2));

    %% -- FILLING THE APROXIMATION PART -- %%
    I_W( 1:S(1,1) , 1:S(1,2) ) = reshape(C(1:S(1,3)),S(1,1:2));
    
    for k = 2 : L-1
        rows = [sum(S(1:k-1,1))+1:sum(S(1:k,1))];
        cols = [sum(S(1:k-1,2))+1:sum(S(1:k,2))];
        
        %% -- FILLING THE HORIZONTAL DETAILS -- %%
        c_start = S(1,3) + 3*sum(S(2:k-1,3)) + 1;
        c_stop = S(1,3) + 3*sum(S(2:k-1,3)) + S(k,3);
        I_W( 1:S(k,1) , cols ) = reshape( C(c_start:c_stop) , S(k,1:2) );

        %% -- FILLING THE VERTICAL DETAILS -- %%
        c_start = S(1,3) + 3*sum(S(2:k-1,3)) + S(k,3) + 1;
        c_stop = S(1,3) + 3*sum(S(2:k-1,3)) + 2*S(k,3);
        I_W( rows , 1:S(k,2) ) = reshape( C(c_start:c_stop) , S(k,1:2) );

        %% -- FILLING THE DIAGONAL DETAILS -- %%
        c_start = S(1,3) + 3*sum(S(2:k-1,3)) + 2*S(k,3) + 1;
        c_stop = S(1,3) + 3*sum(S(2:k,3));
        I_W( rows , cols ) = reshape( C(c_start:c_stop) , S(k,1:2) );
    end
end