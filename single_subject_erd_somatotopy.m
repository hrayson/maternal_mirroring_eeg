% age - age ('6m' or '9m')
% conditions - list of conditions ({'shuffled','unshuffled_congruent','unshuffled_incongruent'})
% time_zero_event - event at time zero ('mov1')
% foi - frequencies of interest ([6 9])
% wois - windows of interest
% freq_range - freqency range to run ERSP on
% nfreqs - num frequencies to run ERSP on
% time_window - time window to run ERSP on
% min_trials - min trials per session
function [data_vector chanlocs]=single_subject_erd_somatotopy(subj_id, conditions, file_ext, foi, wois, varargin)

% Parse inputs
defaults=struct('subj_dir_ext','','freq_range', [2 35], 'nfreqs', 100, 'ntimesout', 800, 'threshold', false, 'plot', true, 'baseline', [-500 0]);
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

subj_dir=fullfile('/data','infant_9m_face_eeg', 'preprocessed', num2str(subj_id), params.subj_dir_ext);

data_vector=zeros(length(conditions),size(wois,1),length(clusters));
    
% For each condition
for condition_idx=1:length(conditions)
    condition=conditions{condition_idx};
    data=pop_loadset(fullfile(subj_dir, [num2str(subj_id) '.' condition '.' file_ext '.set']));
    
    % For each cluster
    for cluster_idx=1:length(clusters)
        
        [ersp times freqs]=cluster_ersp(data, clusters(cluster_idx).channels, params.baseline, 'freq_range', params.freq_range, 'nfreqs', params.nfreqs, 'ntimesout', params.ntimesout);
        foi_idx=intersect(find(round(freqs)>=foi(1)),find(round(freqs)<=foi(2)));

        % Go through each WOI
        for woi_idx=1:size(wois,1)
            time_idx=intersect(find(times>=wois(woi_idx,1)),find(times<=wois(woi_idx,2))); 
            woi_ersp=squeeze(ersp(foi_idx,time_idx));
            data_vector(condition_idx,woi_idx,cluster_idx)=mean(woi_ersp(:));
        end
    end
end


chanlocs=data.chanlocs;

if length(data_vector)>0 && params.plot
    map_lim=[min(data_vector(:)) max(data_vector(:))];
    for condition_idx=1:length(conditions);
        figure('Position',[1 1 1855 629]);
        for woi_idx=1:size(wois,1)
            if size(wois,1)>1
                subplot(2,round(ceil(size(wois,1)/2)),woi_idx);
            end
            topoplot(squeeze(data_vector(condition_idx,woi_idx,:)), data.chanlocs, 'maplimits',map_lim,'chaninfo',data.chaninfo);
            title([num2str(subj_id) ' ' conditions{condition_idx} ':' num2str(wois(woi_idx,1)) '-' num2str(wois(woi_idx,2)) 'ms']);
        end
        colorbar();
    end
end

