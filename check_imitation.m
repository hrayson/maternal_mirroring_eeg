function check_imitation(conditions)

base_dir=fullfile('/data','infant_9m_face_eeg');

[included_subjects excluded_subjects]=exclude_subjects(conditions, 'nomove', 5, 'subj_dir_ext', 'ica_optimized4')

subj_exes=zeros(length(conditions),length(included_subjects));
subj_imis=zeros(length(conditions),length(included_subjects));
perc_exe_imi=zeros(length(conditions),length(included_subjects));
for k=1:length(conditions)
    for j=1:length(included_subjects)
        subj_id=included_subjects(j);
        try
            exe=pop_loadset(fullfile(base_dir, 'preprocessed', num2str(subj_id), 'ica_optimized', [num2str(subj_id) '.' conditions{k}  '.move.set']));
            subj_exes(k,j)=exe.trials;
        catch
        end
        try
            imi=pop_loadset(fullfile(base_dir, 'preprocessed', num2str(subj_id), 'ica_optimized', [num2str(subj_id) '.' conditions{k}  '.imitation.set']));
            subj_imis(k,j)=imi.trials;
        catch
        end
        %if subj_exes(k,j)>0
        %    perc_exe_imi(k,j)=subj_imis(k,j)./subj_exes(k,j);
        %end
        perc_exe_imi(k,:)=subj_imis(k,:)./subj_exes(k,:);
    end
        
end

overall_perc_exe_imi=sum(subj_imis,1)./sum(subj_exes,1);
unshuffled_perc_exe_imi=sum(subj_imis(1:3,:),1)./sum(subj_exes(1:3,:),1);

figure();
means=[];
stderrs=[];
for j=1:length(conditions)
    means(j)=mean(subj_exes(j,:));
    stderrs(j)=std(subj_exes(j,:))/sqrt(length(included_subjects));
end
means(end+1)=mean(sum(subj_exes(1:3,:),1));
stderrs(end+1)=std(sum(subj_exes(1:3,:),1))/sqrt(length(included_subjects));
means(end+1)=mean(sum(subj_exes,1));
stderrs(end+1)=std(sum(subj_exes,1))/sqrt(length(included_subjects));

[h herr]=barwitherr(stderrs, means);
label_conditions=conditions;
label_conditions{end+1}='unshuffled';
label_conditions{end+1}='overall';
set(gca,'XTickLabel',label_conditions);
title('# of Executions');

figure();
means=[];
stderrs=[];
for j=1:length(conditions)
    means(j)=mean(subj_imis(j,:));
    stderrs(j)=std(subj_imis(j,:))/sqrt(length(included_subjects));
end
means(end+1)=mean(sum(subj_imis(1:3,:),1));
stderrs(end+1)=std(sum(subj_imis(1:3,:),1))/sqrt(length(included_subjects));
means(end+1)=mean(sum(subj_imis,1));
stderrs(end+1)=std(sum(subj_imis,1))/sqrt(length(included_subjects));

[h herr]=barwitherr(stderrs, means);
label_conditions=conditions;
label_conditions{end+1}='unshuffled';
label_conditions{end+1}='overall';
set(gca,'XTickLabel',label_conditions);
title('# of Imitations');

figure();
means=[];
stderrs=[];
for j=1:length(conditions)
    means(j)=nanmean(perc_exe_imi(j,:));
    stderrs(j)=nanstd(perc_exe_imi(j,:))/sqrt(length(included_subjects));
end
means(end+1)=nanmean(unshuffled_perc_exe_imi);
stderrs(end+1)=nanstd(unshuffled_perc_exe_imi)/sqrt(length(included_subjects));
means(end+1)=nanmean(overall_perc_exe_imi);
stderrs(end+1)=nanstd(overall_perc_exe_imi)/sqrt(length(included_subjects));

[h herr]=barwitherr(stderrs, means);
label_conditions=conditions;
label_conditions{end+1}='unshuffled';
label_conditions{end+1}='overall';
set(gca,'XTickLabel',label_conditions);
title('% of Executions that are Imitation');


