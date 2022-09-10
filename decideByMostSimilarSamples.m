function [predictedDiseases] = decideByMostSimilarSamples(dataTrain, knownDiseases, nPredict)

nTrain = length(dataTrain);
maxSimilarSamples = 20;
minSimilarityValue = 0.3;
predictedDiseases = cell(1, nPredict);
%% Calculate the similarity between the test sample and train samples
simVals = zeros(1, nTrain);
for i = 1:nTrain
    s1 = knownDiseases;
    s2 = dataTrain{i};
    if length(s2)>length(s1)
        simVals(i) = sequenceSimilarityMeasrue(s1, s2, 'Overlap');
    end
end

%% Find most similar samples in the train data
idx = find(simVals==1);
if ~isempty(idx) > 0 % If some samples contain all the diseases in the test sample
    selected = dataTrain(idx);
else % Otherwise, find most similar samples from train data
    [vals, iS] = sort(simVals, 'descend');
    vals = vals(1:maxSimilarSamples);
    iS = iS(1:maxSimilarSamples);
    iM = find(vals>minSimilarityValue);
    vals = vals(iM);
    if ~isempty(vals) > 0
        iS = iS(1:length(vals));
    else
        iS = [];
    end
    selected = dataTrain(iS);
end

%% If no similar samples in the train data
if isempty(selected)
    for i = 1:nPredict
        predictedDiseases{i} = 'nnn';
    end
    return;
end

%% Remove the diseases in the test sample from the train samples
nSelected = length(selected);

for i = 1:nSelected
    idx = [];
    temp = selected{i};
    shared = intersect(temp, knownDiseases);
    for j = 1:length(shared)
        t = shared{j};
        ii = find(strcmp(temp, t));
        idx = [idx ii];
    end
    temp(idx) = [];
    selected{i} = temp;
end

%% Find the most occurrent diseases in selected similar samples
selected_1D = cat(1, selected{:});
diseaseList = unique(selected_1D);
nDiseases = length(diseaseList);
occurrences = zeros(1, nDiseases);
for i = 1:nDiseases
    idx = find(strcmp(selected_1D, diseaseList{i}));
    occurrences(i) = length(idx);
end

[~, idx] = sort(occurrences, 'descend');

% initialize
for i = 1:nPredict
    predictedDiseases{i} = 'nnn';
end

if nDiseases >= nPredict
    predictedDiseases = diseaseList(idx(1:nPredict));
else
    predictedDiseases(1:nDiseases) = diseaseList(idx(1:nDiseases));
end


