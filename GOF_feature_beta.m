function [ neurite_an_vector ] = GOF_feature_beta( filename )

%path: Load file path
%x_convert:the x scale to convert pixel to micrometer
%y_convert:the y scale to convert pixel to micrometer
%z_convert:the z scale to convert pixel to micrometer

    S_data = swc_read(filename);
    
    A = S_data;
    
    [m,n] = size(A);
    
    B = A(:,3:5);
    
    vector_matrix = zeros(m,9); %ʸ�����󣬼�¼�����ÿ���������1�����ռ����꣨2:4�����õ��븸�ڵ�ķ���ʸ����5:7�����õ�ĸ��ڵ㣨8�����Լ��õ�ʸ�����׼ʸ���ļнǣ�9����
    
    vector_matrix(:,1) = A(:,1);
    
    vector_matrix(:,2:4) = B;
    
    vector_matrix(:,8) = A(:,7);
    
    standard_vector = zeros(m,3); %��׼ʸ������¼��soma���õ��ʸ��

    for i =m:-1:1
        
        if (A(i,7) == -1)
            
            continue;
            
        else
            index_1 = A(i,7);
            
            vector_matrix(i,5) = (B(i,1)-B(index_1,1));%�õ��ʸ��Ϊ���ڵ㵽�õ�ķ���ʸ�������õ�λ���븸�ڵ�Ĳ�ֵ
            
            vector_matrix(i,6) = (B(i,2)-B(index_1,2));
            
            vector_matrix(i,7) = (B(i,3)-B(index_1,3));
            
            standard_vector(i,1) = (B(index_1,1)-B(1,1)); %�õ�ı�׼ʸ���ɸõ�ĸ��ڵ���soma��λ��������
           
            standard_vector(i,2) = (B(index_1,2)-B(1,2));
            
            standard_vector(i,3) = (B(index_1,3)-B(1,3));
            
            vector_matrix(i,9) = acos(((vector_matrix(i,5)*standard_vector(i,1) + vector_matrix(i,6)*standard_vector(i,2) + vector_matrix(i,7)*standard_vector(i,3))/...
                (sqrt(vector_matrix(i,5)^2 + vector_matrix(i,6)^2 + vector_matrix(i,7)^2)*sqrt(standard_vector(i,1)^2 + standard_vector(i,2)^2 + standard_vector(i,3)^2))));
            
            vector_matrix(isnan(vector_matrix))=0;
        
        end
        
    end
    %-----------------------------------------------------------------
    Parent_list = ones(m,2);
    
    Parent_list(:,1) = A(:,1);
    
    Parent_list(:,2) = A(:,7);
    
    Child_list = ones(m,2);
    
    Child_list(:,1) = A(:,7);
    
    Child_list(:,2) = A(:,1);
    
    Child_list((Child_list(:,1) == -1),:) = [];
    
    elem_A = A(:,1);
    
    [count_elem, node_ind] = hist(Child_list(:,1),elem_A);
    
    leaf_node = node_ind(count_elem == 0);
    
    branch_node = node_ind(count_elem > 1);

    
    %------------------------------------------------------------------

    if ~isempty(branch_node)
        
        [raw_i raw_j] = size(A);
        
        location_ma = zeros(raw_i,4);
        
        location_ma(:,1) = A(:,1);
        
        location_ma(:,2:4) = A(:,3:5);
        
        diam_ma = A(:,6);
        
        [neurite_ma] = split_neurite_delta(branch_node,leaf_node,Parent_list, Child_list);
        
        [era_i era_j] = size(neurite_ma);
        
        for pre_i =1:1:era_i
            
            era = find(neurite_ma(pre_i,:)==0);
            
            neurite_ma(pre_i,era) = NaN;
        
        end
        
        [neurite_parem ]  = neu_length(neurite_ma, location_ma,diam_ma);
        
        [neurite_an_vector,neurite_child]= feature_detect_beta(vector_matrix,location_ma,Child_list,Parent_list,branch_node,leaf_node,neurite_ma, 1); %���м�֦
        
        for pre_i =1:1:era_i
           
            era = isnan(neurite_child(pre_i,:));
           
            neurite_child(pre_i,era) = 0;
        
        end
        
        neurite_an_vector = [neurite_an_vector, neurite_parem];
        
    else
        
        neurite_an_vector = [];
        
        neurite_child = [];
    end


end

