
function [A_hat] = parallel_cvx(i, num_nodes, horizon, type_diffusion, progressTrackerHandle)

A_potential = csvread('w/a_potential.csv')
A_bad = csvread('w/a_bad.csv')
cascades = csvread('w/cascades')
num_cascades = csvread('w/num_cascades')
A = csvread('w/S_matrix.csv')

disp('Starting process %i', i)

% Number of nodes that each processor will compute
% Matlab rounds integers by default
% Use fix() to truncate 
nodes_processor = int8(fix(num_nodes/num_processors))
remaining_nodes = mod(num_nodes, num_processors) 

% Distribute the remaining nodes among the processors
if i <= remaining_nodes
	nodes_processor = nodes_processor + 1
	nodes = ((i-1)*nodes_processor + 1):nodes_processor*i
else
	nodes = (i-1) * nodes_processor + remaining_nodes + 1: (i-1) * nodes_processor + remaining_nodes + nodes_processor

fprintf('This process will calculate for %i nodes', nodes_processor)
fprintf('Nodes to be computed are %i', nodes)

for n = nodes
	if (num_cascades(i)==0)
		a_hat(:,n) = 0;
		filename = 'temporary/a_hat_' + string(n) + '.csv'
		csvwrite(filename, full(a_hat); 
		continue;
	end

	tic
	[a_hat, obj] = solve_using_cvx(n, type_diffusion, num_nodes, num_cascades, A_potential, A_bad, cascades);

	stop=toc;

	fprintf(progressTrackerHandle,'Done with node:%d, Took %.3f seconds\n',n, stop);
	disp('Done with node:%d, Took %.3f seconds\n',i, stop);
	total_obj = total_obj + obj;
	filename = 'temporary/a_hat_' + string(n) + '.csv'
	csvwrite(filename, full(a_hat); 
end
