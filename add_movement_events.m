
function data=add_movement_events(subj_id, data, behavior_file)

behavior_fid=fopen(['/data/infant_9m_face_eeg/raw/' num2str(subj_id) '/' behavior_file]);
lines=textscan(behavior_fid,'%s','Delimiter','\n','CollectOutput',true);
for i=3:length(lines{1})
    cols=strsplit(lines{1}{i},',');
    movement=cols{2};

    init_onset=cols{3};
    init_onset_min=str2num(init_onset(1:2));
    init_onset_sec=str2num(init_onset(4:5));
    init_onset_ms=str2num(init_onset(7:end));
    init_onset_level=str2num(cols{4});

    init_offset=cols{5};
    init_offset_min=str2num(init_offset(1:2));
    init_offset_sec=str2num(init_offset(4:5));
    init_offset_ms=str2num(init_offset(7:end));    
    init_offset_level=str2num(cols{6});

    init_latency=init_onset_min*60.0+init_onset_sec+0.001*init_onset_ms;
    init_duration=(init_offset_min*60.0+init_offset_sec+0.001*init_offset_ms)-init_latency;
    init_magnitude=init_offset_level-init_onset_level;
    data = pop_editeventvals(data,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'artifact'},'changefield',{2 'latency' init_latency},'changefield',{2 'duration' init_duration},'changefield',{2 'actor' 'None'},'changefield',{2 'code' init_magnitude},'changefield',{2 'movement' movement});
    %data = pop_editeventvals(data,'append',{1 'artifact' init_latency init_duration 'None' init_magnitude movement});
    %data=eeg_addnewevents(data, {[init_latency]}, {'artifact'}, {'duration','actor','code','movement'}, {[init_duration],['None'],[init_magnitude],[movement]});

    if length(cols)>6
        ret_onset=cols{7};
        ret_onset_min=str2num(ret_onset(1:2));
        ret_onset_sec=str2num(ret_onset(4:5));
        ret_onset_ms=str2num(ret_onset(7:end));
        ret_onset_level=str2num(cols{8});

        ret_offset=cols{9};
        ret_offset_min=str2num(ret_offset(1:2));
        ret_offset_sec=str2num(ret_offset(4:5));
        ret_offset_ms=str2num(ret_offset(7:end));    
        ret_offset_level=str2num(cols{10});

        ret_latency=ret_onset_min*60.0+ret_onset_sec+0.001*ret_onset_ms;
        ret_duration=(ret_offset_min*60.0+ret_offset_sec+0.001*ret_offset_ms)-ret_latency;
        ret_magnitude=ret_onset_level-ret_offset_level;
        data = pop_editeventvals(data,'append',{1 [] [] [] [] [] [] []},'changefield',{2 'type' 'artifact'},'changefield',{2 'latency' ret_latency},'changefield',{2 'duration' ret_duration},'changefield',{2 'actor' 'None'},'changefield',{2 'code' ret_magnitude},'changefield',{2 'movement' movement});
        %data = pop_editeventvals(data,'append',{1 'artifact' ret_latency ret_duration 'None' ret_magnitude movement});
        %data=eeg_addnewevents(data, {[ret_latency]}, {'artifact'}, {'duration','actor','code','movement'}, {[ret_duration],['None'],[ret_magnitude],[movement]});
    end
end
