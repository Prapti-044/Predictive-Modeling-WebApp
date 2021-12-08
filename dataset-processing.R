get.feature.importance.plot <- function(data.dt, target.col) {
  cwis.logs.merge <- data.dt
  
  threshold <- mean(cwis.logs.merge[[target.col]])
  
  for (i in 1:NROW(cwis.logs.merge)) {
    if(cwis.logs.merge[[target.col]][i] >= threshold){cwis.logs.merge[[target.col]][i] <- 1}
    else{cwis.logs.merge[[target.col]][i] <- 0}
  }
  
  input.data <- cwis.logs.merge
  
  
  # Accuracy
  
  split = 5
  fold.vec <- sample(rep(1:split,l=nrow(input.data)))
  folds.input.data <- data.table::data.table(input.data,fold=as.numeric(factor(fold.vec)))
  
  
  final.accuracy.list <- list()
  accuracy.dt <- list()
  predictions.list <- list()
  
  weight.dt.list <- list()
  
  for(i in 1:split){
    set.seed(i)
    datatrain <-folds.input.data[fold != i] #69637 obs. of  129 variables:
    datatest <- folds.input.data[fold == i]
    
    y_train <- as.matrix(datatrain[[target.col]])
    y_test <- as.matrix(datatest[[target.col]])
    
    X_train <- as.matrix(datatrain[,-c(target.col), with=FALSE])
    X_test <-  as.matrix(datatest[,-c(target.col), with=FALSE])
    
    cv.fit.gaussian <- cv.glmnet(X_train, y_train, family = "binomial")
    
    weight.dt.list[[i]] <- data.table(
      i,
      Featues.Name=rownames(coef(cv.fit.gaussian))[-1],
      Coefficients=coef(cv.fit.gaussian)[-1])
    
    one.pred <- function(x)rep(x, nrow(X_test))
    as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}
    freq <-as.data.frame(table(y_train))
    median.values <- sort(y_train)
    median.ind.val <- median(median.values)
    mean.ind.val <- mean(y_train)
    
    predictions.list <-  list(
      glmnet.gaussian=as.numeric(predict(cv.fit.gaussian,newx=X_test,s=cv.fit.gaussian$lambda.1se,type="response")),
      baseline.l0=one.pred(as.numeric.factor(freq[which.max(freq$Freq),]$y_train)),
      baseline.l1=one.pred(median.ind.val),
      baseline.l2=one.pred(mean.ind.val)
    )
    
    accuracy.dt.list <- list()
    for(algo in names(predictions.list)){
      pred.vec = predictions.list[[algo]]
      accuracy.dt.list[[algo]] <- data.table(
        algo.name = algo,
        misclassfication.error= mean(pred.vec != actual),
        log.loss.error=MLmetrics::LogLoss(y_pred = pred.vec, y_true = actual)
        
        #meanabs.error.percent= mean(abs((pred.vec) - (y_test)))
        #rmse.error.percent = sqrt(mean(((pred.vec) - (y_test))^2))#l2 error
      )
    }
    
    accuracy.dt[[i]] <- data.table(fold=i,accuracies = do.call(rbind, accuracy.dt.list))
  }
  
  weight.dt <- do.call(rbind, weight.dt.list)
  
  weight.dt[, n.nonzero := sum(Coefficients != 0), by=Featues.Name]
  
  
  ggplot()+
    facet_grid(n.nonzero ~ ., scales="free", space="free")+
    geom_point(aes(
      Coefficients, Featues.Name),
      data=weight.dt)
}
