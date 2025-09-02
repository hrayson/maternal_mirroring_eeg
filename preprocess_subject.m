function subj_info=preprocess_subject(subj_id, behavior_file, varargin)
% function subj_info=preprocess_subject(subj_id, age, delay, zero_event, epoch_limits)
% Preprocess a single subject
% INPUT:
%     subj_id: ID of subject to preprocess

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
% Time zero event
subj_info.time_zero_event='mov1';
% Time limits (s) of each epoch
subj_info.epoch_limits=[-1 2];
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
% Number of trials - mouth opening
subj_info.mouth_opening_trials=0;
% Number of trials - happy
subj_info.happy_trials=0;
% Number of trials - sad
subj_info.sad_trials=0;
% Number of trials - shuffled
subj_info.shuffled_trials=0;

% Where to save files
base_dir='/data/infant_9m_face_eeg/';
output_dir=fullfile(base_dir,'preprocessed',num2str(subj_id));
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

if length(params.sessions)==0    
    % Read in Netstation simple binary file and convert to EEGLab format
    raw=pop_readegi(fullfile(base_dir,'raw',num2str(subj_id),[num2str(subj_id) '.raw']));

    % Update channel locations based on EGI electrode location file
    raw_events=update_channel_locations(raw);

    % Adjust time of events based on timing test
    events_to_delete=[];
    event_durations=[];
    for i=1:length(raw_events.event)
        if strcmp(raw_events.event(i).type,'ima1') || strcmp(raw_events.event(i).type,'mov1') || strcmp(raw_events.event(i).type,'mov2')
            raw_events.event(i).latency=raw_events.event(i).latency+params.delay*raw_events.srate;
            event_durations=[event_durations 1];
        else
            events_to_delete=[events_to_delete i];
        end        
    end

    % Delete all events other than mov1 and mov2
    raw_events=pop_editeventvals(raw_events,'delete',events_to_delete);

    % Adjust event durations    
    raw_events=pop_editeventfield(raw_events,'duration',event_durations);

    % Add event codes
    raw_events=pop_editeventfield(raw_events,'actor',fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '-events_actr.evt']));
    raw_events=pop_editeventfield(raw_events,'code',fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '-events_code.evt']));
    raw_events=pop_editeventfield(raw_events,'movement',fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '-events_mvmt.evt']));        

    % Read data header to get start time of recording
    [data_fid,message] = fopen(fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '.raw']),'rb','b');
    data_head=readegihdr(data_fid);
    year = data_head.year;
    month = data_head.month;
    day = data_head.day;
    hour = data_head.hour;
    minute = data_head.minute;
    second = data_head.second;
    millisecond = data_head.millisecond;

    % Add no attention artifact events
    noat_artifacts_fid=fopen(fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '-events_noat.evt']));
    noat_artifacts=textscan(noat_artifacts_fid,'%s','Delimiter','\n','CollectOutput',true);
    disp([num2str(length(noat_artifacts{1})) ' no attention artifacts']);
    for i=1:length(noat_artifacts{1})
        artifact_string=noat_artifacts{1}{i};
        start_hour=str2num(artifact_string(6:7));
        start_min=str2num(artifact_string(9:10));
        start_sec=str2num(artifact_string(12:17));
        dur_hour=str2num(artifact_string(19:20));
        dur_min=str2num(artifact_string(22:23));
        dur_sec=str2num(artifact_string(25:30));
        start_rel=(start_hour*60.0*60.0+start_min*60.0+start_sec);
        if params.relative_noat
            start_rel= start_rel - (hour*60.0*60.0+minute*60.0+second+.001*millisecond);
        end
        duration=dur_hour*60.0*60.0+dur_min*60.0+dur_sec;
        raw_events = pop_editeventvals(raw_events,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'artifact'},'changefield',{2 'latency' start_rel},'changefield',{2 'duration' duration},'changefield',{2 'actor' 'None'},'changefield',{2 'code' 'noat'},'changefield',{2 'movement' 'None'});
    end
    raw_events=pop_saveset(raw_events,'filepath',output_dir,'filename',[num2str(subj_id) '.events.set']);
else
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

    for i=1:length(params.sessions)
        session_num=params.sessions(i);

        % Read in Netstation simple binary file and convert to EEGLab format
        raw=pop_readegi(fullfile(base_dir,'raw',num2str(subj_id),[num2str(subj_id) '-' num2str(session_num) '.raw']));

        % Update channel locations based on EGI electrode location file
        raw_events=update_channel_locations(raw);

        % Adjust time of events based on timing test
        events_to_delete=[];
        event_durations=[];
        for i=1:length(raw_events.event)
            if strcmp(raw_events.event(i).type,'ima1') || strcmp(raw_events.event(i).type,'mov1') || strcmp(raw_events.event(i).type,'mov2')
                raw_events.event(i).latency=raw_events.event(i).latency+params.delay*raw_events.srate;
                event_durations=[event_durations 1];
            else
                events_to_delete=[events_to_delete i];
            end        
        end

        % Delete all events other than mov1 and mov2
        raw_events=pop_editeventvals(raw_events,'delete',events_to_delete);

        % Adjust event durations    
        raw_events=pop_editeventfield(raw_events,'duration',event_durations);

        % Add event codes
        raw_events=pop_editeventfield(raw_events,'actor',fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '-events_actr_' num2str(session_num) '.evt']));
        raw_events=pop_editeventfield(raw_events,'code',fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '-events_code_' num2str(session_num) '.evt']));
        raw_events=pop_editeventfield(raw_events,'movement',fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '-events_mvmt_' num2str(session_num) '.evt']));        

        % Read data header to get start time of recording
        [data_fid,message] = fopen(fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '-' num2str(session_num) '.raw']),'rb','b');
        data_head=readegihdr(data_fid);
        year = data_head.year;
        month = data_head.month;
        day = data_head.day;
        hour = data_head.hour;
        minute = data_head.minute;
        second = data_head.second;
        millisecond = data_head.millisecond;

        % Add no attention artifact events
        noat_artifacts_fid=fopen(fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '-events_noat_' num2str(session_num) '.evt']));
        noat_artifacts=textscan(noat_artifacts_fid,'%s','Delimiter','\n','CollectOutput',true);
        disp([num2str(length(noat_artifacts{1})) ' no attention artifacts']);
        for i=1:length(noat_artifacts{1})
            artifact_string=noat_artifacts{1}{i};
            start_hour=str2num(artifact_string(6:7));
            start_min=str2num(artifact_string(9:10));
            start_sec=str2num(artifact_string(12:17));
            dur_hour=str2num(artifact_string(19:20));
            dur_min=str2num(artifact_string(22:23));
            dur_sec=str2num(artifact_string(25:30));
            start_rel=(start_hour*60.0*60.0+start_min*60.0+start_sec);
            if params.relative_noat
                start_rel= start_rel - (hour*60.0*60.0+minute*60.0+second+.001*millisecond);
            end
            duration=dur_hour*60.0*60.0+dur_min*60.0+dur_sec;
            raw_events = pop_editeventvals(raw_events,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'artifact'},'changefield',{2 'latency' start_rel},'changefield',{2 'duration' duration},'changefield',{2 'actor' 'None'},'changefield',{2 'code' 'noat'},'changefield',{2 'movement' 'None'});
        end
        [ALLEEG, raw_events, CURRENTSET] = eeg_store( ALLEEG, raw_events, 0 );
        raw_events=pop_saveset(raw_events,'filepath',output_dir,'filename',[num2str(subj_id) '_' num2str(session_num) '.events.set']);
    end
    raw_events = pop_mergeset( ALLEEG, [1:length(params.sessions)], 0);
    raw_events=pop_saveset(raw_events,'filepath',output_dir,'filename',[num2str(subj_id) '.events.set']);
end

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
epochs = pop_epoch(ch_reject, {subj_info.time_zero_event}, subj_info.epoch_limits, 'epochinfo', 'yes');
epochs = pop_saveset(epochs,'filepath',output_dir,'filename',[num2str(subj_id) '.' subj_info.time_zero_event '.epochs.set']);

% Epoch rejection
subj_info.ch_epochs_to_delete=[];
% Number of channels remaining
num_channels=size(epochs.data,1);
% Call EEG thresh
[Itmp Irej NS Erejtmp] = eegthresh(epochs.data, epochs.pnts, [1:num_channels], subj_info.lower_channel_thresh, subj_info.upper_channel_thresh, [epochs.xmin epochs.xmax], epochs.xmin, epochs.xmax);
num_affected_trials=size(Erejtmp,2);
% Looping through all trials with bad channels
for i=1:num_affected_trials
    % Get actual trial number - out of all trials (not just ones with bad channels
    trial_num=Irej(i);
    % Get number of bad channels for this trial
    affected_channels=sum(Erejtmp(:,i));

    % If percentage of bad channels > 15% then reject trial
    if affected_channels/num_channels>subj_info.prop_bad_channel_thresh
        subj_info.ch_epochs_to_delete(end+1)=trial_num;
    end
end

% Remove epochs with no attention artifacts
subj_info.artifact_epochs_to_delete=[];
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

epochs_to_delete=union(subj_info.ch_epochs_to_delete, subj_info.artifact_epochs_to_delete);
epoch_reject = pop_rejepoch(epochs, epochs_to_delete ,0);
epoch_reject=pop_saveset(epoch_reject,'filepath',output_dir,'filename',[num2str(subj_id) '.' subj_info.time_zero_event '.epoch_reject.set']);

% Run ICA
ica = pop_runica(epoch_reject, 'extended',1,'interupt','on');
ica = pop_saveset(ica,'filepath',output_dir,'filename',[num2str(subj_id) '.' subj_info.time_zero_event '.ica.set']);

% Run adjust
[subj_info.adjust_artifact_comps, horiz, vert, blink, disc, soglia_DV, diff_var, soglia_K, med2_K, meanK, soglia_SED, med2_SED, SED, soglia_SAD, med2_SAD, SAD, soglia_GDSF, med2_GDSF, GDSF, soglia_V, med2_V, nuovaV, soglia_D, maxdin]=ADJUST(ica, fullfile(output_dir,[num2str(subj_id) '.' subj_info.time_zero_event '.adjust_report.txt']));

% Reject adjust-identified components
ica_pruned = pop_subcomp(ica, subj_info.adjust_artifact_comps);
ica_pruned = pop_saveset(ica_pruned,'filepath',output_dir,'filename',[num2str(subj_id) '.' subj_info.time_zero_event '.ica_pruned.set']);

% Interpolate missing channels
interp = pop_interp(ica_pruned, ica_pruned.urchanlocs, 'spherical');
interp = pop_saveset(interp,'filepath',output_dir,'filename',[num2str(subj_id) '.' subj_info.time_zero_event '.interp.set']);

% Rereference
reref = pop_reref(interp, []);
reref = pop_saveset(reref,'filepath',output_dir,'filename',[num2str(subj_id) '.' subj_info.time_zero_event '.reref.set']);

% Split by trial type
subj_info=split_by_trial_type(subj_id, subj_info, subj_info.time_zero_event, output_dir);

save(fullfile(output_dir,['subj_info.' subj_info.time_zero_event '.mat']),'subj_info');
