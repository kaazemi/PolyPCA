function PolyPCA_messages(mname,varargin)
switch lower(mname)
    case 'start'
        if varargin{3}
            fprintf(['Running the Minimax formulation of (' num2str(varargin{1}) ','  num2str(varargin{2}) ')-PolyPCA \n'])
        else
            fprintf(['Running (' num2str(varargin{1}) ','  num2str(varargin{2}) ')-PolyPCA \n'])
        end
    case 'preprocess'
        if varargin{1}
            fprintf(['Preprocessing the data using PCA: Keeping ' num2str(varargin{2}) ' %% of variance \n'])
        end
    case 'postprocessing'
        if varargin{1}
            fprintf('Post Processing the estimated latents \n')
        end
        case 'projectup'
        if varargin{1}
            fprintf(['Projecting the measurements up to ' num2str(varargin{2}) ' dimensions \n'])
        end
    case 'initialization'
        fprintf(['Initialization: ' varargin{1} '\n'])
    case 'lifting'
        if varargin{1}
            switch varargin{4}
                case {'Projection','projection','project'}
                    fprintf(['Lifting the problem via "projection" from ' num2str(varargin{2}) ' to ' num2str(varargin{3}) ' dimensions.\n'])
                case {'penalty','Penalty'}
                    fprintf(['Lifting the problem via "penalization from" ' num2str(varargin{2}) ' to ' num2str(varargin{3}) ' dimensions.\n'])
            end
        end
    case 'embedding'
        fprintf(['Delay = ' num2str(varargin{1}) ' samples, ' ...
                'Embedding dimension = '  num2str(varargin{2}) '\n'])
    case 'coeffs'
        fprintf(['Polynomial coefficients initilized with ' varargin{1} '\n'])
    case 'saddle'
        fprintf(['Saddle point gradient noise standard devaition = ' num2str(varargin{1}) '\n'])
    case 'autoregression'
        theta = varargin{1};
        if theta == 1
            fprintf('Latent model: i.i.d \n')
        else
            tau = -1/log(-theta(2));
            fprintf(['Latent model: AR(1), time constant ~ ' num2str(ceil(tau)) ' samples \n'])
        end

    case 'penalty'
        if varargin{2} ==0
        fprintf('No penalty on latents \n')
        else
        fprintf(['Penalizing ' varargin{1} ' norm of innovations: lambda = ' num2str(varargin{2}) '\n'])
        end
    case 'normalized'
        fprintf('Latents are normalized to have peak 1 per iteration \n')
    case 'rotatedy'
        if varargin{1} == 1
            fprintf('Rotating measurements per iteration for better stability \n')
        end
    case 'rotatedx'
        if varargin{1} == 1
            fprintf('Rotating Latents per iteration for better stability \n')
        end
    case 'whiten'
        if varargin{1} == 1
            fprintf('Whitening latents per iteration \n')
        end
    case 'coeffsupdatemethod'
        switch varargin{1}
            case 'LS'
                fprintf('Performing "Least Squares" updates on the polynomial coefficients \n')
            case 'GD'
                fprintf('Performing "Gradient Descent" updates on the polynomial coefficients \n')
            otherwise
                error
        end
    case 'stepsize'
        switch lower(varargin{1})
            case 'adam'
                fprintf('Step size chosen using ADAM optimizer \n')
            case 'fixed'
                fprintf('Step size chosen using adaptive backtracking \n')
            otherwise
                error
        end
    case 'sgd'
        if varargin{1}
             fprintf(['Performing Stochastic Gradient Descent: batch size = ' num2str(varargin{2})  ' \n'])
        end
    otherwise
        error('Message not defined')
end        

end

