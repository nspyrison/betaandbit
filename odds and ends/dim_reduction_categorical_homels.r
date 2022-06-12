###############
## Dim Reduction takeaways:
## 1) Classical PCA is only for numeric data;
## 2) The rrcov package has many Pca* functions and settings; but prob not needed.
## 3) Gifi::homals is a Psych approach to performing Dim Reduc on categories.
##   - out$objectscores is the data projection.
##   - out$loadings is the list basis, though takes some messaging to work with.
###############


df <- cheem::amesHousing2018_NorthAmes
str(df)

## 1) NB: classical PCA is only for numeric data;
#### Cannot be used for DR on categorical.
prc <- prcomp(df) ## Error in colMeans(x, na.rm = TRUE) : 'x' must be numeric

bas <- spinifex::basis_pca(df[, -11])
spinifex::is_orthonormal(bas)


## 2) The rrcov package has many Pca* functions and settings; but prob not needed.
?rrcov::PcaHubert()


## 3) the Gifi package facilitates homals, nonortho DR of 
install.packages("Gifi")
?Gifi::homals()
library("Gifi")

## multiple Categorical attributed
fithart <- homals(hartigan,
                  ndim = 7, ## output dim
                  ordinal = FALSE) ## Do consider categories ordinal?
fithart
summary(fithart)
names(fithart)
plot(fithart)
?Gifi:::plot.homals()

lapply(fithart, class)
if(F)
  lapply(fithart, print)

## supplied plotting
plot(fithart, plot.type = "biplot")
plot(fithart, plot.type = "screeplot")

## I think this looks like the proj:
proj_cat <- fithart$objectscores
class(proj_cat)
##
dim(proj_cat)
dim(hartigan)

## I think this looks like the basis:
bas_cat <- fithart$loadings
#d    <- nrow(bas_cat[[1]])
lens <- sapply(bas_cat, ncol)
nms  <- names(bas_cat)
#p    <- sum(lens)
dat_in <- hartigan ## data needed
bas_out <- NULL #matrix(NA, nrow = d, ncol = p)
dat_out <- nms_out <- NULL

## there is an issue with the example as length is numeric
for(i in seq_along(bas_cat)){
  lvls <- levels(dat_in[, i])
  nms_out <- c(nms_out, paste0(nms[i], ":", lvls))
  bas_out <- cbind(bas_out, bas_cat[[i]])
  for(j in seq_along(lvls)) ## one encoding the categories
    dat_out <- cbind(dat_out, dat_in[, i] == lvls[j])
}
bas_out <- as.data.frame(bas_out, )
dat_out <- as.data.frame(dat_out)
colnames(bas_out) <- colnames(dat_out) <- nms_out
str(bas_out)


class(bas_cat)
##
dim(bas_cat)
dim(hartigan)

## It's not ortho:
#tourr::is_orthonormal(bas_cat) ## Another examp where tourr::is_ortho is wrong.
spinifex::is_orthonormal(bas_cat)
obas_cat <- tourr::orthonormalise(bas_cat)
spinifex::is_orthonormal(obas_cat)


## Eigen values for the scree plot
eigen_vals <- fithart$evals
  

