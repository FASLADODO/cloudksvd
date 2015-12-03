function [M] = getM(Y,D,X,k)
%Update the M (E_R*E_R') across all sites
%   Input: Y - Signals across 'N' sites           ( m x n x N )
%          D - Dictionary across 'N' sites        ( m x K x N )
%          X - sparse coding                      ( K x n x N )
%               hat and tilda should be same dimension
%          k - kth atom we are updating for each site's local dictionary
%   Output: M - Error matrix across 'N' sites     ( m x n x N )

 
[m,n,N] = size(Y);
    
%% Create M matrix (m x m x N ) & Cell Arrays

M = zeros(m,m,N);



%%
    for i=1:N    % for each site node...
        
        Ind_nz = find(X(k,:,i));     %find all non-zero indexs, X_t if needed
        nz = length(Ind_nz);
        
        if(nz~=0)
            Omega = zeros(n,nz);
            for col=1:nz                % for each column in Omega
                Omega(Ind_nz(col),col) = 1;
            end
            P = D(:,:,i)*X(:,:,i) - D(:,k,i)*X(k,:,i);
            E = Y(:,:,i) - P;
            E_R = E*Omega;
            
            M(:,:,i) = E_R*(E_R');
            
        end
        
        
    end

end
        