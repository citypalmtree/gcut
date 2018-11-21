clear all;
clc;

if ismac || isunix
    path_1 = './demo_data/'; %the path of Sample data
    path_2 = './demo_result/'; %the path to store the result
elseif ispc
    path_1 = '.\demo_data\'; %the path of Sample data
    path_2 = '.\demo_result\'; %the path to store the result
else
    disp('Platform not supported')
end

soma_index = 0; 
%soma location format. 
%0 - sequence number of soma in SWC file.
%1 - x, y, z location of soma
ext = '.mat';
%postfix of the neuron cluster file name
%'.swc'- standard swc file generated by APP2 or Neurostudio
%'.mat'- Neuron cluster file (graph structure like tree in TREES toolbox) generated by Matlab
Neuron_split_sparse_graph_beta(path_1, path_2, ext,  soma_index, 's10', [], [], [], []); 