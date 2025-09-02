function all_subjects_tf(freq_range, baseline, varargin)

% Parse inputs
defaults=struct('subj_dir_ext','');
params=struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54', 'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};

[included_subjects excluded_subjects]=exclude_subjects(3, 'subj_dir_ext', params.subj_dir_ext)

tf=[];
for j=1:length(included_subjects)
    subj_id=included_subjects(j);
    subj_dir=fullfile('/data','infant_9m_face_eeg','preprocessed',num2str(subj_id), 'exe_aligned', params.subj_dir_ext);

    subj_tf=[];
    data=pop_loadset(fullfile(subj_dir, [num2str(subj_id) '.exe.reref.set']));    
    chan_x=[];
    for chan_idx=1:length(channels)
        [x times freqs]=std_ersp(data, 'type', 'ersp', 'trialindices', [1:data.trials], 'cycles', 0, 'nfreqs', 100, 'ntimesout', 400, 'freqs', freq_range, 'freqscale', 'linear', 'channels', {channels{chan_idx}}, 'baseline', baseline, 'savefile', 'off', 'winsize',128, 'padratio', 16, 'verbose', 'off');
        chan_x(chan_idx,:,:)=x;
    end
    tf(j,:,:)=squeeze(mean(chan_x));
end

figure();
imagesc(times, freqs, squeeze(mean(tf)));
set(gca,'YDir','normal');
xlabel('Time');
ylabel('Frequency');
colorbar();
