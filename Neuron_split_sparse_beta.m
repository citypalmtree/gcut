function [] = Neuron_split_sparse_beta(path_1, path_2, soma_option, poly_option, poly_path, pre_prun_c, post_prun_c, recon_dist)

% This script will run the neuron segmentation algorithm.
% [] = Neuron_split_spare_beta(path_1, path_2, soma_option) 
% path_1: input data folder. must contain neuron cluster in swc format, and 
%         corresponding text file with soma information. The swc file and text
%         file should be named [cluster_name].swc and [cluster_name]_soma_ind.txt
%         respectively. Multiple neuron clusters can exist in the input data
%         folder, as long as their corresponding soma information files are
%         present .
% path_2: output folder. SWC file for segemented individual neurons are stored
%         in this folder as [cluster_name]_[number].swc, where number ranges 
%         between 1 and total number of neurons in the cluster.
% soma_option - input soma information file type:
% 0 - soma_index: The node number of somas in SWC file
%                 if node 5 and 23 are somas, the file should be written as:
%                 5
%                 23
% 1 - soma_location: The x,y,z locations of somas
%                    if node 5 has coordinates (1, 2, 3) and node 23 has 
%                    coordinates (4, 5, 6), the file should be written as:
%                    1 2 3
%                    4 5 6
% poly_option: Choose a set of GOF distribution polyfit parameters to compute the
%   fitness. The project provides serious of default GOF parameters in some brain 
%   region or speicies (please see 'GOF_list.xlsx' for the poly_option of default 
%   GOF parameters). Users can provide their own data for customized GOF parameters.
%   poly_option needs to be a string.
%
%   '0' - customized data for computing GOF distribution: This option allows
%       user to provide their own dataset for computing GOF distribution 
%       parameters of specific brain region or species, the path of 
%       customized data folder must be provided in the parameter 'poly_path'.
%
% pre_prun_c = [];
% post_prun_c = [];


if poly_option <0 
    
    error('polyfit option must be a positive integral!');
    
elseif str2double(poly_option) == 0
    
    [poly_para ] = cust_data_poly( poly_path);
    
else
    poly_para_set = importdata('GOF_mouse_default.mat');
    
    type_1 = poly_option
    
    p_col = str2num(type_1(regexp(type_1, '\d')))
    
    type_1(regexp(type_1, '\d')) = []
    
    switch type_1
        case 'b'
            p_row = 1;
        case 's'
            p_row = 2;
    end
    
    poly_para = poly_para_set{p_row, p_col};
    
end


if soma_option ~= 0 && soma_option ~=1
        disp('Please input a valid soma index!');
        return;
end
file_list = dir(fullfile(path_1,'*.swc'));
file_n = length(file_list);

for file_i = 1:1:file_n
    file_name = file_list(file_i).name;
    [path, or_name, ext] = fileparts(file_name);
    A_1 = swc_read(strcat(path_1,file_name));
    index_import = soma_option;
    [Parent_list, Child_list, branch_node, leaf_node ] = neuron_detect(A_1);
    [A_1] = soma_leaf_prun(A_1, Child_list, 2);
    %--pre_pruning here----------------------------------------
    if ~isempty(pre_prun_c)
     
     [neurite_ma] = split_neurite_delta(branch_node,leaf_node,Parent_list, Child_list);
     [A_1, neurite_ma] = leaf_pruning(A_1, neurite_ma, leaf_node, pre_prun_c, 1);
     A_1 = tree_resort(A_1);
    end
    %------------------------------------------------------------

    location_path_name = strcat(path_1 ,or_name,'_soma_ind.txt');
    
    [A, index_x] = find_soma_location(A_1, location_path_name, index_import);
    
    index_x = sort(index_x);
    
    tic;
    
    [m,n] = size(A);
    
    [Parent_list, Child_list, branch_node, leaf_node ] = neuron_detect(A);
    
    [neurite_ma] = split_neurite_delta(branch_node,leaf_node,Parent_list, Child_list);
%-----------------topo_recon is in develpment---------------
    if ~isempty(recon_dist)
        [neurite_ma] = topo_recon(neurite_ma, leaf_node,A, recon_dist);
    end
%--------------------------------------------------------------
    Set_index = zeros(m,1);
    Set_index(index_x) = 1;
    neurite_ma(neurite_ma == 0) = NaN;
    disp('split complete');
    toc;
    [in_neuron, rec_matrix] = connect_neurite_beta_3(A,neurite_ma, Set_index,m, poly_para);
    for i = 1:1:length(rec_matrix)
        neuron_1 = rec_matrix{i};
        if ~isempty(post_prun_c)
                [Parent_list_1, Child_list_1, branch_node_1, leaf_node_1 ] = neuron_detect(neuron_1);
                [neurite_ma_1] = split_neurite_delta(branch_node_1,leaf_node_1,Parent_list_1, Child_list_1);
                [neuron_1 ] = post_neurite_pruning(neuron_1, neurite_ma_1, branch_node_1, leaf_node_1, post_prun_c);
        end
        save_file_std_swc(strcat(path_2, or_name, '_split_',num2str(i),'.swc'),neuron_1);
    end
    disp(strcat(num2str(file_i),'_complete!'));
end
