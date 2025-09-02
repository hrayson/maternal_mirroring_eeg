
function clusters=single_subject_erd(subj_id, conditions, file_ext, foi, woi, varargin)

% Parse inputs
defaults=struct('subj_dir_ext','','freq_range', [2 35], 'nfreqs', 100, 'clusters', [], 'ntimesout', 800, 'plot', true, 'baseline', [-500 0]);

params=struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

if length(params.clusters)==0
    % Initialize clusters
    clusters(1).name='C3';
    clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
 
    clusters(2).name='C4';
    clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};

    clusters(3).name='O1';
    clusters(3).channels={'E69', 'E70', 'E73', 'E74'};

    clusters(4).name='O2';
    clusters(4).channels={'E83', 'E82', 'E89', 'E88'};
else
    for i=1:length(params.clusters)
        clusters(i).name=params.clusters(i).name;
        clusters(i).channels=params.clusters(i).channels;
    end
end

cluster_labels={};
for i=1:length(clusters)
    clusters(i).erd=dict();
    cluster_labels{i}=clusters(i).name;
end

subj_dir=fullfile('/data','infant_9m_face_eeg','preprocessed',num2str(subj_id),params.subj_dir_ext);
        
all_ersps=zeros(length(conditions),length(clusters),params.nfreqs,params.ntimesout);

for condition_idx=1:length(conditions)
    condition=conditions{condition_idx};

    data=pop_loadset(fullfile(subj_dir, [num2str(subj_id) '.' condition '.' file_ext '.set']));    
    
    % For each cluster
    for cluster_idx=1:length(clusters)

        clusters(cluster_idx).erd(condition)=cluster_erd(data, clusters(cluster_idx).channels, foi, woi, params.baseline, 'freq_range', params.freq_range, 'nfreqs', params.nfreqs, 'ntimesout', params.ntimesout);
    end
end

if params.plot
    figure('Position',[1 1 1200 389]);
    cluster_means=[];
    for cluster_idx=1:length(clusters)
        condition_means=[];
        for condition_idx=1:length(conditions)
            condition=conditions{condition_idx};
            condition_means(end+1)=clusters(cluster_idx).erd(condition);
        end
        cluster_means(end+1,:)=condition_means;
    end
    bar(cluster_means);    
    set(gca,'XTickLabel',cluster_labels);
    title([num2str(subj_id) ': ' num2str(foi(1)) '-' num2str(foi(2)) 'Hz, ' num2str(woi(1)) '-' num2str(woi(2)) 'ms']);
    legend(conditions);
end

