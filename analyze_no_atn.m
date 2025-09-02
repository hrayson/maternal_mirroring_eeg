function analyze_no_atn()

[included_subjects excluded_subjects]=exclude_subjects({'movement','happy','sad','shuffled'}, 'nomove', 5, 'subj_dir_ext', 'ica_optimized4')

condition_prop_noatn=dict();
condition_dur_noatn=dict();
conditions={'happy','mouthopen','shuffled','sad'};
    
for subj_idx=1:length(included_subjects)
    subj_id=included_subjects(subj_idx);
    epochs = pop_loadset('filepath',['/data/infant_9m_face_eeg/preprocessed/' num2str(subj_id)],'filename',[num2str(subj_id) '.mov1.epochs.set']);
    subj_condition_num_trials=dict();
    subj_condition_num_noatn=dict();
    subj_condition_dur_noatn=dict();
    for condition_idx=1:length(conditions)
        condition=conditions{condition_idx};
        subj_condition_num_trials(condition)=0;
        subj_condition_num_noatn(condition)=0;
    end
    for epoch_idx=1:length(epochs.epoch)
        condition='';
        has_noat=false;
        dur_noat=0;
        for evt_idx=1:length(epochs.epoch(epoch_idx).eventtype)
            if strcmp(epochs.epoch(epoch_idx).eventtype{evt_idx},'mov1')
                if strcmp(epochs.epoch(epoch_idx).eventcode{evt_idx},'joy')
                    condition='happy';
                elseif strcmp(epochs.epoch(epoch_idx).eventcode{evt_idx},'move')
                    condition='mouthopen';
                elseif strcmp(epochs.epoch(epoch_idx).eventcode{evt_idx},'shuf')
                    condition='shuffled';
                elseif strcmp(epochs.epoch(epoch_idx).eventcode{evt_idx},'sad')
                    condition='sad';
                end
            elseif strcmp(epochs.epoch(epoch_idx).eventcode{evt_idx},'noat')
                has_noat=true;
                dur_noat=dur_noat+epochs.epoch(epoch_idx).eventduration{evt_idx};
            end
        end
        dur_noat=min([epochs.xmax*1000,dur_noat]);
        subj_condition_num_trials(condition)=subj_condition_num_trials(condition)+1;
        if has_noat
            subj_condition_num_noatn(condition)=subj_condition_num_noatn(condition)+1;
        end
        subj_condition_dur_noatn(condition)=[subj_condition_dur_noatn(condition) dur_noat];
    end
    for condition_idx=1:length(conditions)
        condition=conditions{condition_idx};
        condition_prop_noatn(condition)=[condition_prop_noatn(condition) subj_condition_num_noatn(condition)/subj_condition_num_trials(condition)];
        condition_dur_noatn(condition)=[condition_dur_noatn(condition) mean(subj_condition_dur_noatn(condition))];
    end
end
for condition_idx=1:length(conditions)
    condition=conditions{condition_idx};
    disp([condition ': proportion of trials with noatn: ' num2str(min(condition_prop_noatn(condition))) '-' num2str(max(condition_prop_noatn(condition))) ', M=' num2str(mean(condition_prop_noatn(condition))) ', SD=' num2str(std(condition_prop_noatn(condition)))]);
    disp([condition ': duration of noatn: ' num2str(min(condition_dur_noatn(condition))) '-' num2str(max(condition_dur_noatn(condition))) ', M=' num2str(mean(condition_dur_noatn(condition))) ', SD=' num2str(std(condition_dur_noatn(condition)))]);
end



