function [branch_order_s ] =  com_or_soma(index, Parent_matrix, Children_matrix, soma_node)
branch_order_s  = 1;
while(~isequal(index,soma_node))

        child = find(Children_matrix(index,:)==1); %���Ϊ��֧��㣬���ҵ�����Ӧ�������ӽ��
        [cm, cn] = size(child);      
        if cn>1
            branch_order_s = branch_order_s+1;
        end  
        index = (find(Parent_matrix(index,:)==1));
end
   