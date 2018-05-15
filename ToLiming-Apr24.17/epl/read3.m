% This file h.all is in "aliant" format, which is also linix
% format. Thus no conversion is required
NXP=56; TNXP=2*NXP;
NFT2=512;NP2=NFT2+2;NFT2=NP2/2;
Fmax=10000;
EPL=[];

fd=fopen('h.all','r');

xp=fread(fd,NXP,'float32'); %Read in place locations

	for k=1:NFT2
data=fread(fd,TNXP,'float32'); %Read in real and imag part of filter
epl=data(1:2:TNXP)+i*data(2:2:TNXP); %rewrite as complex
%semilogy(xp,abs(epl))
%pause(1)
drawnow
EPL=[EPL,epl(:)];
	end

hold off
	for ix=1:10:NXP
pltfast(EPL(ix,:),Fmax)
drawnow
hold on
	end
hold off
ylim([1e-6 1])
xlim([1e2 1e4])
