
% Definir las matrices de peso para el controlador LQR
Q = diag([1 1 1 1 1]);
R = 1;

% Calcular los polos deseados para el controlador por pole placement
omega_n = 2;
zeta = 0.7;
s1 = -omega_n*zeta + omega_n*sqrt(1-zeta^2)*1i;
s2 = -omega_n*zeta - omega_n*sqrt(1-zeta^2)*1i;

% Diseñar el controlador por pole placement
K_pp = place(A, B, [s1 s2]);

% Diseñar el controlador por LQR
K_lqr = lqr(A, B, Q, R);

% Definir las condiciones iniciales y la perturbación
X0 = [10; 0; 0; 0; 1000];
X_pert = X0 + [-1; 0; 0; 0.05; 0];
T_sim = 2;

% Simular el sistema con el controlador por pole placement
sys_pp = ss(A-B*K_pp, B, C, D);
[y_pp, t_pp, x_pp] = initial(sys_pp, X_pert, T_sim);

% Simular el sistema con el controlador por LQR
sys_lqr = ss(A-B*K_lqr, B, C, D);
[y_lqr, t_lqr, x_lqr] = initial(sys_lqr, X_pert, T_sim);

% Graficar las respuestas
subplot(211)
plot(t_pp, y_pp(:,1), 'b', t_lqr, y_lqr(:,1), 'r--')
xlabel('Tiempo (s)')
ylabel('Velocidad (m/s)')
legend('Pole placement');


