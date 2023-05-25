clc
clear

N = 100;
altura=1.2;
vol=0.8;
Eval=1000000; 
Iter = 1000000;

y1=1;
y2=1;

y0=sin(linspace(pi,2*pi,N))+altura;
yLow=linspace(0,0,N); yLow(1) = 1; yLow(end) = y2;
yUp=linspace(y1,y2,N);
y0 = altura*y0; 
yUp = altura*yUp; 
yLow = altura*yLow;

options = optimoptions('fmincon');
options = optimoptions(options,'Algorithm', 'interior-point');

options = optimoptions(options,'Display', 'final-detailed');
options = optimoptions(options,'MaxFunctionEvaluations', Eval);
options = optimoptions(options,'MaxIterations', Iter);
options = optimoptions(options,'PlotFcn', { @optimplotx });

tic
    [y,Areasol,exitflag,output,lambda,grad,hessian] = fmincon(@Area,y0,[],[],[],[],yLow,yUp,@(F)V(F,vol),options);
    tiempo = toc;
%Enseño el número de iteraciones    
Niteraciones = output.iterations;
Nevaluaciones = output.funcCount;