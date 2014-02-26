function mvmap = majorvote(A,B)
% MAJORVOTE apply major voting method to build up a map from voters in A to
% corresponding major candidate in B


Aset = sort(unique(A)); % Set of Voter
Bset = sort(unique(B)); % Set of Candidates

% Vote and Select Major Candidates
mvmap.voter = Aset;
mvmap.major = zeros(size(Aset));
for i = 1 : length(Aset)
    % Distribution of Candidates by i-th Voter
    d = hist(B(A==Aset(i)), Bset);
    % Choose Maximum Voted Candidate
    [~,id] = max(d);
    % Record Result
    mvmap.major(i) = Bset(id);
end

end
