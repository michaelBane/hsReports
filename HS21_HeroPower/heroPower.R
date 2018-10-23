library(dplyr)
library(ggplot2)
library(scales)
library(tidyr)

hsColors <- c('#DCDCDC', '#DCDCDC', '#FF7D0A', '#ABD473', '#69CCF0',  '#F58CBA',
              '#000000', '#FFF569', '#0070DE', '#9482C9', '#C79C6E', '#2F4F4F')

data <- read.csv('HS21_HeroPower/heroPower.csv', sep = '\t')
data$play_category <- factor(data$play_category, levels = c("Other",
                                                            "The Coin",
                                                            "DRUID",
                                                            "HUNTER",
                                                            "MAGE",
                                                            "PALADIN",
                                                            "PRIEST",
                                                            "ROGUE",
                                                            "SHAMAN",
                                                            "WARLOCK",
                                                            "WARRIOR",
                                                            "NEUTRAL"))

data %>%
  filter(turn <= 30,
         game_type == 2) %>%
  ggplot(aes(x = turn,
             y = plays,
             fill = play_category)) +
  geom_histogram(stat = 'identity',
                 position = 'fill',
                 alpha = 1/2) +
  scale_fill_manual(values = hsColors) +
  scale_y_continuous(labels = percent)
