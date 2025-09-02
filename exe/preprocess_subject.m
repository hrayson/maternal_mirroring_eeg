function reepoch_subject_exe(subj_id, behavior_file, varargin)

% Parse inputs
defaults=struct('delay',0.021036,'fps',29.97,'relative_noat',true,'sessions',[]);
params=struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

subj_info=[];
subj_info.subj_id=subj_id;
% lower freq limit
subj_info.lower_freq_limit=2;
% higher freq limit
subj_info.upper_freq_limit=35;
% impedance threshold
subj_info.impedance_thresh=50;
% Time limits (s) of each epoch
subj_info.epoch_limits=[-1.5 2];
% lower channel threshold
subj_info.lower_channel_thresh=-250;
% upper channel threshold
subj_info.upper_channel_thresh=250;
% proportion of bad channels to reject epoch
subj_info.prop_bad_channel_thresh=.15;
% Delay adjustment
subj_info.delay_adjustment=params.delay;
% Channels removed
subj_info.channels_to_remove={};
% Epochs removed because of bad channels
subj_info.ch_epochs_to_delete=[];
% Epochs removed because of noatn or cry artifacts
subj_info.artifact_epochs_to_delete=[];
% ADJUST-identified artifact components
subj_info.adjust_artifact_comps=[];

base_dir='/data/infant_9m_face_eeg/';
output_dir=fullfile(base_dir,'preprocessed',num2str(subj_id),'exe_aligned');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

raw_events=pop_loadset('filepath',fullfile(base_dir,'preprocessed',num2str(subj_id)), 'filename',sprintf('%d.events.set',subj_id));

% Add movement artifact events
raw_events=add_movement_events(subj_id, raw_events, behavior_file);

% Filter
filtered = pop_eegfiltnew(raw_events, subj_info.lower_freq_limit, subj_info.upper_freq_limit);
filtered = pop_saveset(filtered,'filepath',output_dir,'filename',[num2str(subj_id) '.filtered.set']);

% Read impedance file to determine channels to reject
subj_info.channels_to_remove={};
% Check if impedance file exists
if exist(fullfile(base_dir,'raw',num2str(subj_id),[num2str(subj_id) '-impedances.txt']), 'file') == 2
    % Load and read impedance file
    imp_fid=fopen(fullfile(base_dir,'raw',num2str(subj_id),[num2str(subj_id) '-impedances.txt']));
    imp=textscan(imp_fid,'%s','Delimiter','\r\n','CollectOutput',true);

    % Loop through each line, starting at line 4 and ignoring last two lines
    for i=4:length(imp{1})-2
        % Split the line using " : " as delimiter
        cols=regexp(imp{1}{i},' : ','split');
        % Get the channel number
        channel=str2num(cols{1});
        % Get impedance
        impedance=str2num(cols{2});

        % If impedance greater than threshold
        if impedance>subj_info.impedance_thresh
            % Add channel label to list of channels to remove
            subj_info.channels_to_remove{end+1}=filtered.chanlocs(channel).labels;
        end
    end
end
    
% Remove channels with high impedances
ch_reject = pop_select(filtered,'nochannel',subj_info.channels_to_remove);
ch_reject = pop_saveset(ch_reject,'filepath',output_dir,'filename',[num2str(subj_id) '.channel_reject.set']);

% Extract epochs
epochs = pop_epoch(ch_reject, {'artifact'}, subj_info.epoch_limits, ...
    'epochinfo', 'yes');
epochs = pop_saveset(epochs,'filepath',output_dir,'filename',...
    sprintf('%d.exe.epochs.set', subj_id));

% Epoch rejection
% Number of channels remaining
num_channels=size(epochs.data,1);
% Call EEG thresh
[Itmp Irej NS Erejtmp] = eegthresh(epochs.data, epochs.pnts, ...
    [1:num_channels], subj_info.lower_channel_thresh, ...
    subj_info.upper_channel_thresh, [epochs.xmin epochs.xmax], ...
    epochs.xmin, epochs.xmax);
num_affected_trials=size(Erejtmp,2);
% Looping through all trials with bad channels
for i=1:num_affected_trials
    % Get actual trial number - out of all trials (not just ones with bad
    % channels
    trial_num=Irej(i);
    % Get number of bad channels for this trial
    affected_channels=sum(Erejtmp(:,i));

    % If percentage of bad channels > 15% then reject trial
    if affected_channels/num_channels>subj_info.prop_bad_channel_thresh
        subj_info.ch_epochs_to_delete(end+1)=trial_num;
    end
end

% Remove epochs with no attention artifacts
% Iterate through each epoch
for i=1:length(epochs.epoch)
    if iscell(epochs.epoch(i).eventtype)>0
        for j=1:length(epochs.epoch(i).eventtype)
            if strcmp(epochs.epoch(i).eventcode{j},'noat')
                subj_info.artifact_epochs_to_delete(end+1)=i;
            end
        end
    else
        if strcmp(epochs.epoch(i).eventcode,'noat')
            subj_info.artifact_epochs_to_delete(end+1)=i;
        end
    end
end

epochs_to_delete=union(subj_info.ch_epochs_to_delete, ...
    subj_info.artifact_epochs_to_delete);
try
    epoch_reject = pop_rejepoch(epochs, epochs_to_delete ,0);
    epoch_reject=pop_saveset(epoch_reject,'filepath',output_dir,...
        'filename',sprintf('%d.exe.epoch_reject.set' , subj_id));

    % Run ICA
    ica = pop_runica(epoch_reject, 'extended',1,'interupt','on');
    ica = pop_saveset(ica,'filepath',output_dir,'filename',...
        sprintf('%d.exe.ica.set', subj_id));

    % Run adjust
    adjust_report_fname=fullfile(output_dir, ...
        sprintf('%d.exe.adust_report.txt', subj_id));
    [subj_info.adjust_artifact_comps, horiz, vert, blink, disc, soglia_DV, ...
        diff_var, soglia_K, med2_K, meanK, soglia_SED, med2_SED, SED, ...
        soglia_SAD, med2_SAD, SAD, soglia_GDSF, med2_GDSF, GDSF, soglia_V, ...
        med2_V, nuovaV, soglia_D, maxdin]=ADJUST(ica, adjust_report_fname);

    % Reject adjust-identified components
    ica_pruned = pop_subcomp(ica, subj_info.adjust_artifact_comps);
    ica_pruned = pop_saveset(ica_pruned,'filepath',output_dir,'filename',...
        sprintf('%d.exe.ica_pruned.set', subj_id));

    % Interpolate missing channels
    interp = pop_interp(ica_pruned, ica_pruned.urchanlocs, 'spherical');
    interp = pop_saveset(interp,'filepath',output_dir,'filename',...
        sprintf('%d.exe.interp.set', subj_id));

    % Rereference
    reref = pop_reref(interp, []);
    reref = pop_saveset(reref,'filepath',output_dir,'filename',...
        sprintf('%d.exe.reref.set', subj_id));
catch
end
save(fullfile(output_dir, 'subj_info.exe.mat'),'subj_info');