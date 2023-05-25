%% Optimización a través del método del gradiente
%Utilizamos métodos basados en el gradiente para realizar la optimización
clc
clear

%Numero de puntos de discretizacion
N = 50;
%Definimos el punto más alto de la pompa
altura =1.2;
%Volumen que queremos que tenga la pompa
vol = 0.8;
%Definimos en número máximo de iteraciones y evaluaciones
MaxEval = 100000000; MaxIter = 10000000;

%Definimos las condiciones iniciales, es decir, los puntos en los que el
y1 = 1; y2 = 1;
 
y0 =sin(linspace(pi,2*pi,N))+altura;    
yLow = linspace(0,0,N);  yLow(1) = 1; yLow(end) = y2;
yUp = linspace(y1,y2,N);
y0 = altura*y0; yUp = altura*yUp; yLow = altura*yLow;
%Ahora empieza la optimización

options = optimoptions('fmincon');
%Selección de algoritmo interior point
options = optimoptions(options,'Algorithm', 'interior-point');
%Se definen el resto de opciones necesarias para que funcione
options = optimoptions(options,'Display', 'final-detailed');
options = optimoptions(options,'MaxFunctionEvaluations', MaxEval);
options = optimoptions(options,'MaxIterations', MaxIter);
options = optimoptions(options,'PlotFcn', { @optimplotx });
%funciones a optimizar y sus valores iniciales
    tic
    [y,Areasol,exitflag,output,lambda,grad,hessian] = fmincon(@Area,y0,[],[],[],[],yLow,yUp,@(F)V(F,vol),options);
    tiempo = toc;

%Se muestran iteraciones y evaluaciones    
Niteraciones = output.iterations;
Nevaluaciones = output.funcCount;

figure
x = linspace(0,1,N);
yAltura = linspace(altura,altura,N);
%Grafica de funcion encontrada.
plot(x,y)
axis([0 1 0 altura+0.1])
title([ 'Geometría de la pompa. ','A = ' num2str(Areasol)]);
xlabel('Separación entre aros'); ylabel('Altura relativa')