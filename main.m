close all



%% To DO
% Optimize TrX calls/faster trace
% Fit distributions & plot vs W

% What is the structural interpretation of these spectra?
% Sum of all weights ~ distance from locality ~ divergence from volume law?

    % Compare Fielder vector with NN couplings - where does it suggest
    % partition?
    % Spectral properties of A, G.
    % Higher-order degrees?
        % D1 = total weight of links
        % D2 = total weight of links to second neighbours
        % Tr(exp(L))?!

    
    % Try fast-trace
%% Generate data
config.gen.savepath = '/home/jacob/Projects/ent_loc/dat/'; % office machine
% % savepath = 'C:\Users\jaker\Documents\MATLAB\ent_loc\dat\'; %notebook
% % savepath = '/home/j/Documents/MATLAB/ent_loc/dat/20181111-20L13/'; %Home machine




%% Should take about 7-8 hours
% config.gen.L = 12;              % System size
% config.gen.Ws = linspace(0,5,20);%linspace(1,7,10); %Disorder values
% config.gen.bc = 'periodic';     % 'periodic' or 'open'
% % config.gen.num_vecs = 100;       % at 12 sites, this takes about one minute   
% config.gen.num_samples = 10;     % # of disorder realizations
% config.gen.verbose = true;          %Additional output (currently useless)
% config.gen.save = true;
% % Sample from the top, middle, and bottom of the spectrum
% config.gen.sel = [1:200:4000];
% config.gen.num_vecs = config.gen.sel;   

config.gen.sel
config.viz.local = false;
config.viz.global = true;
config.viz.num_bins = 30;
config.viz.scaling = false;

%% Generate eigenstate data
profile on
data=gen_data(config);
profile off
profile viewer

%% Import & preprocess (old format)

% clear net_data;
% net_data = cell(numel(config.gen.Ws,1));
% for N=1:numel(config.gen.Ws)
%     N
%     fname = [config.gen.savepath,'L-',num2str(config.gen.L),'-W',num2str(config.gen.Ws(N)),...
%         '-N',num2str(config.gen.num_vecs),'-PBC.mat'];
%     data = load(fname);
%     net_data{N} = get_network_data_oldform(data);
%     clear data
% end

%% Import & Process (newer format) - update for next data gen run
% clear net_data;
% net_data = cell(numel(config.gen.Ws,1));
% for N=1:numel(config.gen.Ws)
%     N
%     fname = [config.gen.savepath,'L-',num2str(config.gen.L),'-W',num2str(config.gen.Ws(N)),...
%         '-N',num2str(config.gen.num_vecs),'-PBC.mat'];
%     data = load(fname);
%     net_data{N} = get_network_data(data);
%     clear data
% end
% 
% %% Plot results
% display_opts.savefig=false;
% display_opts.local = false;
% display_opts.global = true;
% net_data_sel = net_data([1,5]);
% config.viz.cutoff = 1e-10;
% 
% display_network_data(net_data,config);




% Temperature?! High energy density ~ localized eigengraph spectrum.
% low-alpha ladder plot for Laplacian, combine L for many eigenstates of
% what is the function sum(L_eval.*L_evec)?
% Normalized Laplacian?
% Remove TrX bottleneck...
% Directions:
%       L-bits ~ decomposition into (approximate) union of subgraphs?
%           System decomposition as (generalized) graph product
%       Majorization by spectrum?


