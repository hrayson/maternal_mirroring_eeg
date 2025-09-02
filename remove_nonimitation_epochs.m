function new_data=remove_nonimitation_epochs(data)
    
code='';
mvmt='';
epochs_to_delete=[];
for i=1:length(data.epoch)
    for j=1:length(data.epoch(i).eventtype)
        if strcmp(data.epoch(i).eventcode{j},'mov1')
            code=data.epoch(i).eventcode{j};
            mvmt=data.epoch(i).eventmovement{j};
        elseif strcmp(data.epoch(i).eventtype{j},'artifact') && strcmp(data.epoch(i).eventcode{j},'noat')==0
            if ~((strcmp(code,'joy') && strcmp(data.epoch(i).eventmovement{j},'J')) || (strcmp(code,'move') && strcmp(data.epoch(i).eventmovement{j},'MO')) || (strcmp(code,'sad') && strcmp(data.epoch(i).eventmovement{j},'S')))
                if length(ismember(epochs_to_delete,i))==0
                    epochs_to_delete(end+1)=i;
                end
            end
        end
    end
end
disp([num2str(data.trials-length(epochs_to_delete)) ' imitation trials']);
if length(epochs_to_delete)<data.trials
    new_data = pop_rejepoch( data, epochs_to_delete ,0);
else
    new_data.trials=0;
end



