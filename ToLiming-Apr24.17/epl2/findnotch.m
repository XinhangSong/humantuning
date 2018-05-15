%
% script to estimate notch vs CF from Delgutte/Liberman data base
%
clear all;close all

load TC_STC.mat

good_notches = [45:83];		% TCs with good notches

% look only at lowest CFs...
% good_notches = good_notches(1:5);
% look only at highest CFs...
% good_notches = good_notches((end-5):end);

N = length(good_notches);
CFs = zeros(size(good_notches));
Notches = zeros(size(good_notches));

%  fig(1);
figure(1)

for j = 1:5:N
  k = good_notches(j);
  TC = TC_grid(k,:);
  semilogx (Freq_grid,TC); hold on;
  % locate CF...
  [pk,pk_idx] = max (TC);

  % first locate a reasonable first guess for notch frequency by
  % looking for small values of the slope...
  sTC = TC(1:(pk_idx-10));		% consider only f<(CF-a little bit)
  dTC = diff(sTC);
  small_slope = find(dTC<0.01);
  notch0 = small_slope(end);		% the initial guess
  
  % now, try to estimate an uncertainty in the notch by
  % considering small slopes in the neighborhood of the
  % initial guess...
  rng = (notch0-30):(notch0+10);
  small_range = find(abs(dTC(rng))<0.2);
  
  % an improved guess...
  meannotch = round(mean(rng(small_range)));
  % and its approximate uncertainty...
  stdnotch = round(std(rng(small_range)));
  
  % plot initial guess...
  semilogx (Freq_grid(notch0),TC(notch0),'rp','MarkerSize',10,'LineWidth',3);
  % plot better guess based on range...
  semilogx (Freq_grid(meannotch),TC(meannotch),'rs','MarkerSize',5,'LineWidth',2);
  % plot range...
  semilogx (Freq_grid(rng(small_range)),TC(rng(small_range)),'gx');
  % plot CF...
  semilogx (Freq_grid(pk_idx),TC(pk_idx),'gp','MarkerSize',10,'LineWidth',2);;
  
  % store the data away...
  CFs(j)= Freq_grid(pk_idx);
  Notches(j)= Freq_grid(meannotch);
  Sigmas(j)= sqrt((Freq_grid(meannotch)-Freq_grid(meannotch-stdnotch))* ...
		  (Freq_grid(meannotch+stdnotch)-Freq_grid(meannotch)));
end

xlim([1e3 4e4])
ylim([-100 0])

pause(5)

% plot data with error bars...
figure;
errorbar(CFs,Notches,Sigmas,'s');
% make it a loglog plot once again...
% (Matlab is such a crock ...)
set(gca,'YScale','log','XScale','log');
hold on;

% fit a line to the data using estimated uncertainties...
if (exist('linear_fit')==2)
  [a,b,sig_a,sig_b] = linear_fit (log(CFs),log(Notches),Sigmas./Notches);
else
  p = polyfit (log(CFs),log(Notches),1);
  a = p(2); b = p(1);
  sig_b = NaN;
end
loglog(CFs,exp(a)*CFs.^b,'-');
disp(strcat('fz = ',sprintf('%.3g',exp(a)),'*CF^',sprintf('%.2f',b)));
disp(strcat('uncertainy in slope =',sprintf('%.2f',sig_b)));

% overlay Allen and Fahey 2nd cochlear map...
figure(2);
map = 0.05*CFs.^1.22;
loglog(CFs,map,':');
% and locate corresponding points on tuning curves...
figure(1);
for k = 1:length(CFs)
  [x_n,n] = closest(Freq_grid,map(k));
  semilogx(map(k),TC_grid(good_notches(k),n),'ks');
end





