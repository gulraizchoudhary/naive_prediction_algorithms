function similarity = sequenceSimilarityMeasrue(s1, s2, measureName)

if isempty(s1) || isempty(s2)
    similarity = -1; % when something wrong return -1
    return;
end

switch measureName
    case 'Jaccard'
        similarity = JaccardSimilarity(s1, s2);
    case 'Cosine'
        similarity = CosineSimilarity(s1, s2);
    case 'Matching'
        similarity = MatchingSimilarity(s1, s2);
    case 'Overlap'
        similarity = OverlapSimilarity(s1, s2);
    otherwise
        similarity = -1; % when something wrong return -1
end
    

end

%% Jaccard similarity
function similarity = JaccardSimilarity(s1, s2)

len1 = length(s1);
len2 = length(s2);
nIntersect = intersectWithRepeat(s1, s2);

similarity = nIntersect / (len1+len2-nIntersect);

end

%% Cosine similarity
function similarity = CosineSimilarity(s1, s2)

len1 = length(s1);
len2 = length(s2);
nIntersect = intersectWithRepeat(s1, s2);

similarity = nIntersect / sqrt(len1*len2);

end

%% Matching similarity
function similarity = MatchingSimilarity(s1, s2)

len1 = length(s1);
len2 = length(s2);
nIntersect = intersectWithRepeat(s1, s2);

similarity = nIntersect / max(len1,len2);

end

%% Overlap similarity
function similarity = OverlapSimilarity(s1, s2)

len1 = length(s1);
len2 = length(s2);
nIntersect = intersectWithRepeat(s1, s2);

similarity = nIntersect / min(len1,len2);

end

%% Calculates the number of shared objects between two sets
function n = intersectWithRepeat(s1, s2)
len1 = length(s1);
len2 = length(s2);
n = 0;
for i = 1:len1
    e = s1{i};
    idx = find(strcmp(s2, e));
    if ~isempty(idx)
        n = n + 1;
        s2{idx(1)} = 'checkedBefore';
    end
end

end