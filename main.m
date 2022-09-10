clearvars;
close all;
clc;

%% Parameters
trainPercentage = 0.8; % 80%
testPercentage = 0.2; % 20%
knownPercentage = 0.5; % 50% percentage of known diseases in test data, we want to predict the next diseases
nRareDiseasesTh = 50; % eliminate diseases with the occurrence less than this number
method = 'NM3';

global moreMatch;
moreMatch = 0;
%% Read JSON data
fname = '../data/patient_info_2019Jul24.json';
data = jsondecode(fileread(fname));
data = cell2mat(struct2cell(data));
data = {data(:).seq_nozwy};
%data = data(1:1000);
fname_mat = '../data/data_seq_nozwy.mat';
%load(fname_mat); % gives the variable 'data'
%dataOrig = data;
fname_mat = '../data/data_range_nozwy.mat';
%load(fname_mat); % gives the variable 'data'
nData = length(data);

%% Remove rare diseases from data
%data = removeRareDiseases(data, nRareDiseasesTh);

%% Remove samples without or with only one disease
idxEmpty = [];
j = 1;
for i=1:nData
    if length(data{i}) < 2 
        idxEmpty(j) = i;
        j = j + 1;
    end
end
data(idxEmpty) = [];
nData = length(data);

%% Divide the data into train and test 
rng(10);

nTrain = floor(trainPercentage*nData);
nTest = nData - nTrain;
randomPositions = randperm(nData);
dataTrain = data(randomPositions(1:nTrain));
dataTest  = data(randomPositions(nTrain+1:nData));
 
%% Make the list of diseases
temp = cat(1, data{:});
diseaseList = unique(temp);
nDiseases = length(diseaseList);
%% Rearrange the train data in 1-D array for faster search
%  Patients' diseases are separated by '&&&'
dataTrainTemp = dataTrain;
for i = 1:nTrain
    temp = dataTrainTemp{i};
    len = length(temp);
    dataTrainTemp{i}{len+1} = '&&&';
    if len==1
        dataTrainTemp{i} = dataTrainTemp{i}';
    end
end
dataTrain_1D = cat(1, dataTrainTemp{:});

%% Disease prediction methods
accuracy = 0;
predictedDiseases = cell(1,nTest); % diseases that we predict
switch method
    case 'NM1'   % Naive method 1: prediction based only on the last disease
        [predictedDiseases, accuracy] = naivePredictor1(dataTrain_1D, diseaseList, dataTest, knownPercentage);
    case 'NM2'   % Naive method 2: consider the last three diseases
        [predictedDiseases, accuracy] = naivePredictor2(dataTrain_1D, diseaseList, dataTest, knownPercentage);
    case 'NM1E1' % Naive method 1 extension 1
        [predictedDiseases, accuracy] = naivePredictor1E1(dataTrain_1D, diseaseList, dataTest, knownPercentage);
    case 'NM1E2' % Naive method 1 extension 2: aggregate co-occurrence
        [predictedDiseases, accuracy] = naivePredictor1E2(dataTrain, diseaseList, dataTest, knownPercentage);
    case 'NM3'   % Naive method 3: Find 20 (at most) similar patients, and predict based on frequent diseases in those 20
        [predictedDiseases, accuracy] = naivePredictor3(dataTrain, dataTest, knownPercentage);
    case 'stats' % Some statistics of the data
        [stats] = dataStatistics(dataOrig);
    case 'accuracyCPT' % CPT (compact predict tree) implemented in python
        accuracy = calculateAccuracyCPT(dataTest, knownPercentage, 'predictions_CPT_1.txt');
    otherwise
end

disp(accuracy);