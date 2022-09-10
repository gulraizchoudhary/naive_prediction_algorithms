function [predictedDiseases, accuracy] = naivePredictor1E1(dataTrain_1D, diseaseList, dataTest, knownPercentage)

nTest = length(dataTest);
nDiseases = length(diseaseList);
%% Naive method 1
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
%nTest = 20;
predictedDiseases = cell(1,nTest); % diseases that we predict
gtDiseases = cell(1,nTest); % ground truth diseases
for i = 1:nTest
    disp(i);
    temp = dataTest{i};
    n =  length(temp);
    if n <= 1
        % nothing to predict
        predictedDiseases{i} = {'nnn'};
        gtDiseases{i} = {'nnn'};
    else
        nKnown = round(n * knownPercentage + 0.01);
        nPredict = n - nKnown;
        gtDiseases{i} = temp(nKnown+1:end); % the remaning half of diseases
        disease = temp(nKnown); % the last known disease for the patient
        % get predicted diseases from train data
        for j = 1:nPredict
            if  strcmp(disease, 'nnn')
                predictedDiseases{i}{j} = {'nnn'};
            else
                idx = find(strcmp(diseaseList, disease));
                predictedDiseases{i}{j} = {nextDiseases{idx}};
            end
            % Continue to predict the next disease based on the predicted
            % one
            disease = predictedDiseases{i}{j};
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