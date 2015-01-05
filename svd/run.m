function answer = run(graph_file, train_file, test_file, out_file) 
   N = 10;
   cluster = parcluster('local');
   cluster.NumWorkers=8;
   saveProfile(cluster);
   matlabpool open 8;


   fprintf(2, 'reading Graph\n');
   graph = readGraph(graph_file);
   fprintf(2, 'reading Training\n');
   train = readTrain(train_file);
   fprintf(2, 'reading Testing\n');
   test = readTest(test_file);

   fid = fopen(out_file, 'w');

   answer = zeros(size(test,2), 100);

   
   % fill matrix for svd
   matrix = -.5*ones(size(train, 2)+1, size(graph, 2));
   for j = 1:size(train, 2) 
     matrix(j, train{j}.node) = train{j}.degree-0.5; 
   end

   for j = 1:size(test, 2)
      matrix(end, :) = -.5; 
      matrix(end, test{j}) = 0.5;

      fprintf(2, 'start svd...\n');
      [U, S, V] = svd(matrix);
      S2 = S;
      S2(N+1:end, N+1:end) = 0;
      M = U*S2*V';

      M(end, test{j}) = -100;
      
      tmp = zeros(size(graph,2), 2);
      tmp(:, 1) = M(end, :)';
      tmp(:, 2) = 1:size(graph,2);

      tmp = sortrows(tmp, -1);

      answer(j, :) = tmp(1:100, 2)';

      fprintf(fid, '%d ', answer(j, :));
      fprintf(fid, '\n');

   end

   matlabpool close

end
