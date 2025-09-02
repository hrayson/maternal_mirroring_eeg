
function subjects_erd(conditions, file_ext, foi, woi, min_trials, varargin)

% Parse inputs
defaults=struct('subj_dir_ext','','subj_ids',[],'freq_range', [2 35], 'nfreqs', 100, 'ntimesout', 800, 'plot', true, 'baseline', [-500 0],'output_file','');
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
all_erds=[];
cluster_labels={};
for cluster_idx=1:length(clusters)
    cluster_labels{end+1}=clusters(cluster_idx).name;
    for condition_idx=1:length(conditions)
        all_erds(condition_idx, cluster_idx).subj_erds=[];
    end
end

base_dir=fullfile('/data','infant_9m_face_eeg');

if length(params.subj_ids)==0
    [included_subjects, excluded_subjects]=exclude_subjects(conditions, file_ext, min_trials, 'subj_dir_ext', params.subj_dir_ext)
else
    included_subjects=params.subj_ids;
    excluded_subjects=[];
end

% For each included subject
for subj_idx=1:length(included_subjects)
    subj_id=included_subjects(subj_idx);
    subj_clusters=single_subject_erd(subj_id, conditions, file_ext, foi, woi, 'subj_dir_ext', params.subj_dir_ext, 'freq_range', params.freq_range, 'nfreqs', params.nfreqs, 'clusters', clusters, 'ntimesout', params.ntimesout, 'plot', false, 'baseline', params.baseline);

    for cluster_idx=1:length(subj_clusters)
        for condition_idx=1:length(conditions)
            condition=conditions{condition_idx};
            all_erds(condition_idx,cluster_idx).subj_erds(subj_idx)=subj_clusters(cluster_idx).erd(condition);
        end
    end
end

if params.plot
    figure('Position',[1 1 1200 389]);
    cluster_means=[];
    cluster_stderrs=[];
    for cluster_idx=1:length(clusters)
        condition_means=[];
        condition_stderrs=[];
        for condition_idx=1:length(conditions)
            condition=conditions{condition_idx};
            condition_means(end+1)=mean(all_erds(condition_idx,cluster_idx).subj_erds);
            condition_stderrs(end+1)=std(all_erds(condition_idx,cluster_idx).subj_erds)/sqrt(length(included_subjects));
        end
        cluster_means(end+1,:)=condition_means;
        cluster_stderrs(end+1,:)=condition_stderrs;
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
            [h,p,ci,stats]=ttest(all_erds(condition_idx,cluster_idx).subj_erds);
            disp([condition '-' clusters(cluster_idx).name ', M=' num2str(cluster_means(cluster_idx,condition_idx)) ', SD=' num2str(cluster_stderrs(cluster_idx,condition_idx)*sqrt(length(included_subjects))) ', t=' num2str(stats.tstat) ', df=' num2str(stats.df) ', p=' num2str(p)]);
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
if length(params.output_file)>0
    analysis_dir=fullfile('/data','infant_9m_face_eeg','analysis');
    fid=fopen(fullfile(analysis_dir,['wide.' params.output_file]),'w');
    title_col='subject';
    for cluster_idx=1:length(clusters)
        for condition_idx=1:length(conditions)
            condition=conditions{condition_idx};
            title_col=[title_col ',' strrep(clusters(cluster_idx).name,' ','') strrep(condition,'_','')];
        end
    end
    fprintf(fid, [title_col '\n']);
    for subj_idx=1:length(included_subjects)
        row=num2str(included_subjects(subj_idx));
        for cluster_idx=1:length(clusters)
            for condition_idx=1:length(conditions)
                condition=conditions{condition_idx};
                row=[row sprintf(',%1.6f',all_erds(condition_idx,cluster_idx).subj_erds(subj_idx))];
            end
        end
        fprintf(fid, [row '\n']);
    end
    fclose(fid);

    fid=fopen(fullfile(analysis_dir,['long.' params.output_file]),'w');
    fprintf(fid, 'subject,hemisphere,region,condition,erd\n');
    for subj_idx=1:length(included_subjects)
        for cluster_idx=1:length(clusters)
            for condition_idx=1:length(conditions)
                condition=conditions{condition_idx};
                fprintf(fid, [num2str(included_subjects(subj_idx)) ',' clusters(cluster_idx).hemisphere ',' clusters(cluster_idx).region ',' condition ',' sprintf('%1.6f',all_erds(condition_idx,cluster_idx).subj_erds(subj_idx)) '\n']);
            end
        end
        
    end
    fclose(fid);
end
