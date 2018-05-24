%% Load data
data = table2array(importfile('train_labeledCSV.csv'));
test_data = table2array(importfile_test_data('testCSV.csv'));
X = data(:,2:129);
y = data(:,1);
%% Train the classifier
predictors = X;
response = y;

template = templateSVM(...
    'KernelFunction', 'polynomial', ...
    'PolynomialOrder', 3, ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true);
classificationSVM = fitcecoc(...
    predictors, ...
    response, ...
    'Learners', template, ...
    'Coding', 'onevsall', ...
    'ClassNames', [0; 1; 2; 3; 4; 5; 6; 7; 8; 9]);

%% Add things to the struct
svmPredictFcn = @(x) predict(classificationSVM, x);
trainedClassifier.predictFcn = @(x) svmPredictFcn(x);

trainedClassifier.ClassificationSVM = classificationSVM;

%% Perform cross-validation
partitionedModel = crossval(trainedClassifier.ClassificationSVM, 'KFold', 5);

% Compute validation predictions
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');

