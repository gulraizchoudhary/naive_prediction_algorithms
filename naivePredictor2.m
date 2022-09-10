function [predictedDiseases, accuracy] = naivePredictor2(dataTrain_1D, diseaseList, dataTest, knownPercentage)

nTest = length(dataTest);
nDiseases = length(diseaseList);

%% Find the most similar disease in the train data to a given disease from
% test data

% Find the most probable disease for each disease in the train data 
nextDiseases = cell(1,nDiseases);
for i = 1:nDiseases
    disease = diseaseList{i};
    idx = find(strcmp(dataTrain_1D, disease));
    nOccurrences = length(idx);
    if nOccurrences == 0
        nextDiseases{i} = 'nnn';
    else
        tempNextDiseases = dataTrain_1D(idx+1);
        idx = strcmp(tempNextDiseases,'&&&');
        tempNextDiseases(idx) = [];
        nOccurrences = length(tempNextDiseases);
        if nOccurrences == 0
            nextDiseases{i} = 'nnn';
        else
            [temp, ~, ic] = unique(tempNextDiseases);
            nextDiseases{i} = char(temp(mode(ic)));
        end
    end
end


%% Test
predictedDiseases = cell(1,nTest); % diseases that we predict
gtDiseases = cell(1,nTest); % ground truth diseases
for i = 1:nTest
    disp(i);
    temp = dataTest{i};
    n =  length(temp);
    if n <= 1
        % nothing to predict
        predictedDiseases{i} = 'nnn';
        gtDiseases{i} = 'nnn';
    else
        nKnown = floor(n * knownPercentage + 0.01);
        if nKnown>=3
            testSeq = temp(nKnown-2:nKnown); % the last three known diseases
        elseif nKnown==2
            testSeq = temp(1:2); % the last two known diseases
        else
            testSeq = temp(1); % the last known disease
        end
        
        gtDiseases{i} = char(temp(nKnown+1));
        % Get predicted diseases from train data
        predictedDiseases{i} = findMostSimilar1_1(dataTrain_1D, diseaseList, nextDiseases, testSeq);
    end
end

%% Calculate the accuracy
TP = 0;
n = 0; % Number of test data that we use in calculating the accuracy
for i = 1:nTest
    if ~strcmp(gtDiseases{i}, 'nnn') % At least two diseases for a patient should be available
        n = n + 1;
        if strcmp(gtDiseases{i}, predictedDiseases{i})
            TP = TP + 1;
        end
    end
end

accuracy = TP/n;