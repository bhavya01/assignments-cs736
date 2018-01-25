clear;
mat = load('../data/hands2D.mat');
pointSets = mat.shapes;
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
patch(meanShape(1,:),meanShape(2,:),'w');hold on;
plotPointsets(pointSets);

flatpointSet = reshape(pointSets,size(pointSets(),1)*size(pointSets(),2),size(pointSets(),3));;
[V,D] = eig(cov(flatpointSet'));
figure;
plot(diag(D));
toplot = size(D,2);
tweak = meanShape+2*sqrt(D(toplot,toplot))*reshape(V(:,toplot),size(pointSets,1),size(pointSets,2));
[~,tweak] = align(meanShape,tweak);
figure;
patch(tweak(1,:),tweak(2,:),'r');hold on;
patch(meanShape(1,:),meanShape(2,:),'g');hold on;
tweak = meanShape-2*sqrt(D(toplot,toplot))*reshape(V(:,toplot),size(pointSets,1),size(pointSets,2));
[~,tweak] = align(meanShape,tweak);
patch(tweak(1,:),tweak(2,:),'b');hold on;
plotPointsets(pointSets);
alpha(0.3);