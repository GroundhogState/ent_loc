% function rho_out = TrX2(rho, systems)

% Computes inner product between rho and the basis vectors spanning the
% product space of specified systems. Returns a 2^l*2^l reduced density
% matrix from a 2^L*2^L, where L is total system size and l is reduced
% system size. Works only for collections of two level systems, but should
% generalize OK, assuming one can efficiently generate a basis for the
% local spaces...
    psi = [1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1];
    rho = toDM(psi);
    
    
    
    P = cell(4);
    P{1} = eye(2);
    P{2} = Pauli('X',0);
    P{3} = Pauli('Y',0);
    P{4} = Pauli('Z',0);
    
    rho1 = 0.5*(P{1});
    rho2 = 0.5*(P{1}+(P{3}+P{4})/sqrt(2));
    rho = Tensor(rho1,rho2);
    
    systems = [2];
    
    L = log2(length(rho));
    l = length(systems);

    
    eye_list = cell(L,1);
    basis_list = zeros(l,l,2^l,2^l);
    coef_list = zeros(2^l,2^l);
    for ii=1:L
        eye_list{ii} = eye(2);
    end
    
    %Generate all pairs of Pauli operators acting on the subsystem
    % Assuming l=2 for now... Perhaps need to recurse in general?
    rho_out = zeros(2^l,2^l);
    for ii=1:4
%         for jj=1:4
            op_list = eye_list;
            op_list{systems(1)} = P{ii};
%             op_list{systems(2)} = P{jj};
            basis_vec = Tensor(op_list);
            exp_val =  trace(rho*basis_vec); %Coefficient of basis_ii,jj
%             coef_list(ii,jj) = exp_val
%             basis_vec
            rho_out = rho_out + exp_val*Tensor(P{ii});
%         end
    end
    rho_out
    trace(rho_out)
    

    V = Tensor(X,Y,Z);

% end