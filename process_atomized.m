function proc_data = process_atomized(net_data,config)

if ~exist(fullfile([config.gen.savepath,'out/']),'dir')
    mkdir(fullfile([config.gen.savepath,'out/']))
end


config.viz.fields = {'A','evals'};
proc_data.A_evals = viz_field(net_data,config);

config.viz.fields = {'A','trace'};
proc_data.A_trace = viz_field(net_data,config);

config.viz.fields = {'L','evals'};
proc_data.L_evals = viz_field(net_data,config);

config.viz.fields = {'L','trace'};
proc_data.L_trace = viz_field(net_data,config);

config.viz.fields = {'P','entropy_VN'};
proc_data.entropy_VN = viz_field(net_data,config);

config.viz.fields = {'P','TMI'};
proc_data.TMI = viz_field(net_data,config);


fwtext('Done!')

end