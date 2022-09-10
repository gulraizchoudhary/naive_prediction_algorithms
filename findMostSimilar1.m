function [predictedDiseases] = findMostSimilar1(dataTrain_1D, diseaseList, nextDiseases, testSeq)

len = length(testSeq);

predictedDiseases = {};

if len == 1
    predictedDiseases = findNextDiseaseSimple(diseaseList, nextDiseases, testSeq{1});
else
    strTrain = strjoin(dataTrain_1D, ''); % convert train data from cell to one string
    strTestSeq = strjoin(testSeq, '');
    
    idx = strfind(strTrain, strTestSeq);
    if isempty(idx) 
        newLen = len - 1;
        if newLen == 1 % when len=2
            predictedDiseases = findNextDiseaseSimple(diseaseList, nextDiseases, testSeq{2});
        else % when len=3, and newLen=2
            newTestSeq = testSeq;
            newTestSeq(1) = []; % remove the first disease in the sequence and consider only two diseaes instead of three
            strTestSeq = strjoin(newTestSeq, '');
            idx = strfind(strTrain, strTestSeq);
            if isempty(idx) % try only with the last disease
                predictedDiseases = findNextDiseaseSimple(diseaseList, nextDiseases, testSeq{3});
            else
                predictedDiseases = findNextDiseaseMultiple(dataTrain_1D, idx, diseaseList, nextDiseases, newTestSeq);
            end
        end
    else
        predictedDiseases = findNextDiseaseMultiple(dataTrain_1D, idx, diseaseList, nextDiseases, testSeq);
    end
end

%%
function predictedDisease = findNextDiseaseSimple(diseaseList, nextDiseases, disease)
idx = find(strcmp(diseaseList, disease));
predictedDisease = nextDiseases{idx};

%%
function predictedDisease = findNextDiseaseMultiple(dataTrain_1D, idx, diseaseList, nextDiseases, diseaseSeq)
idx = floor(idx/3)+1; % index in dataTrain_1D
len = length(diseaseSeq);
nInstances = length(idx);

idxNew = idx;
for i = nInstances:-1:1
    if strcmp(dataTrain_1D{idx(i)+len}, '&&&')
        idxNew(i) = []; % remove
    end
end

nInstances = length(idxNew);
if nInstances == 0
    if len == 2
        predictedDisease = findNextDiseaseSimple(diseaseList, nextDiseases, diseaseSeq{2});
    else % when len=3
        diseaseSeq(1) = []; % remove the first disease and continue with a sequence of two diseases
        strTrain = strjoin(dataTrain_1D, ''); % convert train data from cell to one string
        strTestSeq = strjoin(diseaseSeq, '');
        idxNew = strfind(strTrain, strTestSeq);
    
        predictedDisease = findNextDiseaseMultiple(dataTrain_1D, idxNew, diseaseList, nextDiseases, diseaseSeq);
    end
else
    tempNextDiseases = dataTrain_1D(idxNew+len);
    [temp, ~, ic] = unique(tempNextDiseases);
    predictedDisease = char(temp(mode(ic)));
end
