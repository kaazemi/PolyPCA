PolyPCA_messages('start',opts.params.d,opts.params.maxDeg,opts.Minimax)
PolyPCA_messages('Preprocess',opts.Flags.Preprocess,opts.var2Keep)
PolyPCA_messages('PostProcessing',opts.Flags.postProcess)
PolyPCA_messages('ProjectUp',opts.ProjectUp,k*opts.params.n)
if opts.Lifting
    PolyPCA_messages('Lifting',opts.Lifting,opts.TargetLatentDim,opts.params.d,opts.LiftingMethod)
end
PolyPCA_messages('autoregression',opts.theta) 
PolyPCA_messages('CoeffsUpdateMethod',opts.CoeffsUpdate)
PolyPCA_messages('StepSize',opts.GradientStep)
PolyPCA_messages('penalty',opts.penalty,opts.lambda)
PolyPCA_messages('saddle',opts.params.saddleSigma)

