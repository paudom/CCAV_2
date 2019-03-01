%% -- FUNCTION TO READ LUM FILES -- %%

% The function gets the name of the file, the dimensions and the type of reading
% name: Name of the file
% imgSize: a row vector indicating the following: [rows, cols, NumberOfFrames]
% type: type of reading, it can be:
%		- uint8/int8
%		- uint16/int16
%		- uint32/int32

function read_lum(name, imgSize, type)

%% -- DEFINING VARIABLES -- %%
imgId = fopen(name, 'rb');
imgFull = fread(imgId, Inf, type);
fclose(imgId);
imgOri = zeros(imgSize);
NumPix = 1;

%% -- CREATING THE VIDEO -- %% 
for i = 1:imgSize(3)
   for j = 1:imgSize(1)
   imgOri(j,:,i) = imgFull(NumPix:(NumPix+imgSize(2)-1)).';
   NumPix = NumPix+imgSize(2);
   end
end

%% -- SAVING THE FINAL VARIABLE -- %%
save('video.mat','ImgOri');

end