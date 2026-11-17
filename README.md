# Maternal mirroring and infant motor-system activation

MATLAB code for preprocessing infant EEG and analysing sensorimotor activity during observation and execution of facial movements.

## Paper

Rayson, H., Bonaiuto, J. J., Ferrari, P. F., & Murray, L. (2017). [Early maternal mirroring predicts infant motor system activation during facial expression observation](https://doi.org/10.1038/s41598-017-12097-w). *Scientific Reports*.

## Code

- [`preprocess_subject.m`](preprocess_subject.m) contains subject-level preprocessing.
- [`all_subjects_tf.m`](all_subjects_tf.m), [`subjects_erd.m`](subjects_erd.m) and [`cluster_ersp.m`](cluster_ersp.m) cover time–frequency, event-related desynchronisation and cluster analyses.
- [`exe/`](exe/) contains scripts for movement execution.

The analyses expect local EEG and behavioural coding files. See [LICENSE](LICENSE) for the code licence.
