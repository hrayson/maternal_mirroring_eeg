function extract_block_times(subj_ids, varargin)

defaults=struct('delay', 0.021036, 'sessions', []);
params=struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

delay=0.021036;

% Start and end time for each subjects blocks

for i=1:length(subj_ids)
    % Read subject data
    subj_id=subj_ids(i)
   
    if length(params.sessions)==0
        raw=pop_readegi(fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '.raw']));

        [subj_block_start_times subj_block_end_times]=get_block_times(raw, params.delay);

        % Iterate through subject block times
        for j=1:length(subj_block_start_times)
            % Compute start time in min:sec
            start_time_min=floor(subj_block_start_times(j)/60);
            start_time_sec=subj_block_start_times(j)-start_time_min*60;

            % Compute end time in min:sec
            if j<=length(subj_block_end_times)
                end_time_min=floor(subj_block_end_times(j)/60);
                end_time_sec=subj_block_end_times(j)-end_time_min*60;
                disp([num2str(start_time_min) ':' num2str(start_time_sec) ' - ' num2str(end_time_min) ':' num2str(end_time_sec)]);
            else
                disp([num2str(start_time_min) ':' num2str(start_time_sec) ' - ']);
            end
        end
    else
        for k=1:length(params.sessions)
            session_num=params.sessions(k)
            raw=pop_readegi(fullfile('/data','infant_9m_face_eeg','raw',num2str(subj_id),[num2str(subj_id) '-' num2str(session_num) '.raw']));

            [subj_block_start_times subj_block_end_times]=get_block_times(raw, params.delay);

            % Iterate through subject block times
            for j=1:length(subj_block_start_times)
                % Compute start time in min:sec
                start_time_min=floor(subj_block_start_times(j)/60);
                start_time_sec=subj_block_start_times(j)-start_time_min*60;

                % Compute end time in min:sec
                if j<=length(subj_block_end_times)
                    end_time_min=floor(subj_block_end_times(j)/60);
                    end_time_sec=subj_block_end_times(j)-end_time_min*60;
                    disp([num2str(start_time_min) ':' num2str(start_time_sec) ' - ' num2str(end_time_min) ':' num2str(end_time_sec)]);
                else
                    disp([num2str(start_time_min) ':' num2str(start_time_sec) ' - ']);
                end
            end
        end
    end
end

function [block_start_times block_end_times]=get_block_times(raw, delay)

block_start_times=[];
block_end_times=[];

% Compute delay in time steps
delay_ts=delay*raw.srate;

start=-1;
% Iterate through events
for j=1:length(raw.event)
    % Get event type and latency - correct for delay
    event_code=raw.event(j).type;
    latency=(raw.event(j).latency+delay_ts)/raw.srate;
        
    % If block start event or ima1 event without a previous block start
    if strcmp(event_code,'blk1') || (strcmp(event_code,'ima1') && start<0)
        start=latency;
        block_start_times(end+1)=start;                    
    % If block end event
    elseif strcmp(event_code,'blk2')
        block_end_times(end+1)=latency;
        start=-1;
    end
end
