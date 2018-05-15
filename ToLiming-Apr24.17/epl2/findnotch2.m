%
% script to estimate notch vs CF from Delgutte/Liberman data base
% uses 2 straight-line approximation to the TC
%
clear all;close all

load TC_STC.mat

good_notches = [40:83];		% TCs with good notches
N = length(good_notches);

% look only at lowest CFs...
% good_notches = good_notches(1:5);
% look only at highest CFs...
% good_notches = good_notches((end-5):end);
% look only at mid CFs...
% good_notches = good_notches((fix(N/2)-2):(fix(N/2)+3));

N = length(good_notches);
CFs = zeros(size(good_notches));
Notches = zeros(size(good_notches));

  fig(1);
%  figure(1);

for j = 1:5:N %prune curves (every fifth)
  k = good_notches(j);
  TC = TC_grid(k,:);
  semilogx (Freq_grid,TC); hold on;
  % locate CF...
  [pk,pk_idx] = max (TC);

  % first locate a reasonable first guess for notch frequency by
  % looking for small values of the slope...
  sTC = TC(1:(pk_idx-10));		% consider only f<(CF-a little bit)
  dTC = diff(sTC);
  small_slope = find(dTC<0.1);
  notch0 = small_slope(end);		% the initial guess
  
  % find a line to fit the basal slope ...
  pts = pk_idx-notch0;
  fit_me1 = fix(notch0+(pts/2)):fix(pk_idx-(pts/20));
  [a1,b1] = linear_fit (log(Freq_grid(fit_me1)),TC(fit_me1));
  % plot it...
  semilogx (Freq_grid(fit_me1),a1+b1*log(Freq_grid(fit_me1)),'r');
  
  % find a line to fit the tail...
  % (N.B. for lack of anything less arbitrary, we fit the ENTIRE TAIL)
  fit_me2 = 1:notch0;
  [a2,b2] = linear_fit (log(Freq_grid(fit_me2)),TC(fit_me2));
  % plot it...
  semilogx (Freq_grid(fit_me2),a2+b2*log(Freq_grid(fit_me2)),'r');
  
  % define the notch as the point of intersection...
  % (N.B. should estimate uncertainty in fnotch).
  fnotch = exp((a1-a2)/(b2-b1));
  semilogx (fnotch,a2+b2*log(fnotch),'s')

  % store the data away...
  CFs(j)= Freq_grid(pk_idx);
  Notches(j)= fnotch;
end
ylim([-100 -10])
xlim([5e2 3e4])

% plot data ...
figure;
loglog(CFs,Notches,'rs');
set(gca,'YScale','log','XScale','log');
hold on;

% fit a line to the data ...
if (exist('linear_fit')==2)
  [a,b,sig_a,sig_b] = linear_fit (log(CFs),log(Notches));
else
  p = polyfit (log(CFs),log(Notches),1);
  a = p(2); b = p(1);
  sig_b = NaN;
end
loglog(CFs,exp(a)*CFs.^b,'-');
disp(strcat('fz = ',sprintf('%.3g',exp(a)),'*CF^',sprintf('%.2f',b)));
disp(strcat('uncertainy in slope =',sprintf('%.2f',sig_b)));
ylim([1e3 3e4])
xlim([1e3 3e4])


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






