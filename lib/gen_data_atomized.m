function data = gen_data_atomized(config)

% TODO: Modify generation so each graph is saved?
%   goal: Make the code 'run' like an experiment so I can leave it idling 
%   Expected problem: Load times will increase with more samples
%   Solution: Create single files for each run...

% Method two: Each graph gets its own .mat file


% Returns
%   Struct with single field, samp, which is a cell array of structs with
%   fields:
%       L               Spin chain length
%       W               Disorder bandwidth
%       num_eigs        Number of selected eigenvalues
%       sel             Indices of selected eigen*
%       num_samples     Number of disorder realizations
%       nrg             List of selected RESCALED eigenvalues corresponding to
%       v_sel           List of selected eigenvalues which are turned into
%       A_list          State graph objects generated by vec_to_graph
%
fwtext('')
fwtext('GENERATING DATA')
if config.gen.freerun
        fwtext('FREERUN MODE')
        while true
            for i=1:numel(config.gen.Ws)
            % don't pass W=0, that's silly
                for ii=1:numel(config.gen.Ws)
                    data = data_gen_core(config,config.gen.Ws(ii));
                end
                fprintf('\n')
           end
        end
else
    for k=1:config.gen.num_samples

        if config.verbose>1
            fprintf('--Sample %u/%u\n',k,config.gen.num_samples)
        end
        for i=1:numel(config.gen.Ws)
            data = data_gen_core(config,config.gen.Ws(i));
        end
        fprintf('\n')
    end
end
    
end

function data = data_gen_core(config,W)

            config.gen.W = W;
            if config.verbose
                fprintf('\n=Disorder strength %.1f  \n',config.gen.W)
            end

        %% Build H
            if config.verbose>2
                fprintf('-- Generating H... ')
            end
            [H, h_list] = disorder_H(config.gen); 
            if config.verbose>2
                fprintf(' Diagonalizing... ')
            end
            [vecs, nrg] = eigs(full(H),config.gen.num_vecs,'smallestabs');
            if config.verbose>2
                fprintf(' Done\n')
            end
            % The eigenvalues are returned in ascending absolute value
            % Spectrum is symmetric about zero, so this samples from the
            % middle of the spectrum


            % Loop over & save generated eigenvectors
            for eig_idx = 1:config.gen.num_vecs
                    if config.verbose > 2
                        fprintf(' - Producing graph for vector %d/%d',eig_idx, config.gen.num_vecs)
                    end
               data = [];
               data.L = config.gen.L;
               data.W = config.gen.W;
               data.h_list = h_list;
               data.nrg = nrg(eig_idx);
               data.vec = vecs(:,eig_idx);
               data.A = v2g_rec_atomized(data.vec);

                if config.gen.save
                    savedir = fullfile(config.gen.savepath,sprintf('W=%.3f',data.W));
                    if ~exist(savedir,'dir')
                        mkdir(savedir)
                    end
                    if config.verbose>2
                        fprintf(' - Saving output\n')
                    end
                    timestamp = 1e3*posixtime(datetime);
                    fname=fullfile(savedir,sprintf('ent_loc_%.f.mat',timestamp));
                    save(fname,'-struct','data','-v7.3');
                end
            end
end