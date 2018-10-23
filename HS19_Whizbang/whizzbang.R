library(dplyr)
library(ggplot2)
library(scales)
library(tidyr)
library(scales)
library(jsonlite)

hsColors <- c('#FF7D0A', '#ABD473', '#69CCF0', '#F58CBA',
              '#000000', '#FFF569', '#0070DE', '#9482C9', '#C79C6E')

rawData <- read.csv('HS19_Whizbang/wb.csv', sep = ',')

lookup <- data.frame(whizzbang_deck_id = unique(data$whizzbang_deck_id),
                     whizzbang_deck_name = c('Treant Druid',
                                             'Spell Hunter',
                                             'Mech Hunter',
                                             'Big Mage',
                                             'Even Paladin',
                                             'Quest Priest',
                                             'Combo Priest',
                                             'Burgle Rogue',
                                             'Deathrattle Rogue',
                                             'Token Shaman',
                                             'Control Shaman',
                                             'Demonlock',
                                             'Control Warlock',
                                             'Mech Warrior',
                                             'Quest Warrior',
                                             'Mech Paladin',
                                             'Spell Power Mage',
                                             'Tiger Druid'))


data <- inner_join(rawData, lookup, by = 'whizzbang_deck_id')

data %>%
  group_by(whizzbang_deck_name, final_state, player_class) %>%
  summarise(games = sum(games)) %>%
  spread(final_state, games) %>%
  ungroup() %>%
  mutate(`Win Rate (%)` = WON / (WON + LOST),
         `Whizbang Deck Name` = factor(whizzbang_deck_name)) %>%
  ggplot(aes(x = `Whizbang Deck Name`,
             y = `Win Rate (%)`,
             fill = player_class)) +
  geom_bar(stat = 'identity') +
  geom_hline(yintercept = 0.5,
             lty = 2) +
  facet_wrap(~ player_class, 
             scales = 'free_x',
             nrow = 1) +
  scale_y_continuous(labels = percent) +
  scale_fill_manual(values = hsColors) +
  guides(fill = FALSE) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

data %>%
  filter(rank >= 0) %>%
  group_by(Result = final_state, 
           Rank = rank) %>%
  summarise(Games = sum(games)) %>%
  ggplot(aes(x = Rank,
             y = Games,
             fill = Result)) +
  geom_bar(stat = 'identity') +
  scale_y_continuous(labels = comma)

data %>%
  filter(rank >= 0) %>%
  group_by(Result = final_state, 
           Rank = rank) %>%
  summarise(Games = sum(games)) %>%
  ggplot(aes(x = Rank,
             y = Games,
             fill = Result)) +
  geom_bar(stat = 'identity',
           position = 'fill') +
  geom_hline(yintercept = 0.5,
             lty = 2) +
  scale_y_continuous(labels = percent) +
  ylab('Win Rate (%)')
