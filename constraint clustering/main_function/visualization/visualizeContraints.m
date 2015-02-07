function visualizeContraints (datasetName, nq, nps, flag)
cd ..;
ppp = {'og', '+m', 'xb', '*r', 'squarey', 'diamondk'};
x = ['Data-Sets/', datasetName];
cd (x);
x = [datasetName, '.data'];
rawData = load (x);
cd ..;
cd ..; %main directory
cd results;
cd (datasetName);
x = [datasetName, '-', flag, '-', num2str(nq), '-', num2str(nps), '-constraints.data'];
data = rawData (:, 1:end-1);
sigma=cov(data);
v=pcacov(sigma);
reduceData= data* [v(:,2),v(:,4)]; 
reducerawData = [reduceData, rawData(:,end)];
class_num = length(unique(rawData(:,end)));
for i = 1 : class_num
    plot (reduceData(reducerawData(:,end)==i, 1), reduceData(reducerawData(:,end)==i, 2), ppp{i});
    hold on;
end

% 113;147;122;139;134;135;114;
%I = [14;30;61;53;57;84;87;51;52;86;77;55;76;59;66;62;92];
I = [14;61];
 plot (reduceData (I, 1), reduceData (I, 2), '*r');
 
 

J = [51;52;53;55;57;59;61;62;66;76;77;84;86;87;92];
K = [54;56;58;60;63;64;65;67;68;69;70;72;73;74;75;79;80;81;82;83;85;88;90;91;93;94;95;96;97;98;99;100];

   
        plot (reduceData (J, 1), reduceData (J, 2), 'squarek');
    plot (reduceData (K, 1), reduceData (K, 2), 'diamondy');

%legend ('Class 1', 'Class 2', 'Class 3');
title ([datasetName, '-', flag, '-', num2str(nq), '-', num2str(nps)]);
cons = load (x);
[mmm,~] = size(cons);
cd ..;
cd ..;
cd visualization;
if ~exist (datasetName)
     mkdir (datasetName);
end
a = reduceData(cons(:,1),:);
b = reduceData(cons(:,2),:);
c = cons(:,3);
xx= [a(:,1);b(:,1)];
yy= [a(:,2);b(:,2)];
theAxes = axis;
fmat = moviein (nq/nps);
for i =1:ceil(mmm/nps)
    for j = 1:nps
        xxx = [xx((i-1)*nps+j);xx((i-1)*nps+j+mmm)];
        yyy = [yy((i-1)*nps+j);yy((i-1)*nps+j+mmm)];
    if c((i-1)*nps+j) == 1
        plot (xxx,yyy,'r-');
    else
        plot (xxx,yyy,'k--');
    end
    end
    hold on;
    axis (theAxes);
    fmat (:,i) = getframe;
end
    movie (gcf, fmat, 1, 20, [73.8,45,11,11]); % 4th argument: number of frames per second
cd (datasetName);
SAVEAS(1,x,'fig');
print (gcf,'-djpeg', [x,'.jpeg']); 
cd ..
end
