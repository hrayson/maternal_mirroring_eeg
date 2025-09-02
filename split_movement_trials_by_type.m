function split_movement_trials_by_type(subj_id, subj_dir_ext)

subj_dir=fullfile('/data/infant_9m_face_eeg/preprocessed/', num2str(subj_id), subj_dir_ext);
file_name=[num2str(subj_id) '.all.move.set'];
if exist(fullfile(subj_dir,file_name),'file')
    all_move=pop_loadset(fullfile(subj_dir, file_name));

    try
        [movement,movement_idx]=pop_selectevent(all_move, 'type', {'artifact'}, 'movement', {'MO'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        movement=pop_saveset(movement,'filepath',subj_dir,'filename',[num2str(subj_id) '.movement.move-same.set']);
    catch
    end

    try
        [happy,happy_idx]=pop_selectevent(all_move, 'type', {'artifact'}, 'movement', {'J'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        happy=pop_saveset(happy,'filepath',subj_dir,'filename',[num2str(subj_id) '.happy.move-same.set']);
    catch
    end

    try
        [sad,sad_idx]=pop_selectevent(all_move, 'type', {'artifact'}, 'movement', {'S'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        sad=pop_saveset(sad,'filepath',subj_dir,'filename',[num2str(subj_id) '.sad.move-same.set']);
    catch
    end
end
