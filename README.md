# Predictive-Modeling-WebApp

## Shiny R-package
A web-based interactive data-driven tool is designed using `Shiny`. 

`Shiny` is an R package that helps to build interactive web apps straight from R. 

 The website shows the output of the variable importance plot which is obtained by applying `cv.glmnet` model. 

## Overview of Shiny

In the figure below the overview of Shiny R package is demonstrated.

Shiny takes input from HTML and feeds to the R. after processing, Shiny takes the output from R and feeds it to HTML.

![shiny](/m.png)

## Outline of WebApp

The web app takes a preprocessed dataset as input. The dataset must be a `csv` file. 

There is a choice selection of whether the first row in the dataset will be taken as the header.

Since, the dataset is fed into a cv.glmnet model, it must have a target variable. The target variable is the variable whose values are to be modeled and predicted by other variables. 

Target variable can be chosen from the dropdown menu where the binarised feature columns can be selected. 
### Output of WebApp

The webapp shows two figures.
* Input Dataset
* Variable Importance Plot using cv.glmnet model


## cv.glmnet

Glmnet is a package that fits generalized linear and similar models via penalized maximum likelihood. cv. glmnet performs cross-validation, by default 10-fold which can be adjusted using n-folds. 

The calculation of the coefficients through cv.glmnet can be found in my repository, [Predictive_Modeling](https://github.com/Prapti-044/Predictive_Modeling).


In the feature importance plot, the x-axis represents the coefficients for each feature which is calculated using the cv.glmnet model. And, the y-axis represents the names of the features present in the input dataset.
## Demonstration

In the demonstration, the preprocessed csv file dataset is taken as input. 

`ETL.AVERAGE` is taken as the target variable.

The output is the variable importance plot obtained through the application of `cv.glmnet` model.

![demo](/web.png)




