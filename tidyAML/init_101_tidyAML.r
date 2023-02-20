## tidyAML (Automated ML), 20 Feb 2023
if(F)
  browseURL("https://www.spsanderson.com/tidyAML/")

library(tidymodels)
library(tidyAML)

rec_obj <- recipe(mpg ~ ., data = mtcars)
frt_tbl <- fast_regression(
  .data = mtcars, 
  .rec_obj = rec_obj, 
  .parsnip_eng = c("lm","glm","gee"),
  .parsnip_fns = "linear_reg"
)

glimpse(frt_tbl)
frt_tbl$pred_wflw


## Doesn't extend as expected...
snd_tbl <- fast_regression_parsnip_spec_tbl(
  .data = mtcars, 
  .rec_obj = rec_obj, 
  .parsnip_fns = "linear_reg"
)
