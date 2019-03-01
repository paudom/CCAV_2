%% -- ZEROTREE WAVELET VIDEO CODER -- %%

% This is an algorithm that recreates the zerotree wavelet coding for video.
% Based on the work of the following paper: 
% 	- Stephen A. Martucci, Member, IEEE, Iraj Sodagar, Member, IEEE, Tihao Chiang, Member, IEEE " A Zerotree Wavelet Video Coder"

%% -- CLEARING MATLAB -- %%
clear all
close all
clc

%% -- LOADING IMAGE -- %%
load video 

%% -- INITIALIZING VARIABLES -- %%
N = 8;
M = 16;
H0 = [4 5 5 5 5 5 5 4;5 5 5 5 5 5 5 5;5 5 6 6 6 6 5 5;5 5 6 6 6 6 5 5;5 5 6 6 6 6 5 5;5 5 6 6 6 6 5 5;5 5 5 5 5 5 5 5;4 5 5 5 5 5 5 4];
H1 = [2 2 2 2 2 2 2 2;1 1.5 2 2 2 2 1.5 1;1 1 1 1 1 1 1 1;1 1 1 1 1 1 1 1;1 1 1 1 1 1 1 1;1 1 1 1 1 1 1 1;1 1.5 2 2 2 2 1.5 1;2 2 2 2 2 2 2 2];
H2 = H1';

%% -- VARIABLES THAT AFFECT THE SYSTEM -- %%
Start = 30;
Mode = 'IPPPPP'; TimesMode = 8;
Repeat = repmat(Mode,TimesMode); Selector = Repeat(1,:); clear Repeat;
RateControl = input('Please Select your desired RateControl: ');
option = input('Fixed Rate Control (1) or Vaiable Rate Control (0): ');
switch option
    case 1
        Limit = ones(length(Selector),1)*RateControl;
    case 0
        Limit = 0+rand(length(Selector))*RateControl;
    otherwise
        return
end
Intra_mode = Selector=='I';
PSNR_EZW = zeros(length(Selector),1);
PSNR_ZTE = PSNR_EZW;

%% -- SYSTEM -- %%
for i=1:length(Selector)
	switch Selector(i)
		case 'I'
			%% -- CALCULATE DWT -- %%
			[Im_W,S]= DWT(Video(:,:,Start+i-1),3,'db8','db1');
	
			%% -- EZW Coding -- %%
			[Im_EZW,~]=EZW(Im_W,Limit(i));
			[Im_ZTE,~]=ZTE(Im_W,Limit(i));
	
			%% -- CALCULATE IDWT -- %%
			Im_1 = IDWT(Im_EZW,S,3,'db8','db1');
			Im_2 = IDWT(Im_ZTE,S,3,'db8','db1');

			%% -- CALCULATE PSNR -- %%
			[PSNR_EZW(i),PSNR_ZTE(i)]=PSNR(Video(:,:,Start+i-1),Im_1,Im_2);
			change = 1;
		case 'P'
			if(change==1)
				%% -- MOTION ESTIMATION -- %%
				[x8,y8,SAD8,~] = motion_estimation(Video(:,:,Start+i-2),Video(:,:,Start+i-1),N);
				[x16,y16,SAD16,MSAD] = motion_estimation(Video(:,:,Start+i-2),Video(:,:,Start+i-1),M);
	
				%% -- INTRA INTER BLOC MODE SELECTOR -- %%
				[x,y] = mode_selector(MSAD,SAD8,SAD16,x8,x16,y8,y16);
            	clear x8, clear y8, clear x16, clear y16, clear SAD8, clear SAD16,clear MSAD;
	
				%% -- MOTION COMPENSATION USING OVERLAPPING -- %%
				rec = OBMC(Video(:,:,Start+i-2),x,y,H0,H1,H2,N);
	
				%% -- CALCULATE ERROR FRAME --%
				error = Video(:,:,Start+i-1)-rec;
	
				%% -- CALCULATE DWT -- %%
				[Im_W,S]= DWT(error,3,'db8','db1');
	
				%% -- EZW Coding -- %%
				[Im_EZW,~]=EZW(Im_W,Limit(i));
				[Im_ZTE,~]=ZTE(Im_W,Limit(i));
	
				%% -- CALCULATE IDWT -- %%
				Ie_ezw = IDWT(Im_EZW,S,3,'db8','db1');
				Ie_zte = IDWT(Im_ZTE,S,3,'db8','db1');

				%% -- RECONSTRUCT THE IMAGE WITH THE MOTION VECTORS -- %%
				Im_1 = Ie_ezw+rec;
				Im_2 = Ie_zte+rec;
            
				%% -- CALCULATE PSNR -- %%
				[PSNR_EZW(i),PSNR_ZTE(i)]=PSNR(Video(:,:,Start+i-1),Im_1,Im_2);
				change = 0;
			else
				%% -- MOTION ESTIMATION -- %%
				[xe8,ye8,SADe8,~] = motion_estimation(Im_1,Video(:,:,Start+i-1),N);
				[xe16,ye16,SADe16,MSADe] = motion_estimation(Im_1,Video(:,:,Start+i-1),M);
				[xt8,yt8,SADt8,~] = motion_estimation(Im_2,Video(:,:,Start+i-1),N);
				[xt16,yt16,SADt16,MSADt] = motion_estimation(Im_2,Video(:,:,Start+i-1),M);

				%% -- INTRA INTER BLOC MODE SELECTOR -- %%
				[xe,ye] = mode_selector(MSADe,SADe8,SADe16,xe8,xe16,ye8,ye16);
            	clear xe8, clear ye8, clear xe16, clear ye16, clear SADe8, clear SADe16,clear MSADe;
				[xt,yt] = mode_selector(MSADt,SADt8,SADt16,xt8,xt16,yt8,yt16);
            	clear xt8, clear yt8, clear xt16, clear yt16, clear SADt8, clear SADt16,clear MSADt;

				%% -- MOTION COMPENSATION USING OVERLAPPING -- %%
				rece = OBMC(Im_1,xe,ye,H0,H1,H2,N);
				rect = OBMC(Im_2,xt,yt,H0,H1,H2,N);
	
				%% -- CALCULATE ERROR FRAME --%
				errore = Video(:,:,Start+i-1)-rece;
				errort = Video(:,:,Start+i-1)-rect;
	
				%% -- CALCULATE DWT -- %%
				[Ime_W,S]= DWT(errore,3,'db8','db1');
				[Imt_W,S]= DWT(errort,3,'db8','db1');
	
				%% -- EZW Coding -- %%
				[Im_EZW,~]=EZW(Ime_W,Limit(i));
				[Im_ZTE,~]=ZTE(Imt_W,Limit(i));
	
				%% -- CALCULATE IDWT -- %%
				Ie_ezw = IDWT(Im_EZW,S,3,'db8','db1');
				Ie_zte = IDWT(Im_ZTE,S,3,'db8','db1');

				%% -- RECONSTRUCT THE IMAGE WITH THE MOTION VECTORS -- %%
				Im_1 = Ie_ezw+rece;
				Im_2 = Ie_zte+rect;
            
				%% -- CALCULATE PSNR -- %%
				[PSNR_EZW(i),PSNR_ZTE(i)]=PSNR(Video(:,:,Start+i-1),Im_1,Im_2);
			end
    end
end

%% -- PLOTTING PSNR -- %%
frames = 1:1:length(Selector);
Maximum = max(max(PSNR_EZW),max(PSNR_ZTE));
Minimum = min(min(PSNR_EZW),min(PSNR_ZTE));
fig_12 = figure(12);
plot(frames,PSNR_EZW,'LineWidth',2.2,'Color',[0.9922 0.6627 0.1098])
hold on;
plot(frames,PSNR_ZTE,'LineWidth',2.2,'Color',[0.9647 0.3960 0.0624])
plot(frames(1:3:end),double(Intra_mode(1:3:end)).*PSNR_EZW(1:3:end),'o','MarkerSize',12,'color',[165 105 189]/255)
plot(frames(1:3:end),double(Intra_mode(1:3:end)).*PSNR_ZTE(1:3:end),'o','MarkerSize',12,'color',[165 105 189]/255)
title(['Comparation between EZW and ZTE, RateControl = Variable' num2str(RateControl) '.']);
xlabel('Frames');
ylabel('PSNR Value');
legend('EZW','ZTE','Intra');
grid on;
axis([1 length(Selector) Minimum-6 Maximum+6]);
hold off;
