function check_coded_exe_obs_corr(conditions)

clusters(1).name='C3';
clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
 
clusters(2).name='C4';
clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};


clusters(1).name='C3';
clusters(1).channels={'E30', 'E31', 'E36', 'E37', 'E41', 'E42', 'E53', 'E54'};
clusters(2).name='C4';
clusters(2).channels={'E79', 'E80', 'E86', 'E87', 'E93', 'E103', 'E104', 'E105'};

base_dir=fullfile('/data','infant_9m_face_eeg');

[included_subjects excluded_subjects]=exclude_subjects(conditions, 'nomove', 5, 'subj_dir_ext', 'ica_optimized4')


cluster_mu_erds=zeros(length(clusters),length(conditions),length(included_subjects));
subj_exes=zeros(length(conditions),length(included_subjects));
for i=1:length(clusters)
    clusters(i).mu_erds=dict;
    clusters(i).mu_mean_erds=dict;
end
for j=1:length(included_subjects)
    subj_id=included_subjects(j);
    subj_clusters=single_subject_erd(subj_id, conditions, 'nomove', [6 9], [0 750], 'subj_dir_ext', 'ica_optimized4', 'freq_range', [2 35], 'nfreqs', 100, 'clusters', clusters, 'ntimesout', 400, 'plot', false, 'baseline', [-650 0]);
    for cluster_idx=1:length(subj_clusters)
        for condition_idx=1:length(conditions)
            condition=conditions{condition_idx};
            cluster_mu_erds(cluster_idx,condition_idx,j)=subj_clusters(cluster_idx).erd(condition);
        end
    end
    for condition_idx=1:length(conditions)
        try
            data=pop_loadset(fullfile(base_dir, 'preprocessed', num2str(subj_id), 'ica_optimized', [num2str(subj_id) '.' conditions{condition_idx}  '.move.set']));
            subj_exes(condition_idx,j)=data.trials;
        catch
        end
    end
end

for c=1:length(conditions)
    figure();
    plot(subj_exes(c,:),squeeze(cluster_mu_erds(1,c,:)),'o');
    xlabel(sprintf('Number %s execution', conditions{c}));
    ylabel(sprintf('C3 mu ERD: %s', conditions{c}));
    [rho,p]=corr(subj_exes(c,:)',squeeze(cluster_mu_erds(1,c,:)),'type','Spearman');
    disp(sprintf('C3 %s: rho=%.3f, p=%.3f', conditions{c}, rho, p));

    figure();
    plot(subj_exes(c,:),squeeze(cluster_mu_erds(2,c,:)),'o');
    xlabel(sprintf('Number %s execution', conditions{c}));
    ylabel(sprintf('C4 mu ERD: %s', conditions{c}));
    [rho,p]=corr(subj_exes(c,:)',squeeze(cluster_mu_erds(2,c,:)),'type','Spearman');
    disp(sprintf('C4 %s: rho=%.3f, p=%.3f', conditions{c}, rho, p));

    figure();
    plot(subj_exes(c,:),squeeze(mean(cluster_mu_erds(:,c,:),1)),'o');
    xlabel(sprintf('Number %s execution', conditions{c}));
    ylabel(sprintf('C mu ERD: %s', conditions{c}));
    [rho,p]=corr(subj_exes(c,:)',squeeze(mean(cluster_mu_erds(:,c,:),1)),'type','Spearman');
    disp(sprintf('C %s: rho=%.3f, p=%.3f', conditions{c}, rho, p));

end

figure();
plot(sum(subj_exes,1), squeeze(mean(cluster_mu_erds(1,:,:),2)),'o');
xlabel('Number executions');
ylabel('C3 mu ERD');
[rho,p]=corr(sum(subj_exes,1)',squeeze(mean(cluster_mu_erds(1,:,:),2)),'type','Spearman');
disp(sprintf('C3: rho=%.3f, p=%.3f', rho, p));

figure();
plot(sum(subj_exes,1), squeeze(mean(cluster_mu_erds(2,:,:),2)),'o');
xlabel('Number executions');
ylabel('C4 mu ERD');
[rho,p]=corr(sum(subj_exes,1)',squeeze(mean(cluster_mu_erds(2,:,:),2)),'type','Spearman');
disp(sprintf('C4: rho=%.3f, p=%.3f', rho, p));

figure();
plot(sum(subj_exes,1), squeeze(mean(mean(cluster_mu_erds(:,:,:),1),2)),'o');
xlabel('Number executions');
ylabel('C mu ERD');
[rho,p]=corr(sum(subj_exes,1)',squeeze(mean(mean(cluster_mu_erds(2,:,:),1),2)),'type','Spearman');
disp(sprintf('C: rho=%.3f, p=%.3f', rho, p));


