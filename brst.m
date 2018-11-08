start_trees

points = 100;
x = rand(points, 1) * 100;
y = rand(points, 1) * 100;
z = zeros(points, 1) * 100;

mst_tree = MST_tree(1, [50; x], [50; y], [0;z], ...
   0, 50, [], [], '-w');

sp_tree = MST_tree(1, [50; x], [50; y], [0;z], ...
   1, 50, [], [], '-w');

[i, j, s] = find(mst_tree.dA);

points = size(sp_tree, 1);
arr = [];
% depth first tour of MST
for i=1:points
    arr = [arr; cnct(i,1)];
end


S = 0;
for i=1:(points - 1)
end
