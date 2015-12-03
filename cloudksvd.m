function [D,X] = cloudksvd(Y,D,To,Td,W)
%Cloud KSVD
%   Input: Y - Signals across 'N' sites           ( m x n x N )
%          D - Dictionary across 'N' sites        ( m x K x N )
%          To - sparsity for each column of X
%          Td - # of cloudksvd iterations 
%          W - weight matrix
%          
%   Output: D - improved dictionary
%           X - sparse coding ( K x n x N )
% K is the # of dictionary atoms

%% Error Checking

    if( size(Y,1) ~= size(D,1) )
        error('Signal and Dictionary are incompatible');
    end

%% Parameters
    
    [m,n,N] = size(Y);
    K = size(D,2);              % number of dictionary atoms 
    
%% d Reference Vector

    d_ref = normc(rand(m, 1));
    
   W = mpower(W,100);

%%  Cloud K-SVD
    for cksvdi = 1:Td
        %% Sparse Coding

        X = zeros(K,n,N);

        for i=1:N
            X(:,:,i) = full(OMP(D(:,:,i),Y(:,:,i),To));
        end
    
        %% Dictionary Update 
        % for each column k = {1,2,.....K} 

            for k=1:K
                %W_k = W;
        

                M = getM(Y,D,X,k);           % get the matrices 
                Z = normc(ones(m,N))';              % init n local eigenvectors where Z(i,;) corresponds to M(:,:,i)
                                                    % init distributed power method    
                tp = 20;
                for poweriter=1:tp    % stopping condition threshold 
                    %tc = 20;                             % consensus averaging
                    %W_k = mpower(W_k,tc);
                    Z = W*Z;                          % rows are eigenvectors, columns are corresponding eigenvalue or ev
                    Z = powMethod(Z,M,1);

        
                    %for i=1:N
                    %   Z(i,:) = Z(i,:)/W_k(i,i);
                    %end
                    
                    Z = normc(Z')';
                    Q = Z';                       % normalize V

                end
       
           
                for i=1:N
                    Ind = find(X(k,:,i));               % non-zero entries
                    Ek = (Y(:,:,i)-D(:,:,i)*X(:,:,i))+D(:,k,i)*X(k,:,i); 
                    Ekr = Ek(:,Ind);
                    
                    if(~isempty(Ind))
                        D(:,k,i) = sign(dot(d_ref',Q(:,i)))*Q(:,i);
                        X(k,:,i) = 0;                   % updating the rows of X
                        X(k,Ind,i) = D(:,k,i)'*Ekr;
                        
                    end
                end
                
                


            end

    end
end

