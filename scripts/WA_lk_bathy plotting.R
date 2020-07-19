library(sf)
library(tidyverse)

# Have a look at what layers are present in .gdb
st_layers("WA_Lk_Bathy.gdb")

# load and join layers
Lk_bath <- st_read("WA_Lk_Bathy.gdb", layer = "LakeBathymetryLine")

Lk_names <- select(Lk_bath, GNIS_Name, ReachCode)

Lk_poly <- st_read("WA_Lk_Bathy.gdb", layer = "LakeBathymetryPoly") %>% 
  rename(ReachCode = Reachcode_NR) %>% 
  left_join(., 
            distinct(st_set_geometry(select(Lk_bath, ReachCode, GNIS_Name), NULL)), 
            by = "ReachCode")

# Explore list of lake names
levels((as.factor(Lk_bath$GNIS_Name)))

# Plot all lakes
plot(Lk_poly$SHAPE)

# Plot w/ ggplot
lk <- "Loon Lake"

ggplot() +
  geom_sf(data = filter(Lk_poly, GNIS_Name == lk),
          aes(fill = LO_DEPTH_QT_FT)) +
  scale_fill_viridis_c(name = "Depth ft", direction = -1) +
  labs(title = lk)

library(stars)
lk1 <- st_transform(filter(Lk_poly, GNIS_Name == lk), st_crs(Lk_bath))

lk1.st <- st_rasterize(lk1["LO_DEPTH_QT_FT"])

plot(lk1.st)


