# Applications

```eval_rst
.. toctree::
    :maxdepth: 1

    alpaoCtrl
    dmMode
    filterWheelCtrl
    ocam2KCtrl
    sshDigger
    trippLitePDU
    xindiserver
    xt1121DCDU
```

## Standard Options

All MagAO-X applications accept the following options:

| Short | Long                   | Config-File *         | Type            | Description |
| ---   | ---                    | ---                   | ---             | --- |
| `-c`  | `--config`             | config                | string          | A local config file |
| `-h`  | `--help`               |                       | none            | Print this message and exit |
| `-p`  | `--loopPause`          | loopPause             | unsigned long   | The main loop pause time in ns |
| `-P`  | `--RTPriority`         | RTPriority            | unsigned        | The real-time priority (0-99) |
| `-L`  | `--logDir`             | logger.logDir         | string          | The directory for log files |
|       | `--logExt`             | logger.logExt         | string          | The extension for log files |
|       | `--maxLogSize`         | logger.maxLogSize     | string          | The maximum size of log files |
|       | `--writePause`         | logger.writePause     | unsigned long   | The log thread pause time in ns |
|       | `--logThreadPrio`      | logger.logThreadPrio  | int             | The log thread priority |
| `-l`  | `--logLevel`           | logger.logLevel       | string          | The log level |
| `-n`  | `--name`               | name                  | string          | The name of the application, specifies config. |

\* In the "Config-File" column, the syntax `section.keyword` means that in the config file this option is set as follows:
```
[section]
keyword=value
```

