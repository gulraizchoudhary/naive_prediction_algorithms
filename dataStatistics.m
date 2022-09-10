function stats = dataStatistics(data)

nData = length(data);
%% Histogram of diseases: number of occurrences of each disease in entire data
% Count eash disease in entire data
diseaseHist = zeros(1, nDiseases);
maxDisease = 0;
for i = 1:nData
    temp = data{i};
    n = length(temp);
    if n > maxDisease
        maxDisease = n;
    end
    for j = 1:n
        d = temp{j};
        idx = find(strcmp(diseaseList, d));
        diseaseHist(idx) = diseaseHist(idx) + 1;
    end
end
diseaseHist = sort(diseaseHist);
plot(diseaseHist);
nAllDiseaseOccurrences = sum(diseaseHist);

diseaseHist50 = diseaseHist(nDiseases-50+1:nDiseases);
figure(2);
plot(diseaseHist50);
n50MostFrequent = sum(diseaseHist50);
n50AllRatio = n50MostFrequent / nAllDiseaseOccurrences;
disp(n50AllRatio);

diseaseHist100 = diseaseHist(nDiseases-100+1:nDiseases);
figure(3);
plot(diseaseHist100);
n100MostFrequent = sum(diseaseHist100);
n100AllRatio = n100MostFrequent / nAllDiseaseOccurrences;
disp(n100AllRatio);

