
function idx = findCellinAnother(dataTrain_1D, testSeq)

len = length(testSeq);
idx = find(ismember(dataTrain_1D, testSeq{1}));
if isempty(idx)
    return
end

idx1 = idx;

for i = 2:len
    temp = dataTrain_1D(idx1+i-1);
    idx1 = find(ismember(temp, testSeq{i}));
    if isempty(idx1)
        idx = [];
        break;
    end
    
    idx = idx(idx1);
    idx1 = idx;
end