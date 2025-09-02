function [ersp times freqs]=cluster_ersp(data, channels, baseline, varargin)

defaults=struct('freq_range', [2 35], 'nfreqs', 100, 'ntimesout', 800);

params=struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

cluster_ersps=zeros(length(channels),params.nfreqs,params.ntimesout);
for chan_idx=1:length(channels)
    [trial_ersp trial_times trial_freqs]=std_ersp(data, 'type', 'ersp', 'trialindices', [1:data.trials], 'cycles', 0, 'nfreqs', params.nfreqs, 'ntimesout', params.ntimesout, 'freqs', params.freq_range, 'freqscale', 'linear', 'channels', {channels{chan_idx}}, 'baseline', baseline, 'savefile', 'off', 'winsize',128, 'padratio', 16, 'verbose', 'off');
    cluster_ersps(chan_idx,:,:)=trial_ersp;
end
freqs=trial_freqs;
times=trial_times;
if length(channels)>1
    ersp=squeeze(mean(cluster_ersps));
else
    ersp=squeeze(cluster_ersps);
end
