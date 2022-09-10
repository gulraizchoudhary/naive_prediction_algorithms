function data = removeRareDiseases(data, nRareDiseasesTh)

nData = length(data);

temp = cat(1, data{:});
diseaseList = unique(temp);
nDiseases = length(diseaseList);

data_1D = cat(1, data{:});

diseaseOCCU = zeros(1, nDiseases);
for i = 1:length(data_1D)
    d = data_1D{i};
    idx = find(strcmp(diseaseList, d));
    diseaseOCCU(idx) = diseaseOCCU(idx) + 1;
end
idx = find(diseaseOCCU<nRareDiseasesTh);
rareDiseases = diseaseList(idx);

for i = 1:nData
    temp = data{i};
    idx = [];
    diseases = intersect(temp, rareDiseases);
    for j = 1:length(diseases)
        t = diseases{j};
        ii = find(strcmp(temp, t));
        idx = [idx ii];
    end
    temp(idx) = [];
    data{i} = temp;
end

i = 1;