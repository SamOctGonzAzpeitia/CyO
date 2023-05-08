%% Optimización a través del método del gradiente
%Utilizamos métodos basados en el gradiente para realizar la optimización
clc
clear

%Numero de puntos en los que se evalua la funcion
N = 100;
%Definimos el punto más alto de la pompa
altura = 1.2;
%Definimos en número máximo de iteraciones y evaluaciones
MaxEval = 1000000; MaxIter = 100000;

%Definimos las condiciones iniciales, es decir, los puntos en los que el
y1 = 1; y2 = 1;
%Elegimos la función de arranque F con la que va a trabajar el optimizador
%Para ello basta con quitarle el %
   % y0 = zeros(1,N);for i=1:N,y0(i) = rand;end %Puntos aleatorios
   % y0 =linspace(y1,y2,N);%Línea a altura 1
   % y0 = linspace(0,0,N);%Linea de ceros
    y0 =sin(linspace(pi,2*pi,N))+altura;%Seno
    
yLow = linspace(0,0,N);  yLow(1) = 1; yLow(end) = y2;
yUp = linspace(y1,y2,N);
y0 = altura*y0; yUp = altura*yUp; yLow = altura*yLow;
%Ahora empieza la optimización
options = optimoptions('fmincon');
%Elijo el algoritmo de optimizacion
%Pueden ser interior-point ; sqp ; active-set
options = optimoptions(options,'Algorithm', 'interior-point');
%Defino el resto de opciones necesarias para que funcione
options = optimoptions(options,'Display', 'final-detailed');
options = optimoptions(options,'MaxFunctionEvaluations', MaxEval);
options = optimoptions(options,'MaxIterations', MaxIter);
options = optimoptions(options,'PlotFcn', { @optimplotx });
%Defino las funciones a optimizar y sus valores iniciales
tic
    [y,Asol,exitflag,output,lambda,grad,hessian] = fmincon(@A_compacto,y0,[],[],[],[],yLow,yUp,[],options);
    tiempo = toc;
%Enseño el número de iteraciones    
Niteraciones = output.iterations;
Nevaluaciones = output.funcCount;

figure
x = linspace(0,1,N);
yAltura = linspace(altura,altura,N);
%Mostramos la función encontrada
plot(x,y)
axis([0 1 0 altura+0.1])
title([ 'Geometría de la pompa. ','A = ' num2str(Asol)]);
xlabel('Separación entre aros'); ylabel('Altura relativa')