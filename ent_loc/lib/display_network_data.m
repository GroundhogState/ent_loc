function display_network_data(in_net_data,display_opts)

    for N=1:numel(in_net_data)
        net_data = in_net_data{N};
    
        if display_opts.local
            figure()
            for ns = 1:net_data.num_samples
                nrg = squeeze(net_data.energies(ns,:));
                colour = magma(0.85*ns/net_data.num_samples);
                for nv = 1:net_data.num_eigs

                    colour_V = magma(0.85*nv/net_data.num_eigs);


                    %Spectrum - row 1
                    subplot(5,3,1)
                    plot(squeeze(net_data.lap_evals(ns,nv,:)),'color',colour_V);
                    hold on

                    subplot(5,3,2)
                    nz_evals = squeeze(net_data.lap_evals(ns,nv,1:end-1));
                    plot(log(nz_evals),'color',colour_V);
                    hold on




                    %Determinants -
                    subplot(5,3,7)
                    sp3=plot(nrg,log(abs(squeeze(net_data.determinants(ns,:)))),'.');
                    sp3.Color = colour;
                    hold on


                    % Purity -


                    %Spectral scaling 
                    subplot(5,3,4)
                    qry=log(nz_evals(2:end))'./(1:numel(nz_evals)-1);
                    sp5=plot(qry,'color',colour);
        %             sp5.Color = colour;
                    hold on

                    % edge/weight statistics
    %                 subplot(5,3,3)
    %                 histogram((abs(net_data.degree_list(ns,nv,:))),linspace(0,1,20),'FaceAlpha',0.2,'FaceColor',colour);
    %                 hold on

                    subplot(5,3,6)
                    histogram((log(abs(net_data.weight_list(ns,nv,:)))),-40:2:2,'FaceAlpha',0.2,'FaceColor',colour);
                    hold on


                    %Trace 
                    subplot(5,3,13)
                    sp2=plot(nrg,squeeze(net_data.traces(ns,:)),'.');
                    sp2.Color = colour;
                    hold on
                    subplot(5,3,14)
                    sp2=plot(nrg,log(squeeze(net_data.traces(ns,:))),'.');
                    sp2.Color = colour;
                    hold on           

                end % loop over eigenvalues
            subplot(5,3,3)
            plot(nrg,exp(net_data.stats.fielder_vals(ns,:)),'.','color',colour)
            set(gca,'Yscale','log')
            title('log Fielder eigenvalues')
            hold on
            end %loop over realizations



            subplot(5,3,1)
            title(['W=',num2str(net_data.W),' spectrum'])
            subplot(5,3,2)
            title('Log spectrum')
            ylim([-35,3])

            all_nz_evals = squeeze(net_data.lap_evals(:,:,1:end-1));
%             all_scale = all_nz_evals./(1:size(all_nz_evals,2));
            subplot(5,3,9)
            histogram(log((all_nz_evals(:))),20)
            title('Spectral hist')
            hold on

            subplot(5,3,10)
%                     lv = sort(squeeze(net_data.lap_evals(ns,nv,:)),'ascend');
%                     cmlt = zeros(size(lv));
%                     for i=1:numel(lv)
%                         cmlt(i) = sum(lv(1:i))/sum(lv);
%                     end
            sp4=plot(sort(log(all_nz_evals(:)),'descend'));
            sp4.Color = colour;
            hold on
            
            %Determinants 
            subplot(5,3,7)
            title('log(|L|')
            ylim([-120,0])
            subplot(5,3,8)
            histogram(log(squeeze(net_data.determinants(:))),-120:4:1);
            title('|L| dist')
            % Purity 
            subplot(5,3,10)
            title('Sorted spectra')
            ylim([0,1])
            subplot(5,3,11)
            histogram(net_data.Qs(:),0:.05:1);
            title('Purity dist') 
            %Entropy 
            subplot(5,3,4)
            title('Spectral scaling')
        %     ylim([0,3])
            subplot(5,3,5)
            histogram(net_data.entropies(:),0:0.15:3)
            title('Entropy dist')



            %Trace 
            subplot(5,3,13)
            title('Trace(L)')
            subplot(5,3,14)
            title('log(Trace(L))')
            subplot(5,3,15)
            histogram((squeeze(net_data.traces(:))),25);
            title('Trace dist')

            % edge/weight statistics
    %         subplot(5,3,3)
    %         title('Sample log degree dist')
        %     xlim([-30,1])
            subplot(5,3,6)
            title('Sample log weight dist')  
            xlim([-50,5])

%             histogram(log(net_data.degree_list(:)),50)
%             title('log Degree dist')
            subplot(5,3,12)
            histogram(log(net_data.weight_list(:)),50)
            title('log weight dist')
        end
        if display_opts.savefig
            savefig(['L',num2str(net_data.L),'W',num2str(net_data.W),'.fig'])
            saveas(gcf,['L',num2str(net_data.L),'W',num2str(net_data.W),'.png'])
        end
    end
    
    
    
    
    
    
    if display_opts.global
        figure();
        for N=1:numel(in_net_data)
%             colour = magma(0.85*N/numel(in_net_data));
            net_data = in_net_data{N}; 
            entropies = net_data.entropies;
            fielders = net_data.stats.fielder_vals;
            determinants = net_data.determinants;
            traces = net_data.traces;
            
            W = net_data.W;
%             Waxis = W*net_data.num_samples;
            for nv=1:net_data.num_eigs
                colour = magma(0.85*nv/net_data.num_eigs);
                
                entropies_loc = entropies(:,nv);
                subplot(3,2,1)
                plot(W,mean(entropies_loc),'.','color',colour);
                hold on
                title('Spectral entropies')
                xlabel('W')


                fielders_loc = fielders(:,nv);
                subplot(3,2,2)
                plot(W,mean(fielders_loc),'.','color',colour)
                hold on
                title('Algebraic connectivity')
                xlabel('W')
                
                determinants_loc = determinants(:,nv);
                subplot(3,2,3)
                plot(W,log(mean(determinants_loc)),'.','color',colour)
                hold on
                title('|L|')
                xlabel('W')
                
                traces_loc = traces(:,nv);
                subplot(3,2,4)
                plot(W,mean(traces_loc),'.','color',colour)
                hold on
                title('Tr(L)')
                xlabel('W')
                
                % Replace with violin or similar
%                 sc1=scatter(W*ones(size(net_data.stats.weights)),log(net_data.stats.weights),'.');
%                 hold on
%                 sc1.MarkerFaceAlpha = 0.2;
%                 sc1.MarkerFaceColor = colour;
                
                
            end

        end
    end

%     network_data.stats.entropy_VN = in_net_data.entropy_VN(:);
%     network_data.stats.determinants = squeeze(in_net_data.determinants(:));
%     network_data.stats.fielder_vals = log(squeeze(in_net_data.lap_evals(ns,:,end-1)));
%     network_data.stats.weights = in_net_data.degree_list(:);
%     network_data.stats.traces = in_net_data.traces(:);
    
    if display_opts.savefig
        savefig(['L',num2str(net_data.L),'W',num2str(net_data.W),'_summary.fig'])
        saveas(gcf,['L',num2str(net_data.L),'W',num2str(net_data.W),'_summary.png'])
    end
end