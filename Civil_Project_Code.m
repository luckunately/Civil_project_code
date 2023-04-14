% the prabla is y = -1/654940125*x^2+22/11445*x+400 distance is approximately the same as horizontal distance
% set up all the constants first: All units in m, s, kg
B_x = 1144500; % the x coodinate of B
B_y = 600; % the y coordinate of B
A_x = 0;
A_y = 0;
Max_x = 686700; % the maximum occurs at x = 686700
Max_y = 1000; % the maximum height
% the prabla is y = -1/654940125x^2+22/11445x+400 distance is approximately the same as horizontal distance
Max_Head = 150;
Min_Head = -7;
flow = 1;
pump_elevation = 100;
pump_cost = 10; % 10 million each
diameter = [0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.4];
friction_factor = [0.0185, 0.0182, 0.0177, 0.0175, 0.017, 0.0167, 0.0165];
cost = [38, 44, 50, 80, 120, 150, 180]; % the corresponding cost, $/m since we are working with meters.
total_cost = zeros(1,7);
down_degree=0;
% Define the derivative and friction_loss functions
derivative = @(position) -2 * position / 654940125 + 22 / 11445;
friction_loss = @(index, velocity) friction_factor(index) * 1 / diameter(index) * (velocity) * velocity / 2 / 9.81;
for i = 1:7 %start with each diameter
 % calculate the velocity for each diameter
 velocity = flow / diameter(i) / diameter(i) / pi * 4;
 fprintf('For diameter %0.1f, the friction factor is %0.4f, the velocity is %0.3fm/s\n', diameter(i), friction_factor(i), velocity);
 current_head = 0;
 current_pump_distance = 0;
 max_pump_distance = 0;
 min_pump_distance = intmax;
 pumps = 0; % amount of pumps
 first_downhill_pump_position = 0; % the first position is different
 for x = 0:B_x
 if current_head <= 0 % when to add the pump
 current_head = current_head + 100;
 pumps = pumps + 1;
 end
 current_lost = derivative(x) + friction_loss(i-down_degree, velocity);
 if current_lost < 0 && current_head >30 % If the loss is negative and we have some head build up
 down_degree = down_degree + 1; % We change to a smaller size
 fprintf('We change the pipe to diameter %0.1f m at %d m\n', diameter(i - down_degree), x);
 velocity = flow ./ (diameter(i-down_degree).^2 .* pi) .* 4; % calculate the velocity for each diameter
 current_lost = derivative(x) + friction_loss(i-down_degree, velocity);
 end
 current_head = current_head - current_lost;
 total_cost(i) = total_cost(i) + cost(i-down_degree);
 end
 fprintf('Head at B is %0.1fm. We used %d pumps.\n', current_head, pumps);
 total_cost(i) = pump_cost * (pumps) + total_cost(i) / 10^6; % calculate the cost for each case.
 fprintf('The cost of this design is $%0.2f million\n\n', total_cost(i));
 down_degree = 0;
end
prabola = zeros(1144501,1);
HGL = zeros(1144501,1);
EGL = zeros(1144501,1);
i =7; % our final choice, using the largest pipe to start
current_head=0;
down_degree=0;
velocity = flow ./ (diameter(i-down_degree).^2 .* pi) .* 4; % calculate the velocity for each diameter
pump_location = zeros(8); % Collect the location of the 8 pumps
location_pointer = 1;
final_cost = 0;
pumps = 0;
fprintf('Here is the final answer. We start with diameter %0.1f m uphill\n',diameter(i));
for x = 0:B_x
 if current_head <= 0 % When to add the pump
 current_head = current_head + 100;
 pumps = pumps + 1;
 pump_location(location_pointer)=x; % Collect the location of current pump
 location_pointer=location_pointer+1; % move the pointer to the next
 end
 current_lost = derivative(x) + friction_loss(i-down_degree, velocity); 
 if current_lost < 0 && current_head >30 % Same as before
 down_degree = down_degree + 1;
 fprintf('We change the pipe to diameter %0.1f m at %d m\n', diameter(i - down_degree), x);
 velocity = flow ./ (diameter(i-down_degree).^2 .* pi) .* 4; % calculate the velocity for each diameter
 current_lost = derivative(x) + friction_loss(i-down_degree, velocity);
 end
 if x == B_x - 8600 % We decided to change the diameter smaller in the end to bring the head to 0 at the end
 down_degree = 4; % to choose the 0.9m pipe
 fprintf('We change the pipe to diameter %0.1f m at %d m\n', diameter(i - down_degree), x);
 velocity = flow ./ (diameter(i-down_degree).^2 .* pi) .* 4; % calculate the velocity for each diameter
 current_lost = derivative(x) + friction_loss(i-down_degree, velocity);
 end
 current_head = current_head - current_lost;
 % Collect the points of each entry in prabola, HGL and EGL
 prabola(x+1) = -1/654940125*x*x+22/11445*x+400;
 HGL(x+1) = prabola(x+1) + current_head;
 EGL(x+1) = HGL(x+1) + velocity*velocity/2/9.81;
 final_cost = final_cost + cost(i-down_degree);
end
final_cost = final_cost / 10^6;
fprintf('The following is the location of pumps in ascending order respect to point A\n');
for p = 1:8
 fprintf('%dm ',pump_location(p));
end
fprintf('\nThe final cost of the project is $%0.2f Minion',final_cost+pumps*pump_cost);
% Plot HGL, EGL, and prabola on the same graph
figure;
xlim([-10,1200000]);
ylim([-10,1100]);
plot(HGL);
hold on;
plot(EGL);
plot(prabola);
hold off;
% Add labels and legend
title('HGL, EGL, and prabola vs. distance');
xlabel('distance, m');
ylabel('Head, m');
legend('HGL', 'EGL', 'prabola');