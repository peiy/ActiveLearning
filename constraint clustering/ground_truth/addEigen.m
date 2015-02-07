function output = addEigen (input)
E = [];
b = size (input);
E = eig (input);
a = min (E);
if (a <= exp(-5))
    output = input + (abs(a) + exp (-5)) * eye(b(1));
else
    output = input;
end;
end
    