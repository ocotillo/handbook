# Compute System

The MagAO-X computing system.

```eval_rst
.. toctree::
   :maxdepth: 1

   administration
   networking
   data_storage_management
   computer_setup/computer_setup
   development_vm
```
   
## Computer Architecture

The computers that run MagAO-X are:

  * The Instrument Control Computer (ICC)
  * The Real Time control Computer (RTC)
  * The Adaptive optics Operator Computer (AOC) *TODO*

While on the University of Arizona network, the RTC is known as `exao2.as.arizona.edu` (`10.130.133.207`) and the ICC as `exao3.as.arizona.edu` (`10.130.133.208`). Both ICC and RTC run modified Linux kernels optimized for low and predictable latency.

### Real Time Controller

Responsible for wavefront sensing and control, and directly connected to the HOWFS detector and deformable mirrors. The operation of the control loop depends on [CACAO: Compute And Control for Adaptive Optics](https://github.com/cacao-org/cacao) authored by [Olivier Guyon and collaborators](https://github.com/cacao-org/cacao/graphs/contributors).

### Instrument Control Computer

Responsible for functions that do not depend on strong realtime constraints, including LOWFS, configuring and reading out science cameras, etc.



