function constraintNum = creatContraintsFile (conMat, name)
conMat = triu (conMat, 1);
[is, js] = find(conMat ~= 0);
conVec = zeros (length(is), 3);
for i = 1:length(is)
    conVec(i,:) = [is(i)-1, js(i)-1, conMat(is(i), js(i))];
end
constraintNum = size(conVec, 1);
cd wekaUT/weka-latest/data;
x = [name, '.constraints'];
dlmwrite(x,conVec,'delimiter','\t');
cd ..;
cd ..;
cd ..;
end