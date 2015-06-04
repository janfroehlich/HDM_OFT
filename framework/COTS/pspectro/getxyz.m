function xyz = getxyz(input)

xyz = zeros(size(input));

for j=1:size(input,1)
    for i=1:size(input,2)
        xyz(j,i) = input(j,i)/sum(input(j,:));
        i = i + 1;
    end
    j = j + 1;
end