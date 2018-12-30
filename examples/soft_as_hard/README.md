# Using soft data and the preferential path

`soft_as_hard.m` compares SNESIM simulation conditional to different types of hard and soft data. Deatils about the data can be 
found in Hansen et al., (2017, in review).

Ideally a 'soft'/uncertain data with no associated uncertainty should be treated exactly as 'hard' data. The two following eas-files 
exactly the same information available from at 3 locations. 


The file `soft_as_hard.dat` defines the data as 'soft' information:
```
Data written by mGstat 10-Jan-2016
5
col1, unknown
col2, unknown
col3, unknown
col4, unknown
col5, unknown
                 6                   14                    0              0.0000              1.0000
                13                   16                    0              0.0000              1.0000
                 3                   14                    0              0.0000              1.0000
```

The file `hard_as_hard.dat` defines the data as 'hard' in information.
```
Data written by mGstat 10-Jan-2016
4
col1, unknown
col2, unknown
col3, unknown
col4, unknown
                 6                   14                    0             1
                13                   16                    0             1
                 3                   14                    0             1
```

Running `soft_as_hard.m` will generate 1000 conditional realizations (using both a random and preferential path). The two figures below shows the Etype-mean 
(probability of a channel in this case) in case considering the information as soft (top) and hard (bottom) data.

![Considering soft data](https://raw.githubusercontent.com/ergosimulation/mpslib/master/examples/soft_as_hard/snes_id4_n1000.png)
![Considering hard data](https://raw.githubusercontent.com/ergosimulation/mpslib/master/examples/soft_as_hard/snes_id5_n1000.png)

