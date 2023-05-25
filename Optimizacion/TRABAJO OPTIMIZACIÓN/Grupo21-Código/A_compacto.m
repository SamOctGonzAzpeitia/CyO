%% Funcion area
%%Función que representa el funcional a optimizar (F), a partir de 
%%minimizar el valor de la función Area (A) utilizando diferencias finitas
%%compactas y la regla del punto medio

function A = A_compacto(F)
%A = integral ( F*sqrt(1+(dF)^2) );

%Numero de puntos que definen la funcion F
N = length(F);

%Equiespaciado entre 0 y 1 que nos sirve para conocer deltaX que nos será
%útil más adelante
x = linspace(0,1,N);
deltaX = x(2) - x(1);

%Calculamos y guardamos en un vector y(:), los valores medios entre dos
%puntos consecutivos de F en todo el intervalo que estudiamos
y = zeros(1,N-1);
for i = 1:N-1
    y(i) = ( F(i) + F(i+1) )/2;
end

%Realizamos la derivada de cada punto de y a través de una primera
%aproximación de una derivada en un punto a partir del siguiente. Se trata
%de diferencias finitas compactas.
dy = zeros(1,N-1);
for i = 1:N-1
    dy(i) = ( F(i+1) - F(i) )/deltaX;
end

%Definimos el funcional
int = y.*sqrt(1+(dy).^2);

%A = integral( int ) 
%Regla del punto medio
%integral(f) entre a y b = (b-a)* f( (b-a)/2 )
A = 0;
for i = 1:N-1
   A = A + deltaX * int(i) ;
end


end