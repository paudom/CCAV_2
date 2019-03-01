function [Symb,Coeff,Rec_Value] = evaluation_2(Symb,Coeff, Rec_Value,T0, ev_block, lev3, lev2, lev1, option)

	switch option
        case 'Level_3'
        	if(isempty(find(lev1>ev_block,1))==1) %ZTR LEVEL 1
	        		if(isempty(find(lev2>ev_block,1))==1) %ZTR LEVEL 2
		        			if(lev3<ev_block) %ZTR LEVEL 3
		        				Symb = 2;
		        			else %IZ
		        				Symb = 3;
		        			end
	        			if(Symb == 0)
	        				Symb = 2;
	        			end 
	        		else
	        			if(Symb == 0)
	        				Symb = 3;
	        			end
	        		end
	        	if(Symb == 0)
	        		Symb = 2;
	        	end
	        else
	            Symb = 3;
            end
            
            Coeff = ev_block;
            Rec_Value = 0;
        
       	case 'Level_2'
       		
       		if(isempty(find(lev1>lev3,1))==1) %ZTR LEVEL 1
	       			if(isempty(find(lev2>lev3,1))==1) %ZTR LEVEL 2
	       				Symb = 2;
	       			else
	       				Symb = 3;
	       			end
	       		if(Symb == 0)
	       			Symb = 2;
	       		end
	       	else
	       		Symb = 3;
	       	end
     
            Coeff = ev_block;
            Rec_Value = 0;

       	case 'Level_1'

       		if(isempty(find(lev1>lev2,1))==1 || isempty(find(lev1>T0,1))==1) %Aquesta última condicio q he afegit no sé si està bé i s'hauria d'afegir a la resta
       			Symb = 2;
       		else
       			Symb = 3;
       		end

          Coeff = ev_block;
           Rec_Value = 0;

    end

end