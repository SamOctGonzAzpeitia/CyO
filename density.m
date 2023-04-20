function rho = density(H)

Tb=288.15;
Lb=-0.0065;
ME=0.0289644;
R=8.3144598;
rhob=1.2250;
g=9.8;

TempRatio=Tb./(Tb+Lb.*H);  
exponent=1.+g.*ME./(R.*Lb);
rho=rhob.*TempRatio.^exponent;

end