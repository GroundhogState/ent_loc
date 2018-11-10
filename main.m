%%
% For playing with spin chains. Uses QETLab for now, at least for the
% partial trace and Pauli functions. 

close all

% savepath = '/home/jacob/ent_loc/dat/'; % office machine
savepath = 'C:\Users\jaker\Documents\MATLAB\ent_loc\dat\'; %home machine

%% Generate data

% data = [];
% num_samples = 1;
% num_vecs = 10;
% L = 6;
% Ws = [0:2:10];
% % profile on
% data = cell(length(Ws),1);
% for i=1:numel(Ws)
%     if Ws(i) == 0
%         n_samp = 1;
%     else
%         n_samp = num_samples;
%     end
%     Ws(i)
%     data{i}=save_samples(L,Ws(i),n_samp,num_vecs,savepath);
% end
% % profile off
% % profile viewer

%%  load data
%Ws = [0:2:8];
% for N=1:numel(Ws)
    % fname = [savepath,'L-12-W6-N30-PBC.mat'];
    % data{N} = load(fname);
% end
Ws = [2:2:6];
close all
%% plot results
for N=1:numel(Ws)
    W  = Ws(N);
    fname = [savepath,'L-6-W',num2str(W),'-N10-PBC.mat'];
    data = load(fname);
    kmax = numel(data.samp);
    figure();
    for k=1:kmax
        sample=data.samp{k};
        
        L_list = sample.graph_data.L_list;
        E_list = sample.graph_data.E_list;
        Energies=rescale(sample.nrg(sample.sel));
        colormap winter(110)
        cm = colormap;
        A_sum = zeros(size(L_list{1}));
        L_sum = zeros(size(L_list{1}));
        degree_list = zeros(data.num_eigs,data.L);
        weight_list = zeros(data.num_eigs,(data.L)*(data.L+1)/2);
        for ii=1:data.num_eigs
            if ~isequal(zeros(size(L_list{ii})),L_list{ii})
                Laplacian = data.samp{1}.graph_data.L_list{ii};
                [~,L_vals] = eigs(Laplacian,data.L); 
                L_vals = diag(L_vals);
                A = -Laplacian;
                for j = 1:L
                    A(j,j) = 0;
                end
                A_sum = A_sum + A;
                L_sum = L_sum + Laplacian;
                evals_nz = L_vals(1:end-1);
                TraceL = sum(evals_nz);
                DetL = prod(evals_nz);
                spectral_entropy = -sum((evals_nz/TraceL).*log(evals_nz/TraceL));
                mode_Q = max(evals_nz)/TraceL;
                degree_list(ii,:) = diag(Laplacian);
                mask = triu(ones(L))==1;
                weight_all = A(mask);
                weight_list(ii,:) = weight_all(:);
                    
                subplot(3,3,2)
                p2=plot(L_vals);
                p2.Color = cm(ii,:);
                hold on
                
                subplot(3,3,3)
                p3=plot(Energies(ii), TraceL,'x');
                p3.Color = cm(round(100*k/kmax),:);
                hold on
                
                subplot(3,3,4)
                b=plot(Energies(ii),DetL,'x');
                b.Color = cm(round(100*k/kmax),:);     
                hold on

                subplot(3,3,5)
                c=plot(Energies(ii),mode_Q,'x');
                c.Color = cm(round(100*k/kmax),:);  
                hold on
                
                subplot(3,3,6)
                d=plot(Energies(ii),spectral_entropy,'x');
                d.Color =  cm(round(100*k/kmax),:);  
                hold on
            end
        end
        subplot(3,3,1)
        G = graph(rescale(A_sum.*(A_sum>0.01)));
        plot(G,'Layout','circle')
        hold off
        
        subplot(3,3,7)
        histogram(log(degree_list(:)),25)
        
        subplot(3,3,8)
        histogram(log(weight_list(:)),25)
        
        subplot(3,3,9)
        imagesc(A_sum)
        
        title(['W=',num2str(W)])
        
    end
    
    subplot(3,3,1)
    title('Graph eg')
    subplot(3,3,2)
    title('Spectrum')
    subplot(3,3,3)
    title('Trace')
    subplot(3,3,4)
    title('|L|')
    subplot(3,3,5)
    title('\lambda_N /Tr(L)')
    ylim([0,1])
    subplot(3,3,6)
    title('Spectrum entropy')
    subplot(3,3,7)
    title('Degree distribution')
    subplot(3,3,8)
    title('Weight distribution')
    subplot(3,3,9)
    title('mean A')
%     subplot(3,3,9)
   
end
profile off
% profile viewer



%To do: Store disorder lists, Laplacian (& some spectral data_temp) for varying
%L,W as .mat struct. Build I/O
% Plots: L1 and L2 norm of spectra for many eigenvalues;
% norm1(Laplacian(Energy)) etc
% 'Condensation'/localization of state spectra vs E and W
% Temperature?! High energy density ~ localized eigengraph spectrum.
% What is the structural interpretation of these spectra?
% low-alpha ladder plot for Laplacian, combine L for many eigenstates of
% single disorder 
% Vizualise the function sum(L_eval.*L_evec) on graph nodes
% Normalized Laplacian?
% SMALL demo systems
% Remove PermuteSystems bottleneck...
% Directions:
%       L-bits ~ decomposition into (approximate) union of subgraphs?
%           System decomposition as (generalized) graph product
%       Degree distribution!
%       Weight distribution!
%       Majorization by spectrum?
%       Linear-algebraic entanglement measures

% Observations: Localized phase seems to have generically lower spectral
% entropy and the 'ground state' mode population grows. Spectral power
% seems lower, too, but maybe more interesting is the entropy. 
% Product states have no links between components!