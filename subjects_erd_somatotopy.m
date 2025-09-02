% ages - list of ages ('6m' or '9m')
% time_zero_event - event at time zero ('mov1')
% foi - frequencies of interest ([6 9])
% wois - windows of interest
% freq_range - freqency range to run ERSP on
% nfreqs - num frequencies to run ERSP on
% time_window - time window to run ERSP on
% min_trials - min trials per session
function subjects_erd_somatotopy(conditions, file_ext, foi, wois, min_trials, varargin)

% Parse inputs
defaults=struct('subj_dir_ext','','subj_ids',[],'freq_range', [2 35], 'nfreqs', 100, 'ntimesout', 800, 'baseline', [-500 0], 'map_lim', []);
params=struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

% Make cluster for each channel
for cluster_idx=1:128
    clusters(cluster_idx).name=['E' num2str(cluster_idx)];
    clusters(cluster_idx).channels={['E' num2str(cluster_idx)]};
end

data_vector=zeros(length(conditions),size(wois,1),128);

base_dir=fullfile('/data','infant_9m_face_eeg');

% Filter subjects
if length(params.subj_ids)==0
    [included_subjects excluded_subjects]=exclude_subjects(conditions, file_ext, min_trials, 'subj_dir_ext', params.subj_dir_ext)
else
    included_subjects=params.subj_ids;
    excluded_subjects=[];
end

for cond_idx=1:length(conditions)
    % Initialize ERDs for each condition, cluster, and woi
    all_erds=[];
    for cluster_idx=1:length(clusters)
        for woi_idx=1:size(wois,1)
            all_erds(cluster_idx,woi_idx).subj_erds=[];
        end
    end

    % For each included subject
    for subj_idx=1:length(included_subjects)
        subj_id=included_subjects(subj_idx);
        subj_dir_ext=params.subj_dir_ext;
        [subj_data_vector chanlocs]=single_subject_erd_somatotopy(subj_id, {conditions{cond_idx}}, file_ext, foi, wois, 'subj_dir_ext', subj_dir_ext, 'freq_range', params.freq_range, 'nfreqs', params.nfreqs, 'ntimesout', params.ntimesout, 'threshold', false, 'plot', false, 'baseline', params.baseline);
        for cluster_idx=1:length(clusters)
            for woi_idx=1:size(wois,1)
                all_erds(cluster_idx, woi_idx).subj_erds=[all_erds(cluster_idx, woi_idx).subj_erds subj_data_vector(1, woi_idx, cluster_idx)];
            end
        end
    end

    for woi_idx=1:size(wois,1)
        for cluster_idx=1:length(clusters)
            data_vector(cond_idx,woi_idx,cluster_idx)=mean(all_erds(cluster_idx,woi_idx).subj_erds);
        end
    end
end

absmax=0;

if length(params.map_lim)==0
    params.map_lim=[min(data_vector(:)) max(data_vector(:))];
end


for condition_idx=1:length(conditions);
    figure('Position',[1 1 1855 629]);
    for woi_idx=1:size(wois,1)
        if size(wois,1)>1
            subplot(2,round(ceil(size(wois,1)/2)),woi_idx);
        end
        topoplot(squeeze(data_vector(condition_idx,woi_idx,:)), chanlocs, 'maplimits', params.map_lim, 'electrodes', 'pts');
        title([conditions{condition_idx} '-' num2str(wois(woi_idx,1)) '-' num2str(wois(woi_idx,2)) 'ms']);
    end    
    colorbar();
end

