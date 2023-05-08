%% Optimización a través del algoritmo genético
%Usamos un algoritmo genético como el ejemplo de optimización mediante el
%uso de un método heurístico
clc
clear

%Numero de puntos en los que se evalua la funcion
N = 200; %Estan 10 por algo, he probado y tarda la vida
%Definimos el punto más alto de la pompa
altura = 1.2;
y1 = altura; 
y2 = altura;
%Elegimos la función de arranque F con la que va a trabajar el optimizador
%Para ello basta con quitarle el %
   % y0 = zeros(1,N);for i=1:N,y0(i) = rand;end %Puntos aleatorios
    y0 =linspace(y1,y2,N);%Línea a altura 1
   % y0 = linspace(0,0,N);%Linea de ceros
   % y0 =sin(linspace(pi,2*pi,N))+altura;%Seno
   
y1 = altura; 
y2 = altura;
yLow = zeros(1,N);
yUp = linspace(y1,y2,N);
y0 = altura*y0; yLow = min(y0)*yLow;
%Definimos las poblaciones iniciales o el intervalo donde puede estar la
%poblacion inicial (en funcion de las condiciones iniciales elegidas)
InitialPopulationRange_Data=[min(y0);max(y0)];
InitialPopulationMatrix_Data=y0;
%Tambien definimos las constrains, en este caso obligaremos a que los puntos 
%de los bordes tengan un valor determinado, que será la altura
%%Para ello realizamos un vector y una matriz que haran las veces de
%%sistema lineal: [Cons_M]*{x}={Cons_V}
Cons_M=[ 1 zeros(1,N-1); zeros(1,N-1) 1];
Cons_V=[altura ; altura];

%Introducimos las opciones que queramos dentro de la realización del
%algoritmo genético que utilizamos con el optimtool de matlab
options = optimoptions('ga');

%Poblacion inicial
options = optimoptions(options,'InitialPopulationMatrix', InitialPopulationMatrix_Data);%Qué puntos cogen al principio
%Numero maximo de iteraciones (poblaciones)
options = optimoptions(options,'MaxGenerations', N*1e3);
%Tolerancia de la funcion
options = optimoptions(options,'FunctionTolerance', 1e-8);
%Representacion en pantalla de la mejor solucion para cada generacion
options = optimoptions(options,'PlotFcn', { @gaplotbestindiv });
%Imprime en pantalla valores relevantes de la funcion en cada generacion
options = optimoptions(options,'Display', 'iter');

nvars=N;

tic
    [x,fval,exitflag,output,population,score] = ga(@A_compacto,nvars,[],[], Cons_M, Cons_V,yLow,yUp,[],[],options);
    tiempo = toc;

%Se imprime el resultado en pantalla
y=0:1/(N-1):1;
fprintf('valor del Area con algoritmo genetico=%d, criterio de salida %d\n',fval,exitflag)
fprintf('Tiempo del proceso %d', tiempo)
figure(2)
plot(y,x,'o');hold on
str=sprintf('Resultados siguiendo un algoritmo genético A=%d', fval);
title(str)
xlabel('Posición en x'); ylabel('Curva de la pompa')
axis([0 1 0 altura])