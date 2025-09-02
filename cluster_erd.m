function erd=cluster_erd(data, channels, foi, woi, baseline, varargin)

defaults=struct('freq_range', [2 35], 'nfreqs', 100, 'ntimesout', 800);

params=struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

[ersp times freqs]=cluster_ersp(data, channels, baseline, 'freq_range', params.freq_range, 'nfreqs', params.nfreqs, 'ntimesout', params.ntimesout);

foi_idx=intersect(find(round(freqs)>=foi(1)),find(round(freqs)<=foi(2)));
time_idx=intersect(find(times>=woi(1)),find(times<=woi(2)));        
erd=(10.0.^(ersp(foi_idx,time_idx)/10.0)-1.0)*100.0;   
erd=mean(erd(:));     

