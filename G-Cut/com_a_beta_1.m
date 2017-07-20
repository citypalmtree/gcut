function [child_ma count_i sum_node sum_penaty ] = com_a_beta_1 (child_ma, count_i,Children_matrix, index_1, node_weight) %��������ý�������child��penaty�Լ�����(��������㱾��
%This function is used for computing the total penalty of all the child 
%node for a starting node
sum_penaty = 0;
sum_node = 0;
if isempty(find(Children_matrix(index_1,:)>0)) %����ý��ΪҶ��㣬���������������
    parent = find(Children_matrix(:,index_1)>0);
    sum_penaty = sum_penaty + (Children_matrix(parent,index_1)*node_weight(index_1,1));
    sum_node = sum_node + 0;
    child_ma(count_i) = index_1;
    count_i = count_i + 1;
else
    child = find(Children_matrix(index_1,:)>0); %���Ϊ��֧��㣬���ҵ�����Ӧ�������ӽ��
    parent = Children_matrix(:,index_1)>0;
%    sum_fitness = sum_fitness + angle_ma(index_1); %�÷�֧����ʸ����
    sum_node = sum_node + sum(Children_matrix(index_1,:));
    [cm, cn] = size(child);    
    child_ma(count_i) = index_1;
    count_i = count_i + 1;
    %if isempty(parent)
        %penaty = 0;
   % else
        penaty = (Children_matrix(parent,index_1)*node_weight(index_1,1)); %����֦�ĳͷ���Ϊ��Ӧ��(���ڵ㵽�ý�㣩*����֦��ƽ��ֱ��
    %end
    sum_penaty = sum_penaty + penaty;
    for i = 1:1:cn
        [child_ma count_i sum_node_1 sum_penaty_1] = com_a_beta_1(child_ma, count_i,Children_matrix,child(i), node_weight); %�����ؼ���÷�֧���������ӽڵ�ĽǶȺ������ܺ�
        sum_node = sum_node + sum_node_1;
        sum_penaty = sum_penaty + sum_penaty_1;
    end
end