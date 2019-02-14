function [] = Neuron_split_sparse_graph_beta(path_1, path_2, ext, soma_option, poly_option, poly_path)

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
% ext - postfix of the filename
%        '.swc' -  generated by APP2 or Neurostudio (tree structure)
%        '.mat' -  generated by Matlab (graph structure G where G.R, G.x, G.y, G.z, G.D
%                   represent the type, x, y, z location and the radius of the nodes, 
%                   and G.dA represents the connection graph of the nodes.
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
%   fitness. The project provides series of default GOF parameters in some brain 
%   region or speicies (please see 'GOF_list.xlsx' for the poly_option of default 
%   GOF parameters). Users can provide their own data for customized GOF parameters.
%   poly_option needs to be a string.
%
%   '0' - customized data for computing GOF distribution: This option allows
%       user to provide their own dataset for computing GOF distribution 
%       parameters of specific brain region or species, the path of 
%       customized data folder must be provided in the parameter 'poly_path'.
%
%Please note the post-process functions have been moved from the main fucntion of
%G-Cut. If you want use these functions to prune the redundant branches,
%please use the function 'soma_leaf_prune.m' and 'post_neurite_pruning.m'
%for small branches close to soma and branches with low fitness,
%respectively. 
%
if poly_option <0 
    
    error('polyfit option must be a positive integral!');
    
elseif str2double(poly_option) == 0
    
    [poly_para ] = cust_data_poly( poly_path);
    
else
    poly_para_set = importdata('GOF_default.mat'); % This function load the parameter of GOF distribution.
    
    type_1 = poly_option;
    
    p_col = str2num(type_1(regexp(type_1, '\d')));
    
    type_1(regexp(type_1, '\d')) = [];
    
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
file_list = dir(fullfile(strcat(path_1,'*',ext))); %find the neuron cluster files in the folder
file_n = length(file_list);

for file_i = 1:1:file_n
    file_name = file_list(file_i).name;
    [path, or_name, ext] = fileparts(file_name);
    tic;
    switch ext
        case '.swc'
            raw_ma = swc_read(strcat(path_1,file_name));
            elem_1 = raw_ma(:, 1);
            [node_n, node_ind_1, ~] = unique(elem_1,'sorted');
            location_ma = [node_n, raw_ma(node_ind_1, 2:6)];
            %--------------tree split------------------------------------
            [Parent_list, Child_list, branch_node, leaf_node ] = neuron_detect(raw_ma);
            [neurite_ma] = split_neurite_delta(branch_node,leaf_node,Parent_list, Child_list);
        case '.mat'
            raw_ma = importdata(strcat(path_1, file_name));
            elem_1 = length(raw_ma.x);
            location_ma = [[1:elem_1]', raw_ma.R, raw_ma.x, raw_ma.y, raw_ma.z, raw_ma.D.*0.5];
            raw_matrix = raw_ma.dA;
            %-------------graph split-----------------------------------
            [neurite_ma] = split_neurite_graph(raw_matrix);
            %-----------------------------------------------------------
    end

    A_1 = location_ma;
    index_import = soma_option;
    if index_import == 0
        index_x_1 = importdata(strcat(path_1 ,or_name,'_soma_ind.txt'));
        index_x_1 = index_x_1';
    else
         soma_location = importdata(strcat(path_1,or_name,'_soma_ind.txt'));
        [lo_m lo_n] = size(soma_location);
        soma_index = zeros(lo_m,1);
        ma_location = A_1(:,3:5);
        for lo_ind = 1:1:lo_m
            location_1 = soma_location(lo_ind,:);
            dist_ma = pdist2(ma_location,location_1);
            candi_soma = A_1(dist_ma < (min(dist_ma) + 10), 1);
            [~, soma_ind] = max(A_1(candi_soma, 6));
             soma_ind_1 = A_1(candi_soma(soma_ind), 1);
             soma_index(lo_ind) = soma_ind_1;
             disp(num2str(lo_ind));
        end
        index_x_1 = soma_index';
        A_1(index_x_1, 6) = 10;
        
    end
     index_x = index_x_1;
    index_x = sort(index_x);
    m = length(location_ma(:, 1));
    Set_index = zeros(m,1);
    Set_index(index_x) = 1;
    neurite_ma(neurite_ma == 0) = NaN;
    disp('split complete');
    toc;
    [in_neuron, rec_matrix] = connect_neurite_beta_3(A_1,neurite_ma, Set_index,poly_para);
    for i = 1:1:length(rec_matrix)
        neuron_1 = rec_matrix{i};
        save_file_std_swc(strcat(path_2, or_name, '_split_',num2str(i),'.swc'),neuron_1);
    end
    disp(strcat(num2str(file_i),'_complete!'));
end
