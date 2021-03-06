function proc_data = process_atomized(data,config)

proc_data.data = [];
proc_data.conf = [];
cats = config.viz.categories;

for cat = 1:numel(cats)
    all_fields = fields(getfield(config.viz,cats{cat}));
    for ii=1:numel(all_fields)
        config.viz.fields = {cats{cat},all_fields{ii}};
        proc_data.conf = setfield(proc_data.conf,cats{cat},{ii},config);
        proc_data.data = setfield(proc_data.data,cats{cat},{ii},config);
    end
end

%Save the output%
if config.viz.save 
    fprintf(' - Saving process output\n')
    if ~exist(config.viz.savepath,'dir')
        mkdir(config.viz.savepath)
    end
%         timestamp = posixtime(datetime)*1e3;
    filename = sprintf('dyn_dat_L_%u',config.gen.L);
    save(fullfile(config.viz.savepath,filename),'-struct','proc_data','-v7.3');
end

hlintext('Done!')

end
