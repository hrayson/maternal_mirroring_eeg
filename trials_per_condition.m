function trials_per_condition(conditions, file_ext, min_trials, varargin)

% Parse inputs
defaults=struct('subj_dir_ext','');
params=struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

[included_subjects excluded_subjects]=exclude_subjects(conditions, file_ext, min_trials, 'subj_dir_ext', params.subj_dir_ext)

condition_trials=dict();
all_trials=[];
overall_trials=[];
for subj_idx=1:length(included_subjects)
    subj_id=included_subjects(subj_idx);
    subj_dir_ext=params.subj_dir_ext;
    
    subj_dir=fullfile('/data','infant_9m_face_eeg','preprocessed',num2str(subj_id),params.subj_dir_ext);
    subj_all_trials=[];
    subj_overall_trials=0;
    for condition_idx=1:length(conditions)
        condition=conditions{condition_idx};

        data=pop_loadset(fullfile(subj_dir, [num2str(subj_id) '.' condition '.' file_ext '.set']));    
        condition_trials(condition)=[condition_trials(condition) data.trials];
        subj_all_trials=[subj_all_trials data.trials];
        subj_overall_trials=subj_overall_trials+data.trials;
    end
    all_trials=[all_trials mean(subj_all_trials)];
    overall_trials=[overall_trials subj_overall_trials];
end

['Average overall, ' num2str(min(overall_trials)) '-' num2str(max(overall_trials)) ', mean=' num2str(mean(overall_trials)) ', stddev=' num2str(std(overall_trials))]

['Average per condition, ' num2str(min(all_trials)) '-' num2str(max(all_trials)) ', mean=' num2str(mean(all_trials)) ', stddev=' num2str(std(all_trials))]

for condition_idx=1:length(conditions)
    condition=conditions{condition_idx}
    [num2str(min(condition_trials(condition))) '-' num2str(max(condition_trials(condition))) ', mean=' num2str(mean(condition_trials(condition))) ', stddev=' num2str(std(condition_trials(condition)))]
end
