mat = load('../data/ellipses2D.mat');
pointSets = mat.pointSets;
mean_diff_threshold = 1e-14;
%% Plotting the pointsets

plotPointsets(pointSets);

%% Aligning the centroid of all pointsets to origin

centroids = sum(pointSets,2);
centroids = repmat(centroids,1,size(pointSets,2),1);
centroids = centroids./size(centroids,2);
pointSets = pointSets - centroids;

%% Now first aligning all pointsets to the first pointset and then finding mean

meanShape = findMeanShape(pointSets);
oldmeanShape = zeros(size(meanShape));

numiterations = 0;

while sum(sum((oldmeanShape-meanShape).^2)) > mean_diff_threshold
    
    for i = 1:mat.numOfPointSets
        [temp,pointSets(:,:,i)] = align(meanShape,pointSets(:,:,i));
    end

    oldmeanShape = meanShape;
    meanShape = findMeanShape(pointSets);

%     sum(sum((oldmeanShape-meanShape).^2))
    
    numiterations = numiterations + 1;
end

numiterations
figure;
patch(meanShape(1,:),meanShape(2,:),'w');hold on;
plotPointsets(pointSets);

%% Now finding the principal modes of variation using the convariance matrix

flatpointSet = reshape(pointSets,size(pointSets(),1)*size(pointSets(),2),size(pointSets(),3));;
[V,D] = eig(cov(flatpointSet'));
tweak = meanShape+reshape(V(:,end),size(pointSets,1),size(pointSets,2));
figure;
patch(tweak(1,:),tweak(2,:),'w');hold on;
patch(meanShape(1,:),meanShape(2,:),'w');hold on;