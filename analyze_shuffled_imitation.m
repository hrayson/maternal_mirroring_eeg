function analyze_shuffled_imitation(conditions)

base_dir=fullfile('/data','infant_9m_face_eeg');
d = dir(fullfile(base_dir, 'preprocessed'));
isub = [d(:).isdir]; % returns logical vector
subjects = {d(isub).name}';
subjects(ismember(subjects,{'.','..'})) = [];
subj_ids=[];
for i=1:length(subjects)
    subj_ids(i)=str2num(subjects{i});
end

nsubjs=length(subj_ids);
nconds=length(conditions);
subj_trials=zeros(nconds,nsubjs);
subj_exe=zeros(nconds,nsubjs);
subj_imi=zeros(nconds,nsubjs);
for subj_idx=1:nsubjs
    EEG=pop_loadset(fullfile('/data/infant_9m_face_eeg/preprocessed',num2str(subj_ids(subj_idx)), sprintf('%d.mov1.epochs.set',subj_ids(subj_idx))));
    for cond_idx=1:length(conditions)
        condition=conditions{cond_idx};
        code='';
        if strcmp(condition,'happy')
            code='joy';
        elseif strcmp(condition,'sad')
            code='sad';
        elseif strcmp(condition,'movement')
            code='move';
        elseif strcmp(condition,'shuffled')
            code='shuf';
        end
        % Get condition trials
        condEEG = pop_selectevent( EEG, 'type',{'mov1'},'code',{code},'deleteevents','off','deleteepochs','on','invertepochs','off');
            
        % Get execution
        try
            exe = pop_selectevent( condEEG, 'type',{'artifact'},'deleteevents','off','deleteepochs','on','invertepochs','off');
            exe_count=0;
            imi_count=0;
            for epoch_idx=1:length(exe.epoch)
                epoch=exe.epoch(epoch_idx);
                trial_type='';
                movement_type='';
                for evt_idx=1:length(epoch.eventtype)
                    if strcmp(epoch.eventtype{evt_idx},'mov1')
                        trial_type=epoch.eventmovement{evt_idx};
                    elseif strcmp(epoch.eventtype{evt_idx},'artifact') && ~strcmp(epoch.eventcode{evt_idx},'noat')
                        movement_type=epoch.eventmovement{evt_idx};
                        break
                    end
                end
                if length(movement_type)
                    exe_count=exe_count+1;
                end
                if (strcmp(trial_type,'smil') && strcmp(movement_type,'J')) || (strcmp(trial_type,'mopn') && strcmp(movement_type,'MO')) || (strcmp(trial_type,'frwn') && strcmp(movement_type,'S'))
                    imi_count=imi_count+1;
                end
            end
            subj_exe(cond_idx,subj_idx)=exe_count;
            subj_imi(cond_idx,subj_idx)=imi_count;
        catch
        end
        subj_trials(cond_idx,subj_idx)=condEEG.trials;    
    end
end

subj_imi./subj_exe