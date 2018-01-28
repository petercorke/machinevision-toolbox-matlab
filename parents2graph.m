function parents2graph(p)
    %{
    filename = tempname;
    
    fp = fopen([filename '.dot'], 'w');
    
    fprintf(fp, 'graph {\n');
    
    for i=1:length(p)
        fprintf(fp, '%d -- %d\n', p(i), i);
    end
    fprintf(fp, '}\n');
    
    system(sprintf('dot -T pdf -o %s.pdf %s.dot; open %s.pdf', filename, filename, filename))
    %}
    
    % create adjacency matrix
    n = length(p);
    adj = zeros(n+1,n+1);
    for i=1:length(p)
        adj(p(i)+1,i+1) = 1;
    end
    
    labels = cellfun(@num2str, num2cell(0:n), 'UniformOutput', false);
    
    g=graphViz4Matlab(adj, '-nodeLabels', labels, '-layout', Treelayout)
end