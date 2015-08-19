####### This tests weights in deeplearning for poisson by comparing results with expected behaviour  ######

setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source('../../h2o-runit.R')

test <- function() {

	fre = h2o.importFile(locate("smalldata/glm_test/freMTPL2freq.csv.zip"),destination_frame = "fre")
	fre$VehPower = as.factor(fre$VehPower)
	fre = h2o.assign(fre[1:6000,],key = "fre")
	#fren = as.data.frame(fre)
	#fren$VehPower = as.factor(fren$VehPower)
	#library(gbm)
	#gg = gbm(formula = ClaimNb~ Area +as.factor(VehPower)+ VehAge+ DrivAge+ BonusMalus+ VehBrand + VehGas +Density +Region,distribution =  "poisson",verbose = T,
	 #        weights=Exposure,data = fren,n.trees = 100,interaction.depth = 1,n.minobsinnode = 1,shrinkage = .1,bag.fraction = 1,train.fraction = 1)
	#gg$train.error #1.9965
	#pr = predict(gg,newdata = fren,type = "response")
	#summary(pr) #mean = 1.052; min = 1.004; max = 1.807; 
	
	hh = h2o.deeplearning(x = 4:12,y = "ClaimNb",distribution =  "poisson",hidden = c(30),epochs = 100,train_samples_per_iteration = -1,overwrite_with_best_model = F,
                      reproducible = T,activation = "Tanh",balance_classes = F,force_load_balance = F,
                      seed = -8224042382692318000,score_training_samples = 0,score_validation_samples = 0,
                      weights_column="Exposure" ,training_frame = fre) 
	mean_deviance = hh@model$training_metrics@metrics$mean_residual_deviance
	expect_equal(mean_deviance,1.996524205)
	ph = as.data.frame(h2o.predict(hh,newdata = fre)) 
	expect_equal(1.065718154, mean(ph[,1]) )
	expect_equal(0.8968355341, min(ph[,1]) )
	expect_equal(1.325415826, max(ph[,1]) )
		
	testEnd()
}
doTest("Deeplearning weight Test: deeplearning w/ weights for poisson distribution", test)

