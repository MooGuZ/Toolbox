function svddisp(data,cutoff,figpath)
% SVDDISP would display data in space spaned by its singular vectors
%
%   SVDDISP(DATA) would display DATA with its projections to its singular
%   vector directions in one-, two-, and three- dimensions. The one 
%   dimensional plot would be the probability distribution function of
%   the projection from original data to each singular vector; The two
%   dimensional plot would show each combination of directions that 
%   represents main structure of the data. This is defined by the  
%   cumulative energy propotion that greater than 0.5; And three
%   dimensional plot would show first three dimension in rotating.
%   
%   SVDDISP(DATA,CUTOFF) does almost the same thing as SVDDISP(DATA) with a
%   threshold CUTOFF to define main structure of data, which is set to its
%   default value 0.5 in SVDDISP(DATA).
%
%   SVDDISP(DATA,CUTOFF,FIGPATH) would store plots generated in function 
%   into FIGPATH.
%
% See also, svdanalysis, svdcompress.
%
% MooGu Z. <hzhu@case.edu>
% Jan 30th, 2014 - Version 0.1

% Switches
swPrint = false;

% Path
if ~exist('figpath','var')
    figpath = './fig/';
else
    swPrint = true; % Ensure Print Swtich is ON
end

% Singular Value Decomposition
[s,U] = svdanalysis(data);

% Rank of Data
rank = length(s);

% Singular Value Map
f = figure(); hold on;
stem(1:rank,s);
plot(s,'.-r','MarkerSize',13); grid on;
axis([0,rank+1,0,max(s)*1.1]);
xlabel('INDEX'); ylabel('Singular Value');
title('Singular Value Map'); hold off;
if swPrint
    print(f,'-depsc2','-r200',[figpath,'svd-svmap.eps']);
end

% Cumulate Energy Proportion
cep = s.^2;
for i = 2 : rank
    cep(i) = cep(i-1) + cep(i);
end
cep = cep / cep(end);
% Cumulative Energy Map
f = figure(); hold on;
stem(1:rank,cep);
plot(cep,'.-r','MarkerSize',13); grid on;
axis([0,rank+1,0,1.1]);
xlabel('INDEX'); ylabel('Cumulative Energy');
title('Cumulative Energy Map'); hold off;
if swPrint
    print(f,'-depsc2','-r200',[figpath,'svd-cemap.eps']);
end

% Projection in Singular Vectors Space
prj = U'*data;

% One Dimensional Plot
NBIN = 100; % Number of Bins to Calculate Distribution
for i = 1 : rank
    f = figure();
    hist(prj(i,:),NBIN); grid on;
    xlabel(['SVector No.',num2str(i),' (SValue=',num2str(s(i)),')']);
    if swPrint
        print(f,'-depsc2','-r200',...
            [figpath,'svddisp-D',num2str(i),'.eps']);
    end
end

if (rank > 1)
    % Two Dimensional Plots
    if ~exist('cutoff','var') || ~isscalar(cutoff) || ~isnumeric(cutoff)
        cutoff = 0.5;
    end
    % Generate Combaination of 2 Directions
    perm = [kron(1:rank,ones(1,rank));kron(ones(1,rank),1:rank)];
    perm = perm(:,(perm(2,:)-perm(1,:))>0);
    % Calculate Corresponding Energy
    temp = s.^2; temp = temp/sum(temp);
    energy = temp(perm(1,:)) + temp(perm(2,:));
    % Get Perms, which match restriction of CUTOFF
    ind = energy > cutoff;
    if any(ind)
        perm = perm(:,ind);
    else
        perm = perm(:,1);
    end
    % Show Combainations
    for i = 1 : size(perm,2)
        f = figure();
        plot(prj(perm(1,i),:),prj(perm(2,i),:),'.','MarkerSize',13); 
        grid on;
        xlabel(['SVector No.',num2str(perm(1,i)),...
            ' (Svalue=',num2str(s(perm(1,i))),')']);
        ylabel(['SVector No.',num2str(perm(2,i)),...
            ' (Svalue=',num2str(s(perm(2,i))),')']);
        if swPrint
            print(f,'-depsc2','-r200',...
                [figpath,'svddisp-D',num2str(perm(1,i)),...
                'D',num2str(perm(2,i)),'.eps']);
        end
    end
end

if (rank > 2)
    % Rotation Unit
    rot = 30;
    % Three Dimensional Plot
    f = figure();
    plot3(prj(1,:),prj(2,:),prj(3,:),'.','MarkerSize',13); grid on;
    title('Most Significant Projections of Data');
    if swPrint
        print(f,'-depsc2','-r200',...
            [figpath,'svddisp-3D-0deg.eps']);
    end
    % Rotating
    for i = 1 : floor(359/rot)
        camorbit(rot,0);
        title(['Most Significant Projections of Data (Rotating ',num2str(rot*i),' Degrees)']);
        if swPrint
            print(f,'-depsc2','-r200',...
                [figpath,'svddisp-3D-',num2str(rot*i),'deg.eps']);
        end
        pause(0.1)
    end
    % Rotate to Original Direction
    camorbit(360-rot*i,0);
    title('Most Significant Projections of Data');
end

end