function n_variants = renderState(stateSpace, stateHash, nodeIndex)
%RENDERALLNODES render all map configurations that belong to the same state
%in the problem state space by definition of the state hash function
% n_variants = renderState(stateSpace, stateHash, nodeIndex)
    
    f = figure;
    
    if any(strcmp(stateSpace.Nodes.Properties.VariableNames, 'Name'))
        pointer = stateHash(stateSpace.Nodes{nodeIndex, 'Name'}{:});
    else
        pointer = stateHash(stateSpace.Nodes{nodeIndex, 'Hash'}{:});
    end
    n_variants = 1;
    while true
        renderMap(f, pointer.Data);
        pause(0.1); clf(f);
        if isempty(pointer.Next)
            break;
        else
            pointer = pointer.Next;
            n_variants = n_variants + 1;
        end
    end
    close(f)
end

