%% Setting up
fwtext('Starting program')
profile on

config.verbose = 1;

% System setup
config.gen.L = 8;
config.gen.bc = 'periodic';
config.gen.Ws = 1:10;
config.gen.num_samples = nan;

savepath = 'C:\data\dyn_data\';
config.gen.savepath=fullfile(savepath,sprintf('L=%u',config.gen.L));
config.gen.run = false;

% initial state
% Say, the staggered state
psi_cell = cell(config.gen.L,1);
for ii=1:config.gen.L
    if mod(ii,2)
        psi_cell{ii} = [1 0]; %spin-up
    else
        psi_cell{ii} = [0 1];% spin-down
    end
end
config.gen.psi_0 = Tensor(psi_cell);
% config.gen.psi_0 = toDM(psi);
% time evolution
config.gen.nsteps = 50;
config.gen.Tmax = 10;

% % Generate the data 
if config.gen.run
    data_sample = gen_dyn_data(config);
end
fwtext('Generation done')

%% Import &  Extract stuff

config.imp.L = 9;
savepath = 'C:\Data\dyn_data';
config.imp.savepath=fullfile(savepath,sprintf('L=%u',config.imp.L));
config.imp.num_files = nan;
config.imp.starting_timestep = 10;
import_data = import_dyn_data(config);
fwtext('Importing complete')

%% Process

fwtext('Processing')
config.viz.L = 9;
savepath = 'C:\Data\dyn_data';
config.viz.savepath=fullfile(savepath,sprintf('L=%u',config.viz.L));
config = dyn_analysis_config(config);
config.viz.W_list = import_data.W;
config.viz.show_plots = false;
config.viz.save = true;
% Plot various things versus VNE; degree, centrality?

proc_data = dyn_process(import_data,config);
fwtext('Processing done')
%%
% Looping over multiple lengths; this will be abstracted shortly
config.L.savepath = 'C:\Data\dyn_data';
config.L.num_files = nan;

% Todo: Edit so it can pick only the latest file; this works for now
% assuming things are timestamped. Maybe a config field.
% Change printed progress for percentage/progress bar
% STOP PASSING RAW DATA BACK UP?!
% change process save to include a field name!!
loop_data = dir_loop_import(config);

fwtext('Loop import done')

%%
% Pick a field and compare it
sfield = {'G','node_cent'};
% Hacky solution so I can get the actual function going...

% Todo: pass dir_plot function a key handle (W, L, etc)
% Which auto-selects colour map
% Ensure Ws are passed cleanly up to this function...
fieldnames = cellfun(@(x) x.conf.viz.fields, loop_data,'UniformOutput',false);
field_idx = 4;
fntemp = fieldnames{field_idx};
xvals = loop_data{1}.data{field_idx}.hist_bins{1};
data = cellfun(@(x) x.data{field_idx}.hist_counts, loop_data,'UniformOutput',false);
% Currently assumes identical Ws - need to fix this in future!
num_slices = numel(data{1});
ref_len_idx = 2;
sfigure(10);
clf
cm = colormap(plasma(num_slices));
for ii=1:num_slices    
    slices = cellfun(@(x) x{ii}, data,'UniformOutput',false);
    ratios = cell2mat(cellfun(@(x) x./slices{ref_len_idx},slices,'UniformOutput',false));
    ratios = ratios.*(~(isinf(ratios) | isnan(ratios)));
    plot(xvals,log(ratios)','color',cm(ii,:))
    hold on
end
% ylim([0,15])


% How to plot various things versus VNE? Way back in Import, make pairs?




















fwtext('ALL DONE')
