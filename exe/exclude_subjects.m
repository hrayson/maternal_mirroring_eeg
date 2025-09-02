function [included_subjects excluded_subjects]=exclude_subjects(min_trials, varargin)

% Parse inputs
defaults=struct('subj_dir_ext','');
params=struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

base_dir=fullfile('/data/infant_9m_face_eeg');
d = dir(fullfile(base_dir, 'preprocessed'));
isub = [d(:).isdir]; % returns logical vector
subj_ids = {d(isub).name}';
subj_ids(ismember(subj_ids,{'.','..'})) = [];

included_subjects=[];
excluded_subjects=[];
for i=1:length(subj_ids)
    subj_id=str2num(subj_ids{i});
    subj_dir=fullfile(base_dir,'preprocessed', num2str(subj_id), 'exe_aligned', params.subj_dir_ext);
    exclude=1;
    if exist(subj_dir,'dir')        
        file_name=fullfile(subj_dir, sprintf('%d.exe.reref.set', subj_id));
        if exist(file_name, 'file') == 2
            data=pop_loadset(file_name);
            num_trials=data.trials;
            if num_trials>=min_trials
                exclude=0;
            end
        end
    end
    if exclude<1
        included_subjects(end+1)=subj_id;
    else
        excluded_subjects(end+1)=subj_id;
    end
end

