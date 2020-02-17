******************************
Planning your observations
******************************

Filters and Throughputs
=============================

Calculated filter characteristics and transmission curves are given below.  All are based on standard reflectivity or transmission data for various surfaces, unless a part specific curve was provided by the manufacturer.  No transmissive optics (ADCs, etc) are currently accounted for.  

The atmosphere is included in the numbers presented in the table below.  BTRAM was used to calculate the atmospheric transmission for LCO, and the below values assume a zenith distance of 30 degrees and 5.0 mm PWV. A version of each curve is provided without the atmosphere contribution, which can then be combined with the atmosphere of your choice.

None of these values have been validated.  They should be used for planning purposes only.

Science
=============================
Filters in the science cameras.

camsci1
--------------------
   
   +--------------+------------+---------------+---------------+---------------+--------------+------------+------------------+----------------------------------------------------------------------------+
   | WFS B/S      | Pupil      | Sci-BS        | Filter        | lambda_0      | w_eff        | qe_max     | F_0              | Files                                                                      |
   |              |            |               |               | [um]          | [um]         |            | [phot/sec]       |                                                                            |
   +==============+============+===============+===============+===============+==============+============+==================+============================================================================+
   | H-alpha/IR   | open       | H-alpha       |  Ha-Cont      |   0.668       | 0.0086       | 0.22       | 3.8e9            | :download:`atm<filters/magaox_sci-halpha-cont_bs-halpha-ir_atm.dat>`       |
   |              |            |               |               |               |              |            |                  | :download:`noatm<filters/magaox_sci-halpha-cont_bs-halpha-ir.dat>`         |
   +--------------+------------+---------------+---------------+---------------+--------------+------------+------------------+----------------------------------------------------------------------------+

camsci2
----------------
   
   +--------------+------------+---------------+---------------+---------------+--------------+------------+------------------+----------------------------------------------------------------------------+
   | WFS B/S      | Pupil      | Sci-BS        | Filter        | lambda_0      | w_eff        | qe_max     | F_0              | Files                                                                      |
   |              |            |               |               | [um]          | [um]         |            | [phot/sec]       |                                                                            |
   +==============+============+===============+===============+===============+==============+============+==================+============================================================================+
   | H-alpha/IR   | open       | H-alpha       |  Halpha       |   0.656       | 0.0085       | 0.23       | 3.5e9            | :download:`atm<filters/magaox_sci-halpha_bs-halpha-ir_atm.dat>`            |
   |              |            |               |               |               |              |            |                  | :download:`noatm<filters/magaox_sci-halpha_bs-halpha-ir.dat>`              |
   +--------------+------------+---------------+---------------+---------------+--------------+------------+------------------+----------------------------------------------------------------------------+

WFS
=================

Filters in the main WFS.

   +--------------+---------------+--------------+------------+------------------+----------------------------------------------------------------------------+
   | WFS B/S      | lambda_0      | w_eff        | qe_max     | F_0              | Files                                                                      |
   |              | [um]          | [um]         |            | [phot/sec]       |                                                                            |
   +==============+===============+==============+============+==================+============================================================================+
   | H-alpha/IR   |   0.837       | 0.205        | 0.20       | 5.3e10           | :download:`atm<filters/magaox_wfs_bs-halpha-ir_atm.dat>`                   |
   |              |               |              |            |                  | :download:`noatm<filters/magaox_wfs_bs-halpha-ir.dat>`                     |
   +--------------+---------------+--------------+------------+------------------+----------------------------------------------------------------------------+

LOWFS
=================

Filters in the low-order WFS.

Atmosphere
=================

Atmospheric transmission curves.
