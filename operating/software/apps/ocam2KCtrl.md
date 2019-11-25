# ocam2KCtrl

## Name

ocam2KCtrl − Controls an OCAM 2K EMCCD 

## Synopsis

```
ocam2KCtrl [options]
```

`ocam2KCtrl` is normally configured with a configuration file, hence all command-line arguments are optional. But note that if the `-n name` option is not given, then a configuration file named `ocam2KCtrl.conf` must be available at the MagAO-X standard config path.

## Description

`ocam2KCtrl` controls the OCAM 2K EMCCD, which serves as the pyramid wavefront sensor detector in MagAO-X.  It monitors and logs temperatures, configures the camera for the desired mode of operation, and manages the grabbing and processing of frames.  It is a MagAO-X `standard camera`, an `EDT camera`, and a standard `framegrabber`.

## Options

ocam2KCtrl accepts the [standard options](index.html#standard-options)

ocam2KCtrl accepts the standard camera options

ocam2KCtrl accepts the EDT camera options

ocam2KCtrl accepts the framegrabber options


\* format in the config file column is section.option which implies the format

```
[section]
option=value
```
in the config file.

## INDI Properties

#### Read-Only INDI Properties

list them here

#### Read-Write INDI Properties

list them here

## Exit Status

`ocam2KCtrl` runs until killed.  Use the `logdump` utility to examine the process log for errors.


## Examples

To start the ocam2KCtrl as the Pyramid WFS camera:
```
/opt/MagAOX/bin/ocam2KCtrl -n camwfs
```

## See also

[Source code.](../../../MagAOX/group__ocam2KCtrl.html)
