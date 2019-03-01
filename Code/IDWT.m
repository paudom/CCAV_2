%% -- IDWT FUNCTION -- %%
function [Im] = IDWT(Im_W2,S,Levels,W12name,W3name)

	L = length(S);

	C = zeros(1,S(1,3)+3*sum(S(2:L-1,3)));

	% approx part
	C(1:S(1,3)) = reshape(Im_W2( 1:S(1,1) , 1:S(1,2) ), 1 , S(1,3) );

	for k = 2:L-1
	    rows = [sum(S(1:k-1,1))+1:sum(S(1:k,1))];
	    cols = [sum(S(1:k-1,2))+1:sum(S(1:k,2))];
	    % horizontal part
	    c_start = S(1,3) + 3*sum(S(2:k-1,3)) + 1;
	    c_stop = S(1,3) + 3*sum(S(2:k-1,3)) + S(k,3);
	    C(c_start:c_stop) = reshape(Im_W2(1:S(k,1),cols) , 1, c_stop-c_start+1);
	    % vertical part
	    c_start = S(1,3) + 3*sum(S(2:k-1,3)) + S(k,3) + 1;
	    c_stop = S(1,3) + 3*sum(S(2:k-1,3)) + 2*S(k,3);
	    C(c_start:c_stop) = reshape(Im_W2( rows , 1:S(k,2) ) , 1 , c_stop-c_start+1 );
	    % diagonal part
	    c_start = S(1,3) + 3*sum(S(2:k-1,3)) + 2*S(k,3) + 1;
	    c_stop = S(1,3) + 3*sum(S(2:k,3));
	    C(c_start:c_stop) = reshape(Im_W2(rows,cols) , 1 , c_stop-c_start+1);
	end

	if (( L - 2) > Levels)   %set those coef. in higher scale to 0
	    temp = zeros(1, length(C) - (S(1,3)+3*sum(S(2:(Levels+1),3))));
	    C(S((Levels+2),3)+1 : length(C)) = temp;
	end

	S(:,3) = [];
	
	rmax = size(S,1);
	nmax = rmax-2;
	Im = zeros(S(1,1),S(1,2));
	Im(:) = C(1:S(1,1)*S(1,2));
	
	rm   = rmax+1;
	for p = nmax:-1:1
		if(p==3)
			[Lo_R,Hi_R] = wfilters(W3name,'r');
	    	[h,v,d] = detcoef2('all',C,S,p);
	    	Im = idwt2(Im,h,v,d,Lo_R,Hi_R,S(rm-p,:),'mode','per');
	    else
 	   		[Lo_R,Hi_R] = wfilters(W12name,'r');
	    	[h,v,d] = detcoef2('all',C,S,p);
	    	Im = idwt2(Im,h,v,d,Lo_R,Hi_R,S(rm-p,:),'mode','per');
	    end	
	end
end