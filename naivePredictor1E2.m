function [predictedDiseases, accuracy] = naivePredictor1E2(dataTrain, diseaseList, dataTest, knownPercentage)

nTest = length(dataTest);
nTrain = length(dataTrain);
nDiseases = length(diseaseList);

%% Find the 4 most probable diseases coccurred with each disease in the train data
nextDiseases = cell(4,nDiseases);
nextDiseasesOC = zeros(nDiseases, 4);

% First build cooccerrence matrix
coocc = zeros(nDiseases, nDiseases);
for i = 1:nTrain
    temp = dataTrain{i};
    n = length(temp);
    for p = 1:n
        for q = p+1:n
            d1 = temp{p};
            d2 = temp{q};
            idx1 = find(strcmp(diseaseList, d1));
            idx2 = find(strcmp(diseaseList, d2));
            coocc(idx1, idx2) = coocc(idx1, idx2) + 1;
            coocc(idx2, idx1) = coocc(idx1, idx2) + 1;
        end
    end
end

predictedDiseases = cell(1,nTest); % diseases that we predict
for i = 1:nTest
    temp = dataTest{i};
    n =  length(temp);
    nKnown = floor(n * knownPercentage + 0.01);
    nPredict = n - nKnown;
    knownDiseases = temp(1:nKnown);
    
    gtDiseases{i} = temp(nKnown+1:end); % the remaning half of diseases
    
    t = zeros(1, nDiseases);
    idxList = zeros(1,nKnown);
    for j = 1:nKnown
        d = temp{j};
        idx = find(strcmp(diseaseList, d));
        t = t + coocc(idx, :);
        idxList(j) = idx;
    end
    t(idxList) = 0; % Do not select next diseaes from known diseases
    [vals, idx] = sort(t, 'descend');
    
    for j = 1:nPredict
        if vals(j) > 0
            predictedDiseases{i}{j} = diseaseList{idx(j)};
        else
            predictedDiseases{i}{j} = 'nnn';
        end
    end
end

%% Calculate the accuracy
TP = 0;
n = 0; % Number of test data that we use in calculating the accuracy
for i = 1:nTest
    temp = dataTest{i};
    lenSeq =  length(temp);
    if lenSeq >= 2 % At least two diseases for a patient should be available
        nKnown = floor(lenSeq * knownPercentage + 0.01);
        nPredict = lenSeq - nKnown;
        n = n + 1;
        for j = 1:nPredict
            disease = predictedDiseases{i}{j};
            idx = find(strcmp(gtDiseases{i}, disease));
            if ~isempty(idx)
                TP = TP + 1/nPredict;
            end
        end
    end
end

accuracy = TP/n;

i = 1;