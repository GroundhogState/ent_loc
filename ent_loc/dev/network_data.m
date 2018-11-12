function network_data = network_data(data)

%Accepts ONE input data.mat file and returns a struct network_data
    fname = [savepath,'L-6-W',num2str(Ws(N)),'-N10-PBC.mat'];
    data = load(fname);
    kmax = numel(data.samp); 

    network_data.W = data.W;
    network_data.entropy_VN=zeros(kmax,data.num_eigs,data.L);
    network_data.energies = zeros(kmax,data.num_eigs+1);%%HACK FOR NOW
    network_data.laplacians = zeros(kmax,data.num_eigs,data.L,data.L);
    network_data.lap_evals = zeros(kmax,data.num_eigs,data.L);
    network_data.entropies = zeros(kmax,data.num_eigs);
    network_data.traces = zeros(kmax,data.num_eigs);
    network_data.determinants = zeros(kmax,data.num_eigs);
    network_data.Qs = zeros(kmax,data.num_eigs);
    network_data.degree_list = zeros(kmax,data.num_eigs,data.L);
    network_data.weight_list = zeros(kmax,data.num_eigs,data.L*(data.L+1)/2);
    for k=1:kmax        
        network_data.energies(k,:)=rescale(data.samp{k}.nrg(data.samp{k}.sel));
        for ii=1:data.num_eigs
            if ~isequal(zeros(size(L_list{ii})),L_list{ii})
                % Retrieve data
                Laplacian = data.samp{1}.graph_data.L_list{ii};
                [~,L_vals] = eigs(Laplacian,data.L); 
                L_vals = abs(diag(L_vals)); % L is positive semidefinite

                evals_nz = L_vals(1:end-1);
                mask = triu(ones(L))==1;
                weight_all = -Laplacian(mask);
                TraceL = sum(evals_nz);

                %Write to output obj
                network_data.laplacians(k,ii,:,:) = Laplacian;
                network_data.entropy_VN(k,ii,:) = data.samp{k}.graph_data.E_list{ii};
                network_data.lap_evals(k,ii,:) = L_vals;
                network_data.traces(k,ii) = TraceL;
                network_data.determinants(k,ii) =  prod(evals_nz);
                network_data.entropies(k,ii) = -sum((evals_nz/TraceL).*log(evals_nz/TraceL));
                network_data.Qs(k,ii) = max(evals_nz)/TraceL;
                network_data.degree_list(k,ii,:) = diag(Laplacian);
                network_data.weight_list(k,ii,:) = weight_all(:);
            end
        end 
%         clear sample
    end
%     clear data

end