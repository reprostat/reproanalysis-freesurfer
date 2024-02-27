# reproanalysis-freesurfer
Reproanalysis Extension for integrating FreeSurfer

## Requirements
- [FreeSurfer](https://surfer.nmr.mgh.harvard.edu)
- [niworkfows](https://www.nipreps.org/niworkflows/master/index.html) - for conversion to CIfTI; for installation instruction see [niwfClass](https://github.com/reprostat/toolboxes/blob/master/niwfClass.m)

## Supported use-cases
- FreeSurfer reconstruction with workflow directives _all_, _autorecon1_, _autorecon2_, _autorecon2-cp_, _autorecon2-wm_, _autorecon2-pial_, _autorecon3_
- Volume-to-surface conversion and saving output into NIfTI, GIfTI, and/or CIfTI
