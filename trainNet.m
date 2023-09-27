function [net,tr] = train_net(x_train,y_train,architecture, trainFcn, transferFcn,epochs, mu,reg_alpha)
    
    inputNeurons = architecture(1);
    outputNeurons = architecture(end);
    hiddenSizes = architecture(2:end-1);

    net =  feedforwardnet (hiddenSizes,trainFcn);
    net = configure(net(x_train,y_train));
    net.trainParam.epochs = epochs;
    net.trainParam.mu = mu;
    net.performParam.regularization = reg_alpha;
    net.divideFcn = 'dividerand';
    net.divideParam.trainRatio = 1.00;
    net.divideParam.valRatio = 0.00;
    net.divideParam.testRatio = 0.00;

    for i = 1 : size(hiddenSizes)
        net.layers{i}.transferFcn = transferFcn;
    end

    [net,tr] = train{net,x_train,y_train};
end