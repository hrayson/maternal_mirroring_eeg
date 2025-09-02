function subj_info=split_by_trial_type(subj_id, subj_info, zero_evt, subj_dir)

    preprocessed=pop_loadset(fullfile(subj_dir,[num2str(subj_id) '.' zero_evt '.reref.set']));
    [preprocessed_nomove,preprocessed_nomove_idx]=pop_selectevent(preprocessed, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'on');

    % Get all with movement - pick all with movement artifacts
    if preprocessed_nomove.trials<preprocessed.trials
        [all_move,all_move_idx]=pop_selectevent(preprocessed, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        all_move=pop_saveset(all_move,'filepath',subj_dir,'filename',[num2str(subj_id) '.all.move.set']);

        all_imitation=remove_nonimitation_epochs(all_move);
        if all_imitation.trials>0
            disp([num2str(subj_id) ' - ' num2str(all_imitation.trials) ' trials']);
            all_imitation=pop_saveset(all_imitation,'filepath',subj_dir,'filename',[num2str(subj_id) '.all.imitation.set']);
        end
    end

    [all_no_move,all_no_move_idx]=pop_selectevent(preprocessed, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'on');
    all_no_move=pop_saveset(all_no_move,'filepath',subj_dir,'filename',[num2str(subj_id) '.all.nomove.set']);

    % Get unshuffled - pick all that are not labeled as shuffled
    [unshuffled,unshuffled_idx]=pop_selectevent(preprocessed, 'type', {'mov1'}, 'omitcode', {'shuf'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');    
    unshuffled=pop_saveset(unshuffled,'filepath',subj_dir,'filename',[num2str(subj_id) '.unshuffled.set']);

    % Get unshuffled without movement - pick all unshuffled without movement artifacts
    [unshuffled_nomove,unshuffled_nomove_idx]=pop_selectevent(unshuffled, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'on');
    unshuffled_nomove=pop_saveset(unshuffled_nomove,'filepath',subj_dir,'filename',[num2str(subj_id) '.unshuffled.nomove.set']);

    % Get unshuffled with movement - pick all unshuffled with movement artifacts    
    if unshuffled_nomove.trials<unshuffled.trials
        [unshuffled_move,unshuffled_move_idx]=pop_selectevent(unshuffled, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        unshuffled_move=pop_saveset(unshuffled_move,'filepath',subj_dir,'filename',[num2str(subj_id) '.unshuffled.move.set']);

        unshuffled_imitation=remove_nonimitation_epochs(unshuffled_move);
        if unshuffled_imitation.trials>0
            unshuffled_imitation=pop_saveset(unshuffled_imitation,'filepath',subj_dir,'filename',[num2str(subj_id) '.unshuffled.imitation.set']);
        end
    end
    
    % Get shuffled - all that are labeled shuffled
    [shuffled,shuffled_idx]=pop_selectevent(preprocessed, 'type', {'mov1'}, 'code', {'shuf'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    shuffled=pop_saveset(shuffled,'filepath',subj_dir,'filename',[num2str(subj_id) '.shuffled.set']);

    % Get shuffled without movement - pick all shuffled without movement artifacts
    [shuffled_nomove,shuffled_nomove_idx]=pop_selectevent(shuffled, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'on');
    shuffled_nomove=pop_saveset(shuffled_nomove,'filepath',subj_dir,'filename',[num2str(subj_id) '.shuffled.nomove.set']);
    subj_info.shuffled_trials=shuffled_nomove.trials;

    % Get shuffled with movement - pick all shuffled with movement artifacts
    if shuffled_nomove.trials<shuffled.trials
        [shuffled_move,shuffled_move_idx]=pop_selectevent(shuffled, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        shuffled_move=pop_saveset(shuffled_move,'filepath',subj_dir,'filename',[num2str(subj_id) '.shuffled.move.set']);

        shuffled_imitation=remove_nonimitation_epochs(shuffled_move);
        if shuffled_imitation.trials>0
            shuffled_imitation=pop_saveset(shuffled_imitation,'filepath',subj_dir,'filename',[num2str(subj_id) '.shuffled.imitation.set']);
        end
    end
    
    % Get emotion - all unshuffled that are not labeled movement
    [emotion,emotion_idx]=pop_selectevent(unshuffled, 'type', {'mov1'}, 'omitcode', {'move'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    emotion=pop_saveset(emotion,'filepath',subj_dir,'filename',[num2str(subj_id) '.emotion.set']);

    % Get emotion without movement - pick all emotion without movement artifacts
    [emotion_nomove,emotion_nomove_idx]=pop_selectevent(emotion, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'on');
    emotion_nomove=pop_saveset(emotion_nomove,'filepath',subj_dir,'filename',[num2str(subj_id) '.emotion.nomove.set']);

    % Get emotion with movement - pick all emotion with movement artifacts
    if emotion_nomove.trials<emotion.trials
        [emotion_move,emotion_move_idx]=pop_selectevent(emotion, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        emotion_move=pop_saveset(emotion_move,'filepath',subj_dir,'filename',[num2str(subj_id) '.emotion.move.set']);

        emotion_imitation=remove_nonimitation_epochs(emotion_move);
        if emotion_imitation.trials>0
            emotion_imitation=pop_saveset(emotion_imitation,'filepath',subj_dir,'filename',[num2str(subj_id) '.emotion.imitation.set']);
        end
    end
    
    % Get happy - all emotion that are labeled joy
    [happy,happy_idx]=pop_selectevent(emotion, 'type', {'mov1'}, 'code', {'joy'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    happy=pop_saveset(happy,'filepath',subj_dir,'filename',[num2str(subj_id) '.happy.set']);

    % Get happy without movement - pick all happy without movement artifacts
    [happy_nomove,happy_nomove_idx]=pop_selectevent(happy, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'on');
    happy_nomove=pop_saveset(happy_nomove,'filepath',subj_dir,'filename',[num2str(subj_id) '.happy.nomove.set']);
    subj_info.happy_trials=happy_nomove.trials;

    % Get happy with movement - pick all happy with movement artifacts
    if happy_nomove.trials<happy.trials
        [happy_move,happy_move_idx]=pop_selectevent(happy, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        happy_move=pop_saveset(happy_move,'filepath',subj_dir,'filename',[num2str(subj_id) '.happy.move.set']);

        happy_imitation=remove_nonimitation_epochs(happy_move);
        if happy_imitation.trials>0
            happy_imitation=pop_saveset(happy_imitation,'filepath',subj_dir,'filename',[num2str(subj_id) '.happy.imitation.set']);
        end
    end
    
    % Get sad - all emotion that are labeled sad
    [sad,sad_idx]=pop_selectevent(emotion, 'type', {'mov1'}, 'code', {'sad'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    sad=pop_saveset(sad,'filepath',subj_dir,'filename',[num2str(subj_id) '.sad.set']);

    % Get sad without movement - pick all sad without movement artifacts
    [sad_nomove,sad_nomove_idx]=pop_selectevent(sad, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'on');
    sad_nomove=pop_saveset(sad_nomove,'filepath',subj_dir,'filename',[num2str(subj_id) '.sad.nomove.set']);
    subj_info.sad_trials=sad_nomove.trials;

    % Get sad with movement - pick all sad with movement artifacts
    if sad_nomove.trials<sad.trials
        [sad_move,sad_move_idx]=pop_selectevent(sad, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        sad_move=pop_saveset(sad_move,'filepath',subj_dir,'filename',[num2str(subj_id) '.sad.move.set']);

        sad_imitation=remove_nonimitation_epochs(sad_move);
        if sad_imitation.trials>0
            sad_imitation=pop_saveset(sad_imitation,'filepath',subj_dir,'filename',[num2str(subj_id) '.sad.imitation.set']);
        end
    end
    
    % Get mouth opening - all labeled movement
    [movement,movement_idx]=pop_selectevent(preprocessed, 'type', {'mov1'}, 'code', {'move'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
    movement=pop_saveset(movement,'filepath',subj_dir,'filename',[num2str(subj_id) '.movement.set']);

    % Get mouth opening without movement - pick all mouth opening without movement artifacts
    [movement_nomove,movement_nomove_idx]=pop_selectevent(movement, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'on');
    movement_nomove=pop_saveset(movement_nomove,'filepath',subj_dir,'filename',[num2str(subj_id) '.movement.nomove.set']);
    subj_info.mouth_opening_trials=movement_nomove.trials;

    % Get mouth opening with movement - pick all mouth opening with movement artifacts
    if movement_nomove.trials<movement.trials
        [movement_move,movement_move_idx]=pop_selectevent(movement, 'type', {'artifact'}, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        movement_move=pop_saveset(movement_move,'filepath',subj_dir,'filename',[num2str(subj_id) '.movement.move.set']);

        movement_imitation=remove_nonimitation_epochs(movement_move);
        if movement_imitation.trials>0
            movement_imitation=pop_saveset(movement_imitation,'filepath',subj_dir,'filename',[num2str(subj_id) '.movement.imitation.set']);
        end
    end
    
    disp(['Subj ' num2str(subj_id) ' - after preprocessing']);
    disp('Overall:');
    disp(['unshuffled=' num2str(unshuffled.trials) ', shuffled=' num2str(shuffled.trials) ', emotion=' num2str(emotion.trials) ', movement=' num2str(movement.trials) ', happy=' num2str(happy.trials) ', sad=' num2str(sad.trials)])
    disp('Without movement:');
    disp(['unshuffled=' num2str(unshuffled_nomove.trials) ', shuffled=' num2str(shuffled_nomove.trials) ', emotion=' num2str(emotion_nomove.trials) ', movement=' num2str(movement_nomove.trials) ', happy=' num2str(happy_nomove.trials) ', sad=' num2str(sad_nomove.trials)])
    %disp('With movement:');
    %disp(['unshuffled=' num2str(unshuffled_move.trials) ', shuffled=' num2str(shuffled_move.trials) ', emotion=' num2str(emotion_move.trials) ', movement=' num2str(movement_move.trials) ', happy=' num2str(happy_move.trials) ', sad=' num2str(sad_move.trials)])
    
    
