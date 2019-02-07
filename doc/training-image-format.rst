Training image format
=====================

Training images must be formatted as
`EAS/GSLIB <http://www.gslib.com/gslib_help/format.html>`__ ascii file,
with the special requirement that that the first line must describe the
dimensions of the training image

::

    2 3 1
    1
    Channel
                     1
                     1
                     0
                     0
                     1
                     1

Line 1: Contains the dimension of training image, specified as 3
integeres seprated by a space ``nx ny nz``

Line 2: The number columns of data (typically one for a training image)

Line 3: The name of column 1, [There should be one line, with the name
of each column, for each number of columns]

Line4 -> : The training image data. One data value on each of the
following ``nx*ny*nz`` lines.
