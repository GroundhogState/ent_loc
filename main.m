close all

%add all subfolders to the path
this_folder = fileparts(which(mfilename));
% Add that folder plus all subfolders to the path.
addpath(genpath(fullfile(this_folder,'lib')));

% clear all
% profile on
% TODO: Test data appending function in save
% TODO: Reformat saveing: L/W/(eps, h_list, G)

% NB:
% L=9 has 15 eigenvectors per realization
% Larger lengths have 26 up to W=10, but 15 from W=10 up
% L = 10:14;
savepath = 'E:\Data\MBL_dat\atomdat';

%% Generating data

for L = 10:10
    config.gen.L = L;              % System size
    config.gen.bc = 'open';     % 'periodic' or 'open'
    config.gen.Ws = 1:10;  %Disorder strengths
    config.gen.num_samples = 300;     % # of disorder realizations
    config.gen.num_vecs = 15;
    config.gen.save = true;

    config.gen.savepath = fullfile(savepath,sprintf('L=%d',config.gen.L));
    config.verbose = 1;
    config.gen.freerun = true;
    % Sample from the middle of the spectrum

    % % CAREFUL, this can take a long time to execute.
    % Generate eigenstate data

    % gen_data_atomized(config);

    % % Import
    % % Visualize & analyze results

    % config.gen.savepath = 'C:\Users\jaker\Documents\Projects\ent_loc\dat\ent_data\L13_dat';
    config.imp.num_files = 100;
    config.imp.savepath = config.gen.savepath;
    [~,foldername,~] = fileparts(config.gen.savepath);
    fwtext({'Starting graph import & process from %s',foldername})
    import_data = function_cache([],@import_atomized_data,{config});
    % Returns importdata.net_data{Dir}{Sample}.category.field
    fwtext('Data import complete')

    %% Process

    fwtext('Processing imported data')
    config.viz = [];
    config.viz.outpath = fullfile(config.gen.savepath,'figs/');
    config.viz.W_list = cellfun(@(x) x, import_data.W);
    config.viz.Nmax = numel(import_data);
    config.viz.cutoff = 1e-13;
    config.viz.save = false;
    config.viz.savepath = fullfile(config.gen.savepath);
    config.viz.show_plots = false;
    config.viz.categories = {'G','P','L','A'};
    config = analysis_config(config);
    proc_data = process_atomized(import_data,config);
end
%% 

config.L.savepath = 'E:\Data\MBL_dat\atomdat';
config.L.num_files = nan;

loop_data = dir_loop_import(config);
fwtext('Loop import done')
%%
show_L_trends(loop_data,config)

fwtext('ALL DONE')


fwtext('Main complete');
% profile off
% profile viewer
