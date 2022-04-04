# fpp2 ------
if(F)
  browseURL("https://otexts.com/fpp2/selecting-predictors.html")
library(fpp2)

## Continuing from 
## 5.6 -----

## Classical additive and multiplicative decomposition
decomp <- elecequip %>% decompose(type="multiplicative")
str(decomp)

elecequip %>% decompose(type="multiplicative") %>%
  autoplot() + xlab("Year") +
  ggtitle("Classical multiplicative decomposition
    of electrical equipment index")

elecequip %>% decompose(type="additive") %>%
  autoplot() + xlab("Year") +
  ggtitle("Classical additive decomposition
    of electrical equipment index")

beer %>% decompose(type="multiplicative") %>%
  autoplot() + xlab("Year") +
  ggtitle("Classical multiplicative decomposition
    of electrical equipment index")



## X11 decomposition
#install.packages("seasonal")
library(seasonal)
library(patchwork)

elecequip %>% seas(x11="") -> fit
x11 <- autoplot(fit) +
  ggtitle("X11 decomposition of electrical equipment index")

decomp_multi <- elecequip %>% decompose(type="multiplicative") %>%
  autoplot() + xlab("Year") +
  ggtitle("Classical multiplicative decomposition
    of electrical equipment index")

## side, by side, X11 does seem to capture more spiky-ness in the trend, 
# resulting in mostly smaller remainders 
x11 + decomp_multi


autoplot(elecequip, series="Data") +
  autolayer(trendcycle(fit), series="Trend") +
  autolayer(seasadj(fit), series="Seasonally Adjusted") +
  xlab("Year") + ylab("New orders index") +
  ggtitle("Electrical equipment manufacturing (Euro area)") +
  scale_colour_manual(values=c("gray","blue","red"),
                      breaks=c("Data","Seasonally Adjusted","Trend"))

