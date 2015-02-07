function traversalSet = find_traversalSet (trainData, neighbor)
classNum = length(unique(trainData(:,end)));
neighborPts = [];
traversalSet = zeros (classNum-length(neighbor), 1);
if isempty (neighbor)
   startPoint = randi (size(trainData, 1), 1, 1);
   traversalSet (1) = startPoint;
   for i = 2:length(traversalSet)
       temp = find_farthest(traversalSet(traversalSet~=0), trainData);
       traversalSet (i) = temp;
   end
else
   for i = 1:length(neighbor)
       neighborPts(end+1:end+length(neighbor{i})) = neighbor{i};
   end
   for i = 1:length(traversalSet)
        traversalSet (i) = find_farthest (neighborPts, trainData);
        neighborPts(end+1) = traversalSet(i);
   end    
end



end

