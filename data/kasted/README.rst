########### 
Kasted data
###########

These data have been produced by Despoina Exizidou, during her Master thesis ("Geostatistical modeling of buried valleys") at Technical University of Denmark, together with
Anne Sophie Høyer (GEUS, Denmark), and Thomas Mejer Hansen.

Kasted is located North of Aarhus, Denmark, and drinking water is produced from high porosity buried valleys structures embedded in thicker non-permeable clays. Imaing of the subsurface buried valleys is therefore important to understand and manage the production of drinking water.

The subsurface is considered to consists of one of two lithologies, identified by '0' and '1':

0: Clay, outside/below buried valley

1: Sand, within a buried valley 



Training image
##############

`kasted_ti.dat` (EAS format) 632x291 pixel training image. Each pixel is of size 50x50 meter.


Soft data
#########

``kasted_welllog.dat`` (GSLIB format) Probability of sand (column 4) and clay (column 5) estimated from welllog analysis at 1254 locations.


Hard data
#########
``kasted_welllog_hard.dat`` (GSLIB format) 122 observations of clay or sand from welllog analysis. These data have been created from the 'soft well log data', described below, where the most certain observations of clay and sand, are considered hard data.  


Other data
##########

``kasted_elevation.dat`` (GSLIB format). Elevation data for the area. A slight positive correlation between elevation and probability of channel is expected


``kasted_resistivity_0_5.dat`` (GSLIB format). Airborne SkyTEM data inverted to resistivity in from 0 to 5m depth. High resistivity is indicative of sand/buried valley.



.. figure:: kasted_data.png
    :width: 200px
    :align: center
    :height: 100px
    :alt: alternate text
    :figclass: align-center

    Kasted data

    
