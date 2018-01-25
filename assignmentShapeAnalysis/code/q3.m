clear;
mat = load('../data/bone3D.mat');
pointSets = mat.shapesTotal;
triIndices = mat.TriangleIndex;
mean_diff_threshold = 1e-31;
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

    for i = 1:size(pointSets,3)
        [temp,pointSets(:,:,i)] = align(meanShape,pointSets(:,:,i));
    end

    oldmeanShape = meanShape;
    meanShape = findMeanShape(pointSets);

%     sum(sum((oldmeanShape-meanShape).^2))
    
    numiterations = numiterations + 1;
end

numiterations
figure;
trimesh(triIndices,meanShape(1,:),meanShape(2,:),meanShape(3,:));hold on;
plotPointsets(pointSets);
%% Now finding the principal modes of variation using the convariance matrix

flatpointSet = reshape(pointSets,size(pointSets(),1)*size(pointSets(),2),size(pointSets(),3));
[V,D] = eig(cov(flatpointSet'));
figure;
plot(diag(D));
tweak = meanShape+2*sqrt(D(end,end))*reshape(V(:,end),size(pointSets,1),size(pointSets,2));
[~,tweak] = align(meanShape, tweak);
figure;

trimesh(triIndices,tweak(1,:),tweak(2,:),tweak(3,:),'EdgeColor' , [1 0 0]);hold on;
trimesh(triIndices,meanShape(1,:),meanShape(2,:),meanShape(3,:),'EdgeColor' , [0 1 0]);hold on;
tweak = meanShape-2*sqrt(D(end,end))*reshape(V(:,end),size(pointSets,1),size(pointSets,2));
[~,tweak] = align(meanShape, tweak);
trimesh(triIndices,tweak(1,:),tweak(2,:),tweak(3,:),'EdgeColor' , [0 0 1]);hold on;
plotPointsets(pointSets);