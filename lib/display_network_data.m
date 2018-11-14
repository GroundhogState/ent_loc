function display_network_data(in_net_data,display_opts)



    for N = 1:numel(in_net_data)
        
        net_data = in_net_data{N};
        
        if display_opts.local
            figure()
            colormap magma;
 
            cm_nrg = colormap(magma(1000));
            cm_nsm = colormap(plasma(1000));
            
            nz_evals = squeeze(net_data.lap_evals(:,:,1:end-1));
            
            subplot(5,3,1)
            for ns = 1:net_data.num_samples
                nrg_scale = round(rescale(net_data.energies(ns,:),1,1000));
                for nv = 1:net_data.num_eigs
                    p1=plot(1:net_data.L-1,squeeze(nz_evals(ns,nv,:))');    
                    p1.Color = cm_nrg(nrg_scale(nv),:);
                    hold on
                    title('Spectrum')
                end
            end
            
            subplot(5,3,2)
            for ns = 1:net_data.num_samples
                nrg_scale = round(rescale(net_data.energies(ns,:),1,1000));
                for nv = 1:net_data.num_eigs
                    p2=plot(1:net_data.L-1,log10(squeeze(nz_evals(ns,nv,:)))');    
                    p2.Color = cm_nrg(nrg_scale(nv),:);
                    hold on
                    title('log10 spectrum')
                end
            end
            
            %Spectral scaling 
            subplot(5,3,3)
            for ns = 1:net_data.num_samples
                nrg_scale = round(rescale(net_data.energies(ns,:),1,1000));
                for nv = 1:net_data.num_eigs
                    Y = squeeze(nz_evals(ns,nv,:));
                    p2=plot(1:net_data.L-1,rescale(Y)');    
                    p2.Color = cm_nrg(nrg_scale(nv),:);
                    hold on
                    title('Scaled spectrum')
                end
            end
            
            log10_nz_evals = log10(net_data.lap_evals(net_data.lap_evals>1.0e-15));
            log10_nz_evals = log10_nz_evals(log10_nz_evals>-31);
            subplot(5,3,4)
            histogram(squeeze(log10_nz_evals(:)))
            title('Spectral dist')
            hold on
            subplot(5,3,9)




            subplot(5,3,5)
            histogram(net_data.lap_evals(:),0:0.15:3)
            title('Spectral dist')

            subplot(5,3,6)
            histogram(net_data.Qs(:),0:.05:1);
            title('Purity dist') 

            


            subplot(5,3,7)
            for ns = 1:net_data.num_samples
                
                p7=plot(net_data.energies(ns,:),log10(abs(squeeze(net_data.determinants(ns,:)))),'.');  
                nrg_scale = round(rescale(net_data.energies(ns,:),1,1000));
                p7.Color = cm_nsm(nrg_scale(ns),:);
                hold on
                title('log10(|L|)')
                xlabel('\epsilon')
            end
            

            subplot(5,3,8)
            det = squeeze(net_data.determinants(:));
            det = det(det>0);
            histogram(log10(det),25);
            title('|L| dist') 
            
            subplot(5,3,9)
            % Fielder vectors
            for ns = 1:net_data.num_samples
                nrg_scale = round(rescale(net_data.energies(ns,:),1,1000));
                norm_fielders = squeeze(net_data.lap_evals(ns,:,end-1))'./max(squeeze(net_data.lap_evals(ns,:,:)),[],2);
                p9=plot(net_data.energies(ns,:),log(norm_fielders),'.');    
                p9.Color = cm_nsm(nrg_scale(ns),:);
                hold on
                title('Algebraic connectivity')
                xlabel('\epsilon')
            end


%             subplot(5,3,9)



            subplot(5,3,10)
            histogram(squeeze(net_data.degree_list(:)),20)
            title('Degree distribution')
            
            subplot(5,3,11)
            histogram((log10(abs(squeeze(net_data.weight_list(:))))),'FaceAlpha',0.2);
            hold on
            title('log10 weight dist')              

            subplot(5,3,12)
            histogram(net_data.entropy_VN(:))
            title('Onsite entropy dist')
            

            subplot(5,3,13)
            all_norm_fielders = squeeze(net_data.lap_evals(:,:,end-1))./squeeze(net_data.lap_evals(:,:,1));
            histogram(log10(all_norm_fielders(:)))
            title('1st connectivity dist')


            subplot(5,3,14)
            all_norm_2A = squeeze(net_data.lap_evals(:,:,end-round(net_data.L/2)))./squeeze(net_data.lap_evals(:,:,1));
            histogram(log10(all_norm_2A(:)))
            title([num2str(round(net_data.L/2)),'-connectivity dist'])


            subplot(5,3,15)
            histogram(log10(squeeze(net_data.traces(:))),25);
            title('Trace dist') 

        
        suptitle(['W=',num2str(net_data.W)])
            
        end
        

        if display_opts.savefig
                savefig(['L',num2str(net_data.L),'W',num2str(net_data.W),'.fig'])
                saveas(gcf,['L',num2str(net_data.L),'W',num2str(net_data.W),'.png'])
        end
    end
    
    
    
     if display_opts.global
        W_list = cellfun(@(x) x.W, in_net_data);
        figure();
        
        cm_nrg = colormap(magma(1000));
        
        subplot(3,3,1)
        hist_win = linspace(-5,5,100);
        all_spec = zeros(numel(net_data),length(hist_win)-1);
%         hist_cts = zeros(numel(net_data,length(hist_win)-2)
        for N = 1:numel(in_net_data)
            dat =-log(abs(squeeze(in_net_data{N}.lap_evals(:))));
            H = histogram(dat,hist_win,'Normalization','pdf');
            all_spec(N,:)=H.Values;
        end
        imagesc(W_list,H.BinEdges,all_spec')
        xlabel('Disorder')
        ylabel('log eigenvalue')
        title('L spectral pdf')
        
        subplot(3,3,2)
        hist_win = linspace(0,6,100);
        all_field = zeros(numel(net_data),length(hist_win)-1);
        for N = 1:numel(in_net_data)
            all_norm_fielders = squeeze(in_net_data{N}.lap_evals(:,:,end-1));%./squeeze(in_net_data{N}.lap_evals(:,:,1));
            H = histogram(-log(all_norm_fielders),hist_win,'Normalization','pdf');
            all_field(N,:)=H.Values;
        end
        imagesc(W_list,H.BinEdges,all_field')
        xlabel('Disorder')
        ylabel('-log(C_1)')
        title('First connectivity density ')
        
        subplot(3,3,3)
        hist_win = linspace(-2,6,100);
        all_field = zeros(numel(net_data),length(hist_win)-1);
        for N = 1:numel(in_net_data)
            all_norm_fielders = squeeze(in_net_data{N}.lap_evals(:,:,round(in_net_data{N}.L/2)));%./squeeze(in_net_data{N}.lap_evals(:,:,1));
            H = histogram(-log(all_norm_fielders),hist_win,'Normalization','pdf');
            all_field(N,:)=H.Values;
        end
        imagesc(W_list,H.BinEdges,all_field')
        xlabel('Disorder')
        ylabel('-log(C_6)')
        title('Middle connectivity density ')
        
        subplot(3,3,4)
        hist_win = linspace(0,30,100);
        all_trace = zeros(numel(net_data),length(hist_win)-1);
        for N = 1:numel(in_net_data)
            data = in_net_data{N}.traces(:);
            H = histogram(abs(data),hist_win,'Normalization','pdf');
            all_trace(N,:)=H.Values;
        end
        imagesc(W_list,H.BinEdges,all_trace')
        xlabel('Disorder')
        ylabel('Tr(L)')
        title('Total mutual information') % = Tr(L)??
        
        
        subplot(3,3,5)
        hist_win = linspace(-3,3,100);
        all_degree = zeros(numel(net_data),length(hist_win)-1);
        for N = 1:numel(in_net_data)
            data = squeeze(in_net_data{N}.degree_list(:));
            H = histogram(-log(abs(data)),hist_win,'Normalization','pdf');
            all_degree(N,:)=H.Values;
        end
        imagesc(W_list,H.BinEdges,all_degree')
        xlabel('Disorder')
        ylabel('-log(degree)')
        title('Degree distribution')
        
        subplot(3,3,6)
        hist_win = linspace(-15,2,100);
        all_weight = zeros(numel(net_data),length(hist_win)-1);
        for N = 1:numel(in_net_data)
            data = squeeze(in_net_data{N}.weight_list(:));
            H = histogram(log(abs(data)),hist_win,'Normalization','pdf');
            all_weight(N,:)=H.Values;
        end
        imagesc(W_list,H.BinEdges,all_weight')
        title('Weight distribution')
        
        subplot(3,3,7)
        hist_win = linspace(-0.1,2.1,100);
        all_entropy = zeros(numel(net_data),length(hist_win)-1);
        for N = 1:numel(in_net_data)
            data = squeeze(in_net_data{N}.entropy_VN(:));
            H = histogram((abs(data)),hist_win,'Normalization','pdf');
            all_entropy(N,:)=H.Values;
        end
        imagesc(W_list,H.BinEdges,log(all_entropy+1)')
        title('Local entropy')
        
        subplot(3,3,8)
%         plot_win = linspace(-0.1,1,100);
        all_spec = zeros(numel(net_data),in_net_data{N}.L-1);
        for N = 1:numel(in_net_data)
            data = squeeze(nanmean(in_net_data{N}.lap_evals(:,:,1:end-1)./in_net_data{N}.lap_evals(:,:,1),1));
            data = mean(data);
%             H = histogram((abs(data(:))),hist_win,'Normalization','pdf');
            all_spec(N,:)=data;
            imagesc(all_spec')
        end
        
        xlabel('Disorder')
        ylabel('Mode index')
        title('Scaled spectrum')
        
        subplot(3,3,9)
        all_spec = zeros(numel(net_data),in_net_data{N}.L-1);
        for N = 1:numel(in_net_data)
            data = squeeze(nanmean(in_net_data{N}.A.eigs(:,:,1:end-1)));
            data = mean(data);
%             H = histogram((abs(data(:))),hist_win,'Normalization','pdf');
            all_spec(N,:)=data;
            imagesc(all_spec')
        end
        
        xlabel('Disorder')
        ylabel('Mode index')
        title('Scaled A spectrum')
     end
      
     

     
       


    if display_opts.savefig
        savefig(['L',num2str(net_data.L),'W',num2str(net_data.W),'_summary.fig'])
        saveas(gcf,['L',num2str(net_data.L),'W',num2str(net_data.W),'_summary.png'])
    end


end