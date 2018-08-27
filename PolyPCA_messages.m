function PolyPCA_messages(mname,varargin)
switch mname
    case 'start'
        fprintf(['Running (' num2str(varargin{1}) ','  num2str(varargin{2}) ')-PolyPCA \n'])
    case 'initialization'
        fprintf(['Initialization: ' varargin{1} '\n'])
    case 'Embedding'
        fprintf(['Delay = ' num2str(varargin{1}) ' samples, ' ...
                'Embedding dimension = '  num2str(varargin{2}) '\n'])
    case 'Coeffs'
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
    case 'rotatedY'
        if varargin{1} == 1
            fprintf('Rotating measurements per iteration for better stability \n')
        end
    case 'rotatedX'
        if varargin{1} == 1
            fprintf('Rotating Latents per iteration for better stability \n')
        end
    case 'whiten'
        if varargin{1} == 1
            fprintf('Whitening latents per iteration \n')
        end

    otherwise
        error('Message not defined')
end        

end

