function check_noat()

conditions={'happy','sad','movement','shuffled'};

base_dir=fullfile('/data','infant_9m_face_eeg');

[included_subjects excluded_subjects]=exclude_subjects(conditions, 'nomove', 5, 'subj_dir_ext', 'ica_optimized4')
subj_trials=zeros(length(conditions),length(included_subjects));
subj_noat_trials=zeros(length(conditions),length(included_subjects));

for j=1:length(included_subjects)
    subj_id=included_subjects(j);
    epochs=pop_loadset(fullfile(base_dir, 'preprocessed', num2str(subj_id), [num2str(subj_id) '.mov1.epochs.set']));
    
    % Remove epochs with no attention artifacts
    for i=1:length(epochs.epoch)        
        cond_idx=-1;
        if iscell(epochs.epoch(i).eventtype)>0
            for k=1:length(epochs.epoch(i).eventtype)             
                if strcmp(epochs.epoch(i).eventcode{k},'shuf')
                    cond_idx=4;
                elseif strcmp(epochs.epoch(i).eventcode{k},'sad')
                    cond_idx=2;
                elseif strcmp(epochs.epoch(i).eventcode{k},'move')
                    cond_idx=3;
                elseif strcmp(epochs.epoch(i).eventcode{k},'joy')
                    cond_idx=1;
                end
            end
            subj_trials(cond_idx,j)=subj_trials(cond_idx,j)+1;
            for k=1:length(epochs.epoch(i).eventtype)                
                if strcmp(epochs.epoch(i).eventcode{k},'noat')
                    subj_noat_trials(cond_idx,j)=subj_noat_trials(cond_idx,j)+1;
                end
            end
        else
            if strcmp(epochs.epoch(i).eventcode,'shuf')
                cond_idx=4;
            elseif strcmp(epochs.epoch(i).eventcode,'sad')
                cond_idx=2;
            elseif strcmp(epochs.epoch(i).eventcode,'move')
                cond_idx=3;
            elseif strcmp(epochs.epoch(i).eventcode,'joy')
                cond_idx=1;
            end
            subj_trials(cond_idx,j)=subj_trials(cond_idx,j)+1;
            if strcmp(epochs.epoch(i).eventcode,'noat')
                subj_noat_trials(cond_idx,j)=subj_noat_trials(cond_idx,j)+1;
            end
        end
    end
end

perc_noat=subj_noat_trials./subj_trials;
[p,tbl,stats]=anova1(perc_noat');
disp(sprintf('F(%d,%d)=%.3f, p=%.4f',tbl{2,3},tbl{3,3},tbl{2,5},p));

figure();
means=[];
stderrs=[];
for j=1:length(conditions)
    means(j)=nanmean(perc_noat(j,:));
    stderrs(j)=nanstd(perc_noat(j,:))/sqrt(length(included_subjects));
end
[h herr]=barwitherr(stderrs, means);
set(gca,'XTickLabel',conditions);
title('% of NoAt Trials');