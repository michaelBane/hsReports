library(dplyr)
library(ggplot2)
library(scales)
library(tidyr)
library(jsonlite)
library(gridExtra)

hsColors <- c('#FF7D0A', '#ABD473', '#69CCF0', '#F58CBA',
              '#000000', '#FFF569', '#0070DE', '#9482C9', '#C79C6E')

url <- 'https://hsreplay.net/api/v1/archetypes/?format=json'
archetypes <- fromJSON(url) %>%
  select(id, name)
regions <- data.frame(Region = c('NA', 'EU', 'Asia', 'CN'),
                      region = c(1, 2, 3, 5))

data <- read.csv('HS20_Regions/regionsData.csv')

limit <- 0.005

plotData <- tbl_df(data) %>%
  mutate(archetype_id = as.integer(as.character(archetype_id))) %>%
  inner_join(archetypes, by = c('archetype_id' = 'id')) %>%
  inner_join(regions, by = 'region') %>%
  select(-archetype_id, -region) %>%
  spread(Region, ï..pcplays) %>%
  arrange(desc(`NA`)) %>%
  mutate(NAvsEU = EU - `NA`,
         NAvsAP = Asia - `NA`,
         NAvsCN = CN - `NA`) %>%
  filter(`NA` > limit |
         EU > limit |
         Asia > limit |
         CN > limit)


p1 <- ggplot(plotData,
       aes(x = `NA`,
             y = CN)) +
  geom_point() +
  geom_text(aes(label = name),
            nudge_y = -0.0002,
            size = 2,
            alpha = 1/2) +
  geom_abline(aes(size),
              slope = 1,
              lty = 2) +
  scale_x_continuous(labels = percent,
                     limits = c(0, 0.05)) +
  scale_y_continuous(labels = percent,
                     limits = c(0, 0.05))

p2 <- ggplot(plotData,
       aes(x = reorder(name, NAvsCN),
           y = NAvsCN)) +
  geom_histogram(stat = 'identity') +
  scale_y_continuous(labels = percent,
                     limits = c(-0.012, 0.012)) +
  coord_flip() +
  xlab('')

grid.arrange(p2, p1, ncol=2)
