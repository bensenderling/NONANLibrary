function [ FR,PC,DRP ] = RelPhase_Disc( S1, S2, varargin )
% [ FR,PC,DRP ] = RelPhase_Disc20180320( S1, S2, S1_events, S2_events )
% inputs    - S1, Signal 1 must be the lower frequency signal.
%           - S2, Signal 2 must be the higher frequency signal.
% optional inputs
%           - S1_events, Cyclical event occuring within Signal 1. Will be
%           calculated as the peaks of S1 if not input.
%           - S2_events, Cyclical event occuring within Signal 2. Will be
%           calculated as the peaks of S2 if not input.
% output    - FR, Frequency Ratios is a table containing Ratios,
%           Occurences, and Percentages.
%           - PC, Phase Couping is a table containing the heel strike
%           number (n) and phase coupling percentage (PC) for that heel 
%           strike.
%           - DRP, Discrete Relative Phase is a table containing the inputs
%           and output of the equation listed in the paper cited above.
% Remarks
% - This code finds the discrete relative phase similar to that described 
%   by O'Halloran, J., et al., 2012. "Locomotor-respiratory coupling 
%   patterns and oxygen consumption during walking above and below 
%   preferred stride frequency." Eur J Physiol. 112: 929-940.
% - It omputes discrete relative phase to give frequency and phasic 
%   relationships between two time series.
% Feb 2018 - Created by Will Denton
% Copyright 2020 Nonlinear Analysis Core, Center for Human Movement
% Variability, University of Nebraska at Omaha
%
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
%    this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%% Variable input length;
if isempty(varargin)
    [~,S1_events] = findpeaks(S1);
    [~,S2_events] = findpeaks(S2);
else
    S1_events = varargin{1};
    S2_events = varargin{2};
end
%% Initialize Figure;
f = figure('units','normalized','outerposition',[0 0 1 1]);
tgroup = uitabgroup('Parent', f);
tab1 = uitab('Parent', tgroup, 'Title', 'DRP');
tab2 = uitab('Parent', tgroup, 'Title', 'Return Map');
%% DRP Plot
axes('parent', tab1);
subplot(3,2,1); plot(S1,'k'); hold on;
for i = 1:length(S2_events)
    plot([S2_events(i),S2_events(i)],[min(S1),max(S1)],'k');
end
set(gca,'XLim',[0 length(S1)]);
set(gca,'YLim',[mean(S1)-0.5*std(S1) max(S1)]);
scatter(S1_events,S1(S1_events),'k','filled');
%% DRP start:
%Compute tiR(p)
clc; i = 2; back = 0;
for i1 = 1:length(S2_events)
    if S2_events(i1) < S1_events(1)
        back = back+1;
    elseif S2_events(i1) < S1_events(i)
        tiRp(i1-back) = S1_events(i) - S2_events(i1);
    else
        if i < length(S1_events)
            i = i+1;
            tiRp(i1-back) = S1_events(i) - S2_events(i1);
        end
    end
end
%Compute Ti
Ti = diff(S2_events);
%Find n's
for i = 1:length(S1_events) - 1
    holder = 0;
    for f = 1:length(S2_events)-1
        if S2_events(f) >= S1_events(i) && S2_events(f) < S1_events(i+1)
            holder = holder + 1;
        end
    end
    N(i,1) = holder-1;
end
%Discrete relative phase calculation
i = 1;
L = min(length(tiRp),length(Ti));
for i1 = 1:L
    DRP(i1,1) = tiRp(i1)/Ti(i1)*360;
    t(i1,1) = tiRp(i1);
    T(i1,1) = Ti(i1);
    i = i+1;
end
i = 1;
for k = 1:length(N)
    for i1 = 0:N(k)
        n(i,1) = N(k) - i1;
        i = i+1;
    end
end
Raw = table(t,n,T,DRP);
subplot(3,2,3:4); plot(DRP,'k-o'); hold on;
maxDRP = round(max(DRP)/360)+1;
for i = 1:maxDRP
    plot([0,length(DRP)],[360*(i-1),360*(i-1)],'k');
    for i1 = 1:length(DRP)
        if DRP(i1) > 360*(i-1) && DRP(i1) <= 360*i
            count(i1,1) = i;
        else
        end
    end
end
set(gca,'XLim',[1 length(DRP)]); set(gca,'YTick',0:360:360*DRP); set(gca,'YLim',[0 360*maxDRP]);
%Find half integers
DRPfirst(1,1) = Raw{1,4};
i1 = 2;
for i = 3:height(Raw)-1
    if Raw{i,2} == 0
        DRPfirst(i1,1) = Raw{i+1,4};
        i1 = i1+1;
    else
    end
end
%Get percentage of coupling frequencies
for i = 1:length(DRPfirst)
    for i1 = 1:maxDRP
        if DRPfirst(i) > (i1-1) * 360 && DRPfirst(i) <= i1*360
            freqFromDRP(i) = i1;
        else
        end
    end
end
if freqFromDRP(1) == freqFromDRP(3) && freqFromDRP(2) == freqFromDRP(4) && abs( freqFromDRP(1)-freqFromDRP(2) ) == 1
    DRPfirstHalfInt(1) = ( freqFromDRP(1) + freqFromDRP(2) ) / 2;
else
    DRPfirstHalfInt(1) = freqFromDRP(1);
end
last=length(freqFromDRP); counter = 0;
for i = 2:last-1
    if freqFromDRP(i-1) == freqFromDRP(i+1) && abs(freqFromDRP(i)-freqFromDRP(i+1)) == 1
        DRPfirstHalfInt(i) = ( freqFromDRP(i)+freqFromDRP(i+1) ) / 2;
        counter = counter+1;
    else
        if mod(counter,2) == 1 && counter<i && counter > 1
            DRPfirstHalfInt(i-counter-1) = DRPfirstHalfInt(i-counter);
        else
        end
        DRPfirstHalfInt(i) = freqFromDRP(i);
        counter = 0;
    end
end
DRPfirstHalfInt(last) = freqFromDRP(last);
%First
if DRPfirstHalfInt(1) == DRPfirstHalfInt(2)
    DRPwithNC(1) = DRPfirstHalfInt(1);
else
    DRPwithNC(1) = 0;
end
%Middle
for i = 2:length(DRPfirstHalfInt)-1
    if DRPfirstHalfInt(i) == DRPfirstHalfInt(i+1) || DRPfirstHalfInt(i) == DRPfirstHalfInt(i-1)
        DRPwithNC(i) = DRPfirstHalfInt(i);
    else
        DRPwithNC(i) = 0;
    end
end
%End
last = length(DRPfirstHalfInt);
if DRPfirstHalfInt(last) == DRPfirstHalfInt(last-1)
    DRPwithNC(last) = DRPfirstHalfInt(last);
else
    DRPwithNC(last) = 0;
end
subplot(3,2,5:6); plot(DRPfirst,'k-o'); hold on;
maxDRP = round(max(DRPfirst)/360)+1;
for i = 1:maxDRP
    plot([0,length(DRPfirst)],[360*i,360*i],'k');
    for i1 = 1:length(DRPfirst)
        if DRPfirst(i1) > 360*(i-1) && DRPfirst(i1) <= 360*i
            count(i1,1) = i;
            text(i1,DRPfirst(i1),[' ',num2str(DRPwithNC(i1))],'VerticalAlignment','bottom');
        else
        end
    end
end
set(gca,'XLim',[1 length(DRPfirst)]); set(gca,'YTick',0:360:360*maxDRP); set(gca,'YLim',[0 360*maxDRP]);
%% Calculate Frequency Ratio Percentages;
maxn = max(DRPwithNC);
Ratio(1,1) = 0;
Occurances(1,1) = length(DRPwithNC(DRPwithNC==0));
Percentage_of_Total(1,1) = Occurances(1,1)/length(DRPwithNC)*100;
for i = 1:0.5:maxn
    Ratio(i*2,1) = i;
    Occurances(i*2,1) = length(DRPwithNC(DRPwithNC==i));
    Percentage_of_Total(i*2,1) = Occurances(i*2,1)/length(DRPwithNC)*100;
end
%% Frequency Ratio Percentage Bar Graph;
[r,~] = size(Ratio);
subplot(3,2,2);
for i = 1:r
    bar(Ratio(i,1),Percentage_of_Total(i,1),0.5,'k','EdgeColor','none'); hold on;
    if Percentage_of_Total(i,1) > 0
        text(Ratio(i,1)-0.025*r,-1,sprintf('%2.2f%%',(Percentage_of_Total(i,1))),'VerticalAlignment','bottom','Color','w','FontSize',12,'FontWeight','bold');
    end
end
holder = Ratio(i,1)+0.5;
set(gca,'XLim',[-0.5 maxn+1],...
    'XTick',(0:0.5:maxn+0.5),...
    'XTickLabel',{'NC',(0.5:0.5:maxn),'PC'},...
    'YTick',0:10:100,...
    'YLim',[0 100]);
%% Return Map;
[~,lag] = max(Occurances);
if mod(lag,2) == 0
    lag = lag/2;
end
clear n;
original = DRP(1:length(DRP)-lag);
lagged = DRP(1+lag:length(DRP));
for k = 1:round(Ratio(Percentage_of_Total == max(Percentage_of_Total),1))
    original_dn = original(original <= 360*k & lagged <=360*k);
    lagged_dn = lagged(original <= 360*k & lagged <=360*k);
    dn = ( (original_dn - lagged_dn) * cosd(45) );
    for i = 1:length(dn)
        if abs(dn(i)) <= 40 %*cosd(45)
            wdn(i) = 1 - ( abs(dn(i)) / (40)); %*cosd(45);
        else
            wdn(i) = 0;
        end
    end
    n(k,1) = round(Ratio(Percentage_of_Total == max(Percentage_of_Total),1))-k;
    PC(k,1) = sum(wdn) / length(wdn) * 100;
end
subplot(3,2,2); hold on; bar(holder,max(PC),0.5,'k','EdgeColor','none');
text(holder-0.025*r,-1,sprintf('%2.2f%%',max(PC)),'VerticalAlignment','bottom','Color','w','FontSize',12,'FontWeight','bold');
original = DRP(1:length(DRP)-lag);
lagged = DRP(1+lag:length(DRP));
axes('parent', tab2);
scatter(original,lagged,'k'); hold on;
plot([0 max(DRP)],[0 max(DRP)],'k'); plot([0+40 max(DRP)+40],[0 max(DRP)],'r--'); plot([0-40 max(DRP)-40],[0 max(DRP)],'r--');
title(['Lag = ',num2str(lag)]); set(gca,'XLim',[0,max(DRP)]); set(gca,'YLim',[0,max(DRP)]); set(gca,'XTick',0:360:max(DRP)); set(gca,'YTick',0:360:max(DRP)); grid on;
axis square;
for i = 1:round(Ratio(Percentage_of_Total == max(Percentage_of_Total),1))
    ann_posx = 0.3+0.4*(360*i-180)/max(DRP); if ann_posx > 0.695, ann_posx = 0.695; end
    annotation(tab2,'textbox',[ann_posx, 0.075 , 0.0325 , 0.02],'String',num2str(PC(i)),'FontSize',20,'EdgeColor','none');
end
%% Output Tables
DRP = Raw;
fprintf('DRP CALCULATION:\r'); disp(DRP);
fprintf('FREQUENCY RATIOS:\r'); FR = table(Ratio,Occurances,Percentage_of_Total); disp(FR);
fprintf('PHASE COUPLING:\r'); PC = table(n,PC); disp(PC);
end