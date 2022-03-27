# fpp2 ------
if(F)
  browseURL("https://otexts.com/fpp2/selecting-predictors.html")
library(fpp2)


## Continuing from 
## 5.5 -----
beer2 <- window(ausbeer, start=1992)
fit.beer <- tslm(beer2 ~ trend + season)
fcast <- forecast(fit.beer)
autoplot(fcast) +
  ggtitle("Forecasts of beer production using regression") +
  xlab("Year") + ylab("megalitres")


## 5.6 -----
fit.consBest <- tslm(
  Consumption ~ Income + Savings + Unemployment,
  data = uschange)
h <- 4
newdata <- data.frame(
  Income = c(1, 1, 1, 1),
  Savings = c(0.5, 0.5, 0.5, 0.5),
  Unemployment = c(0, 0, 0, 0))
fcast.up <- forecast(fit.consBest, newdata = newdata)
newdata <- data.frame(
  Income = rep(-1, h),
  Savings = rep(-0.5, h),
  Unemployment = rep(0, h))
fcast.down <- forecast(fit.consBest, newdata = newdata)
autoplot(uschange[, 1]) +
  ylab("% change in US consumption") +
  autolayer(fcast.up, PI = TRUE, series = "increase") +
  autolayer(fcast.down, PI = TRUE, series = "decrease") +
  guides(colour = guide_legend(title = "Scenario"))

## 5.8 -----

# https://otexts.com/fpp2/nonlinear-regression.html#forecasting-with-a-nonlinear-trend
# basically the idea I am thinking of is: 
# 1) identifying _knots_, 2) de-(knot, trend, season), 3) identify abnormal points/periods
# For each lat-long? feels like it wants a hierarchical model on lat-long.

boston_men <- window(marathon, start=1924)
h <- 10
fit.lin <- tslm(boston_men ~ trend)
fcasts.lin <- forecast(fit.lin, h = h)
fit.exp <- tslm(boston_men ~ trend, lambda = 0)
fcasts.exp <- forecast(fit.exp, h = h)

t <- time(boston_men)
t.break1 <- 1950
t.break2 <- 1980
tb1 <- ts(pmax(0, t - t.break1), start = 1924)
tb2 <- ts(pmax(0, t - t.break2), start = 1924)

fit.pw <- tslm(boston_men ~ t + tb1 + tb2)
t.new <- t[length(t)] + seq(h)
tb1.new <- tb1[length(tb1)] + seq(h)
tb2.new <- tb2[length(tb2)] + seq(h)

newdata <- cbind(t=t.new, tb1=tb1.new, tb2=tb2.new) %>%
  as.data.frame()
fcasts.pw <- forecast(fit.pw, newdata = newdata)

fit.spline <- tslm(boston_men ~ t + I(t^2) + I(t^3) +
                     I(tb1^3) + I(tb2^3))
fcasts.spl <- forecast(fit.spline, newdata = newdata)

autoplot(boston_men) +
  autolayer(fitted(fit.lin), series = "Linear") +
  autolayer(fitted(fit.exp), series = "Exponential") +
  autolayer(fitted(fit.pw), series = "Piecewise") +
  autolayer(fitted(fit.spline), series = "Cubic Spline") +
  autolayer(fcasts.pw, series="Piecewise") +
  autolayer(fcasts.lin, series="Linear", PI=FALSE) +
  autolayer(fcasts.exp, series="Exponential", PI=FALSE) +
  autolayer(fcasts.spl, series="Cubic Spline", PI=FALSE) +
  xlab("Year") + ylab("Winning times in minutes") +
  ggtitle("Boston Marathon") +
  guides(colour = guide_legend(title = " "))

boston_men %>%
  splinef(lambda=0) %>%
  autoplot()

boston_men %>%
  splinef(lambda=0) %>%
  checkresiduals()


## 5.10, exercises 1-----
daily20 <- head(elecdaily,20)
autoplot(daily20)
str(daily20)

df <- as.data.frame(daily20)
ggplot(df, aes(Temperature, Demand)) +
  geom_point(aes( shape = factor(WorkDay))) +
  geom_smooth(method="lm", se = FALSE)

daily20_lm <- tslm(Demand~Temperature, daily20)
daily20_lm %>%
  checkresiduals()
## All clean here.
forecast(daily20_lm, newdata=data.frame(Temperature=c(15,35)))
## 35 seems good, I am skeptical of 15, we don't epect demand to decrease linear, eventually we will need to start heating again.


# ## Attempt following 5.8 -- didn't work
# h <- 10
# fit.lin <- tslm(daily20 ~ trend + season, daily20)
# fcasts.lin <- forecast(fit.lin, h = h)
# fit.exp <- tslm(daily20 ~ trend + season,  lambda = 0)
# fcasts.exp <- forecast(fit.exp, h = h)
# 
# autoplot(daily20) +
#   autolayer(fitted(fit.lin), series = "Linear") +
#   #autolayer(fitted(fit.exp), series = "Exponential") +
#   autolayer(fcasts.lin, series="Linear", PI=FALSE) 
#   #autolayer(fcasts.exp, series="Exponential", PI=FALSE)

## data.frame route, following 5.10 d code
autoplot(daily20, facets=TRUE)
daily20 %>%
  as.data.frame() %>%
  ggplot(aes(x=Temperature, y=Demand)) +
  geom_point() +
  geom_smooth(method="lm", se=FALSE)
fit <- tslm(Demand ~ Temperature, data=daily20)
checkresiduals(fit)
forecast(fit, newdata=data.frame(Temperature=c(15,35)))

## With trend and season
fit.lin <- tslm(Demand ~ Temperature + trend + season, daily20)
checkresiduals(fit.lin)

## Checking full range of data, expect to see lower temp curve up
elecdaily %>%
  as.data.frame() %>%
  ggplot(aes(x=Temperature, y=Demand)) +
  geom_point()
## correct, the low range is mostly between 20-30 C.

## what is the time range of the data
str(elecdaily)
?elecdaily ## daily consumption, for VIC in 2014.




## 5.10, exercises 2-----
?mens400
autoplot(mens400) ## downward trend, flattens at the end as would be expected for winning race times.
#fit <- tslm( ~ trend, mens400) ## cannot fit, going to visual analytics
autoplot(mens400) + geom_smooth(method = "lm") ## decrease of about 2.5 sec / 40 years or -.0625s/yr.
df <- data.frame(time = mens400, year = seq(1896, 2016, 4))
fit <- lm(time~year, df)
fit$coefficients
checkresiduals(fit)

idx <- !is.na(mens400)
df <- data.frame(
  wining_time = mens400[idx],
  year = time(mens400)[idx],
  residuals = residuals(fit)
)
ggplot(df, aes(residuals, year)) + 
  geom_point()
## Cresent shaped indicating not linear fit is needed, which we already noted. 
forecast(fit, newdata=data.frame(year=2020))

## Exercise 3
easter(ausbeer) ## show easter osscilating between Q1 and Q2 over the years.

## Exercise 4, woah that seems left field, idk wherer to begin

## Exercise 5
?fancy
autoplot(fancy) ## regular seasonal peak around the holidays and exponential base growth
## Because, we span several orders of magnitude, and exp growth
log(fancy)

fit <- tslm(log(fancy) ~ trend + season, fancy)
checkresiduals(fit) ## there is still sine signal in the residuals
coefficients(fit)
## bgtest, p-value = 0.003, there is higher-order serial correlation\
(newdata <- data.frame(year=1994:(1994+36)))
fc <- forecast(fit, newdata=newdata)
autoplot(fancy) + autolayer(fc, PI = TRUE, series = "increase")


