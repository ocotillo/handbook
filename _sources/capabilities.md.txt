# Instrument description and capabilities

## Hal the H-alpha detector

## Connie the continuum detector

## Heidi the high-order wavefront sensing camera (HOWFS)

## Lois the low-order wavefront sensing camera (LOWFS)

## Computer architecture

The computers that run MagAO-X are:

  * The Instrument Control Computer (ICC)
  * The Real Time control Computer (RTC)
  * The Adaptive optics Operator Computer (AOC) *TODO*

While on the University of Arizona network, the RTC is known as `exao2.as.arizona.edu` (`10.130.133.207`) and the ICC as `exao3.as.arizona.edu` (`10.130.133.208`). Both ICC and RTC run modified Linux kernels (see [Installing the realtime Linux kernel and the NVIDIA GPU driver](appendices/computer_setup/realtime_linux_config)) optimized for low and predictable latency.

### Real Time Controller

Responsible for wavefront sensing and control, and directly connected to the HOWFS detector and deformable mirrors. The operation of the control loop depends on [CACAO: Compute And Control for Adaptive Optics](https://github.com/cacao-org/cacao) authored by [Olivier Guyon and collaborators](https://github.com/cacao-org/cacao/graphs/contributors).

### Instrument Control Computer

Responsible for functions that do not depend on strong realtime constraints, including LOWFS, configuring and reading out science cameras, etc.
