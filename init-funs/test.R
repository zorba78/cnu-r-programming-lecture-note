require(jpeg)
# install.packages("pixmap")

myurl <- "https://img1.daumcdn.net/thumb/R800x0/?scode=mtistory2&fname=https%3A%2F%2Ft1.daumcdn.net%2Fcfile%2Ftistory%2F253DD84B5802406C1E"
z <- tempfile()
download.file(myurl,z,mode="wb")
pic <- readJPEG(z)
pic[250:350, 225:290, 1] <- 255
pic[250:350, 225:290, 2] <- 255
pic[250:350, 225:290, 3] <- 255

require(cowplot)
require(magick)

ggdraw() +
  draw_image(pic)

plot(1:2, type='n')
rasterImage(pic, 1, 1.25, 1.1, 1)


library(rvest)
library(httr)
library(jpeg)

lego_movie <- read_html("http://www.imdb.com/title/tt1490017/")

poster <- lego_movie %>%
  html_nodes("#img_primary img") %>%
  html_attr("src")

GET(poster, write_disk("lego.jpg"))
img <- readJPEG("lego.jpg")
plot(1:2, type='n')
rasterImage(img, 1, 1.25, 1.1, 1)