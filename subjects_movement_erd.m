
function subjects_movement_erd(conditions, file_ext, foi, woi, min_trials, varargin)

% Parse inputs
defaults=struct('subj_dir_ext','','freq_range', [2 35], 'nfreqs', 100, 'ntimesout', 800, 'plot', true, 'baseline', [-500 0]);
params=struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

% Initialize clusters
clusters(1).name='C3';
clusters(1).hemisphere='left';
clusters(1).region='central';
clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
 
clusters(2).name='C4';
clusters(2).hemisphere='right';
clusters(2).region='central';
clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};

clusters(3).name='O1';
clusters(3).hemisphere='left';
clusters(3).region='occipital';
clusters(3).channels={'E69', 'E70', 'E73', 'E74'};

clusters(4).name='O2';
clusters(4).hemisphere='right';
clusters(4).region='occipital';
clusters(4).channels={'E83', 'E82', 'E89', 'E88'};

% Initialize ERDs for each condition, cluster, and woi
cluster_labels={};
for cluster_idx=1:length(clusters)
    cluster_labels{end+1}=clusters(cluster_idx).name;
    clusters(cluster_idx).mu_mean_erds=dict;
    for condition_idx=1:length(conditions)
        clusters(cluster_idx).mu_mean_erds(conditions{condition_idx})=[];
    end
end

base_dir=fullfile('/data','infant_9m_face_eeg');

base_dir=fullfile('/data','infant_9m_face_eeg');
d = dir(fullfile(base_dir, 'preprocessed'));
isub = [d(:).isdir]; % returns logical vector
subj_ids = {d(isub).name}';
subj_ids(ismember(subj_ids,{'.','..'})) = [];

included_subjects=[];
for i=1:length(subj_ids)
    subj_id=str2num(subj_ids{i});
    included_subjects=[included_subjects subj_id];
end

trials_per_condition=zeros(length(conditions),length(included_subjects));

% For each cluster
for cluster_idx=1:length(clusters)

    for condition_idx=1:length(conditions)
        condition=conditions{condition_idx};
        condition_mu_erds=[];
        for subj_idx=1:length(included_subjects)
            subj_id=included_subjects(subj_idx);
            subj_dir=fullfile('/data','infant_9m_face_eeg','preprocessed',num2str(subj_id),params.subj_dir_ext);
            file_name=fullfile(subj_dir, [num2str(subj_id) '.' condition '.' file_ext '.set']);
            if exist(file_name,'file')
                data=pop_loadset(file_name); 
                trials_per_condition(condition_idx,subj_idx)=data.trials;   
                if data.trials>=min_trials    
                    mu_erd=cluster_erd(data, clusters(cluster_idx).channels, foi, woi, params.baseline, 'freq_range', params.freq_range, 'nfreqs', params.nfreqs, 'ntimesout', params.ntimesout);
                    condition_mu_erds=[condition_mu_erds mu_erd];
                end
            end
        end
        clusters(cluster_idx).mu_mean_erds(condition)=condition_mu_erds;
    end
end

for condition_idx=1:length(conditions)
    condition=conditions{condition_idx};
    disp([condition ': ' num2str(min(trials_per_condition(condition_idx,:))) '-' num2str(max(trials_per_condition(condition_idx,:))) ', M=' num2str(mean(trials_per_condition(condition_idx,:))) ', SD=' num2str(std(trials_per_condition(condition_idx,:)))]);
end

if params.plot
    figure('Position',[1 1 1200 389]);
    cluster_means=[];
    cluster_stderrs=[];
    cluster_n=[];
    for cluster_idx=1:length(clusters)
        condition_means=[];
        condition_stderrs=[];
        condition_n=[];
        for condition_idx=1:length(conditions)
            condition=conditions{condition_idx};
            condition_means(end+1)=mean(clusters(cluster_idx).mu_mean_erds(condition));
            condition_stderrs(end+1)=std(clusters(cluster_idx).mu_mean_erds(condition))/sqrt(length(clusters(cluster_idx).mu_mean_erds(condition)));
            condition_n(end+1)=length(clusters(cluster_idx).mu_mean_erds(condition));
        end
        cluster_means(end+1,:)=condition_means;
        cluster_stderrs(end+1,:)=condition_stderrs;
        cluster_n(end+1,:)=condition_n;
    end
    [h herr]=barwitherr(cluster_stderrs, cluster_means);
    hold on;
    for condition_idx=1:length(conditions)
        condition=conditions{condition_idx};
        xdata=get(get(herr(condition_idx),'children'),'xdata');
        ydata=get(get(herr(condition_idx),'children'),'ydata');
        clusterx=cell2mat(xdata(1));
        clustery=cell2mat(ydata(2));
        for cluster_idx=1:length(clusters)
            [h,p,ci,stats]=ttest(clusters(cluster_idx).mu_mean_erds(condition));
            disp([condition '-' clusters(cluster_idx).name ', N=' num2str(length(clusters(cluster_idx).mu_mean_erds(condition))) ', M=' num2str(cluster_means(cluster_idx,condition_idx)) ', SD=' num2str(cluster_stderrs(cluster_idx,condition_idx)*sqrt(cluster_n(cluster_idx,condition_idx))) ', t=' num2str(stats.tstat) ', df=' num2str(stats.df) ', p=' num2str(p)]);
            if p<=0.05                
                x=clusterx(cluster_idx)-.035;
                y1=clustery((cluster_idx-1)*9+1);
                y2=clustery((cluster_idx-1)*9+2);
                y=y1+1;
                if y1<0 && y2<0
                    y=y2-1;
                end
                text(x, y, '*', 'VerticalAlignment', 'top', 'FontSize', 18);
            end
        end
    end
    hold off;
    set(gca,'XTickLabel',cluster_labels);
    title([num2str(foi(1)) '-' num2str(foi(2)) 'Hz, ' num2str(woi(1)) '-' num2str(woi(2)) 'ms']);
    legend(conditions);
end

