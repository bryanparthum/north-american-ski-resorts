##########################
#################  library
##########################

## clear workspace
rm(list = ls())
gc()

## this function will check if a package is installed, and if not, install it
list.of.packages <- c('magrittr', 'tidyverse', 
                      'sf', 'rnaturalearth',
                      'ggplot2', 'ggsn', 'RColorBrewer')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

##########################
##################### data
##########################

## read resort data and create spatial sf object
resorts = 
  read_csv('data/north_american_resorts.csv') %>% 
  st_as_sf(coords = c(x = 'longitude',
                      y = 'latitude'), 
           crs = 4326) %>% 
  st_transform(5070)

## get us shape
usa =
  ne_states(country = "united states of america", 
            returnclass = "sf") %>%
  st_transform(st_crs(resorts)) %>%
  select(name, name_len) %>% 
  filter(!(name %in% c('Hawaii')))

## get canada shape
canada = 
  ne_states(country = "canada", 
            returnclass = "sf") %>%
  st_transform(st_crs(resorts)) %>%
  select(name, name_len)

##########################
##################### plot
##########################

## plot elevation
ggplot() +
  geom_sf(data  = resorts,
          aes(color = elev_vertical),
          shape = 17,
          alpha = 0.9,
          size  = 3, 
          ) +
  geom_sf(data  = usa,
          color = 'grey20',
          alpha = 0.2) + 
  geom_sf(data  = canada,
          color = 'grey20',
          alpha = 0.2) + 
  scale_color_distiller(palette = "Spectral",
                        breaks = scales::pretty_breaks(n = 6),
                        na.value = NA) +
  labs(title   = 'North American Ski Resorts',
       caption = 'Set of 393 North American ski resorts, some of which underly Parthum and Christensen (2022).',
       color   = 'Vertical Drop (feet)') +
  theme_void() +
  theme(legend.position = 'bottom',
        legend.title     = element_text(size = 14, color = 'grey20'),
        legend.text      = element_text(size = 14, color = 'grey20'),
        legend.key.width = unit(2.5, 'cm'),
        plot.caption     = element_text(size = 10, hjust = 0.5),
        plot.title       = element_text(size = 24, hjust = 0.5)) +
  guides(color = guide_colorbar(title.position = 'top', 
                                title.hjust = 0.5,
                                na.value    = 'white'))

## export 
ggsave('figures/north_american_resorts.png', width  = 9, height = 6)

## end of script. have a great day! 