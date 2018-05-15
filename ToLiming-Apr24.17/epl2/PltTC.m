figure(1); clf

load TC_STC

%Fix the data above 10 kHz
% k=find(Freq_grid>10000);
%	for l=1:92 %Correct freq resp above 10 kHz
% TC_grid(l,k)=TC_grid(l,k).*(Freq_grid(k(1))./Freq_grid(k));
%	end

semilogx(Freq_grid,TC_grid(2:5:91,:));
axis([100,50000,-100,0]);

figure(2); clf


% L=2.1; A=456; a=2.1; k= 0.8
% z=(L-x)/L; fcf=456.0*(10.^(2.1*z) - 0.8 ); %Liberman cochlear map
%

L=2.1;
X = L*( 1 - log10( ( CF_grid + 0.8 )/456.0 )/2.1 );

I=397:-40:2;
plot(X, TC_grid(:,I));
axis([0,2.5,-100,0]);
grid
