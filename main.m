close all
% clear all

% TODO: Test data appending function in save
% TODO: Reformat saveing: L/W/(eps, h_list, G)

% TODO: Find out how to safely interrupt a while loop; Or, if the saving
% is stable, just interrupt when you sit down...
% 

%% Generating data
config.gen.L = 9;              % System size
config.gen.bc = 'periodic';     % 'periodic' or 'open'
config.gen.Ws = 1:10;  %Disorder strengths
config.gen.num_samples = 2;     % # of disorder realizations
% config.gen.sel = 4075:4125;
% config.gen.E_bounds = ?
config.gen.num_vecs = 15;
config.gen.save = true;
savepath = 'C:\Users\jaker\Documents\Projects\ent_loc\atomdat\';
config.gen.savepath = fullfile(savepath,sprintf('L=%d',config.gen.L));
config.verbose = 1;
config.gen.freerun = true;
% Sample from the middle of the spectrum

%% CAREFUL, this can take a long time to execute.
% Generate eigenstate data
% profile on
% gen_data_atomized(config);
% profile off
% profile viewer
%% Import
% % Visualize & analyze results

% config.gen.savepath = 'C:\Users\jaker\Documents\Projects\ent_loc\dat\ent_data\L13_dat';
[~,foldername,~] = fileparts(config.gen.savepath);
fwtext({'Starting graph import & process from %s',foldername})
% import_data = import_atomized_data(config);
% Returns importdata.net_data{Dir}{Sample}.category.field
fwtext('Data import complete')

%% Process

fwtext('Processing imported data')
config.viz = [];
config.viz.outpath = fullfile([config.gen.savepath,'out/']);
config.viz.W_list = cellfun(@(x) x, import_data.W);
config.viz.Nmax = numel(import_data.net_data);
config.viz.cutoff = 1e-15;
config.viz.save = false;
config = analysis_config(config);

process_atomized(import_data.net_data,config);
% 
fwtext('Main complete');
