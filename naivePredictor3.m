function [predictedDiseases, accuracy] = naivePredictor3(dataTrain, dataTest, knownPercentage)

nTest = length(dataTest);

%% Test
%nTest = 20;
predictedDiseases = cell(1,nTest); % diseases that we predict
gtDiseases = cell(1,nTest); % ground truth diseases
for i = 1:nTest
    if mod(i,100) == 0
        disp(i);
    end
    temp = dataTest{i};
    n =  length(temp);
    
    nKnown = round(n * knownPercentage + 0.01);
    nPredict = n - nKnown;
    knownDiseases = temp(1:nKnown);
    gtDiseases{i} = temp(nKnown+1:end); % the remaning half of diseases
    
    % get predicted diseases from train data
    predictedDiseases{i} = decideByMostSimilarSamples(dataTrain, knownDiseases, nPredict);
end

%% Calculate the accuracy
TP = 0;
n = 0; % Number of test data that we use in calculating the accuracy
for i = 1:nTest
    temp = dataTest{i};
    lenSeq =  length(temp);
    if lenSeq >= 2 % At least two diseases for a patient should be available
        nKnown = round(lenSeq * knownPercentage + 0.01);
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