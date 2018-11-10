function data = save_samples(L,W,num_samples,n_vecs,savepath)
    data.samp= cell(num_samples,1);
    data.L = L;
    data.W = W;
    data.num_eigs = n_vecs;
%     spmd 
    for k=1:num_samples
        k
    %% Build H
        [H, data_temp.h_list] = disorder_H(data.L,data.W); 
        [data_temp.vecs, nrg] = eigs(full(H),2^data.L);
        data_temp.nrg = diag(nrg);
        %% Select vectors & build state graph Laplacian
        data_temp.sel = ceil(linspace(1,2^data.L,n_vecs));
        v_sel = data_temp.vecs(:,data_temp.sel);
        data_temp.graph_data = vec_to_graph(v_sel);

        data.samp{k} = data_temp;
    end


    fname=[savepath,'L-',num2str(data.L),...
        '-W',num2str(data.W),'-N',num2str(n_vecs),'-PBC.mat'];
    save(fname,'-struct','data','-v7.3');
    
    % 2000 sec on office machine to generate 7 instances of L=13, 5 samples
    % each. Diagonalized all of them, but did not compute graphs - partial
    % trace takes forever, so let's try to find a faster way. 18GB of data!
end