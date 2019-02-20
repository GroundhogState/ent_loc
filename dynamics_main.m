%% Make data

config.gen.L = 9;
config.gen.bc = 'periodic';
config.gen.Ws = 1:10;
config.gen.verbose = 2;
savepath = 'C:\Users\jacob\Documents\Projects\ent_loc\dyn_data\';
config.gen.savepath=fullfile(savepath,sprintf('L=%u',config.gen.L));
fwtext('Starting program')
% profile on

% for N = 1:303
%     for W = config.gen.Ws
        % Generate Hamiltonian
        if config.gen.verbose
            fwtext({'Generating H, W=%.3f',W})
        end
        config.gen.W = 10;
        [H, h_list] = disorder_H(config.gen);

        % Generate an initial state
        % Say, the staggered state
        psi_up = [1 0];
        psi_down = [0 1];
        psi_cell = cell(config.gen.L,1);
        for ii=1:config.gen.L
            if mod(ii,2)
                psi_cell{ii} = psi_up;
            else
                psi_cell{ii} = psi_down;
            end
        end
        psi = Tensor(psi_cell);
        rho = toDM(psi);
        % Initial graph
        graph_data = rho_to_graph(rho);
        % Spectral decomposition of initial state
        [vecs, vals] = eigs(H,length(H));
        coefs = (psi*vecs)';

        % Time evolution
        if config.gen.verbose
            fwtext('Graphing over time')
        end
        nsteps = 100;
        T = linspace(0,20,nsteps);
        G_t = zeros(nsteps,config.gen.L,config.gen.L);
        for step = 1:nsteps
            t = T(step);
            U = exp(-1j*diag(vals)*t);
            psi_T = vecs*(coefs.*U);
            G_t(step,:,:) = rho_to_graph(toDM(psi_T));
        end



        % Saving structure

        dyn_data.P.h_list = h_list;
        dyn_data.P.W = config.gen.W;
        dyn_data.P.init = psi;
        dyn_data.P.bc = config.gen.bc;
        dyn_data.G.node_cent = node_cent;
        dyn_data.G.G_t = G_t;
        dyn_data.G.traces = traces;
        if config.gen.verbose
            fprintf(' - Saving data\n')
        end
        if ~exist(config.gen.savepath,'dir')
            mkdir(config.gen.savepath)
        end
        savedir = fullfile(config.gen.savepath,sprintf('W=%.3f',W));
        if ~exist(savedir,'dir')
            mkdir(savedir)
        end
        timestamp = 1e3*posixtime(datetime);
        thisname = sprintf('dyn_data_%.f.mat',timestamp);
        fname=fullfile(savedir,thisname);
        save(fname,'-struct','dyn_data','-v7.3');
%     end %loop over Ws
% end



% %% Import &  Extract stuff
% 
% config.imp.num_files = NaN;
% 
% datapath = config.gen.savepath;
% subdirs = dir(fullfile(datapath,'W=*'));
% num_dirs = numel(subdirs);
% import_data.W = cell(num_dirs,1);
% import_data.net_data = cell(num_dirs,1);
% for dir_idx = 1:num_dirs
%     subdir = subdirs(dir_idx).name;
%     files = dir(fullfile(datapath,subdir,'*.mat'));
%     if ~isnan(config.imp.num_files)
%         num_files = config.imp.num_files;
%     else
%         num_files = size(files,1);
%     end
%     dir_data = cell(numel(subdir,1));    
%     fprintf('\n Importing %6.f files from dir %u/%u:\n000000',num_files,dir_idx,num_dirs)
%     for N=1:num_files
%         if mod(N,100) ==0
%             fprintf('\b\b\b\b\b\b%06.f',N)
%         end
%         fname = files(N).name;
%         fname = fullfile(datapath,subdir,fname);
%         data = load(fname);
%         dir_data{N} = get_dyn_data(data);
%     end % loop over files
%     import_data.W{dir_idx} = str2double(subdir(3:end));
%     import_data.net_data{dir_idx} = dir_data; 
% end % loop over dirs
% 
% 
% %% Process
% data = import_data.net_data;
% config.viz.fields = {'G','node_cent'};
% 
% num_Ws = numel(data);
% data_dist = cell(num_Ws,1);
% for nW = 1:num_Ws 
%     data_dist{nW} = cell_vertcat(cellfun(@(x) rec_getfield(x,config.viz.fields),data{nW},'UniformOutput',false)');
% end
% %%
% config_viz.W_list = config.gen.Ws;
% config_viz.pos_def = true;
% config_viz.cutoff = 1e-11;
% config_viz.scaling = false;
% config_viz.win = [0,0.5];
% config_viz.num_bins = 50;
% config_viz.fid = 111;
% config_viz.fig_title = 'out';
% config_viz.plots = {'linXlinY','linXlogY'};
% 
% 
% proc_data = distribution_viz(data_dist,config_viz);
% 
% plot_hists(proc_data,config_viz);
% 
% % proc_data.cent = viz_field(import_data.net_data,config);

% 
traces = zeros(nsteps,1);
C2 = zeros(nsteps,1);
node_cent = zeros(nsteps,config.gen.L);
for step = 1:nsteps
   traces(step) = trace(squeeze(G_t(step,:,:)));
   hc = squeeze(G_t(step,:,:));
   hc = hc - diag(diag(hc));
   C2(step) = sum(sum(hc));
    Lap_offdiag = hc + hc';
    D_temp = sum(Lap_offdiag)';
    mu_temp =Lap_offdiag*D_temp./D_temp; % Weighted sum of (normalized) neighbour degrees
    norm = zeros(config.gen.L,1);
    for i=1:config.gen.L
        norm(i) = sum(D_temp) - D_temp(i); %Average of neighbour degrees
    end
    node_cent(step,:) = mu_temp./(norm);

end

fwtext('Importing done')

%% Plot things
sfigure(1);
clf;
subplot(2,2,1)
for i=1:config.gen.L
   plot(T,G_t(:,i,i),'.');
   hold on
end
subplot(2,2,2)
plot(T,traces/config.gen.L)
hold on
plot(T,C2/(config.gen.L*(config.gen.L-1)))


subplot(2,2,3)
for i=1:config.gen.L
   plot(T(2:end),node_cent(2:end,i),'-');
   hold on
end
ylim([0,0.2])

subplot(2,2,4)
plot(T,traces/config.gen.L-C2/(config.gen.L*(config.gen.L-1)))

sfigure(2);
ngraph = 25;
for i=1:ngraph
    subplot(ceil(sqrt(ngraph)),ceil(sqrt(ngraph)),i)
    gplot = squeeze(G_t(ceil(nsteps*i/ngraph),:,:))/2;
    gplot(10,1) = 1;
    imagesc(gplot)
end

sfigure(3);
subplot(1,2,1)
imagesc(squeeze(sum(G_t,1)));
subplot(1,2,2)
plot(h_list);

sfigure(4);
subplot(1,2,1)
histogram(node_cent(:)*(config.gen.L-1))
subplot(1,2,2)
histogram(node_cent(:)*(config.gen.L-1))
set(gca,'Yscale','log')


fwtext('ALL DONE')
%% 
% profile off
% profile viewer

function dyn_data = get_dyn_data(data)
        dyn_data.P.h_list = data.P.h_list;
        dyn_data.P.W = data.P.W;
        dyn_data.P.init = data.P.init;
        dyn_data.P.bc = data.P.bc;
        dyn_data.G.node_cent = data.G.node_cent;
        dyn_data.G.G_t = data.G.G_t;
        dyn_data.G.traces = data.G.traces;
end