% combine solution tables

mkdir('../out/sol-tab-combine');

for id = 1:120
    mkdir(['../out/sol-tab-combine/' sprintf('%03d',id)]);
    for c = 1:10 % unit procurement costs
        S1 = load(['../out/sol-tab/' sprintf('%03d',id) ...
                   '/sol-tab-abGm' sprintf('%03d',id) ...
                   '-c' sprintf('%d',c) ...
                   '-store1.mat'],'TabSol');
        S2 = load(['../out/sol-tab/' sprintf('%03d',id) ...
                   '/sol-tab-abGm' sprintf('%03d',id) ...
                   '-c' sprintf('%d',c) ...
                   '-store2.mat'],'TabSol');
        % 496 sales obs., 4 stockout states, 2 stores
        % TODO: make these input parameters
        TabSol = zeros(496,4,2); 
        TabSol(:,:,1) = S1.TabSol;
        TabSol(:,:,2) = S2.TabSol;
        clear S1 S2
        
        save(['../out/sol-tab-combine/' sprintf('%03d',id) ...
              '/sol-tab-abGm' sprintf('%03d',id) ...
              '-c' sprintf('%d',c) '.mat'],'TabSol')
    end
end