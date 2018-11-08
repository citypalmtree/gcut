points = 100;
x = rand(points, 1) * 100;
y = rand(points, 1) * 100;
z = zeros(points, 1) * 100;

mst_tree = MST_tree(1, [50; x], [50; y], [0;z], ...
   0, 50, [], [], '-w');

sp_tree = MST_tree(1, [50; x], [50; y], [0;z], ...
   1, 50, [], [], '-w');

points = size(mst_tree.dA, 1);
mst_set = set()
arr = [];
% depth first tour of MST
for i=1:points
    arr = [arr; mst_tree.dA(i,1)];
end

S = 0;
for i=1:(points - 1)
end
