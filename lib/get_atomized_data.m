
function network_data = get_atomized_data(data)

% This function is a part-B to the gen_data function, designed to be a bit
% more flexible. The objects here could *probably* be ported to be
% constructed in individual analyses, which might actually enhance
% modularity. That'll be left for later - the vis/anal parts will act on
% these, to save the expense of repeatedly computing them whenever later
% functions called. Of course, caching large calls is an option.

%Accepts ONE input data.mat file (single disorder strength) and returns a struct network_data
% Input field for each cell in data.samp{}
%       L               Spin chain length
%       W               Disorder bandwidth
%       num_eigs        Number of selected eigenvalues
%       sel             Indices of selected eigen*
%       num_samples     Number of disorder realizations
%       nrg             List of selected RESCALED eigenvalues corresponding to
%       v_sel           List of selected eigenvalues which are turned into
%       A_list          State graph objects generated by vec_to_graph
% Output: 
%   struct network_data with fields defined below, indexed by {realization#, eigenvalue}
 
    % Importing parameters
    network_data.prm.L = data.L;
    network_data.prm.W = data.W;
    network_data.prm.h_list = data.h_list;
    
%     % Setting up output
%     % Laplacian properties
%     network_data.L.Laplacian = zeros(data.L,data.L);
%     network_data.L.evals = zeros(data.L);
%     network_data.L.evecs = zeros(data.L,data.L);
%     network_data.L.trace = [];
%    
%     % Aleph properties
%     network_data.A.Aleph = zeros(data.L,data.L);
%     network_data.A.evals = zeros(data.L);
%     network_data.A.evecs = zeros(data.L,data.L);
%     network_data.A.trace = [];
% %     network_data.
%     
%     % Graph properties
%     network_data.G.degree_list = zeros(data.L);
%     network_data.G.weight_list = zeros(data.L*(data.L-1)/2);
%     network_data.G.node_centrality = zeros(data.L);
%     
%     % Physical properties
%     network_data.P.entropy_VN=zeros(data.L);
%     network_data.P.nrg = [];

    
%         nrg_full=data.nrg;
        network_data.P.nrg = data.nrg;
            % Aleph properties
            Aleph_UD = data.A;
            % Produces Aleph with -2*onsite entropy along diagonal
            Aleph = Aleph_UD - 2*diag(diag(Aleph_UD));
            
%             network_data.A.unif_projection = sum(sum(Aleph_UD));
            network_data.A.Aleph = Aleph;                               
            [network_data.A.evecs,val_temp] = eigs(Aleph,data.L);
            network_data.A.evals = diag(val_temp);
            network_data.A.trace = trace(Aleph); % = total correlations

            % Generate additional properties
            A_temp = Aleph - diag(diag(Aleph));

            % Laplacian properties
            Lap_offdiag = A_temp + A_temp';
            Lap_diag = sum(Lap_offdiag);
            network_data.L.Laplacian = diag(Lap_diag)-Lap_offdiag;    
            [network_data.L.evecs,v_temp] = eigs(network_data.L.Laplacian,data.L);
            network_data.L.evals = diag(v_temp);
            network_data.L.trace = trace(squeeze(network_data.L.Laplacian));

            % Graph properties
            D_temp = sum(Lap_offdiag)';
            mu_temp =Lap_offdiag*D_temp./D_temp; % Weighted sum of (normalized) neighbour degrees
            norm = zeros(data.L,1);
            for i=1:data.L
                norm(i) = sum(D_temp) - D_temp(i); %Average of neighbour degrees
            end
            network_data.G.degree_list = D_temp;
            network_data.G.weight_list = A_temp;
            network_data.G.node_centrality = mu_temp./(norm); %= sum(deg_i w_ij) / avg(d_j) for all i in Neighb(j)

            % Physical properties
            network_data.P.entropy_VN = abs(diag(Aleph));
            network_data.P.TMI = sum(sum(Aleph));
        
            inf_grid = Lap_diag + Lap_offdiag;
            % QMI decay
            QMI_grid = zeros(data.L);
            for ii = 1:data.L
                QMI_grid(ii,:) = circshift(Lap_offdiag(ii,:),-ii+1);
            end
            QMI_grid(:,1) = network_data.P.entropy_VN;
            network_data.P.QMI_grid = QMI_grid;

%            network_data.things = func(data, stuff)r
%         end % Loop over eigenvectors
%     end% Loop over samples
    
end