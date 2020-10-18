# Create DEM from countours as per
# https://www.r-bloggers.com/2019/04/r-as-gis-for-ecologists/

library(raster)
library(rgdal)
library(rgeos)
library(gstat)
library(rgl)
library(rasterVis)
library(spdplyr) # additional package for selection of single lake

# Load lakes for .gdb

wa_lks_line <- readOGR(dsn = "D:/R/WA_data/WA_lk_bathy/WA_Lk_Bathy.gdb",
                        layer =  "LakeBathymetryLine")

# Look at lakes in .gdb
mapview::mapview(wa_lks_line)

# Select one lake
Lk <- wa_lks_line %>% filter(GNIS_Name == "Sullivan Lake")

# Obtain extent
dem_bbox <- bbox(Lk)

# Create raster
dem_rast <- raster(xmn = dem_bbox[1, 1], 
                   xmx = ceiling(dem_bbox[1, 2]),
                   ymn = dem_bbox[2, 1], 
                   ymx = ceiling(dem_bbox[2, 2]))

# Set projection
projection(dem_rast) <- CRS(projection(Lk))

# Set resolution
res(dem_rast) <- 5

# Convert to elevation points
dem_points <- as(Lk, "SpatialPointsDataFrame")

# Compute the interpolation function
dem_interp <- gstat(formula = Depth ~ 1, locations = dem_points,
                    set = list(idp = 0), nmax = 5)

# Obtain interpolation values for raster grid
DEM <- interpolate(dem_rast, dem_interp)

# Subset contour lines to 20m to enhance visualization
# Plot 2D DEM with contour lines
plot(DEM, col = terrain.colors(20))
plot(Lk, add = T)

plot3D(DEM)
